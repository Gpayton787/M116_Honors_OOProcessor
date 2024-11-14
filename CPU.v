`include "control.v"
`include "fetch_buffer.v"
`include "single_port_ROM.v"
`include "PC.v"
`include "PCAdder.v"
`include "two_input_mux.v"

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
