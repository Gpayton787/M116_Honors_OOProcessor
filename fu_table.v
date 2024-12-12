module fu_table
(
  input wire clk,
  input wire rst,
  input wire alu0,
  input wire alu1,
  input wire [2:0] update_in,
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
    	table_out <= update_in;
      	table_out[0] <= table_out[0] | alu0;
      	table_out[1] <= table_out[1] | alu1;
	end
  end
endmodule
