`include "constants.v"

module lsq #(
    parameter int NUM_ENTRIES = 16,
    parameter int PC_WIDTH = 12,
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
)(
  input wire clk,
  input wire rst,

  // Entry inputs
  input wire is_load,                    // Load or store
  input wire [11:0] pc,
  input wire [31:0] issue_address,       // Memory address if available
  input wire [31:0] store_data,          // Data
  input wire wr_en,
  //Potential additional inputs

  // Outputs
  output reg [`LSQ_ENTRY:0] curr_entry,
  output reg [31:0] mem_address,        // Address for memory access
  output reg [31:0] mem_data      // Data for store
);
    // Internal LSQ entries
  reg [1+PC_WIDTH+ADDR_WIDTH+DATA_WIDTH] lsq [NUM_ENTRIES];
  logic [$clog2(NUM_ENTRIES):0] head_ptr;

  initial begin
    head_ptr = 0;
  end
  
  //Sequential logic
  always @(posedge clk) begin
    if(rst) begin
      head_ptr <= 0;
    end
    else if(wr_en) begin
      //Reserve an entry in the LSQ if we can
      if(head_ptr < NUM_ENTRIES) begin
        lsq[head_ptr] <= {is_load, pc, issue_address, store_data};
      	head_ptr <= head_ptr + 1;  
      end
    end
  end
  //Combinational logic
  always @(*) begin
    curr_entry = lsq[head_ptr];
  end
endmodule
