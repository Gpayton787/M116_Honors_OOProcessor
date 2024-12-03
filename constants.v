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

