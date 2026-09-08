module riscv_2s_top
  import riscv_pkg::*;
(
  input  logic          clk_i,
  input  logic          rst_ni,

  // Instruction memory interface (native – easy to wrap with AXI4)
  output logic          imem_req_o,
  output logic [XLEN-1:0] imem_addr_o,
  input  logic          imem_gnt_i,
  input  logic [XLEN-1:0] imem_rdata_i,

  // Data memory interface (native – easy to wrap with AXI4)
  output logic          dmem_req_o,
  output logic          dmem_we_o,
  output logic [3:0]    dmem_be_o,
  output logic [XLEN-1:0] dmem_addr_o,
  output logic [XLEN-1:0] dmem_wdata_o,
  input  logic          dmem_gnt_i,
  input  logic [XLEN-1:0] dmem_rdata_i
);

  // ------------------------------------------------------------
  // Internal signals
  // ------------------------------------------------------------
  if_id_t if_id_data, if_id_data_q;

  logic stall, flush;
  logic take_branch;
  logic [XLEN-1:0] branch_target;

  logic [XLEN-1:0] id_pc, id_pc_plus4;
  logic [XLEN-1:0] id_rs1_data, id_rs2_data, id_imm;
  logic [REG_ADDR_W-1:0] id_rd, id_rs1_addr, id_rs2_addr;
  ctrl_t id_ctrl;

  logic ex_reg_we;
  logic [REG_ADDR_W-1:0] ex_reg_waddr;
  logic [XLEN-1:0] ex_reg_wdata;
  logic [XLEN-1:0] ex_alu_result;

  logic forward_rs1_en, forward_rs2_en;
  logic [XLEN-1:0] forward_rs1, forward_rs2;

  // ------------------------------------------------------------
  // IF Stage
  // ------------------------------------------------------------
  if_stage u_if_stage (
    .clk_i            ( clk_i          ),
    .rst_ni           ( rst_ni         ),
    .stall_i          ( stall          ),
    .flush_i          ( flush          ),
    .take_branch_i    ( take_branch    ),
    .branch_target_i  ( branch_target  ),
    .imem_req_o       ( imem_req_o     ),
    .imem_addr_o      ( imem_addr_o    ),
    .imem_gnt_i       ( imem_gnt_i     ),
    .imem_rdata_i     ( imem_rdata_i   ),
    .if_id_o          ( if_id_data     )
  );

  // ------------------------------------------------------------
  // IF/ID Pipeline Register
  // ------------------------------------------------------------
  pipeline_reg_if_id u_if_id (
    .clk_i    ( clk_i        ),
    .rst_ni   ( rst_ni       ),
    .stall_i  ( stall        ),
    .flush_i  ( flush        ),
    .data_i   ( if_id_data   ),
    .data_o   ( if_id_data_q )
  );

  // ------------------------------------------------------------
  // ID Stage
  // ------------------------------------------------------------
  id_stage u_id_stage (
    .clk_i            ( clk_i            ),
    .rst_ni           ( rst_ni           ),
    .if_id_i          ( if_id_data_q     ),
    .reg_we_i         ( ex_reg_we        ),
    .reg_waddr_i      ( ex_reg_waddr     ),
    .reg_wdata_i      ( ex_reg_wdata     ),
    .forward_rs1_i    ( forward_rs1      ),
    .forward_rs2_i    ( forward_rs2      ),
    .forward_rs1_en_i ( forward_rs1_en   ),
    .forward_rs2_en_i ( forward_rs2_en   ),
    .pc_o             ( id_pc            ),
    .pc_plus4_o       ( id_pc_plus4      ),
    .rs1_data_o       ( id_rs1_data      ),
    .rs2_data_o       ( id_rs2_data      ),
    .imm_o            ( id_imm           ),
    .rd_o             ( id_rd            ),
    .rs1_addr_o       ( id_rs1_addr      ),
    .rs2_addr_o       ( id_rs2_addr      ),
    .ctrl_o           ( id_ctrl          )
  );

  // ------------------------------------------------------------
  // EX Stage
  // ------------------------------------------------------------
  ex_stage u_ex_stage (
    .pc_i             ( id_pc            ),
    .pc_plus4_i       ( id_pc_plus4      ),
    .rs1_data_i       ( id_rs1_data      ),
    .rs2_data_i       ( id_rs2_data      ),
    .imm_i            ( id_imm           ),
    .rd_i             ( id_rd            ),
    .ctrl_i           ( id_ctrl          ),
    .dmem_req_o       ( dmem_req_o       ),
    .dmem_we_o        ( dmem_we_o        ),
    .dmem_be_o        ( dmem_be_o        ),
    .dmem_addr_o      ( dmem_addr_o      ),
    .dmem_wdata_o     ( dmem_wdata_o     ),
    .dmem_gnt_i       ( dmem_gnt_i       ),
    .dmem_rdata_i     ( dmem_rdata_i     ),
    .reg_we_o         ( ex_reg_we        ),
    .reg_waddr_o      ( ex_reg_waddr     ),
    .reg_wdata_o      ( ex_reg_wdata     ),
    .take_branch_o    ( take_branch      ),
    .branch_target_o  ( branch_target    ),
    .alu_result_o     ( ex_alu_result    )
  );

  // ------------------------------------------------------------
  // Hazard Unit
  // ------------------------------------------------------------
  hazard_unit u_hazard (
    .id_rs1_i       ( id_rs1_addr      ),
    .id_rs2_i       ( id_rs2_addr      ),
    .ex_mem_read_i  ( id_ctrl.mem_read ),
    .ex_rd_i        ( id_rd            ),
    .take_branch_i  ( take_branch      ),
    .stall_o        ( stall            ),
    .flush_o        ( flush            )
  );

  // ------------------------------------------------------------
  // Forwarding Unit
  // ------------------------------------------------------------
  forwarding_unit u_forwarding (
    .id_rs1_i         ( id_rs1_addr     ),
    .id_rs2_i         ( id_rs2_addr     ),
    .ex_reg_we_i      ( ex_reg_we       ),
    .ex_rd_i          ( ex_reg_waddr    ),
    .ex_alu_result_i  ( ex_alu_result   ),
    .forward_rs1_en_o ( forward_rs1_en  ),
    .forward_rs2_en_o ( forward_rs2_en  ),
    .forward_rs1_o    ( forward_rs1     ),
    .forward_rs2_o    ( forward_rs2     )
  );

endmodule