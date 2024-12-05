module single_port_mem #(
    parameter READ_LATENCY = 10,
    parameter WRITE_LATENCY = 10,
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 20
)
(
    input clk,
    input rst,
    input cs,
    input mem_re,
    input mem_wr,
    input wire [ADDR_WIDTH-1 : 0] address,
    inout wire [DATA_WIDTH-1 : 0] data
);

    //Byte Addressable Main Memory, 1MB
    reg [DATA_WIDTH-1:0] mem[0:2**ADDR_WIDTH-1];
    reg [DATA_WIDTH-1:0] temp_data;

    always @(posedge clk) begin
        if(cs & mem_wr) begin
          mem[address] <= data;
        end
    end

    always @(posedge clk) begin
        if(cs & !mem_wr) begin
            temp_data <= mem[address];
        end
    end

    assign data = cs & mem_re & !mem_wr ? temp_data : 'hz;
endmodule