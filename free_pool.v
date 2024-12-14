// Code your design here
module free_pool #(parameter WIDTH = 6, parameter DEPTH = 32)(
    input wire              clk,
    input wire              rst,
    input wire              push1,
  	input wire 				push2,
    input wire              pop,
  	input wire [WIDTH-1:0]  data_in1,
  	input wire [WIDTH-1:0]  data_in2,
    output reg [WIDTH-1:0]  data_out,
    output reg              empty,
    output reg              full
);

    reg [WIDTH-1:0]        stack [0:DEPTH-1];
    reg [$clog2(DEPTH):0]  stack_ptr;
  
  	//In addition to rst
    initial begin
      for(integer i = 0; i < DEPTH; i = i + 1) begin
            stack[i] <= i + DEPTH;
          end
          stack_ptr <= DEPTH;
          empty <= 0;
          full <= 1;
    end
  
  always @(negedge clk) begin
    if (push1 && push2 && stack_ptr < DEPTH-1) begin
        //$display("PUSH2, stackptr: %d", stack_ptr);
        stack[stack_ptr] <= data_in1;
        stack[stack_ptr+1] <= data_in2;
        stack_ptr        <= stack_ptr + 2;
        empty            <= 0;

          if (stack_ptr == DEPTH - 1) begin
            full <= 1;
          end
      end else if (push1 && !full) begin
        //$display("PUSH1");
        stack[stack_ptr] <= data_in1;
        stack_ptr        <= stack_ptr + 1;
        empty            <= 0;

        if (stack_ptr == DEPTH - 1) begin
          full <= 1;
        end
      end
    end

    always @(posedge clk or posedge rst) begin
      /*
      for(integer i = 0; i < DEPTH; i = i + 1) begin
        $display("Stack at i: %d", stack[i]);
      end
      $display("Ptr at %d", stack_ptr);
      */
      if (rst) begin
        //Initialize free pool to full 
        for(integer i = 0; i < DEPTH; i = i + 1) begin
          stack[i] <= i + DEPTH;
      	end
        stack_ptr <= DEPTH;
        empty <= 0;
        full <= 1;
      end else begin
        if (pop && !empty) begin
          stack_ptr <= stack_ptr - 1;
          full      <= 0;

          if (stack_ptr == 1) begin
            empty <= 1;
          end
        end
      end
    end

    always @(*) begin
      if (!empty & pop)
        data_out = stack[stack_ptr - 1];
      else
        data_out = {WIDTH{1'b0}};
    end
endmodule