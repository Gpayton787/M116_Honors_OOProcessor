`include "constants.v"

module tb;
  parameter ADDR_WIDTH = 20;
  parameter DEPTH = 16;

  reg [10:0] tb_cycle;
  reg clk;
  reg rst;
  reg cs;
  reg we;
  reg oe;
  reg [ADDR_WIDTH-1:0] addr;
  reg [31:0] data_in;
  reg [31:0] data_out;
  reg mem_done;
  
  

  single_port_mem u0
  ( 	
    .clk(clk),
   .rst(rst),
   .address(addr),
    .data_in(data_in),
    .data_out(data_out),
   .cs(cs),
   .mem_wr(we),
    .mem_re(oe),
    .mem_done(mem_done)
  );
  
  


  always #5 clk = ~clk;
  
  initial begin
    rst <= 1;
    #10
    rst <= 0;
    #10
    
    {clk, cs, we, addr, data_in , oe, tb_cycle} <= 0;
   
    addr<= 1; we<= 1; cs<= 1; oe<= 0; data_in <=5;
    #10
    $display("WRITE: Time=%0t, Addr=0x%0h, Data=0x%0h", $time, addr,data_in);
    addr<= 0; we<= 0; cs<= 1; oe<= 0; data_in <=0;
    #100
    addr<= 1; we<= 0; cs<=1; oe<=1; 
    #20 //Ensure we only issue read once memory is done
    $display("READ: Time=%0t, Addr=0x%0h and wait ten cycles", $time, addr);
    addr<= 0; we<= 0; cs<=1; oe<=0; 
    #130
    $display("FINISH READ: Time=%0t, Addr=0x%0h Data=0x%0h", $time, addr, data_out);
    
    

    #250 $finish;
  end
  
  always @(posedge clk) begin
    tb_cycle <= tb_cycle+1;
    $display ("Cylce: %0d, Mem_done: %b", tb_cycle, mem_done);

  end

endmodule
