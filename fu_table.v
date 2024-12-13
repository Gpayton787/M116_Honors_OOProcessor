module fu_table
(
  input wire clk,
  input wire rst,
  input wire [2:0] rs_update,
  input wire [2:0] fu_update,
  output reg [2:0] table_out
);
  
  initial begin
      //All FUs start ready
      table_out = 3'b111;
  end

  always @(negedge clk) begin 
    if(rst) begin	
       table_out <= 3'b111;
    end 
    else begin
    	table_out <= rs_update | fu_update;
	end
  end
endmodule