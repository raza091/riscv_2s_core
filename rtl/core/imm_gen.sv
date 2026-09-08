module imm_gen
  import riscv_pkg::*;
(
  input  logic [XLEN-1:0] instr_i,
  output logic [XLEN-1:0] imm_o
);

  logic [OPCODE_W-1:0] opcode;
  assign opcode = instr_i[6:0];

  always_comb begin
    unique case (opcode)
      OPCODE_OP_IMM,  // I-type (ADDI, SLTI, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
      OPCODE_LOAD,    // I-type (LB, LH, LW, LBU, LHU)
      OPCODE_JALR:    // I-type
        imm_o = {{20{instr_i[31]}}, instr_i[31:20]};

      OPCODE_STORE:   // S-type
        imm_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};

      OPCODE_BRANCH:  // B-type
        imm_o = {{19{instr_i[31]}}, instr_i[31], instr_i[7],
                 instr_i[30:25], instr_i[11:8], 1'b0};

      OPCODE_LUI,     // U-type
      OPCODE_AUIPC:
        imm_o = {instr_i[31:12], 12'b0};

      OPCODE_JAL:     // J-type
        imm_o = {{11{instr_i[31]}}, instr_i[31], instr_i[19:12],
                 instr_i[20], instr_i[30:21], 1'b0};

      default:
        imm_o = '0;
    endcase
  end

endmodule