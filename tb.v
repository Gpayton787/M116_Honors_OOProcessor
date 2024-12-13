// Read trace into instruction memory
`include "rs_constants.v"
`include "rob_constants.v"

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
  wire tb_db_valid;
  wire [`RS_WIDTH-1:0] tb_cpu_issue1;
  wire [`RS_WIDTH-1:0] tb_cpu_issue2;
  wire [`RS_WIDTH-1:0] tb_cpu_issue3;
  wire [2:0] tb_cpu_instr_valid;
  wire [2:0] tb_cpu_fu_table_out;
  wire [2:0] tb_cpu_rs_update;
  wire tb_cpu_alu0_valid;
  wire tb_cpu_alu1_valid;
  wire tb_cpu_alu2_valid;
  wire [31:0] tb_cpu_alu0_res;
  wire [31:0] tb_cpu_alu1_res;
  wire [31:0] tb_cpu_alu2_res;
  wire [5:0] tb_cpu_rd0;
  wire [5:0] tb_cpu_rd1;
  wire [5:0] tb_cpu_rd2;
  wire [`BUS_WIDTH-1:0] cpu_bus0;
  wire [`BUS_WIDTH-1:0] cpu_bus1;
  wire [`BUS_WIDTH-1:0] cpu_bus2;
  wire [`RETIRE_WIDTH-1:0] tb_cpu_retire0;
  wire [`RETIRE_WIDTH-1:0] tb_cpu_retire1;
  
  
  
  
  
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
    .cpu_db_valid(tb_db_valid),
    .cpu_issue1(tb_cpu_issue1),
    .cpu_issue2(tb_cpu_issue2),
    .cpu_issue3(tb_cpu_issue3),
    .cpu_instr_valid(tb_cpu_instr_valid),
    .cpu_fu_table_out(tb_cpu_fu_table_out),
    .cpu_rs_update(tb_cpu_rs_update),
    .cpu_alu0_valid(tb_cpu_alu0_valid),
    .cpu_alu1_valid(tb_cpu_alu1_valid),
    .cpu_alu2_valid(tb_cpu_alu2_valid),
    .cpu_alu0_res(tb_cpu_alu0_res),
    .cpu_alu1_res(tb_cpu_alu1_res),
    .cpu_alu2_res(tb_cpu_alu2_res),
    .cpu_alu0_rd(tb_cpu_rd0),
    .cpu_alu1_rd(tb_cpu_rd1),
    .cpu_alu2_rd(tb_cpu_rd2),
    .cpu_bus0(cpu_bus0),
    .cpu_bus1(cpu_bus1),
    .cpu_bus2(cpu_bus2),
    .cpu_retire0(tb_cpu_retire0),
    .cpu_retire1(tb_cpu_retire1)
  );

  initial begin
    tb_cycle_count = 32'b0;
    tb_clk = 0;
    tb_rst = 0;
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
    $display(" DISPATCH | instr: %h, valid: %b", tb_db_instr_out, tb_db_valid);
    
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
    
    
    //EXECUTION (RESULTS) && BUS Values
    if(tb_cpu_alu0_valid) begin
      $display("ALU 0 Result: %d, Rd: %d | BUS, rd: %d, res: %0d", tb_cpu_alu0_res, tb_cpu_rd0, cpu_bus0[`BUS_RD], cpu_bus0[`BUS_RESULT]);
    end
    if(tb_cpu_alu1_valid) begin
      $display("ALU 1 Result: %d Rd: %d | BUS, rd: %d, res: %0d, %b", tb_cpu_alu1_res, tb_cpu_rd1, cpu_bus1[`BUS_RD], cpu_bus1[`BUS_RESULT], cpu_bus1);

    end
    if(tb_cpu_alu2_valid) begin
      $display("ALU 2 Result: %d Rd: %d | BUS, rd: %d, res: %0d", tb_cpu_alu2_res, tb_cpu_rd2, cpu_bus2[`BUS_RD], cpu_bus2[`BUS_RESULT]);
    end
    
    //RETIRE UP TO TWO INSTRUCTION
    
    if(tb_cpu_retire0[`RETIRE_VALID]) begin
      $display("RETIRE 0 | rd: %d, data: %d, old_rd: %d", tb_cpu_retire0[`RETIRE_RD], tb_cpu_retire0[`RETIRE_DATA], tb_cpu_retire0[`RETIRE_OLDRD]);
    end
    if(tb_cpu_retire1[`RETIRE_VALID]) begin
      $display("RETIRE 1 | rd: %d, data: %d, old_rd: %d", tb_cpu_retire1[`RETIRE_RD], tb_cpu_retire1[`RETIRE_DATA], tb_cpu_retire1[`RETIRE_OLDRD]);
    end
    
    
    //STATE
  	$display("FU Table (210): %b", tb_cpu_fu_table_out);
    
    
    
  end
  
 
  
  initial begin
    #200;
    $finish;
  end
  
endmodule