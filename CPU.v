`include "fetch.v"
`include "fetch_buffer.v"
`include "decode.v"
`include "free_pool.v"
`include "areg_file.v"
`include "decode_buffer.v"
`include "lsq.sv"
`include "single_port_mem.v"
`include "fu_table.v"
`include "rs.v"
`include "rs_constants.v"
`include "alu.v"
`include "result_buffer.v"
`include "rob.v"
`include "rob_constants.v"

//TOP LEVEL MODULE
module CPU#(
	parameter REG_DATA_WIDTH = 32
)(
  input wire clk,
  input wire rst,
  output wire [31:0] cpu_f_instr_out,
  output wire [31:0] cpu_d_instr_out, //temporary
  output wire [6:0] cpu_d_c_sig_out, //temporary
  output wire [31:0] cpu_d_imm_out, //temporary
  output wire [2:0] cpu_d_alu_sig_out, //temporary
  output wire [5:0] cpu_r_rrd_out,
  output wire [5:0] cpu_r_rrs1_out,
  output wire [5:0] cpu_r_rrs2_out,
  output wire [31:0] cpu_db_instr_out,
  output wire cpu_db_valid,
  output wire [`RS_WIDTH-1:0] cpu_issue1,
  output wire [`RS_WIDTH-1:0] cpu_issue2,
  output wire [`RS_WIDTH-1:0] cpu_issue3,
  output wire [2:0] cpu_instr_valid,
  output wire [2:0] cpu_fu_table_out,
  output wire [2:0] cpu_rs_update,
  output wire cpu_alu0_valid,
  output wire cpu_alu1_valid,
  output wire cpu_alu2_valid,
  output wire [31:0] cpu_alu0_res,
  output wire [31:0] cpu_alu1_res,
  output wire [31:0] cpu_alu2_res,
  output wire [5:0] cpu_alu0_rd,
  output wire [5:0] cpu_alu1_rd,
  output wire [5:0] cpu_alu2_rd,
  output wire [`BUS_WIDTH-1:0] cpu_bus0,
  output wire [`BUS_WIDTH-1:0] cpu_bus1,
  output wire [`BUS_WIDTH-1:0] cpu_bus2,
  output wire [`RETIRE_WIDTH-1:0] cpu_retire0,
  output wire [`RETIRE_WIDTH-1:0] cpu_retire1,
  output wire [11:0] cpu_fb_pc_out,
  output wire [11:0] cpu_db_pc_out
  
);
  //Parameters
  parameter PREG_WIDTH = 6;
  parameter AREG_WIDTH = 5;
  
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
  wire db_valid;
  assign cpu_db_valid = db_valid;

  //LOGIC WIRES AFTER DECODE BUFFER
  wire [6:0] db_opcode;

  assign db_opcode = db_instr_out[`OPCODE];
  
  //RENAME LOGIC WIRES
  wire r_reg_write;
  wire [AREG_WIDTH-1:0] rd;
  wire [AREG_WIDTH-1:0] rs1;
  wire [AREG_WIDTH-1:0] rs2;
  wire empty;
  wire full;
  
  assign r_reg_write = db_c_sig_out[`REG_WRITE];
  assign rd = r_reg_write ? db_instr_out[11:7] : 0; //make rd idx 0 if we don't write to reg
  assign rs1 = db_instr_out[19:15];
  assign rs2 = db_instr_out[24:20];
  
  //RENAME OUTPUTS
  wire [PREG_WIDTH-1:0] rename_rrd_out;
  wire [PREG_WIDTH-1:0] rename_rrs1_out;
  wire [PREG_WIDTH-1:0] rename_rrs2_out;
  wire [PREG_WIDTH-1:0] rename_old_rd_out;
  

  
  //AREG OUTPUTS
  wire [REG_DATA_WIDTH-1:0] areg_data1_out;
  wire [REG_DATA_WIDTH-1:0] areg_data2_out;
  wire areg_ready1_out;
  wire areg_ready2_out;

  //DISPATCH LOGIC WIRES
  wire di_mem_re;
  wire di_mem_wr;

  assign di_mem_re = db_c_sig_out[`MEMRE];
  assign di_mem_wr = db_c_sig_out[`MEMWR];
  
  //RS OUTPUTS
  wire [`RS_WIDTH-1:0] rs_out0;
  wire [`RS_WIDTH-1:0] rs_out1;
  wire [`RS_WIDTH-1:0] rs_out2;
  wire [2:0] rs_valid_out;
  
  //ALU OUTPUTS
  wire [31:0] alu0_res;
  wire [31:0] alu1_res;
  wire [31:0] alu2_res;
  wire [`RS_WIDTH-1:0] alu0_instr_info_out;
  wire [`RS_WIDTH-1:0] alu1_instr_info_out;
  wire [`RS_WIDTH-1:0] alu2_instr_info_out;
  wire alu0_valid;
  wire alu1_valid;
  wire alu2_valid;
  
  //Result Buffer Outputs
  wire [31:0] rb_res0;
  wire rb_valid0;
  wire [5:0] rb_rd0;
  wire [31:0] rb_res1;
  wire rb_valid1;
  wire [5:0] rb_rd1;
  wire [31:0] rb_res2;
  wire rb_valid2;
  wire [5:0] rb_rd2;
  wire [5:0] rb_rob0;
  wire [5:0] rb_rob1;
  wire [5:0] rb_rob2;
  wire [11:0] rb_pc0;
  wire [11:0] rb_pc1;
  wire [11:0] rb_pc2;
  
  //BUS wires
  wire [`BUS_WIDTH-1:0] bus0 = {rb_valid0, rb_pc0, rb_res0, rb_rd0, rb_rob0};
  wire [`BUS_WIDTH-1:0] bus1 = {rb_valid1, rb_pc1, rb_res1, rb_rd1, rb_rob1};
  wire [`BUS_WIDTH-1:0] bus2 = {rb_valid2, rb_pc2, rb_res2, rb_rd2, rb_rob2};
  assign cpu_bus0 = bus0;
  assign cpu_bus1 = bus1;
  assign cpu_bus2 = bus2;

  
  //ROB OUTPUTS
  wire rob_push;
  wire [PREG_WIDTH-1:0] rob_free_reg;
  wire [`RETIRE_WIDTH-1:0] rob_retire0;
  wire [`RETIRE_WIDTH-1:0] rob_retire1;
  wire [5:0] rob_num;

  //LSQ WIRES
  wire [31:0] lsq_address_in;  
  wire [31:0] lsq_data_in; 
  wire [31:0] lsq_address_out;  
  wire [31:0] lsq_data_out; 

  wire [76:0] lsq_curr_entry;
  
  //MEM WIRES
  wire mem_re;
  wire mem_wr;
  wire [19:0] mem_address;
  wire [7:0] mem_data;
  
  //FU WIRES
  wire [2:0] rs_update;
  wire [2:0] fu_update;
  reg [2:0] fu_table_out;
  assign fu_update = {alu2_valid, alu1_valid, alu0_valid};
  
  //Assign to CPU outputs
  assign cpu_f_instr_out = fb_instr_out;
  assign cpu_d_instr_out = db_instr_out;
  assign cpu_d_c_sig_out = db_c_sig_out;
  assign cpu_d_imm_out = db_imm_out;
  assign cpu_d_alu_sig_out  = db_alu_sig_out;
  assign cpu_r_rrd_out = rename_rrd_out;
  assign cpu_r_rrs1_out = rename_rrs1_out;
  assign cpu_r_rrs2_out = rename_rrs2_out;
  assign cpu_db_instr_out = db_instr_out;
  assign cpu_issue1 = rs_out0;
  assign cpu_issue2 = rs_out1;
  assign cpu_issue3 = rs_out2;
  assign cpu_instr_valid = rs_valid_out;
  assign cpu_fu_table_out = fu_table_out;
  assign cpu_rs_update = rs_update;
  assign cpu_alu0_valid = rb_valid0;
  assign cpu_alu1_valid = rb_valid1;
  assign cpu_alu2_valid = rb_valid2;
  assign cpu_alu0_res = rb_res0;
  assign cpu_alu1_res = rb_res1;
  assign cpu_alu2_res = rb_res2;
  assign cpu_alu0_rd = rb_rd0;
  assign cpu_alu1_rd = rb_rd1;
  assign cpu_alu2_rd = rb_rd2;
  assign cpu_retire0 = rob_retire0;
  assign cpu_retire1 = rob_retire1;
  assign cpu_fb_pc_out = fb_pc_out;
  assign cpu_db_pc_out = db_pc_out;
  
  
  //Module instantiations
  fetch my_fetch(
    .clk(clk),
    .rst(rst),
    .instr_out(f_instr_out),
    .pc_out(f_pc_out)
  );
  
  fetch_buffer my_fetch_buffer(
    .clk(clk),
    .rst(rst),
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
    .rst(rst),
    .pc_in(d_pc_out),
    .instr_in(d_instr_out),
    .c_sig_in(d_c_sig_out),
    .alu_sig_in(d_alu_sig_out),
    .imm_in(d_imm_out),
    .pc_out(db_pc_out),
    .instr_out(db_instr_out),
    .c_sig_out(db_c_sig_out),
    .alu_sig_out(db_alu_sig_out),
    .imm_out(db_imm_out),
    .valid(db_valid)
  );
  
  //ARF
  areg_file my_areg_file(
    .clk(clk),
    .rst(rst),
    .rd_tag_idx(rd),
    .rs1_tag_idx(rs1),
    .rs2_tag_idx(rs2),
    .reg_write(r_reg_write),
    .rd_tag(rename_rrd_out),
    .rs1_tag(rename_rrs1_out),
    .rs2_tag(rename_rrs2_out),
    .rd_old_tag(rename_old_rd_out),
    .rs1_data(areg_data1_out),
    .rs2_data(areg_data2_out),
    .rs1_ready(areg_ready1_out),
    .rs2_ready(areg_ready2_out),
    .retire0(rob_retire0),
    .retire1(rob_retire1)
  );
  
  //Free Pool
  free_pool my_free_pool(
    .clk(clk),
    .rst(rst),
    .push(rob_push),
    .pop(r_reg_write),
    .data_in(rob_free_reg),
    .data_out(rename_rrd_out),
    .empty(empty),
    .full(full)
  );
  
  rs my_rs(
    .clk(clk),
    .instr(db_instr_out),
    .pc(db_pc_out),
    .alu_op(db_alu_sig_out),
    .imm(db_imm_out),
    .rd(rename_rrd_out),
    .src1(rename_rrs1_out),
    .data1(areg_data1_out),
    .ready1(areg_ready1_out),
    .src2(rename_rrs2_out),
    .data2(areg_data2_out),
    .ready2(areg_ready2_out),
    .c_sigs(db_c_sig_out),
    .fu_table_in(fu_table_out),
    .fu_table_out(rs_update),
    .rob_num(rob_num),
    .instr_out0(rs_out0),
    .instr_out1(rs_out1),
    .instr_out2(rs_out2),
    .instr_valid(rs_valid_out),
    //Forwarding
    .bus0(bus0),
    .bus1(bus1)
  );
  
  fu_table my_fu_table(
    .clk(clk),
    .rst(rst),
    .rs_update(rs_update),
    .fu_update(fu_update),
    .table_out(fu_table_out)
  );
  
  alu_wrapper my_alu0(
    .clk(clk),
    .rst(rst),
    .instr_info_in(rs_out0),
    .en(rs_valid_out[0]),
    .result(alu0_res),
    .valid(alu0_valid),
    .instr_info_out(alu0_instr_info_out)
  );
  alu_wrapper my_alu1(
    .clk(clk),
    .rst(rst),
    .instr_info_in(rs_out1),
    .en(rs_valid_out[1]),
    .result(alu1_res),
    .valid(alu1_valid),
    .instr_info_out(alu1_instr_info_out)
  );
  alu_wrapper my_alu2(
    .clk(clk),
    .rst(rst),
    .instr_info_in(rs_out2),
    .en(rs_valid_out[2]),
    .result(alu2_res),
    .valid(alu2_valid),
    .instr_info_out(alu2_instr_info_out)
  );
  

  result_buffer my_result_buffer(
    .clk(clk),
    .rst(rst),
    .res0(alu0_res),
    .valid0(alu0_valid),
    .info0(alu0_instr_info_out),
    .res1(alu1_res),
    .valid1(alu1_valid),
    .info1(alu1_instr_info_out),
    .res2(alu2_res),
    .valid2(alu2_valid),
    .info2(alu2_instr_info_out),
    .res0_(rb_res0),
    .valid0_(rb_valid0),
    .rd0_(rb_rd0),
    .res1_(rb_res1),
    .valid1_(rb_valid1),
    .rd1_(rb_rd1),
    .res2_(rb_res2),
    .valid2_(rb_valid2),
    .rd2_(rb_rd2),
    .rob0_(rb_rob0),
    .rob1_(rb_rob1),
    .rob2_(rb_rob2),
    .pc0_(rb_pc0),
    .pc1_(rb_pc1),
    .pc2_(rb_pc2)
  );
  
  rob my_rob(
    .clk(clk),
    .rd(rename_rrd_out),
    .rd_old(rename_old_rd_out),
    .pc(db_pc_out),
    .wr_en(db_valid),
    .bus0(bus0),
    .bus1(bus1),
    .bus2(bus2),
    .rob_num(rob_num),
    .retire0(rob_retire0),
    .retire1(rob_retire1)
  );
  
  //Writeback
  
  /*
  lsq my_lsq(
    .clk(clk),
 	.rst(rst),
    .wr_en(di_mem_re || di_mem_wr),
    .opcode(db_opcode),
    .pc(db_pc_out),
    .address_in(lsq_address_in),   
    .data_in(lsq_data_in),  
  // Outputs
    .curr_entry(lsq_curr_entry),
    .address_out(lsq_address_out),       
    .data_out(lsq_data_out)    
  );
  
  //Main Memory
  single_port_mem my_single_port_mem(
    .clk(clk),
    .rst(rst),
    .cs(1'b1),
    .mem_re(mem_re),
    .mem_wr(mem_wr),
    .address(mem_address),
    .data(mem_data)
  );
  */
endmodule


