`include "rs_constants.v"
`include "rob_constants.v"

module rob#(
    parameter ENTRY_SIZE 
)
(
    input wire [5:0] rd,
    input wire [31:0] pc,
    input wire [5:0] rd_old,
    input wire clk,

  	output reg [`ROB_WIDTH-1:0] rob_out [`ROB_SIZE-1:0],// temp output
  	output reg [5:0] rob_pointer //position of new rob entry
);

reg [`ROB_WIDTH-1:0] rob_lines [`ROB_SIZE-1:0];
reg valid;
reg comp;
reg [5:0] head;
reg [5:0] tail;

initial begin // set head of rob
  	rob_pointer = 0;
    head = 0;
  	tail = 0;
end

  /*
always @(fu_line) begin // set complete bit from functional unit
    rob_lines[fu_line[`RS_ROB]][`ROB_COMP] = 1;
end
*/

  always @(negedge clk) begin // add entry from reservation station
    valid = 1;
    comp = 0;
    if (rs_line[`RS_OP] != 0) begin
    	rob_pointer <= tail + 1;
    	rob_lines[tail] <= {valid, rs_line[`RS_RD], rd_old, pc, comp};
    	rob_out[tail] <= {valid, rs_line[`RS_RD], rd_old, pc, comp};
    	tail <= tail + 1;
    end
    
end

always @(posedge clk) begin // retire
    while (rob_lines[head][`ROB_VALID] == 1 && rob_lines[head][`ROB_COMP] == 1) begin
      	rob_lines[head][`ROB_VALID] <= 0;
        head = head + 1;
    end
end

endmodule