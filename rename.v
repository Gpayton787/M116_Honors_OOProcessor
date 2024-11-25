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
  output reg [PREG_WIDTH-1:0] rd_old_tag_out
);
  
  wire reg_write;
  wire [PREG_WIDTH-1:0] rrd;
  reg [AREG_WIDTH-1:0] rd;
  reg [AREG_WIDTH-1:0] rs1;
  reg [AREG_WIDTH-1:0] rs2;
  reg empty;
  reg full;
  
  assign reg_write = c_sig[`REG_WRITE];
  assign rrd_out = rrd;
  
 
  Areg_file my_areg_file(
    .clk(clk),
    .rst(rst),
    .rd_tag_idx(rd),
    .rs1_tag_idx(rs1),
    .rs2_tag_idx(rs2),
    .reg_write(reg_write),
    .rd_tag(rrd),
    .rs1_tag(rrs1_out),
    .rs2_tag(rrs2_out),
    .rd_old_tag(rd_old_tag_out)
  );
 
  
  
  free_pool my_free_pool(
    .clk(clk),
    .rst(rst),
    .push(push_free_reg),
    .pop(reg_write),
    .data_in(freed_reg),
    .data_out(rrd),
    .empty(empty),
    .full(full)
  );
 
  
  //When input signals change...
  always @(*) begin
    rd = instr_in[11:7];
    rs1 = instr_in[19:15];
    rs2 = instr_in[24:20];
    $display("instr: %h rd: %d, rs1: %d, rs2: %d", instr_in, rd, rs1, rs2);
  end
  
  
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
  
  	//In addition to rst
    initial begin
      for(integer i = 0; i < DEPTH; i = i + 1) begin
            stack[i] <= i + DEPTH;
          end
          stack_ptr <= DEPTH;
          empty <= 0;
          full <= 1;
    end

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


module Areg_file#(
  PREG_WIDTH = 6,
  READY_WIDTH = 1,
  DATA_WIDTH = 32,
  AREG_WIDTH = 5,
  NUM_REG = 32
) 
(
  input wire clk,
  input wire rst,
  input wire [AREG_WIDTH-1:0] rs1_tag_idx,
  input wire [AREG_WIDTH-1:0] rs2_tag_idx,
  input wire [AREG_WIDTH-1:0] rd_tag_idx,
  input wire reg_write,
  input wire [PREG_WIDTH-1:0] rd_tag,
 
  output reg [PREG_WIDTH-1:0] rs1_tag,
  output reg [PREG_WIDTH-1:0] rs2_tag,
  output reg [PREG_WIDTH-1:0] rd_old_tag

);
  //Declare register file memory
  reg [PREG_WIDTH-1:0] mem[0:NUM_REG-1];

  //Initialize the tags
  initial begin 
    for (integer i = 0; i < NUM_REG; i = i+1) begin
      mem[i] = i;
    end
  end
  
//Sequential block for writes
  always @(posedge clk or rst) begin
    if(rst) begin
      for (integer i = 0; i < NUM_REG; i = i+1) begin
        mem[i] <= i;
      end
    end
    
    if(reg_write) begin 
      //Ensure we can't write to x0
      if(rd_tag_idx != 0) begin
        mem[rd_tag_idx] <= rd_tag;
      end
    end
end
  
 
//Combinational block for reads
always @(*) begin
  rd_old_tag = mem[rd_tag_idx];
  rs1_tag = mem[rs1_tag_idx];
  rs2_tag = mem[rs2_tag_idx];
end

endmodule


