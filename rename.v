`include "constants.v"

module rename#(
  C_SIG_WIDTH = 7,
  PREG_WIDTH = 6,
  AREG_WIDTH = 5
  
)
(
  input wire clk,
  input wire rst,
  input wire push_free_reg,
  input wire [PREG_WIDTH-1:0] freed_reg,
  input wire [C_SIG_WIDTH-1:0] c_sig,
  input wire [31:0] instr_in,
  output reg [PREG_WIDTH-1:0] rrd_out,
  output reg [PREG_WIDTH-1:0] rrs1_out,
  output reg [PREG_WIDTH-1:0] rrs2_out,
  output reg [PREG_WIDTH-1:0] old_rd_out
);
  
  wire reg_write;
  reg [AREG_WIDTH-1:0] rd;
  reg [AREG_WIDTH-1:0] rs1;
  reg [AREG_WIDTH-1:0] rs2;
  reg empty;
  reg full;
  
  assign reg_write = c_sig[`REG_WRITE];
  
  free_pool my_free_pool(
    .clk(clk),
    .rst(rst),
    .push(push_free_reg),
    .pop(reg_write),
    .data_in(freed_reg),
    .data_out(rrd_out),
    .empty(empty),
    .full(full)
  );
  
  //When a new instruction comes in, set regs
  always @(instr_in) begin
    rd = instr_in[11:7];
    rs1 = instr_in[19:15];
    rs2 = instr_in[24:20];
    $display("instr: %h rd: %d, rs1: %d, rs2: %d", instr_in, rd, rs1, rs2);
  end
    
 
  
  /*
  Areg_file my_areg_file(
    .rs1_read_tag(rs1),
    .rs2_read_tag(rs2),
    .old_rd_tag(old_rd_out)
  );
  */
  
  
endmodule

// FREE POOL MUST BE INITIALIZED WITH RESET
module free_pool #(parameter WIDTH = 6, parameter DEPTH = 32)(
    input wire              clk,
    input wire              rst,
    input wire              push,
    input wire              pop,
    input wire [WIDTH-1:0]  data_in,
    output reg [WIDTH-1:0]  data_out,
    output reg              empty,
    output reg              full
);

    reg [WIDTH-1:0]        stack [0:DEPTH-1];
    reg [$clog2(DEPTH):0]  stack_ptr;

    always @(posedge clk or posedge rst) begin
      if (rst) begin
        //Initialize free pool to full 
        for(integer i = 0; i < DEPTH; i = i + 1) begin
          stack[i] <= i + DEPTH;
      	end
        stack_ptr <= DEPTH;
        empty <= 0;
        full <= 1;

      end else begin
        if(push && pop) begin
          
          stack[stack_ptr-1] <= data_in;
          
        end else if (push && !full) begin
          stack[stack_ptr] <= data_in;
          stack_ptr        <= stack_ptr + 1;
          empty            <= 0;

          if (stack_ptr == DEPTH - 1) begin
            full <= 1;
          end

        end else if (pop && !empty) begin
          stack_ptr <= stack_ptr - 1;
          full      <= 0;

          if (stack_ptr == 1) begin
            empty <= 1;
          end
        end
      end
    end

    always @(*) begin
      if (!empty & pop)
        data_out = stack[stack_ptr - 1];
      else
        data_out = {WIDTH{1'b0}};
    end
endmodule

/*
module Areg_file#(
  PREG_WIDTH = 6,
  AREG_WIDTH = 5
  
) 
(
  input wire [AREG_WIDTH-1:0] rs1_tag_idx,
  input wire [AREG_WIDTH-1:0] rs2_tag_idx,
  input wire [AREG_WIDTH-1:0] rd_tag_idx,
 
  output reg [PREG_WIDTH-1:0] rs1_tag,
  output reg [PREG_WIDTH-1:0] rs2_tag,
  output reg [PREG_WIDTH-1:0] rd_old_tag,

);
  
  
endmodule
*/


