module clk;
  
  
endmodule


// Code your design here
module CPU(
	input wire clk,
  output wire [31:0] instruction
);
  //1 KB instruction ROM, byte addressable, 256 instructions
  reg [7:0] instructionROM [0:1023];
  //PC, 1024 addresses
  reg [9:0] PC;
  
  //Connect output wire
  assign instruction = {instructionROM[PC], instructionROM[PC+1], instructionROM[PC+2], instructionROM[PC+3]}; 
  
  initial begin //Read trace, init values
    PC = 0;
    $readmemh("test.txt", instructionROM, 0, 47);
  end

  //Update PC on the clk
  always @(posedge clk) begin
    
    PC <= PC + 4;
  end

endmodule
