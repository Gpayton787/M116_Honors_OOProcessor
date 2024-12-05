`define REG_WRITE 6
`define ALU_SRC 5
`define BRANCH 4
`define MEMRE 3
`define MEMWR 2
`define MEM_TO_REG 1
`define BYTE 0

`define RS_WIDTH 132
`define RS_ROB 5:0
`define RS_FU 7:6
`define RS_IMM 39:8
`define RS_RDY2 40:40
`define RS_DATA2 72:41
`define RS_SRC2 78:73
`define RS_RDY1 79:79
`define RS_DATA1 111:80
`define RS_SRC1 117:112
`define RS_RD 123:118
`define RS_OP 130:124
`define RS_USE 131:131

`define LSQ_DATA 31:0
`define LSQ_ADDR 63:32
`define LSQ_PC 75:64
`define LSQ_IS_LOAD 76
`define LSQ_ENTRY 77

`define OPCODE 6:0

//INSTRUCTION OPCODES
`define RTYPE_INSTR 7'b0110011
`define ITYPE_INSTR 7'b0010011
`define LOAD_INSTR 7'b0000011
`define STORE_INSTR 7'b0100011
`define LUI_INSTR 7'b0110111

//FUNCT3S
`define F3_BYTE 3'b000
`define F3_WORD 3'b010
`define F3_ADD 3'b000
`define F3_OR 3'b110
`define F3_XOR 3'b100
`define F3_SHIFT 3'b101
`define F3_AND 3'b111

//SIGNALS
`define RTYPE_SIG 7'b1000000
`define ITYPE_SIG 7'b1100000
`define LB_SIG 7'b1101011
`define SB_SIG 7'b0100101
`define LW_SIG 7'b1101010
`define SW_SIG 7'b0100100

//ALUOP_SIGS
`define ADD 3'b000
`define SHIFT_LEFT 3'b001
`define SHIFT_RIGHT 3'b010
`define XOR 3'b011
`define OR 3'b100
`define AND 3'b101


`define LSQ_DATA 31:0
`define LSQ_ADDR 63:32
`define LSQ_PC 75:64
`define LSQ_IS_LOAD 76
`define LSQ_ENTRY 77


//MISC
`define INSTR_WIDTH 32
`define DATA_WIDTH 32
`define ADDR_WIDTH 20
