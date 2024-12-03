typedef struct {
    logic is_load;         // 1 if load, 0 if store
    logic [11:0] pc;  // pc
    logic [31:0] address;  // Memory address (optional if not calculated yet)
    logic [31:0] data;     // Store data
} lsq_entry_t;

module LSQ #(
    parameter int NUM_ENTRIES = 16,
    parameter int PC_WIDTH = 12,
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 3
)(
    input logic clk,
    input logic reset,

    // Entry inputs
    input logic is_load,                    // Load or store
    input logic pc,
    input logic [31:0] issue_address,       // Memory address if available
    input logic [31:0] store_data,          // Data
    input logic wr_en,

    //Potential additional inputs
    
    // Outputs
    output logic [31:0] mem_address,        // Address for memory access
    output logic [31:0] mem_data,           // Data for store
);
    // Internal LSQ entries
    lsq_entry_t lsq [NUM_ENTRIES];
    logic [$clog2(NUM_ENTRIES):0] head_ptr;

    initial begin
        head_ptr = 0;
    end

    // Write logic for the LSQ here
    always @(posedge clk) begin
        if(rst) begin
            head_ptr <= 0;
        end
        else if(wr_en) begin
            lsq[head_ptr].is_load <= is_load;
            lsq[head_ptr].pc <= pc;
            lsq[head_ptr].address <= issue_address;
            lsq[head_ptr].data <= store_data;
        end
    end
endmodule