module fetch_buffer
#(
    parameter ADDR_WIDTH = 12,
              INSTR_WIDTH = 32
)
(
  input wire clk,
  input wire [ADDR_WIDTH-1: 0] pc_in,
  input wire [INSTR_WIDTH-1: 0] instr_in,
  output wire [ADDR_WIDTH-1: 0] pc_out,
  output wire [INSTR_WIDTH-1: 0] instr_out
  
);
  reg [ADDR_WIDTH-1: 0] pc;
  reg [INSTR_WIDTH-1: 0] instr;
  
  initial begin
    pc = 0;
    instr = 0;
  end
  
  always@(posedge clk) begin
    pc <= pc_in;
    instr <= instr_in;
  end

  assign pc_out = pc;
  assign instr_out = instr;

endmodule
