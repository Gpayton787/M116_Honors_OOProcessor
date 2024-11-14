`include "fetch.v"
`include "fetch_buffer.v"
`include "decode.v"

//TOP LEVEL MODULE
module CPU(
	input wire clk,
  output wire [31:0] fetch_instr_out,
  output wire [11:0] fetch_pc_out, //temporary
  output wire [6:0] decode_c_sig_out //temporary
);
  
  wire [11:0] pc_decode_out;
  
  //Module instantiations
  fetch my_fetch(
    .clk(clk),
    .instr_out(fetch_instr_out),
    .pc_out(fetch_pc_out)
  );
  /*
  fetch_buffer my_fetch_buffer(
    .clk(clk),
    .pc_in(PC),
    .instr_in(instruction),
    .pc_out(cpu_pc_out),
    .instr_out(cpu_instr_out)
  );*/
  decode my_decode(
    .pc_in(fetch_pc_out),
    .instr_in(fetch_instr_out),
    .c_sig_out(decode_c_sig_out),
    .pc_out(pc_decode_out)
  );
endmodule


