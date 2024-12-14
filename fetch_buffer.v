module fetch_buffer
#(
    parameter ADDR_WIDTH = 12,
              INSTR_WIDTH = 32
)
(
  input wire clk,
  input wire rst,
  input wire [ADDR_WIDTH-1: 0] pc_in,
  input wire [INSTR_WIDTH-1: 0] instr_in,
  output reg [ADDR_WIDTH-1: 0] pc_out,
  output reg [INSTR_WIDTH-1: 0] instr_out
  
);
  
  initial begin
    pc_out = 0;
    instr_out = 0;
  end
  
  always@(posedge clk) begin
    if(rst) begin
      pc_out <= 0;
      instr_out <= 0;
    end else begin
      //Update buffer
      pc_out <= pc_in;
      instr_out <= instr_in;  
    end
  end
endmodule