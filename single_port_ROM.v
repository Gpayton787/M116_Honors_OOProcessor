
module single_port_ROM 
#(
    parameter ADDR_WIDTH = 12,
              DATA_WIDTH = 8
)
(
  //12 bit PC input
  input wire [ADDR_WIDTH-1: 0] addr,
  //32 bit instruction output
  output wire [DATA_WIDTH*4-1: 0] dout
);
  //2^12 or 4 KB byte addressable memory
  reg [DATA_WIDTH-1:0] mem[0:2**ADDR_WIDTH-1];
  
  initial begin //Read trace, initialize ROM
    $readmemh("test.txt", mem, 0, 47);
  end

  assign dout = {mem[addr], mem[addr+1], mem[addr+2], mem[addr+3]}; 

endmodule