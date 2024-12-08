`include "fetch.v"
`include "fetch_buffer.v"
`include "decode.v"
`include "rename.v"
`include "decode_buffer.v"
`include "lsq.sv"
`include "single_port_mem.v"

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
  output wire [5:0] cpu_r_rrs2_out,
  output wire [140:0] cpu_rs_out [63:0], //temporary
  output wire [45:0] cpu_rob_out [15:0] // temporary 
  output wire [76:0] cpu_curr_lsq
  
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
  assign rd = db_instr_out[11:7];
  assign rs1 = db_instr_out[19:15];
  assign rs2 = db_instr_out[24:20];
  
  //RENAME OUTPUTS
  wire [PREG_WIDTH-1:0] rename_rrd_out;
  wire [PREG_WIDTH-1:0] rename_rrs1_out;
  wire [PREG_WIDTH-1:0] rename_rrs2_out;
  wire [PREG_WIDTH-1:0] rename_old_rd_out;
  wire [DATA_WIDTH-1:0] data_rrs1_out;
  wire [DATA_WIDTH-1:0] data_rrs2_out;
  wire ready_rrs1_out;
  wire ready_rrs2_out;

  //DISPATCH LOGIC WIRES
  wire di_mem_re;
  wire di_mem_wr;

  assign di_mem_re = db_c_sig_out[`MEMRE];
  assign di_mem_wr = db_c_sig_out[`MEMWR];

  //RS OUTPUTS
  wire [RS_WIDTH-1:0] rs_dispatch_out;
  
  //ROB OUTPUTS
  wire rob_push;
  wire [PREG_WIDTH-1:0] rob_free_reg;

  //RS to FU WIRES
  wire [2:0] rs_fu_in;
  wire [2:0] rs_fu_out;

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
  
  //Assign to CPU outputs
  assign cpu_f_instr_out = fb_instr_out;
  assign cpu_d_instr_out = db_instr_out;
  assign cpu_d_c_sig_out = db_c_sig_out;
  assign cpu_d_imm_out = db_imm_out;
  assign cpu_d_alu_sig_out  = db_alu_sig_out;
  assign cpu_r_rrd_out = rename_rrd_out;
  assign cpu_r_rrs1_out = rename_rrs1_out;
  assign cpu_r_rrs2_out = rename_rrs2_out;
  assign cpu_curr_lsq = lsq_curr_entry;
  
  
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
 
 /*
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
  */
  
  //ARF
  Areg_file my_areg_file(
    .clk(clk),
    .rst(rst),
    .rd_tag_idx(rd),
    .rs1_tag_idx(rs1),
    .rs2_tag_idx(rs2),
    .reg_write(r_reg_write),
    .rd_tag(rename_rrd_out),
    .rs1_tag(rename_rrs1_out),
    .rs2_tag(rename_rrs2_out),
    .rd_old_tag(rename_old_rd_out)
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
    .instr(db_instr_out),
    .imm(db_imm_out),
    .rd(rename_rrd_out),
    .rd_old(rename_old_rd_out),
    .src1(rename_rrs1_out),
    .data1(data_rrs1_out),
    .ready1(ready_rrs1_out),
    .src2(rename_rrs2_out),
    .data2(data_rrs2_out),
    .ready2(ready_rrs2_out),
    .clk(clk),
    .fu_in(rs_fu_in),
    .fu_out(rs_fu_out),
    .rs_lines(cpu_rs_out),
    .rob_out(rs_dispatch_out)
  );
  
  fu my_fu(
    .ready_in(rs_fu_out),
    .ready_out(rs_fu_in)
  );
  
  rob my_rob(
    .rs_line(rs_dispatch_out),
    .pc(db_pc_out),
    .clk(clk),
    .rob_out(cpu_rob_out)
  );
  
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
endmodule


