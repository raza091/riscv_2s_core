module decoder
  import riscv_pkg::*;
(
  input  logic [XLEN-1:0] instr_i,

  // Decoded fields
  output logic [REG_ADDR_W-1:0] rs1_o,
  output logic [REG_ADDR_W-1:0] rs2_o,
  output logic [REG_ADDR_W-1:0] rd_o,
  output logic [FUNCT3_W-1:0]   funct3_o,
  output logic [FUNCT7_W-1:0]   funct7_o,
  output opcode_e               opcode_o
);

  assign opcode_o  = opcode_e'(instr_i[6:0]);
  assign rd_o      = instr_i[11:7];
  assign funct3_o  = instr_i[14:12];
  assign rs1_o     = instr_i[19:15];
  assign rs2_o     = instr_i[24:20];
  assign funct7_o  = instr_i[31:25];

endmodule