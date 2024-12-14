// Code your testbench here
// or browse Examples

module tb;
  parameter ADDR_WIDTH = 20;
  parameter DEPTH = 16;

  reg clk;
  reg rst;
  reg en;
  reg we;
  reg oe;
  reg [ADDR_WIDTH-1:0] to_mem_addr;
  reg [31:0] wr_data;
  wire [31:0] re_data;
  reg cycle_count;
  reg mem_done_flag;
  

  single_port_mem u0
  ( 	
   .clk(clk),
   .rst(rst),
   .address(to_mem_addr),
   .data_in(wr_data),
   .data_out(re_data),
   .en(en),
   .mem_wr(we),
   .mem_re(oe),
   .mem_done(mem_done_flag)
  );

  initial begin
    cycle_count = 32'b0;
    clk = 0;
    rst = 0;
  end
  
  always #5 clk = ~clk;
  
  always @(posedge clk) begin
    if(mem_done_flag) begin
      $display("Reading: %d", re_data);
    end
  end
  
  initial begin
    en = 1;
    we = 1;
    wr_data = 7;
    to_mem_addr = 4;
    #10
    en = 1;
    we = 0;
    wr_data = 0;
    to_mem_addr = 0;
    #120
    en = 1;
    oe = 1;
    to_mem_addr = 4;
    #10
    en = 1;
    oe = 0;
    to_mem_addr = 0;
    #300 $finish;
  end

endmodule
