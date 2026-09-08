package riscv_pkg;

  // ------------------------------------------------------------
  // Global parameters
  // ------------------------------------------------------------
  parameter int unsigned XLEN        = 32;
  parameter int unsigned REG_ADDR_W  = 5;
  parameter int unsigned REG_NUM     = 32;
  parameter int unsigned IMM_W       = 32;
  parameter int unsigned OPCODE_W    = 7;
  parameter int unsigned FUNCT3_W    = 3;
  parameter int unsigned FUNCT7_W    = 7;

  // ------------------------------------------------------------
  // Opcode definitions (RV32I)
  // ------------------------------------------------------------
  typedef enum logic [OPCODE_W-1:0] {
    OPCODE_LUI    = 7'b0110111,
    OPCODE_AUIPC  = 7'b0010111,
    OPCODE_JAL    = 7'b1101111,
    OPCODE_JALR   = 7'b1100111,
    OPCODE_BRANCH = 7'b1100011,
    OPCODE_LOAD   = 7'b0000011,
    OPCODE_STORE  = 7'b0100011,
    OPCODE_OP_IMM = 7'b0010011,
    OPCODE_OP     = 7'b0110011,
    OPCODE_SYSTEM = 7'b1110011,
    OPCODE_FENCE  = 7'b0001111
  } opcode_e;

  // ------------------------------------------------------------
  // ALU operation encoding
  // ------------------------------------------------------------
  typedef enum logic [3:0] {
    ALU_ADD  = 4'b0000,
    ALU_SUB  = 4'b0001,
    ALU_SLL  = 4'b0010,
    ALU_SLT  = 4'b0011,
    ALU_SLTU = 4'b0100,
    ALU_XOR  = 4'b0101,
    ALU_SRL  = 4'b0110,
    ALU_SRA  = 4'b0111,
    ALU_OR   = 4'b1000,
    ALU_AND  = 4'b1001
  } alu_op_e;

  // ------------------------------------------------------------
  // Control signals structure (passed through pipeline)
  // ------------------------------------------------------------
  typedef struct packed {
    logic        reg_write;
    logic        mem_read;
    logic        mem_write;
    logic        alu_src;      // 0 = rs2, 1 = immediate
    logic        branch;
    logic        jump;
    logic        lui;
    logic        auipc;
    alu_op_e     alu_op;
    logic [2:0]  funct3;       // needed for branch & load/store
  } ctrl_t;

  // ------------------------------------------------------------
  // IF/ID pipeline register payload
  // ------------------------------------------------------------
  typedef struct packed {
    logic [XLEN-1:0] pc;
    logic [XLEN-1:0] pc_plus4;
    logic [XLEN-1:0] instr;
  } if_id_t;

endpackage