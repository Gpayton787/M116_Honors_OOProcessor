`include "constants.v"
`include "lsq_constants.v"
`include "rs_constants.v"

module lsq #(
    parameter int DEPTH = 16
)(
  input wire clk,
  input wire rst,
  input wire wr_en,
  input wire [6:0] opcode,                  
  input wire [11:0] pc,
  input wire mem_valid,
  input wire [31:0] mem_res,
  input [`RS_WIDTH-1:0] mem_info,
 
  output reg [`BUS_WIDTH-1:0] bus2
);
  reg mem_en;
  reg mem_re;
  reg mem_wr;
  reg [19:0] addr;
  reg [31:0] data_in;
  reg is_byte;
  wire [31:0] data_out;
  wire mem_done;
  wire busy;
  
  //Instantiate memory
  
  single_port_mem my_mem(
    .clk(clk),
    .rst(rst),
    .en(mem_en),
    .mem_re(mem_re),
    .mem_wr(mem_wr),
    .address(addr),
    .data_in(data_in),
    .data_out(data_out),
    .mem_done(mem_done),
    .busy(busy),
    .is_byte(is_byte)
  );
  
  
  
    // Internal LSQ entries
  reg [`LSQ_ENTRY-1:0] lsq[DEPTH-1:0];
  reg [`RS_WIDTH:0] lsq_info[DEPTH-1:0];
  reg [3:0] head_ptr;
  reg [3:0] next_ptr;
  wire [6:0] head_lsq_byte;
  assign head_lsq_byte = lsq_info[head_ptr][`RS_C_SIGS];
  
  wire is_load;
  assign is_load = (opcode == `LOAD_INSTR ? 1 : 0);
    
  initial begin 
    head_ptr = 0;
    next_ptr = 0;
  end

  //UPDATE LSQ WITH RESULTS FROM FU
  always@(negedge clk) begin
    if(mem_valid) begin
      for (integer i = head_ptr; i != next_ptr; i = i+1) begin
        if(lsq[i][`LSQ_PC] == mem_info[`RS_PC]) begin
          //If a load
          if(lsq[i][`LSQ_ISLOAD]) begin
            lsq[i][`LSQ_ADDR] <= mem_res;
            lsq[i][`LSQ_READY] <= 1;
            //Also store instr info
            lsq_info[i] <= mem_info;
            //Also check if you can forward
            for (integer j = head_ptr; j < i; j = j+1) begin
              //If its a store and this is our address, forward & set bypass bit
              if(!lsq[j][`LSQ_ISLOAD] && lsq[j][`LSQ_ADDR] == mem_res) begin
                lsq[i][`LSQ_DATA] <= lsq[j][`LSQ_DATA];
                lsq[i][`LSQ_READY] <= 1;
                lsq[i][`LSQ_BYPASS] <= 1;
              end
            end
          end
          //Otherwise its a store, add address and data and forward
          else begin 
            lsq[i][`LSQ_ADDR] <= mem_res;
            lsq[i][`LSQ_DATA] <= mem_info[`RS_DATA2];
            lsq[i][`LSQ_READY] <= 1;
            //Also store instr info
            lsq_info[i] <= mem_info;
          end
        end
      end
    end
  end
  
  
  //Sequential logic
  always @(posedge clk) begin
    //PRINT LSQ
    for (integer i = head_ptr; i != next_ptr; i = i+1) begin
      $display("LSQ | is_load: %b, is_ready: %b, bypass: %b, pc: %h, addr: %0d, data: %0d", lsq[i][`LSQ_ISLOAD], lsq[i][`LSQ_READY], lsq[i][`LSQ_BYPASS], lsq[i][`LSQ_PC], lsq[i][`LSQ_ADDR], lsq[i][`LSQ_DATA]);
    end
    
    if(wr_en) begin
      //Reserve an entry in the LSQ if we can
      if(next_ptr < DEPTH) begin
        lsq[next_ptr] <= {is_load, 1'b0,1'b0, pc, 32'b0, 32'b0};
      	next_ptr <= next_ptr + 1;  
      end
    end
  end
  
  //Issuing logic
  always @(posedge clk) begin
        //If memory is ready
    bus2 <= 0;
    if(!busy && !mem_done) begin
      // If head of LSQ is ready to go
      if(lsq[head_ptr][`LSQ_READY]) begin
        $display("ISSUE %b from LSQ", lsq_info[head_ptr][`RS_C_SIGS]);
          //IF LOAD
          if(lsq[head_ptr][`LSQ_ISLOAD]) begin
            mem_en <= 1;
            mem_re <= 1;
            mem_wr <= 0;
            addr <= lsq[head_ptr][`LSQ_ADDR];
            is_byte <= head_lsq_byte[`BYTE];
          end
          //ELSE STORE
          else begin
            mem_en <= 1;
            mem_re <= 0;
            mem_wr <= 1;
            addr <= lsq[head_ptr][`LSQ_ADDR];
            data_in <= lsq[head_ptr][`LSQ_DATA];
            is_byte <= head_lsq_byte[`BYTE];
          end
      end
    //Otherwise we're waiting for an instruction to finish
    end else begin
      //Ensure we don't issue same instruction once it finishes
      mem_en<=0;
      
      //Once instruction finsihes
      if(mem_done) begin
        //Write it back
        if(lsq[head_ptr][`LSQ_ISLOAD]) begin
          $display("MEM COMPLETED LOAD: %d", data_out);
          bus2<={1'b1, lsq_info[head_ptr][`RS_PC], data_out, lsq_info[head_ptr][`RS_RD], lsq_info[head_ptr][`RS_ROB]};
        end else begin
          $display("MEM COMPLETED STORE");
          bus2<={1'b1, lsq_info[head_ptr][`RS_PC], 32'b0, lsq_info[head_ptr][`RS_RD], lsq_info[head_ptr][`RS_ROB]};
        end
        
        //Then we can move the head
        head_ptr <= head_ptr+1;        
      end
    end

  end
endmodule

// Code your design here
// Code your design here
module single_port_mem #(
    parameter LATENCY = 3,
    parameter ADDR_WIDTH = 20
)
(
    input clk,
    input rst,
    input en,
    input mem_re,
    input mem_wr,
  	input is_byte,
    input wire [ADDR_WIDTH-1 : 0] address,
    input wire [31: 0] data_in,
    output reg [31: 0] data_out,
  	output reg busy,
    output reg mem_done
);

    //Byte Addressable Main Memory, 1MB
    reg [7:0] mem[0:2**ADDR_WIDTH-1];
    reg [3:0] counter; //Tracks 10 cycles
  	reg pending_mem_wr;
    reg [ADDR_WIDTH-1:0] pending_address; // Address in process
    reg [31:0] pending_data;    // Data to write during a write operation
  	reg pending_is_byte;
  
  	initial begin
      counter <= 0;
      busy <= 0;
      mem_done <= 0;
      data_out <= 0;
    end

    always @(posedge clk or posedge rst) begin
      
      //$display("busy: %b, counter: %d, pending_address: %0h, pending_data: %0d", busy, counter, pending_address, pending_data);
      
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
                  	
                  	pending_is_byte <= is_byte;
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
                  if(pending_is_byte) begin
                    mem[pending_address] <= pending_data[7:0];
                  end
                  else begin
                    mem[pending_address+3] <= pending_data[31:24];
                    mem[pending_address+2] <= pending_data[23:16];
                    mem[pending_address+1] <= pending_data[15:8];
                    mem[pending_address] <= pending_data[7:0];
                  end
                end
                else begin
                  if(pending_is_byte) begin
                    data_out <= {{24{mem[pending_address][7]}}, mem[pending_address]};
                    $display("set data out to: %b",
                             {{24{mem[pending_address][7]}}, mem[pending_address]} );
                  end else begin
                    data_out <=
                    {mem[pending_address+3],
                     mem[pending_address+2],
                     mem[pending_address+1], 
                     mem[pending_address]};
                    $display("set data out to: %b", {mem[pending_address+3],
                     mem[pending_address+2],
                     mem[pending_address+1], 
                     mem[pending_address]});
                  end
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