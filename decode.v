`include "constants.v"

module decode(
  input wire [11:0] pc_in,
  input wire [31:0] instr_in,
  output wire [6:0] c_sig_out,
  output wire [2:0] alu_sig_out,
  output reg [31:0] instr_out,
  output reg [11:0] pc_out,
  output wire [31:0] imm
);
  
  control my_control(
    .instr_in(instr_in),
    .c_sig_out(c_sig_out)
  );
  
  imm_gen my_imm_gen(
    .instruction(instr_in),
    .immediate(imm)
  );
  alu_control my_alu_control(
    .instr_in(instr_in),
    .alu_sig_out(alu_sig_out)
  );
  
  always @(instr_in or pc_in) begin
    instr_out = instr_in;
    pc_out = pc_in;
  end
endmodule


module control
#(
    parameter INSTR_WIDTH = 32,
  	parameter C_SIG_WIDTH = 7
)
(
  input wire [INSTR_WIDTH-1: 0] instr_in,
  output reg [C_SIG_WIDTH-1: 0] c_sig_out
);
  reg [6:0] opcode;
  reg [2:0] funct3;
  
  always @(instr_in) begin
    opcode = instr_in[6:0];
    funct3 = instr_in[14:12];
    case(opcode)
      `RTYPE_INSTR: c_sig_out = `RTYPE_SIG;
      `ITYPE_INSTR: c_sig_out = `ITYPE_SIG;
      `LUI_INSTR: c_sig_out = `ITYPE_SIG;
      `LOAD_INSTR: begin
        case(funct3)
          `F3_BYTE : c_sig_out = `LB_SIG;
          `F3_WORD : c_sig_out = `LW_SIG;
        endcase
      end
      `STORE_INSTR: begin
        case(funct3)
          `F3_BYTE : c_sig_out = `SB_SIG;
          `F3_WORD : c_sig_out = `SW_SIG;
        endcase
      end
      default: c_sig_out = 7'b0000000;
    endcase
  end
endmodule

module alu_control
#(
    parameter INSTR_WIDTH = 32,
  	parameter ALU_SIG_WIDTH = 3
)
(
  input wire [INSTR_WIDTH-1: 0] instr_in,
  output reg [ALU_SIG_WIDTH-1: 0] alu_sig_out
);
  reg [6:0] opcode;
  reg [2:0] funct3;
  
  always @(instr_in) begin 
    opcode = instr_in[6:0];
    funct3 = instr_in[14:12];
    if(opcode == `LOAD_INSTR || opcode == `STORE_INSTR) alu_sig_out = `ADD; 
    else if(opcode == `LUI_INSTR) alu_sig_out = `SHIFT_LEFT;
    else if(opcode == `RTYPE_INSTR) begin
      if(funct3 == `F3_XOR) alu_sig_out = `XOR;
      else if(funct3 == `F3_ADD) alu_sig_out = `ADD;
      else if(funct3 == `F3_SHIFT) alu_sig_out = `SHIFT_RIGHT;
      else $display("Unsupported R-Type Instruction cannot generate ALUOP opcode: %b, funct3: %b", opcode, funct3);
    end
    else if(opcode == `ITYPE_INSTR) begin
      if(funct3 == `F3_SHIFT) alu_sig_out = `SHIFT_RIGHT;
      else if(funct3 == `F3_OR) alu_sig_out = `OR;
      else if(funct3 == `F3_ADD) alu_sig_out = `ADD;
      else if(funct3 == `F3_AND) alu_sig_out = `AND;
      else $display("Unsupported I-Type Instruction cannot generate ALUOP opcode: %b, funct3: %b", opcode, funct3);
    end
    else alu_sig_out = 3'b0;
  end

     
endmodule

module imm_gen
(
    input wire [31:0] instruction,
    output reg [31:0] immediate 
);
  reg [6:0] opcode;
  reg [31:0] immR;
  reg [11:0] immI;
  reg [11:0] immS;
  reg [19:0] immLUI;
  
    always @(instruction)
    begin
      	opcode = instruction[6:0];
        immR = 32'h00000000;
		immI = instruction[31:20];
      	immS = {instruction[31:25],instruction[11:7]};
      	immLUI = instruction[31:12];
      
        case (opcode)
            7'b0110011 : immediate = immR; //add, xor
            7'b0010011 : immediate = {{20{immI[11]}},immI}; //addi, ori, srai
            7'b0110111 : immediate = {{12{immLUI[19]}},immLUI}; //lui
          	7'b0000011 : immediate = {{20{immI[11]}},immI}; //lb, lw
         	7'b0100011 : immediate = {{20{immS[11]}},immS}; //sb, sw
          default: immediate = 0;
        endcase
    end
endmodule