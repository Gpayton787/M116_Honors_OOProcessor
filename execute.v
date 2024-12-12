`include "rs_constants.v"
`include "constants.v"
`include "alu_constants.v"

module alu0
(
  input wire [`RS_WIDTH-1:0] instr_in0,
  input wire [2:0] instr_ready,
  input wire clk,
  output reg [`ALU_WIDTH-1:0] result0
);

reg [6:0] opcode;
reg [2:0] funct3;
reg [31:0] out;
wire [6:0] c_sigs;
wire reg_write;

  assign c_sigs = instr_in0[`RS_C_SIGS];
  assign reg_write = c_sigs[`REG_WRITE];

always @(posedge clk) begin
    opcode = instr_in0[`RS_OP];
    funct3 = instr_in0[`RS_FUNCT3];

  	case (opcode)
        7'b0110011 : begin
            if (funct3 == 3'b000) begin // add
              	out = instr_in0[`RS_DATA1] + instr_in0[`RS_DATA2];
            end
            else if (funct3 == 3'b100) begin // xor
              	out = instr_in0[`RS_DATA1] ^ instr_in0[`RS_DATA2];
            end
        end 
        7'b0010011 : begin 
            if (funct3 == 3'b000) begin // addi
              	out = instr_in0[`RS_DATA1] + instr_in0[`RS_IMM];
            end
            else if (funct3 == 3'b110) begin // ori
              	out = instr_in0[`RS_DATA1] | instr_in0[`RS_IMM];
            end
            else if (funct3 == 3'b101) begin // srai
              	out = instr_in0[`RS_DATA1] >>> instr_in0[`RS_IMM];
            end
        end
        7'b0110111 : out = instr_in0[`RS_IMM] << 12; //lui
    endcase
  
  if (instr_ready[0] == 1) begin
    $display("OUT, %d", out);
    result0 <= {1'b1, reg_write, out, instr_in0[`RS_RD]};
  end 
  else begin
    result0 <= `ALU_WIDTH'b0;
  end
  //$display("ALU0 Output: %b", result0);
end

endmodule

module alu1
(
  input wire [`RS_WIDTH-1:0] instr_in1,
  input wire [2:0] instr_ready,
  input wire clk,
  output reg [`ALU_WIDTH-1:0] result1
);

reg [6:0] opcode;
reg [2:0] funct3;
reg [31:0] out;
wire [6:0] c_sigs;
wire reg_write;

  assign c_sigs = instr_in1[`RS_C_SIGS];
  assign reg_write = c_sigs[`REG_WRITE];

always @(posedge clk) begin
    opcode = instr_in1[`RS_OP];
    funct3 = instr_in1[`RS_FUNCT3];

  	case (opcode)
        7'b0110011 : begin
            if (funct3 == 3'b000) begin // add
              	out = instr_in1[`RS_DATA1] + instr_in1[`RS_DATA2];
            end
            else if (funct3 == 3'b100) begin // xor
              	out = instr_in1[`RS_DATA1] ^ instr_in1[`RS_DATA2];
            end
        end 
        7'b0010011 : begin 
            if (funct3 == 3'b000) begin // addi
              	out = instr_in1[`RS_DATA1] + instr_in1[`RS_IMM];
            end
            else if (funct3 == 3'b110) begin // ori
              	out = instr_in1[`RS_DATA1] | instr_in1[`RS_IMM];
            end
            else if (funct3 == 3'b101) begin // srai
              	out = instr_in1[`RS_DATA1] >>> instr_in1[`RS_IMM];
            end
        end
        7'b0110111 : out = instr_in1[`RS_IMM] << 12; //lui
    endcase
  
  if (instr_ready[1] == 1) begin
    $display("OUT, %d", out);
    result1 <= {1'b1, reg_write, out, instr_in1[`RS_RD]};
  end 
  else begin
    result1 <= `ALU_WIDTH'b0;
  end
  //$display("ALU1 Output: %d, Instruction %b", out, instr_in1[`RS_FUNCT3]);
end

endmodule


module mem
(
  input wire [`RS_WIDTH-1:0] instr_in2,
  input wire [2:0] instr_ready,
  input wire clk,
  output reg [`ALU_WIDTH-1:0] result2
);
  
reg [6:0] opcode;
reg [2:0] funct3;
reg [31:0] out;
wire [6:0] c_sigs;
wire reg_write;

  assign c_sigs = instr_in2[`RS_C_SIGS];
  assign reg_write = c_sigs[`REG_WRITE];

  always @(posedge clk) begin
    out = instr_in2[`RS_DATA1] + instr_in2[`RS_IMM];
  
  if (instr_ready[1] == 1) begin
    result2 <= {1'b1, reg_write, out, instr_in2[`RS_RD]};
  end 
  else begin
    result2 <= `ALU_WIDTH'b0;
  end
end
endmodule
