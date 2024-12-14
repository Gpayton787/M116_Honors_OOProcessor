/* Notes
Free pool should be initialized with reset, although there is a initial begin block
*/

module free_pool #(parameter WIDTH = 6, parameter DEPTH = 32)(
    input wire              clk,
    input wire              rst,
    input wire              push,
    input wire              pop,
    input wire [WIDTH-1:0]  data_in,
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

    always @(posedge clk or posedge rst) begin
      if (rst) begin
        //Initialize free pool to full 
        for(integer i = 0; i < DEPTH; i = i + 1) begin
          stack[i] <= i + DEPTH;
      	end
        stack_ptr <= DEPTH;
        empty <= 0;
        full <= 1;

      end else begin
        if(push && pop) begin
          
          stack[stack_ptr-1] <= data_in;
          
        end else if (push && !full) begin
          stack[stack_ptr] <= data_in;
          stack_ptr        <= stack_ptr + 1;
          empty            <= 0;

          if (stack_ptr == DEPTH - 1) begin
            full <= 1;
          end

        end else if (pop && !empty) begin
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


