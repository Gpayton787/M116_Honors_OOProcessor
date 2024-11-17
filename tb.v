// MASTER TB

module tb;
  reg [31:0] tb_cycle_count;
  reg tb_clk;
  wire [31:0] tb_instruction;
  wire [11:0] tb_pc;
  wire [6:0] tb_c_sig;
  wire [2:0] tb_alu_sig;
  wire [31:0] tb_imm;
  //Instantiate modules
  CPU tb_cpu(
    .clk(tb_clk),
    .fetch_instr_out(tb_instruction),
    .fetch_pc_out(tb_pc),
    .decode_c_sig_out(tb_c_sig),
    .imm_out(tb_imm),
    .alu_sig_out(tb_alu_sig)
  );

  initial begin
    tb_cycle_count = 32'b0;
    tb_clk = 0;
    #5;
  end
  
  always begin
    #5 tb_clk = ~tb_clk;  //100 MHz clock
  end
  
  always @(posedge tb_clk) begin
    tb_cycle_count <= tb_cycle_count + 1;
    $display("Cycle: %0d, Fetch PC: %h, Instruction: %h | Decode C_sig: %b ALU_sig: %b | Imm: %d", tb_cycle_count, tb_pc, tb_instruction, tb_c_sig, tb_alu_sig, tb_imm);
  end
  
  initial begin
    #200;
    $finish;
  end
  
endmodule