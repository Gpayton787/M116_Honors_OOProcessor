`include "constants.v"

module lsq #(
    parameter int NUM_ENTRIES = 16,
    parameter int PC_WIDTH = 12,
    parameter int ADDR_WIDTH = 20,
    parameter int DATA_WIDTH = 32
)(
  input wire clk,
  input wire rst,
  input wire wr_en,
  input wire [6:0] opcode,                  
  input wire [11:0] pc,
  input wire [31:0] address_in,     
  input wire [31:0] data_in,          
  // Outputs
  output reg [`LSQ_ENTRY-1:0] curr_entry,
  output reg [31:0] address_out,        // Address for memory access
  output reg [31:0] data_out      // Data for store
);
    // Internal LSQ entries
  reg [1+1+PC_WIDTH+ADDR_WIDTH+DATA_WIDTH] lsq[NUM_ENTRIES];
  reg [$clog2(NUM_ENTRIES):0] head_ptr;
  reg is_load;

  initial begin
    head_ptr = 0;
  end
  
  //Sequential reservation logic
  always @(posedge clk) begin
    if(rst) begin
      head_ptr <= 0;
    end
    else if(wr_en) begin
      //Reserve an entry in the LSQ if we can
      if(head_ptr < NUM_ENTRIES) begin
        lsq[head_ptr] <= {is_load, pc, address_in, data_in};
      	head_ptr <= head_ptr + 1;  
      end
    end
  end
  //Sequential issue logic
  always @(posedge clk) begin
    for(integer i = 0; i < NUM_ENTRIES; i= i+1) begin
      lsq[i]
    end
  end
  
  //Combinational logic
  always @(opcode or head_ptr) begin
    curr_entry = lsq[head_ptr-1];
    case (opcode)
        `LOAD_INSTR:  is_load = 1;
        `STORE_INSTR: is_load = 0;
        default:      is_load = 1'bx; // Undefined behavior 
    endcase
  end
endmodule
