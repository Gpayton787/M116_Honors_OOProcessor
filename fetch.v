module fetch(
  input clk,
  input rst,
  output reg [31:0] instr_out,
  output reg [11:0] pc_out
);
 
  reg [11:0] pc;
  
  single_port_ROM my_ROM(
    .addr(pc),
    .dout(instr_out)
  );
  initial begin
    pc <= 0;
    pc_out<=0;
  end
  
  always @(posedge clk) begin
    if(rst) begin
      pc <= 0;
      pc_out <= 0;
    end else begin
      if(instr_out != 32'b0) begin
        pc <= pc+4;
        pc_out <= pc+4;
        end
    end
  end

endmodule

/*
module PC
(
  input wire [11:0] pc_next,
  input wire reset, clk, pc_write,
  output reg [11:0] pc_current
);
  	initial begin
        pc_current <= 0;
    end
    always @(posedge clk)
    begin
        if (reset == 1)
        begin
            pc_current <= 0;
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
    input wire [11:0] curr_pc,
    output reg [11:0] new_pc
  );
  	always @(curr_pc)
    begin
        new_pc <= curr_pc + 4;
    end
endmodule
*/

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
  integer i;
  
  initial begin //initialize ROM, then read TRACE
    for (i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin
      mem[i] = 8'b0;
    end
    $readmemh("final.txt", mem, 0, 71);
  end
  assign dout = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]}; 
endmodule