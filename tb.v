// Read trace into instruction memory
`include "rs_constants.v"

module tb;
  reg [31:0] tb_cycle_count;
  reg tb_clk;
  reg tb_rst;
  wire [31:0] tb_f_instr;
  wire [31:0] tb_d_instr;
  wire [6:0] tb_d_c_sig;
  wire [2:0] tb_d_alu_sig;
  wire [31:0] tb_d_imm;
  wire [5:0] tb_r_rrd_out;
  wire [5:0] tb_r_rrs1_out;
  wire [5:0] tb_r_rrs2_out;
  wire [31:0] tb_db_instr_out;
  wire [`RS_WIDTH-1:0] tb_cpu_issue1;
  wire [`RS_WIDTH-1:0] tb_cpu_issue2;
  wire [`RS_WIDTH-1:0] tb_cpu_issue3;
  wire [2:0] tb_cpu_instr_valid;
  wire [2:0] tb_cpu_fu_table_out;
  wire [2:0] tb_cpu_fu_table_in;
  wire tb_cpu_alu0_valid;
  wire tb_cpu_alu1_valid;
  wire tb_cpu_alu2_valid;
  wire [31:0] tb_cpu_alu0_res;
  wire [31:0] tb_cpu_alu1_res;
  wire [31:0] tb_cpu_alu2_res;
  
  
  
  //Instantiate modules
  CPU tb_cpu(
    .clk(tb_clk),
    .rst(tb_rst),
    .cpu_f_instr_out(tb_f_instr),
    .cpu_d_instr_out(tb_d_instr),
    .cpu_d_c_sig_out(tb_d_c_sig),
    .cpu_d_imm_out(tb_d_imm),
    .cpu_d_alu_sig_out(tb_d_alu_sig),
    .cpu_r_rrd_out(tb_r_rrd_out),
    .cpu_r_rrs1_out(tb_r_rrs1_out),
    .cpu_r_rrs2_out(tb_r_rrs2_out),
    .cpu_db_instr_out(tb_db_instr_out),
    .cpu_issue1(tb_cpu_issue1),
    .cpu_issue2(tb_cpu_issue2),
    .cpu_issue3(tb_cpu_issue3),
    .cpu_instr_valid(tb_cpu_instr_valid),
    .cpu_fu_table_out(tb_cpu_fu_table_out),
    .cpu_fu_table_in(tb_cpu_fu_table_in),
    .cpu_alu0_valid(tb_cpu_alu0_valid),
    .cpu_alu1_valid(tb_cpu_alu1_valid),
    .cpu_alu2_valid(tb_cpu_alu2_valid),
    .cpu_alu0_res(tb_cpu_alu0_res),
    .cpu_alu1_res(tb_cpu_alu1_res),
    .cpu_alu2_res(tb_cpu_alu2_res)
  );

  initial begin
    tb_cycle_count = 32'b0;
    tb_clk = 0;
    tb_rst = 1;
    #10;
    tb_rst = 0;
    #10;
  end
  
  always begin
    #5 tb_clk = ~tb_clk;  //100 MHz clock
  end
  
  always @(posedge tb_clk) begin
    tb_cycle_count <= tb_cycle_count + 1;
    $display("Cycle: %0d ", tb_cycle_count);
    
    //FETCH, DECODE, RENAME, DISPATCH
    $write(" FETCH | instr: %h",tb_f_instr);
    $write(" DECODE | instr: %h c_sig: %b alu_sig: %b, imm: %0d", tb_d_instr, tb_d_c_sig, tb_d_alu_sig, tb_d_imm);
    $write(" RENAME |rrd: %d, rrs1: %d, rrs2: %d", tb_r_rrd_out, tb_r_rrs1_out, tb_r_rrs2_out);
    $display(" DISPATCH | instr: %h", tb_db_instr_out);
    
    //ISSUE
    
    if(tb_cpu_instr_valid[0] == 1) begin
      $display(" ISSUE from port 0 | opcode: %b | rd: %d | imm: %0d", tb_cpu_issue1[`RS_OP], tb_cpu_issue1[`RS_RD], tb_cpu_issue1[`RS_IMM]);
    end
    if(tb_cpu_instr_valid[1] == 1) begin
      $display(" ISSUE from port 1 | opcode: %b | rd: %d | imm: %0d", tb_cpu_issue2[`RS_OP], tb_cpu_issue2[`RS_RD], tb_cpu_issue2[`RS_IMM]);
    end
    if(tb_cpu_instr_valid[2] == 1) begin
      $display(" ISSUE from port 2 | opcode: %b | rd: %d | imm: %0d", tb_cpu_issue3[`RS_OP], tb_cpu_issue3[`RS_RD], tb_cpu_issue3[`RS_IMM]);
    end
    
    
    //EXECUTION (RESULTS)
    if(cpu_alu0_valid) begin
      $display("ALU 0 Result: %d", cpu_alu0_res)
    end
    if(cpu_alu1_valid) begin
      $display("ALU 1 Result: %d", cpu_alu1_res)

    end
    if(cpu_alu2_valid) begin
      $display("ALU 2 Result: %d", cpu_alu2_res)
    end
  end
  
  initial begin
    #200;
    $finish;
  end
  
endmodule