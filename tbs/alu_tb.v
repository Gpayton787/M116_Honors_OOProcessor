// Code your testbench here
// or browse Examples
//Free pool testbench
`define ADD 3'b000
`define SHIFT_LEFT 3'b001
`define SHIFT_RIGHT 3'b010
`define XOR 3'b011
`define OR 3'b100
`define AND 3'b101

module tb;
  
  reg clk, rst;
  reg [31:0] tb_arg1;
  reg [31:0] tb_arg2;
  reg [2:0] tb_alu_op;
  wire [31:0] tb_result;
  
   alu my_alu(
     .arg1(tb_arg1),
     .arg2(tb_arg2),
     .aluop(tb_alu_op),
     .clk(clk),
     .rst(rst),
     .result(tb_result)
  );
 
  //Generate clock
  initial begin 
    clk = 0;
    forever #5 clk = ~clk; //10 ns clock period
  end
  
  //Test sequence
  initial begin
    // Reset sequence
    rst = 1;
    tb_arg1 = 0;
    tb_arg2 = 0;
    tb_alu_op = 3'b000;
    #10; // Wait for reset
    rst = 0;

    // Test case 1: ADD operation
    tb_arg1 = 5;
    tb_arg2 = 2;
    tb_alu_op = `ADD;
    #10; // Wait for a clock edge
    $display("Expected: 5+2=7 Result: 5+2= %0d", tb_result);
    tb_arg1 = 0;
    tb_arg2 = 1;
    tb_alu_op = `SHIFT_LEFT;
    #10;
    $display("Expected: 1<<12=4096 Result: 1<<12= %0d", tb_result);
    tb_arg1 = 4;
    tb_arg2 = 1;
    tb_alu_op = `SHIFT_RIGHT;
    #10;
    $display("Expected: 4>>1=2 Result: 4>>1= %0d", tb_result);
    tb_arg1 = 4'b1010;
    tb_arg2 = 4'b1001;
    tb_alu_op = `XOR;
    #10;
    $display("Expected: 1010^1001=11 Result: 1010^1001= %0b", tb_result);
    tb_arg1 = 4'b1100;
    tb_arg2 = 4'b0011;
    tb_alu_op = `OR;
    #10;
    $display("Expected: 1100 | 0011=1111 Result: 1100 | 0011 = %0b", tb_result);
    tb_arg1 = 4'b1010;
    tb_arg2 = 4'b1001;
    tb_alu_op = `AND;
    #10;
    $display("Expected: 1010&1001=1000 Result: 1010&1001= %0b", tb_result);
    
    $finish;
  end 
endmodule
