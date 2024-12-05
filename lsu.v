module lsu#()
(
    input wire clk,
    input wire rst,
    input wire en,
    input wire [`ADDR_WIDTH-1 : 0] address_in,
    input wire ls, //1 for load, 0 for store
    input wire data_in,
    input wire pc_in

    //From memory
    input wire [31:0] ret_data,
    input wire mem_done,

    //To memory
    output reg [31:0] data_out, //Data to be written
    output reg [`ADDR_WIDTH-1:0] address_out,
    output reg mem_wr,
    output reg mem_re

    //LSU outputs
    output reg pc_out;
    output reg load_data;
);
    reg mem_ready; //1 if memory not in use

    initial begin
        mem_ready = 1;
    end

    always @(posedge clk) begin
        if(rst) begin
            mem_ready<=1; 
            pc_out <= 0;        // Default value for pc_out
            load_data <= 0;     // Default value for load_data
            mem_wr <= 0;        // Default value for mem_wr
            mem_re <= 0;        // Default value for mem_re
            data_out <= 0;      // Default value for data_out
        end     

        else if(en && mem_ready) begin
            address_out<=address_in;
            mem_wr <= ls ? 0 : 1;
            mem_re <= ls? 1 : 0;
            data_out <= !ls ? data_in : 32'b0;
            //Set memory as in use
            mem_ready <= 0;
        end     

        else if(mem_done) begin
            pc_out <= pc_in;
            load_data <= ls ? ret_data : 'bx;
            //Set memory as ready again
            mem_ready <= 1;
        end    
    end



endmodule