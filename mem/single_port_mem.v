// Code your design here
module single_port_mem #(
    parameter LATENCY = 10,
    parameter ADDR_WIDTH = 20
)
(
    input clk,
    input rst,
    input en,
    input mem_re,
    input mem_wr,
    input wire [ADDR_WIDTH-1 : 0] address,
    input wire [31: 0] data_in,
    output reg [31: 0] data_out,
    output reg mem_done
);

    //Byte Addressable Main Memory, 1MB
    reg [7:0] mem[0:2**ADDR_WIDTH-1];
    reg [3:0] counter; //Tracks 10 cycles
    reg busy;
  	reg pending_mem_wr;
    reg [ADDR_WIDTH-1:0] pending_address; // Address in process
    reg [31:0] pending_data;    // Data to write during a write operation
  
  	initial begin
      counter <= 0;
      busy <= 0;
      mem_done <= 0;
      data_out <= 0;
    end

    always @(posedge clk or posedge rst) begin
      
      //$display("busy: %b, counter: %d, pending_address: %0h, pending_data: %0h", busy, counter, pending_address, pending_data);
      
        if(rst) begin
            counter <= 0;
            busy <= 0;
            mem_done <= 0;
            data_out <= 0;
        end else begin
            //If we're not busy and we're enabled
          if(!busy && en) begin
                //If we're a read or write
                if(mem_wr || mem_re) begin
                  	pending_mem_wr <= mem_wr;
                    pending_address <= address;
                    if(mem_wr) begin
                        pending_data <= data_in;
                    end
                  	
                    busy <= 1;
                    mem_done <= 0;
                    counter <= LATENCY;
                end

            end
            else if (counter>0) begin
                counter <= counter-1;
            end
            else if (busy && counter == 0) begin
                //If we're working and once the counter has reached 0
              if(pending_mem_wr) begin
                  mem[pending_address] <= pending_data;
                end
                else begin
                  	$display("set data out");
                    data_out <= mem[pending_address];
                end
                busy <= 0;
                mem_done <= 1;
            end
            else begin
              mem_done <= 0;
            end
        end
    end
endmodule