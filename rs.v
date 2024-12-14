`include "constants.v"
`include "rs_constants.v"

module rs#(
  PREG_WIDTH = 6,
  DEPTH = 64
)
(
  //Row inputs
  input wire [31:0] instr,
  input wire [11:0] pc,
  input wire [2:0] alu_op,
  input wire [31:0] imm,
  input wire [PREG_WIDTH-1:0] rd,
  input wire [PREG_WIDTH-1:0] src1,
  input wire [31:0] data1,
  input wire ready1,
  input wire [PREG_WIDTH-1:0] src2,
  input wire [31:0] data2,
  input wire ready2,
  input wire [6:0] c_sigs,
  
  
  //Logic inputs
  input wire [2:0] fu_table_in,
  input wire clk,
  input wire [5:0] rob_num,
  input wire [`BUS_WIDTH-1:0] bus0,
  input wire [`BUS_WIDTH-1:0] bus1,
  

  //Outputs
  output reg [`RS_WIDTH-1:0] instr_out0,
  output reg [`RS_WIDTH-1:0] instr_out1,
  output reg [`RS_WIDTH-1:0] instr_out2,
  output reg [2:0] fu_table_out,
  output reg [2:0] instr_valid
);

  reg [`RS_WIDTH-1:0] queue[DEPTH-1:0];
  reg [5:0] rs_pointer; //circular reservation station
  reg next_alu; //switches between first two alu

  wire [6:0] opcode;
  wire [2:0] funct3;
  reg [1:0] fu_pos;
  
  assign opcode = instr[6:0];
  assign funct3 = instr[14:12];

initial begin
  	instr_valid = 3'b000; // no instructions ready to issue
    rs_pointer = 0;
    next_alu = 2'b00;
  	fu_table_out = 3'b111;
end

  //Writeback from alu
  always @(negedge clk)
  begin
    
    //Debug
    /*
    if(bus0[`BUS_VALID]) begin
      $display("inside rs... rd: %d, res, %0d %b", bus0[`BUS_RD], bus0[`BUS_RESULT], bus0);
    end
    if(bus1[`BUS_VALID]) begin
      $display("inside rs..., rd: %d, res, %0d %b", bus1[`BUS_RD], bus1[`BUS_RESULT], bus1);
    end
    */
    
    for (integer i = 0; i < 64; i = i+1) begin
      if (queue[i][`RS_SRC1] == bus0[`BUS_RD] && bus0[`BUS_VALID] == 1)
        begin
          queue[i][`RS_DATA1] <= bus0[`BUS_RESULT];
          queue[i][`RS_RDY1] <= 1;
        end
      if (queue[i][`RS_SRC2] == bus0[`BUS_RD] && bus0[`BUS_VALID] == 1)
        begin
          queue[i][`RS_DATA2] <= bus0[`BUS_RESULT];
          queue[i][`RS_RDY2] <= 1;
       	end
      if (queue[i][`RS_SRC1] == bus1[`BUS_RD] && bus1[`BUS_VALID] == 1)
        begin
          //$display("WRITE RESULT %b", alu0_in);
          queue[i][`RS_DATA1] <= bus1[`BUS_RESULT];
          queue[i][`RS_RDY1] <= 1;
        end
      if (queue[i][`RS_SRC2] == bus1[`BUS_RD] && bus1[`BUS_VALID] == 1)
        begin
          queue[i][`RS_DATA2] <= bus1[`BUS_RESULT];
          queue[i][`RS_RDY2] <= 1;
       	end
    end
  end
  
 reg [2:0] temp_fu_issued; 
  
always @(posedge clk) //issue
begin
  fu_table_out <= fu_table_in;
  instr_valid <= 3'b000;
  temp_fu_issued = 3'b000; //BLOCKING
 	
  //Issue logic
  for (integer i = 0; i < 64; i = i+1) begin
    if(queue[i][`RS_USE]) begin
      $display("RS| USE %b, PC: %h, OP %b, RD %d, RS1 %d, DATA1 %d, RDY1 %b, RS2 %d, DATA2 %d, RDY2 %b, IMM, %d, FU %d, ROB %d", queue[i][`RS_USE], queue[i][`RS_PC], queue[i][`RS_OP], queue[i][`RS_RD], queue[i][`RS_SRC1], queue[i][`RS_DATA1], queue[i][`RS_RDY1], queue[i][`RS_SRC2], queue[i][`RS_DATA2], queue[i][`RS_RDY2], queue[i][`RS_IMM], queue[i][`RS_FU], queue[i][`RS_ROB]);
    end
    
    if (
        queue[i][`RS_USE] == 1 //
        && queue[i][`RS_RDY1] == 1 //rs1 ready
        && queue[i][`RS_RDY2] == 1 //rs2 ready
        && fu_table_in[queue[i][`RS_FU]] == 1 //fu ready
      	&& temp_fu_issued[queue[i][`RS_FU]] != 1
    ) // check fu ready and src reg ready
     	begin
          //Update FU to used
          fu_table_out[queue[i][`RS_FU]] <= 0;
          temp_fu_issued[queue[i][`RS_FU]] = 1; //BLOCKING
          if (queue[i][`RS_FU] == 2'b00) begin
            instr_out0 <= queue[i];
            instr_valid[0] <= 1;
          end
          else if (queue[i][`RS_FU] == 2'b01) begin
            instr_out1 <= queue[i];
            instr_valid[1] <= 1;
          end
          else if (queue[i][`RS_FU] == 2'b10) begin
            instr_out2 <= queue[i];
            instr_valid[2] <= 1;
          end
          queue[i][`RS_USE] <= 0;
        end
    end 
end

  always @(posedge clk) //dispatch
begin
    case (opcode)
        7'b0000011 : fu_pos = 2'b10; //lb, lw
        7'b0100011 : fu_pos = 2'b10; //sb, sw
        default : begin
            fu_pos <= next_alu;
            next_alu <= !next_alu;
        end
    endcase
  
  	//If opcode is not zero, reserve an entry
    if(opcode!=0) begin
      queue[rs_pointer] <= {1'b1, pc, alu_op, funct3, c_sigs, opcode, rd, src1, data1, ready1, src2, data2, ready2, imm, fu_pos, rob_num};
      
      //$display("Reserving entry | alu_op: %b f3: %b, c_sigs: %b, opcode: %b, rd: %0d, src1: %0d, data1: %h, ready1: %b, src2: %0d, data2: %h, ready2: %b, imm: %0d, fu_pos: %b, rob_num, %h", alu_op, funct3, c_sigs, opcode, rd, src1, data1, ready1, src2, data2, ready2, imm, fu_pos, rob_num);
      

        rs_pointer <= rs_pointer + 1;
    end
end
  
endmodule