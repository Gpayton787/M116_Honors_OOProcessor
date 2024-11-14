`define RTYPE_INSTR 7'b0110011
`define ITYPE_INSTR 7'b0010011
`define RTYPE_SIG 7'b1000000
`define ITYPE_SIG 7'b1100000
`define LOAD_INSTR 7'b0000011
`define STORE_INSTR 7'b0100011
`define LB_SIG 7'b1101011
`define SB_SIG 7'b0100101
`define LW_SIG 7'b1101010
`define SW_SIG 7'b0100100
`define F3_BYTE 3'b000
`define F3_WORD 3'b010

module decode(
  input wire [11:0] pc_in,
  input wire [31:0] instr_in,
  output wire [6:0] c_sig_out,
  output wire [11:0] pc_out,
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
  
  assign pc_out = pc_in;
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
  wire [6:0] opcode = instr_in[6:0];
  wire [2:0] funct3 = instr_in[14:12];
  
  always @(instr_in) begin
    case(opcode)
      `RTYPE_INSTR: c_sig_out = `RTYPE_SIG;
      `ITYPE_INSTR: c_sig_out = `ITYPE_SIG;
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
        endcase
    end
endmodule
