module decode_buffer
#(
    parameter ADDR_WIDTH = 12,
              INSTR_WIDTH = 32,
              C_SIG_WIDTH = 7,
              ALU_SIG_WIDTH = 3
)
(
  input wire clk,
  input wire [ADDR_WIDTH-1: 0] pc_in,
  input wire [INSTR_WIDTH-1: 0] instr_in,
  input wire [C_SIG_WIDTH-1: 0] c_sig_in,
  input wire [ALU_SIG_WIDTH-1: 0] alu_sig_in,
  input wire [31:0] imm_in,
  
  output wire [ADDR_WIDTH-1: 0] pc_out,
  output wire [INSTR_WIDTH-1: 0] instr_out,
  output wire [C_SIG_WIDTH-1: 0] c_sig_out,
  output wire [ALU_SIG_WIDTH-1: 0] alu_sig_out,
  output wire [31:0] imm_out
);
  
  reg [ADDR_WIDTH-1: 0] pc;
  reg [INSTR_WIDTH-1: 0] instr;
  reg [C_SIG_WIDTH-1: 0] c_sig;
  reg [ALU_SIG_WIDTH-1: 0] alu_sig;
  reg [31: 0] imm;
  
  
  initial begin
    pc = 0;
    instr = 0;
    c_sig = 0;
    alu_sig = 0;
    imm = 0;
  end
  
  always@(posedge clk) begin
    pc <= pc_in;
    instr <= instr_in;
    c_sig <= c_sig_in;
    alu_sig <= alu_sig_in;
    imm <= imm_in;
    
  end

  assign pc_out = pc;
  assign instr_out = instr;
  assign c_sig_out = c_sig;
  assign alu_sig_out = alu_sig;
  assign imm_out = imm;

endmodule
