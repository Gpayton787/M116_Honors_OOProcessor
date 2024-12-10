module rs#(
  PREG_WIDTH = 6,
  DEPTH = 64,
  
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
  input wire c_sigs,
  
  
  //Logic inputs
  input wire [2:0] fu_in,
  input wire clk,

  //Outputs
  output reg rob_num,
  output reg [2:0] fu_out,
  output reg [2:0] rdy_out
);

  reg [`RS_WIDTH-1:0] queue[0:DEPTH-1];
  reg [5:0] rob_pointer; //circular rob
  reg [5:0] rs_pointer; //circular reservation station
  reg next_alu; //switches between first two alu

  reg [6:0] opcode;
  reg [1:0] fu_pos;
  reg [2:0] fu_update;

initial begin
  	rdy_out = 3'b000; // no instructions ready to issue
    rob_pointer = 0;
    rs_pointer = 0;
    next_alu = 2'b00;
    fu_update = 3'b111; // all fu start out ready
end

always @(posedge clk) //issue
begin
  rdy_out = 3'b000;
  for (integer i = 0; i < 8; i = i+1) begin
    if (lines[i][`RS_WIDTH-1] == 1 && lines[i][`RS_RDY1] == 1 && lines[i][`RS_RDY2] == 1 && fu_in[lines[i][`RS_FU]] == 1) // check fu ready and src reg ready
     	begin
          fu_update[lines[i][`RS_FU]] = 0;
          if (rdy_out[0] == 0) begin
            rs_out1 = lines[i];
            rdy_out[0] = 1;
          end
          else if (rdy_out[1] == 0) begin
            rs_out2 = lines[i];
            rdy_out[1] = 1;
          end
          else if (rdy_out[2] == 0) begin
            rs_out3 = lines[i];
            rdy_out[2] = 1;
          end
          lines[i][`RS_USE] = 0;
        end
    end
    fu_out = fu_update;
end

always @(instr) //dispatch
begin
    opcode = instr[6:0];

    case (opcode)
        7'b0000011 : fu_pos = 2'b10; //lb, lw
        7'b0100011 : fu_pos = 2'b10; //sb, sw
        default : begin
            fu_pos = next_alu;
            next_alu = !next_alu;
        end
    endcase

	rob_num = rob_pointer;
  queue[rs_pointer] = {1, opcode, rd, src1, data1, ready1, src2, data2, ready2, imm, fu_pos, rob_pointer, c_sigs};
	
  	rob_pointer = rob_pointer + 1;
    rs_pointer = rs_pointer + 1;
end
  
always @(fu_in)
begin
    fu_update = fu_in;
end
  
endmodule