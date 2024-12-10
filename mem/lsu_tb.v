`include "constants.v"

module tb;
  parameter ADDR_WIDTH = 20;
  parameter DEPTH = 16;

  reg clk;
  reg rst;
  reg cs;
  reg we;
  reg oe;
  reg [ADDR_WIDTH-1:0] to_mem_addr;
  wire [31:0] mem_data;
  reg [31:0] tb_data;

  reg en;
  reg [ADDR_WIDTH-1:0] to_lsu_addr;
  reg ls;
  reg [31:0] to_lsu_data;
  reg [11:0] to_lsu_pc;

  
  

  single_port_mem #(.DATA_WIDTH(DATA_WIDTH)) u0
  ( 	
    .clk(clk),
   .rst(rst),
   .address(to_mem_addr),
   .data(mem_data),
   .cs(cs),
   .mem_wr(we),
   .mem_re(oe)
  );

  lsu u1 (
    .clk(clk),
    .rst(rst),
    .en(en),
    .address_in(to_lsu_addr),
    .ls(ls),
    .data_in(to_lsu_data),
    .pc_in(to_lsu_pc),
    .ret_data(mem_data),
    .mem_done(),
    .data_out(),
    .mem_wr(),
    .mem_re(),
    .pc_out(),
    .load_data()
  )
  
  


  always #5 clk = ~clk;
  
  initial begin
    #200 $finish;
  end

endmodule
