module fu_table
(
  input wire clk,
  input wire rst,
  input wire [2:0] update_in,
  output reg [2:0] table_out
);

  reg [2:0] fu_table;

  initial begin
      //All FUs start ready
      fu_table = 3'b111;
  end

  always @(posedge clk) begin 
    if(rst) begin	
      fu_table <= 3'b111;
    end 
    else begin
    	fu_table <= update_in;
	end
  end
  
  always @(*) begin
    table_out = fu_table; // Continuous assignment for output
  end

endmodule