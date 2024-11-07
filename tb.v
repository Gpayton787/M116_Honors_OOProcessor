// Read trace into instruction memory

module tb;
  
  reg tb_clk;
  wire [31:0] tb_instruction;
  
  //Instantiate modules
  CPU tb_cpu(
    .clk(tb_clk),
    .instruction(tb_instruction)
  );

  initial begin
    tb_clk = 0;
  end
  
  always begin
    #5 tb_clk = ~tb_clk;  //100 MHz clock
  end
  
  always @(posedge tb_clk) begin
    $display("PC: %d, Instruction: %h", tb_cpu.PC, tb_instruction);
  end

  
  initial begin
    #100;
    $finish;
  end
  
endmodule