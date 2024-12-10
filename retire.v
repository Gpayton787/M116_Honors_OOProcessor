`include "constants.v"

module rob
(
    input wire [`RS_WIDTH-1:0] rs_line, // instruction from reservation station
    input wire [31:0] pc,
    input wire clk,

    //input wire [`RS_WIDTH-1:0] fu_line // instruction from functional unit
  	output reg [`ROB_WIDTH-1:0] rob_out [`ROB_SIZE-1:0]// temp output
);

reg [`ROB_WIDTH-1:0] rob_lines [`ROB_SIZE-1:0];
reg valid;
reg comp;
reg [3:0] head;

initial begin // set head of rob
    head = 0;
end

  /*
always @(fu_line) begin // set complete bit from functional unit
    rob_lines[fu_line[`RS_ROB]][`ROB_COMP] = 1;
end
*/

always @(rs_line) begin // add entry from reservation station
    valid = 1;
    comp = 0;
    rob_lines[rs_line[`RS_ROB]] = {valid, rs_line[`RS_RD], rs_line[`RS_OLD], pc, comp};
  for (integer i = 0; i < `ROB_SIZE; i = i+1) begin
    rob_out[i] = rob_lines[i];
  end
end

always @(posedge clk) begin // retire
    while (rob_lines[head][`ROB_VALID] == 1 && rob_lines[head][`ROB_COMP] == 1) begin
        rob_lines[head][`ROB_VALID] = 0;
        head = head + 1;
    end
end

endmodule
