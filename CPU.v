`include "fetch.v"
`include "fetch_buffer.v"
`include "decode.v"
`include "rename.v"
`include "decode_buffer.v"

//TOP LEVEL MODULE
module CPU(
  input wire clk,
  input wire rst,
  output wire [31:0] cpu_f_instr_out,
  output wire [31:0] cpu_d_instr_out, //temporary
  output wire [6:0] cpu_d_c_sig_out, //temporary
  output wire [31:0] cpu_d_imm_out, //temporary
  output wire [2:0] cpu_d_alu_sig_out, //temporary
  output wire [5:0] cpu_r_rrd_out,
  output wire [5:0] cpu_r_rrs1_out,
  output wire [5:0] cpu_r_rrs2_out
  
);
  //Parameters
  parameter PREG_WIDTH = 6;
  parameter AREG_WDITH = 5;
  
  //Internal wires to connect modules
  
  //FETCH OUTPUTS
  wire [31:0] f_instr_out;
  wire [11:0] f_pc_out;
  
  //FETCH BUFFER OUTPUTS
  wire [31:0] fb_instr_out;
  wire [11:0] fb_pc_out;
  
  //DECODE OUTPUTS
  wire [31:0] d_instr_out;
  wire [11:0] d_pc_out;
  wire [6:0] d_c_sig_out;
  wire [2:0] d_alu_sig_out;
  wire [31:0] d_imm_out;
  
  //DECODE BUFFER OUTPUTS
  wire [31:0] db_instr_out;
  wire [11:0] db_pc_out;
  wire [6:0] db_c_sig_out;
  wire [2:0] db_alu_sig_out;
  wire [31:0] db_imm_out;
  
  //RENAME OUTPUTS
  wire [PREG_WIDTH-1:0] rename_rrd_out;
  wire [PREG_WIDTH-1:0] rename_rrs1_out;
  wire [PREG_WIDTH-1:0] rename_rrs2_out;
  wire [PREG_WIDTH-1:0] rename_old_rd_out;
  
  //ROB OUTPUTS
  wire rob_push;
  wire [PREG_WIDTH-1:0] rob_free_reg;
  
  //Assign to CPU outputs
  assign cpu_f_instr_out = fb_instr_out;
  assign cpu_d_instr_out = db_instr_out;
  assign cpu_d_c_sig_out = db_c_sig_out;
  assign cpu_d_imm_out = db_imm_out;
  assign cpu_d_alu_sig_out  = db_alu_sig_out;
  assign cpu_r_rrd_out = rename_rrd_out;
  assign cpu_r_rrs1_out = rename_rrs1_out;
  assign cpu_r_rrs2_out = rename_rrs2_out;
  
  
  //Module instantiations
  fetch my_fetch(
    .clk(clk),
    .instr_out(f_instr_out),
    .pc_out(f_pc_out)
  );
  
  fetch_buffer my_fetch_buffer(
    .clk(clk),
    .pc_in(f_pc_out),
    .instr_in(f_instr_out),
    .pc_out(fb_pc_out),
    .instr_out(fb_instr_out)
  );
  
  decode my_decode(
    .pc_in(fb_pc_out),
    .instr_in(fb_instr_out),
    .c_sig_out(d_c_sig_out),
    .alu_sig_out(d_alu_sig_out),
    .pc_out(d_pc_out),
    .instr_out(d_instr_out),
    .imm(d_imm_out)
  );
  
  decode_buffer my_decode_buffer(
    .clk(clk),
    .pc_in(d_pc_out),
    .instr_in(d_instr_out),
    .c_sig_in(d_c_sig_out),
    .alu_sig_in(d_alu_sig_out),
    .imm_in(d_imm_out),
    .pc_out(db_pc_out),
    .instr_out(db_instr_out),
    .c_sig_out(db_c_sig_out),
    .alu_sig_out(db_alu_sig_out),
    .imm_out(db_imm_out)
  );
  
  rename my_rename(
    .clk(clk),
    .rst(rst),
    .c_sig(db_c_sig_out),
    .push_free_reg(rob_push),
    .freed_reg(rob_free_reg),
    .instr_in(db_instr_out),
    .rrd_out(rename_rrd_out),
    .rrs1_out(rename_rrs1_out),
    .rrs2_out(rename_rrs2_out),
    .rd_old_tag_out(rename_old_rd_out)
  );
  
  
endmodule


