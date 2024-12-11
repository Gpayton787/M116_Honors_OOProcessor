`include "rs_constants.v"
`include "alu_constants.v"

module rs#(
  PREG_WIDTH = 6,
  DEPTH = 64
)
(
  //Row inputs
  input wire [31:0] instr,
  input wire [31:0] imm,
  input wire [PREG_WIDTH-1:0] rd,
  input wire [PREG_WIDTH-1:0] src1,
  input wire [31:0] data1,
  input wire ready1,
  input wire [PREG_WIDTH-1:0] src2,
  input wire [31:0] data2,
  input wire ready2,
  input wire [6:0] c_sigs,
  
  //ALU inputs
  input wire [`ALU_WIDTH-1:0] alu0_in,
  input wire [`ALU_WIDTH-1:0] alu1_in,
  
  //Logic inputs
  input wire [2:0] fu_table_in,
  input wire clk,
  input wire [5:0] rob_num,

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
  
always @(negedge clk) //writeback from alu
  begin
    for (integer i = 0; i < 64; i = i+1) begin
      if (queue[i][`RS_SRC1] == alu0_in[`ALU_REG])
        begin
          queue[i][`RS_DATA1] <= alu0_in[`ALU_RESULT];
          queue[i][`RS_RDY1] <= 1;
        end
      if (queue[i][`RS_SRC2] == alu0_in[`ALU_REG])
        begin
          queue[i][`RS_DATA2] <= alu1_in[`ALU_RESULT];
          queue[i][`RS_RDY2] <= 1;
       	end
    end
  end

always @(posedge clk) //issue
begin
  fu_table_out <= fu_table_in;
  instr_valid <= 3'b000;
 	
  //Issue logic
  for (integer i = 0; i < 64; i = i+1) begin
    if (
        queue[i][`RS_USE] == 1 //
        && queue[i][`RS_RDY1] == 1 //rs1 ready
        && queue[i][`RS_RDY2] == 1 //rs2 ready
        && fu_table_in[queue[i][`RS_FU]] == 1 //fu ready
    ) // check fu ready and src reg ready
     	begin
          //Update FU to used
          fu_table_out[queue[i][`RS_FU]] <= 0;
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
      queue[rs_pointer] <= {1'b1, funct3, c_sigs, opcode, rd, src1, data1, ready1, src2, data2, ready2, imm, fu_pos, rob_num};
      

        rs_pointer <= rs_pointer + 1;
    end
  //$display("Reserving entry | f3: %b, c_sigs: %b, opcode: %b, rd: %0d, src1: %0d, data1: %h, ready1: %b, src2: %0d, data2: %h, ready2: %b, imm: %0d, fu_pos: %b, rob_num, %h", funct3, c_sigs, opcode, rd, src1, data1, ready1, src2, data2, ready2, imm, fu_pos, rob_num);
end
  
endmodule
