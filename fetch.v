module fetch;

endmodule

module PC
(
    input wire [31:0] pc_next,
    input wire reset, clk, pc_write,
    output reg [31:0] pc_current
);
  	initial begin
        pc_current <= 32'h00000000;
    end
    always @(posedge clk)
    begin
        if (reset == 1)
        begin
            pc_current <= 32'h00000000;
        end 
        else
        begin
            if (pc_write == 1)
            begin
                pc_current <= pc_next;
            end
        end
    end
endmodule

module PCAdder
  (
    input wire [31:0] curr_pc,
    output reg [31:0] new_pc
  );
  	always @(curr_pc)
    begin
        new_pc <= curr_pc + 32'h00000004;
    end
endmodule

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