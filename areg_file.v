module areg_file#(
  parameter PREG_WIDTH = 6,
  DATA_WIDTH = 32,
  AREG_WIDTH = 5,
  NUM_AREG = 32,
  NUM_PREG = 64
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
  output reg [PREG_WIDTH-1:0] rd_old_tag,
  output reg rs1_ready,
  output reg rs2_ready

);
  //Declare register file memory
  
  //READY BITS
  reg ready_mem[0:NUM_PREG-1];
  
  //TAGS
  reg [PREG_WIDTH-1:0] tag_mem[0:NUM_AREG-1];
  
  //DATA
  reg [DATA_WIDTH-1:0] data_mem[0:NUM_AREG-1];

  //Initialize memory
  initial begin 
    //INIT READY to all 1's
    for (integer i = 0; i < NUM_PREG; i = i+1) begin
      ready_mem[i] = 1;
    end
    //INIT TAGS to one-to-one mapping
    for (integer i = 0; i < NUM_AREG; i = i+1) begin
      tag_mem[i] = i;
    end
    
    //INIT DATA TO 0's
    for (integer i = 0; i < NUM_AREG; i = i+1) begin
      data_mem[i] = 0;
    end
  end
  
//Sequential block for writes
  always @(posedge clk or rst) begin
    if(rst) begin
      for (integer i = 0; i < NUM_AREG; i = i+1) begin
        tag_mem[i] <= i;
      end
    end
    
    if(reg_write) begin 
      //Ensure we can't write to x0
      if(rd_tag_idx != 0) begin
        tag_mem[rd_tag_idx] <= rd_tag;
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