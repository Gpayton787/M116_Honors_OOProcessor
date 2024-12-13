`include "rs_constants.v"

module result_buffer
(
  input wire clk,
  input wire rst,
  input wire [31:0] res0,
  input wire valid0,
  input wire [`RS_WIDTH-1:0] info0,
  input wire [31:0] res1,
  input wire valid1,
  input wire [`RS_WIDTH-1:0] info1,
  input wire [31:0] res2,
  input wire valid2,
  input wire [`RS_WIDTH-1:0] info2,
  
  output reg [31:0] res0_,
  output reg valid0_,
  output reg rd0_,
  output reg [31:0] res1_,
  output reg valid1_,
  output reg rd1_,
  output reg [31:0] res2_,
  output reg valid2_,
  output reg rd2_
);
  
  always@(posedge clk) begin
    if(rst) begin
        res0_ <= 0;
        valid0_ <= 0;
        rd0_ <= 0;
        res1_ <= 0;
        valid1_ <= 0;
        rd1_ <= 0;
        res2_ <= 0;
        valid2_ <= 0;
        rd2_ <= 0;
    end else begin
        res0_ <= res0;
        valid0_ <= valid0;
        rd0_ <= info0[`RS_RD];
        res1_ <= res1;
        valid1_ <= valid1;
        rd1_ <= info1[`RS_RD];
        res2_ <= res2;
        valid2_ <= valid2;
        rd2_ <= info2[`RS_RD];
    end
  end
endmodule