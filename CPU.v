module clk;
  
  
endmodule

module fetch_buffer
#(
    parameter ADDR_WIDTH = 12,
              INSTR_WIDTH = 32
)
(
  input wire clk,
  input wire [ADDR_WIDTH-1: 0] pc_in,
  input [INSTR_WIDTH-1: 0] instr_in,
  output wire [ADDR_WIDTH-1: 0] pc_out,
  output [INSTR_WIDTH-1: 0] instr_out
  
);
  reg [ADDR_WIDTH-1: 0] pc;
  reg [INSTR_WIDTH-1: 0] instr;
  
  always@(posedge clk) begin
    pc <= pc_in;
    instr <= instr_in;
  end

  assign pc_out = pc;
  assign instr_out = instr;

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

//TOP LEVEL MODULE
module CPU(
	input wire clk,
  	output wire [31:0] cpu_instr_out,
  	output wire [11:0] cpu_pc_out //temporary
);
  
  reg [11:0] PC;
  output wire [31:0] instruction;
  
  
  initial begin
    PC = 0;
  end
  
  //Module instantiations
  single_port_ROM instMem(
    .addr(PC),
    .dout(instruction)
  );
  
  fetch_buffer fetchBuf(
    .clk(clk),
    .pc_in(PC),
    .instr_in(instruction),
    .pc_out(cpu_pc_out),
    .instr_out(cpu_instr_out)
  );
  
  //Update PC on the clk
  always @(posedge clk) begin
    PC <= PC + 4;
  end

endmodule

module mux
  (
    input wire selector,
    input wire [31:0] in0, in1,
    output wire [31:0] out
  );
  assign out = (selector == 0) ? in0 : in1;
endmodule

module ProgramCounter
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

module PCAdder(curr_pc, new_pc);
    input wire [31:0] curr_pc;
    output wire [31:0] new_pc;
    always @(curr_pc)
    begin
        new_pc => curr_pc + 32'h00000004;
    end
endmodule

