`include "rs_constants.v"
`define ALU_SRC 5

module alu_wrapper(
  input wire clk,
  input wire rst,
  input wire [`RS_WIDTH-1:0] instr_info_in,
  output reg [31:0] result,
  output reg [`RS_WIDTH-1:0] instr_info_out
);
  
  wire [31:0] imm;
  wire [31:0] rs1;
  wire [31:0] rs2;
  wire [31:0] arg1;
  wire [31:0] arg2;
  wire [6:0] c_sigs;
  wire [2:0] alu_op;
  
  assign imm = instr_info[`RS_IMM];
  assign rs1 = instr_info[`RS_DATA1];
  assign rs2 = instr_info[`RS_DATA2];
  assign arg1 = rs1;
  assign arg2 = c_sigs[`ALU_SRC] ? imm : rs2;
  
  assign c_sigs = instr_info[`RS_C_SIGS];
  assign alu_op = instr_info[`RS_ALU_OP];
  
  alu my_alu(
    .clk(clk),
    .rst(rst)
    .arg1(arg1),
    .arg2(arg2),
    .alu_op(al_op),
    .result(result)
  );
  always @(posedge clk) begin
    if(rst) begin 
      instr_info_out <= 0;
    end else begin
      instr_info_out <= instr_info_in;
    end
  end 
  
endmodule 


module alu
(
  input wire [31:0] arg1,
  input wire [31:0] arg2,
  input wire [2:0] alu_op,
  input wire clk,
  input wire rst,
  output reg [31:0] result
);

  always @(posedge clk) begin
    if(rst) begin
      result <= 0;
    end else begin 
      case(alu_op) 
        `ADD: result <= arg1+arg2;
        `SHIFT_LEFT: result <= arg2 << 12;
        `SHIFT_RIGHT: result <= arg1 >> arg2;
        `XOR: result <= arg1^arg2;
        `OR: result <= arg1 | arg2;
        `AND: result <= arg1 & arg2;
        default: result <= 0;
      endcase 
    end
  end
endmodule