`include "rs_constants.v"
`include "rob_constants.v"

module rob#(
  DEPTH = 64
)
(
  	input wire clk,
  
  	//Write 1 instr per cycle
	input wire [5:0] rd,
  	input wire [5:0] rd_old,
  	input wire [11:0] pc,
  	input wire wr_en,                    // Write enable
  
  	//Writeback
 	input wire [`BUS_WIDTH-1:0] bus0,
  	input wire [`BUS_WIDTH-1:0] bus1,
  	input wire [`BUS_WIDTH-1:0] bus2,
  
  
    output reg [5:0] rob_num,

     //Read, Retire 2 instr per cycle
  	output reg [`RETIRE_WIDTH-1:0] retire0,
  	output reg [`RETIRE_WIDTH-1:0] retire1
  	
);
  reg [`ROB_WIDTH-1:0] rob_lines[DEPTH-1:0];
  
  //HEAD AND TAIL POINTERS
  reg [$clog2(DEPTH):0] head;
  reg [$clog2(DEPTH):0] rob_next;
  reg [$clog2(DEPTH+1):0] count;
  reg empty;
  reg full;
  reg [1:0] retire_valid;

  initial begin // set head of rob
      rob_next = 0;
      rob_num = 0;
      head = 0;
      count = 0;
      full = 0;
      empty = 1;
  end
  
  //Writeback from alu
  always @(negedge clk)
  begin
    //Debug
    if(bus0[`BUS_VALID]) begin
      $display("inside rob... rd: %d, res, %0d %b", bus0[`BUS_RD], bus0[`BUS_RESULT], bus0);
    end
    if(bus1[`BUS_VALID]) begin
      $display("inside rob..., rd: %d, res, %0d %b", bus1[`BUS_RD], bus1[`BUS_RESULT], bus1);
    end
    if(bus2[`BUS_VALID]) begin
      $display("inside rob..., rd: %d, res, %0d %b", bus1[`BUS_RD], bus1[`BUS_RESULT], bus1);
    end
    
    //Iterate over circular buffer
    for (integer i = head; i != rob_next; i = i+1) begin
      if (rob_lines[i][`ROB_RD] == bus0[`BUS_RD] && bus0[`BUS_VALID] == 1)
        begin
          rob_lines[i][`ROB_DATA] <= bus0[`BUS_RESULT];
          rob_lines[i][`ROB_COMP] <= 1;
        end
      if (rob_lines[i][`ROB_RD] == bus1[`BUS_RD] && bus1[`BUS_VALID] == 1)
        begin
          rob_lines[i][`ROB_DATA] <= bus1[`BUS_RESULT];
          rob_lines[i][`ROB_COMP] <= 1;
        end
      if (rob_lines[i][`ROB_RD] == bus2[`BUS_RD] && bus2[`BUS_VALID] == 1)
        begin
          rob_lines[i][`ROB_DATA] <= bus2[`BUS_RESULT];
          rob_lines[i][`ROB_COMP] <= 1;
        end
    end
  end

  always @(posedge clk) begin // add an entry in parallel with RS entry
    
    if (wr_en && !full) begin
      rob_lines[rob_next] <= {1'b1, rd, rd_old, pc, 32'b0, 1'b0};
      
      $display("Reserving ROB entry | rd: %d, rd_old: %d, pc: %h", rd, rd_old, pc);
      
      	rob_next <= rob_next+1;
      	rob_num<= rob_next+1;
    end
  end
 
  always @(posedge clk) begin // Retire 2 instructions
    retire_valid = 2'b11;
    retire0<= 0;
    retire1<= 0;
    $display("ROB count: %d", count);
    
    //DEBUG DISPLAY THE ROB
      for (integer i = head; i != rob_next; i = i+1) begin
      $display("ROB Entry | valid: %b, rd: %d, rd_old: %d, pc: %0h, data: %0d, complete: %b", 
               rob_lines[i][`ROB_VALID], rob_lines[i][`ROB_RD], rob_lines[i][`ROB_OLD], rob_lines[i][`ROB_PC], rob_lines[i][`ROB_DATA], rob_lines[i][`ROB_COMP]);
    end
    
    while (
      	rob_lines[head][`ROB_VALID] == 1 
        && rob_lines[head][`ROB_COMP] == 1 
        && retire_valid != 2'b00
      	//&& !empty
    ) begin
      rob_lines[head][`ROB_VALID] <= 0;
      if(retire_valid[0] == 1'b1) begin
        retire0 <= {1'b1, rob_lines[head][`ROB_OLD], rob_lines[head][`ROB_DATA], rob_lines[head][`ROB_RD]};
        retire_valid[0] = 0;
        //$display("RETIRE 1 | rd: %d, data: %d, old_rd: %d", rob_lines[head][`ROB_RD], rob_lines[head][`ROB_DATA], rob_lines[head][`ROB_OLD]);
        
      end
      else if(retire_valid[1] == 1'b1) begin
        retire1 <= {1'b1, rob_lines[head][`ROB_OLD], rob_lines[head][`ROB_DATA], rob_lines[head][`ROB_RD]};
        retire_valid[1] = 0;
        //$display("RETIRE 2 | rd: %d, data: %d, old_rd: %d", rob_lines[head][`ROB_RD], rob_lines[head][`ROB_DATA], rob_lines[head][`ROB_OLD]);
      end
      head = head+1;
    end
    
    //UPDATE COUNT
    /*
    if(wr_en) begin
      count <= count + 1 - (retire_valid[0] ? 0 : 1) - (retire_valid[1] ? 0 : 1);
      empty <= (count + 1 - (retire_valid[0] ? 0 : 1) - (retire_valid[1] ? 0 : 1) == 0);
      full <= (count + 1 - (retire_valid[0] ? 0 : 1) - (retire_valid[1] ? 0 : 1) == DEPTH-1);
    end else begin
      count <= count-(retire_valid[0] ? 0 : 1) - (retire_valid[1] ? 0 : 1);
      empty <= (count-(retire_valid[0] ? 0 : 1) - (retire_valid[1] ? 0 : 1) == 0);
    end
    */
  end

endmodule