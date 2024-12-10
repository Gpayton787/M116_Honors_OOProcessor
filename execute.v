module alu1
(
    input wire [`RS_WIDTH-1:0] rs_in;
);

reg [6:0] opcode;
reg [2:0] funct3;
reg [31:0] out;

always @(rs_in) begin
    opcode = rs_in[`RS_OP];
    funct3 = rs_in[`RS_FUNCT3];

    case (opcode)
        7'b0110011 : begin
            if (funct3 == 3'b000) begin // add
                out = rs_in[`RS_DATA1] + rs_in[`RS_DATA2];
            end
            else if (funct3 == 3'b100) begin // xor
                out = rs_in[`RS_DATA1] ^ rs_in[`RS_DATA2];
            end
        end; 
        7'b0010011 : begin 
            if (funct3 == 3'b000) begin // addi
                out = rs_in[`RS_DATA1] + rs_in[`RS_IMM];
            end
            else if (funct3 == 3'b110) begin // ori
                out = rs_in[`RS_DATA1] | rs_in[`RS_IMM];
            end
            else if (funct3 == 3'b101) begin // srai
                out = rs_in[`RS_DATA1] >>> rs_in[`RS_IMM];
            end
        end;
        7'b0110111 : out = rs_in[`RS_IMM] << 12; //lui
    endcase
end

endmodule

module alu2
(

);
endmodule

module memory
(

);
endmodule
