module id_stage
  import riscv_pkg::*;
(
  input  logic          clk_i,
  input  logic          rst_ni,

  // From IF/ID pipeline register
  input  if_id_t        if_id_i,

  // From EX stage (for write-back)
  input  logic          reg_we_i,
  input  logic [REG_ADDR_W-1:0] reg_waddr_i,
  input  logic [XLEN-1:0]       reg_wdata_i,

  // Forwarding data (from EX)
  input  logic [XLEN-1:0]       forward_rs1_i,
  input  logic [XLEN-1:0]       forward_rs2_i,
  input  logic                  forward_rs1_en_i,
  input  logic                  forward_rs2_en_i,

  // Outputs to EX stage
  output logic [XLEN-1:0]       pc_o,
  output logic [XLEN-1:0]       pc_plus4_o,
  output logic [XLEN-1:0]       rs1_data_o,
  output logic [XLEN-1:0]       rs2_data_o,
  output logic [XLEN-1:0]       imm_o,
  output logic [REG_ADDR_W-1:0] rd_o,
  output logic [REG_ADDR_W-1:0] rs1_addr_o,
  output logic [REG_ADDR_W-1:0] rs2_addr_o,
  output ctrl_t                 ctrl_o
);

  logic [REG_ADDR_W-1:0] rs1_addr, rs2_addr, rd_addr;
  logic [FUNCT3_W-1:0]   funct3;
  logic [FUNCT7_W-1:0]   funct7;
  opcode_e               opcode;

  logic [XLEN-1:0]       rs1_data_raw, rs2_data_raw;
  logic [XLEN-1:0]       imm;

  // Decoder
  decoder u_decoder (
    .instr_i   ( if_id_i.instr ),
    .rs1_o     ( rs1_addr      ),
    .rs2_o     ( rs2_addr      ),
    .rd_o      ( rd_addr       ),
    .funct3_o  ( funct3        ),
    .funct7_o  ( funct7        ),
    .opcode_o  ( opcode        )
  );

  // Control
  control u_control (
    .opcode_i  ( opcode  ),
    .funct3_i  ( funct3  ),
    .funct7_i  ( funct7  ),
    .ctrl_o    ( ctrl_o  )
  );

  // Immediate generator
  imm_gen u_imm_gen (
    .instr_i   ( if_id_i.instr ),
    .imm_o     ( imm           )
  );

  // Register file
  regfile u_regfile (
    .clk_i     ( clk_i         ),
    .rst_ni    ( rst_ni        ),
    .we_i      ( reg_we_i      ),
    .waddr_i   ( reg_waddr_i   ),
    .wdata_i   ( reg_wdata_i   ),
    .raddr_a_i ( rs1_addr      ),
    .rdata_a_o ( rs1_data_raw  ),
    .raddr_b_i ( rs2_addr      ),
    .rdata_b_o ( rs2_data_raw  )
  );

  // Forwarding muxes
  assign rs1_data_o = forward_rs1_en_i ? forward_rs1_i : rs1_data_raw;
  assign rs2_data_o = forward_rs2_en_i ? forward_rs2_i : rs2_data_raw;

  // Pass-through
  assign pc_o        = if_id_i.pc;
  assign pc_plus4_o  = if_id_i.pc_plus4;
  assign imm_o       = imm;
  assign rd_o        = rd_addr;
  assign rs1_addr_o  = rs1_addr;
  assign rs2_addr_o  = rs2_addr;

endmodule