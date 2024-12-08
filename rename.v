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
  //PLEASE NOTE THAT THIS REG_WRITE CORRESPONDS TO RENAMING RD NOT WRITING DATA
  input wire reg_write,
  input wire [PREG_WIDTH-1:0] rd_tag,
 
  output reg [DATA_WIDTH-1:0] rs1_data,
  output reg [DATA_WIDTH-1:0] rs2_data,
  output reg [PREG_WIDTH-1:0] rs1_tag,
  output reg [PREG_WIDTH-1:0] rs2_tag,
  output reg rs1_ready,
  output reg rs2_ready,
  output reg [PREG_WIDTH-1:0] rd_old_tag

);
  //Declare register file memory
  
  //READY BITS
  reg ready_mem[0:NUM_REG-1];
  
  //TAGS
  reg [PREG_WIDTH-1:0] tag_mem[0:NUM_REG-1];
  
  //DATA
  reg [DATA_WIDTH-1:0] data_mem[0:NUM_REG-1];

  //Initialize memory
  initial begin 
    //INIT READY to all 1's
    for (integer i = 0; i < NUM_REG; i = i+1) begin
      ready_mem[i] = 1;
    end
    //INIT TAGS to one-to-one mapping
    for (integer i = 0; i < NUM_REG; i = i+1) begin
      tag_mem[i] = i;
    end
    
    //INIT DATA TO 0's
    for (integer i = 0; i < NUM_REG; i = i+1) begin
      data_mem[i] = 0;
    end
  end
  
//Sequential block for writes
  always @(posedge clk or rst) begin
    if(rst) begin
      for (integer i = 0; i < NUM_REG; i = i+1) begin
        tag_mem[i] <= i;
      end
    end
    
    if(reg_write) begin 
      //Ensure we can't write to x0
      if(rd_tag_idx != 0) begin
        tag_mem[rd_tag_idx] <= rd_tag;
        ready_mem[rd_tag_idx] <= 0;
      end
    end
end
  
 
//Combinational block for reads
always @(*) begin
  rd_old_tag = tag_mem[rd_tag_idx];
  rs1_tag = tag_mem[rs1_tag_idx];
  rs2_tag = tag_mem[rs2_tag_idx];
  rs1_data = data_mem[rs1_tag_idx];
  rs2_data = data_mem[rs2_tag_idx];
  rs1_ready = ready_mem[rs1_tag_idx];
  rs2_ready = ready_mem[rs2_tag_idx];
end

endmodule


module rs
(
  input wire [31:0] instr,
  input wire [31:0] imm,
  input wire [5:0] rd,
  input wire [5:0] rd_old,
  input wire [5:0] src1,
  input wire [31:0] data1,
  input wire ready1,
  input wire [5:0] src2,
  input wire [31:0] data2,
  input wire ready2,
  input wire clk,
  input wire [2:0] fu_in,

  output reg rob,
  output reg [2:0] fu_out,
  output reg [`RS_WIDTH-1:0] rs_out1,
  output reg [`RS_WIDTH-1:0] rs_out2,
  output reg [`RS_WIDTH-1:0] rs_out3,
  output reg [2:0] rdy_out,
  
  output reg [`RS_WIDTH-1:0] rs_lines [`RS_SIZE-1:0], //temp output
  output reg [`RS_WIDTH-1:0] rob_out // dispatch to rob
);

  reg [`RS_WIDTH-1:0] lines [`RS_SIZE-1:0];
  reg [5:0] rob_pointer; //circular rob
  reg [5:0] rs_pointer; //circular reservation station
  reg next_alu; //switches between first two alu

  reg usec;
  reg [6:0] opcode;
  reg [2:0] funct3;
  reg [1:0] fu_pos;
  reg [2:0] fu_update;

initial begin
  	rdy_out = 3'b000; // no instructions ready to issue
    rob_pointer = 0;
    rs_pointer = 0;
    next_alu = 2'b00;
    fu_update = 3'b111; // all fu start out ready
end

always @(posedge clk) //issue
begin
  rdy_out = 3'b000;
  for (integer i = 0; i < 8; i = i+1) begin
    if (lines[i][`RS_WIDTH-1] == 1 && lines[i][`RS_RDY1] == 1 && lines[i][`RS_RDY2] == 1 && fu_in[lines[i][`RS_FU]] == 1) // check fu ready and src reg ready
     	begin
          fu_update[lines[i][`RS_FU]] = 0;
          if (rdy_out[0] == 0) begin
            rs_out1 = lines[i];
            rdy_out[0] = 1;
          end
          else if (rdy_out[1] == 0) begin
            rs_out2 = lines[i];
            rdy_out[1] = 1;
          end
          else if (rdy_out[2] == 0) begin
            rs_out3 = lines[i];
            rdy_out[2] = 1;
          end
          lines[i][`RS_USE] = 0;
        end
    end
    fu_out = fu_update;
end

always @(posedge clk) //dispatch
begin
    usec = 1;
    opcode = instr[6:0];
  	funct3 = instr[14:12];

    case (opcode)
        7'b0000011 : fu_pos = 2'b10; //lb, lw
        7'b0100011 : fu_pos = 2'b10; //sb, sw
        default : begin
            fu_pos = next_alu;
            next_alu = !next_alu;
        end
    endcase
  
	rob = rob_pointer;
  
  	if (opcode != 0) begin
      lines[rs_pointer] = {usec, funct3, opcode, rd, rd_old, src1, data1, ready1, src2, data2, ready2, imm, fu_pos, rob_pointer};
      rob_out = lines[rs_pointer];
      for (integer i = 0; i < 64; i = i+1) begin
      	rs_lines[i] = lines[i];
      end	
  
  	  rob_pointer = rob_pointer + 1;
      rs_pointer = rs_pointer + 1;
  	end
    
end
  
always @(fu_in)
begin
    fu_update = fu_in;
end
  
endmodule


module fu
(
  input wire [2:0] ready_in,

  output reg [2:0] ready_out
);
reg [2:0] fu_ready;

initial begin
    for (integer i = 0; i < 3; i = i+1) begin
      fu_ready[i] = 1;
    end
    ready_out = fu_ready;
end

always @(ready_in)
begin
    fu_ready = ready_in;
  	ready_out = fu_ready;
end

endmodule

