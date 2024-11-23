// Read trace into instruction memory

module tb;
  reg [31:0] tb_cycle_count;
  reg tb_clk;
  reg tb_rst;
  wire [31:0] tb_f_instr;
  wire [31:0] tb_d_instr;
  wire [6:0] tb_d_c_sig;
  wire [2:0] tb_d_alu_sig;
  wire [31:0] tb_d_imm;
  
  
  //Instantiate modules
  CPU tb_cpu(
    .clk(tb_clk),
    .rst(tb_rst),
    .cpu_f_instr_out(tb_f_instr),
    .cpu_d_instr_out(tb_d_instr),
    .cpu_d_c_sig_out(tb_d_c_sig),
    .cpu_d_imm_out(tb_d_imm),
    .cpu_d_alu_sig_out(tb_d_alu_sig)
  );

  initial begin
    tb_cycle_count = 32'b0;
    tb_clk = 0;
    tb_rst = 0;
    #5;
  end
  
  always begin
    #5 tb_clk = ~tb_clk;  //100 MHz clock
  end
  
  always @(posedge tb_clk) begin
    tb_cycle_count <= tb_cycle_count + 1;
    $display("Cycle: %0d, FETCH| instr: %h DECODE| instr: %h c_sig: %b alu_sig: %b, imm: %0d", tb_cycle_count, tb_f_instr, tb_d_instr, tb_d_c_sig, tb_d_alu_sig, tb_d_imm);
  end
  
  initial begin
    #200;
    $finish;
  end
  
endmodule
