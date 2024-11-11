// Read trace into instruction memory

module tb;
  
  reg tb_clk;
  wire [31:0] tb_instruction;
  wire [11:0] tb_pc;
  
  //Instantiate modules
  CPU tb_cpu(
    .clk(tb_clk),
    .cpu_instr_out(tb_instruction),
    .cpu_pc_out(tb_pc)
  );

  initial begin
    tb_clk = 0;
  end
  
  always begin
    #5 tb_clk = ~tb_clk;  //100 MHz clock
  end
  
  always @(posedge tb_clk) begin
    $display("PC: %d, Instruction: %h", tb_pc, tb_instruction);
  end

  
  initial begin
    #100;
    $finish;
  end
  
endmodule
