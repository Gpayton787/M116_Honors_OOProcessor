module PCAdder
  (
    input wire [31:0] curr_pc,
    output reg [31:0] new_pc
  );
  	always @(curr_pc)
    begin
        new_pc <= curr_pc + 32'h00000004;
    end
endmodule