module PC
(
    input wire [31:0] pc_next,
    input wire reset, clk, pc_write,
    output reg [31:0] pc_current
);
  	initial begin
        pc_current <= 32'h00000000;
    end
    always @(posedge clk)
    begin
        if (reset == 1)
        begin
            pc_current <= 32'h00000000;
        end 
        else
        begin
            if (pc_write == 1)
            begin
                pc_current <= pc_next;
            end
        end
    end
endmodule