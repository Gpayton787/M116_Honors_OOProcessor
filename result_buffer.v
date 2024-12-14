`include "rs_constants.v"
`include "lsq_constants.v"
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
  output reg [5:0] rob0_,
  output reg [5:0] rob1_,
  output reg [11:0] pc0_,
  output reg [11:0] pc1_,
  output reg [11:0] pc2_,
  output reg [5:0] rd0_,
  output reg [31:0] res1_,
  output reg valid1_,
  output reg [5:0] rd1_,
  output reg mem_valid,
  output reg [31:0] mem_res,
  output reg [`RS_WIDTH-1:0] mem_info
);
  
  always@(posedge clk) begin
    if(rst) begin
        res0_ <= 0;
        valid0_ <= 0;
        rd0_ <= 0;
        res1_ <= 0;
        valid1_ <= 0;
        rd1_ <= 0;
      	mem_res <= 0;
      	mem_info <= 0;
      	mem_valid <= 0;
    end else begin
        res0_ <= res0;
        valid0_ <= valid0;
        rd0_ <= info0[`RS_RD];
        res1_ <= res1;
        valid1_ <= valid1;
        rd1_ <= info1[`RS_RD];
        rob0_ <= info0[`RS_ROB];
        rob1_ <= info1[`RS_ROB];
        pc0_ <= info0[`RS_PC];
        pc1_ <= info1[`RS_PC];
      	mem_valid <= valid2;
      	mem_res <= res2;
        mem_info <= info2;
    end
  end
endmodule