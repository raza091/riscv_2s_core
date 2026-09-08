module control
  import riscv_pkg::*;
(
  input  opcode_e             opcode_i,
  input  logic [FUNCT3_W-1:0] funct3_i,
  input  logic [FUNCT7_W-1:0] funct7_i,

  output ctrl_t               ctrl_o
);

  always_comb begin
    // Default values (safe bubble)
    ctrl_o.reg_write = 1'b0;
    ctrl_o.mem_read  = 1'b0;
    ctrl_o.mem_write = 1'b0;
    ctrl_o.alu_src   = 1'b0;
    ctrl_o.branch    = 1'b0;
    ctrl_o.jump      = 1'b0;
    ctrl_o.lui       = 1'b0;
    ctrl_o.auipc     = 1'b0;
    ctrl_o.alu_op    = ALU_ADD;
    ctrl_o.funct3    = funct3_i;

    unique case (opcode_i)

      OPCODE_LUI: begin
        ctrl_o.reg_write = 1'b1;
        ctrl_o.alu_src   = 1'b1;
        ctrl_o.lui       = 1'b1;
        ctrl_o.alu_op    = ALU_ADD;   // result = imm
      end

      OPCODE_AUIPC: begin
        ctrl_o.reg_write = 1'b1;
        ctrl_o.alu_src   = 1'b1;
        ctrl_o.auipc     = 1'b1;
        ctrl_o.alu_op    = ALU_ADD;
      end

      OPCODE_JAL: begin
        ctrl_o.reg_write = 1'b1;
        ctrl_o.jump      = 1'b1;
      end

      OPCODE_JALR: begin
        ctrl_o.reg_write = 1'b1;
        ctrl_o.alu_src   = 1'b1;
        ctrl_o.jump      = 1'b1;
        ctrl_o.alu_op    = ALU_ADD;
      end

      OPCODE_BRANCH: begin
        ctrl_o.branch    = 1'b1;
        ctrl_o.alu_op    = ALU_SUB;   // for comparison
      end

      OPCODE_LOAD: begin
        ctrl_o.reg_write = 1'b1;
        ctrl_o.mem_read  = 1'b1;
        ctrl_o.alu_src   = 1'b1;
        ctrl_o.alu_op    = ALU_ADD;
      end

      OPCODE_STORE: begin
        ctrl_o.mem_write = 1'b1;
        ctrl_o.alu_src   = 1'b1;
        ctrl_o.alu_op    = ALU_ADD;
      end

      OPCODE_OP_IMM: begin
        ctrl_o.reg_write = 1'b1;
        ctrl_o.alu_src   = 1'b1;

        unique case (funct3_i)
          3'b000: ctrl_o.alu_op = ALU_ADD;   // ADDI
          3'b010: ctrl_o.alu_op = ALU_SLT;   // SLTI
          3'b011: ctrl_o.alu_op = ALU_SLTU;  // SLTIU
          3'b100: ctrl_o.alu_op = ALU_XOR;   // XORI
          3'b110: ctrl_o.alu_op = ALU_OR;    // ORI
          3'b111: ctrl_o.alu_op = ALU_AND;   // ANDI
          3'b001: ctrl_o.alu_op = ALU_SLL;   // SLLI
          3'b101: ctrl_o.alu_op = (funct7_i[5]) ? ALU_SRA : ALU_SRL; // SRAI / SRLI
          default: ctrl_o.alu_op = ALU_ADD;
        endcase
      end

      OPCODE_OP: begin
        ctrl_o.reg_write = 1'b1;

        unique case (funct3_i)
          3'b000: ctrl_o.alu_op = (funct7_i[5]) ? ALU_SUB : ALU_ADD;
          3'b001: ctrl_o.alu_op = ALU_SLL;
          3'b010: ctrl_o.alu_op = ALU_SLT;
          3'b011: ctrl_o.alu_op = ALU_SLTU;
          3'b100: ctrl_o.alu_op = ALU_XOR;
          3'b101: ctrl_o.alu_op = (funct7_i[5]) ? ALU_SRA : ALU_SRL;
          3'b110: ctrl_o.alu_op = ALU_OR;
          3'b111: ctrl_o.alu_op = ALU_AND;
          default: ctrl_o.alu_op = ALU_ADD;
        endcase
      end

      default: begin
        // already set to safe defaults
      end
    endcase
  end

endmodule