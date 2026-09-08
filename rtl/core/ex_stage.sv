module ex_stage
  import riscv_pkg::*;
(
  // From ID stage
  input  logic [XLEN-1:0]       pc_i,
  input  logic [XLEN-1:0]       pc_plus4_i,
  input  logic [XLEN-1:0]       rs1_data_i,
  input  logic [XLEN-1:0]       rs2_data_i,
  input  logic [XLEN-1:0]       imm_i,
  input  logic [REG_ADDR_W-1:0] rd_i,
  input  ctrl_t                 ctrl_i,

  // Data memory interface
  output logic                  dmem_req_o,
  output logic                  dmem_we_o,
  output logic [3:0]            dmem_be_o,
  output logic [XLEN-1:0]       dmem_addr_o,
  output logic [XLEN-1:0]       dmem_wdata_o,
  input  logic                  dmem_gnt_i,
  input  logic [XLEN-1:0]       dmem_rdata_i,

  // Results / control to other units
  output logic                  reg_we_o,
  output logic [REG_ADDR_W-1:0] reg_waddr_o,
  output logic [XLEN-1:0]       reg_wdata_o,

  output logic                  take_branch_o,
  output logic [XLEN-1:0]       branch_target_o,

  // For forwarding
  output logic [XLEN-1:0]       alu_result_o
);

  logic [XLEN-1:0] alu_operand_a;
  logic [XLEN-1:0] alu_operand_b;
  logic [XLEN-1:0] alu_result;
  logic            alu_zero;

  // Operand A selection (AUIPC uses PC)
  always_comb begin
    if (ctrl_i.auipc)
      alu_operand_a = pc_i;
    else if (ctrl_i.lui)
      alu_operand_a = '0;
    else
      alu_operand_a = rs1_data_i;
  end

  // Operand B selection
  assign alu_operand_b = ctrl_i.alu_src ? imm_i : rs2_data_i;

  // ALU
  alu u_alu (
    .operand_a_i ( alu_operand_a ),
    .operand_b_i ( alu_operand_b ),
    .operator_i  ( ctrl_i.alu_op ),
    .result_o    ( alu_result    ),
    .zero_o      ( alu_zero      )
  );

  assign alu_result_o = alu_result;

  // Branch / Jump target & decision
  logic branch_taken;

  always_comb begin
    branch_taken = 1'b0;
    if (ctrl_i.branch) begin
      unique case (ctrl_i.funct3)
        3'b000: branch_taken =  alu_zero;           // BEQ
        3'b001: branch_taken = ~alu_zero;           // BNE
        3'b100: branch_taken = alu_result[0];       // BLT  (SLT result)
        3'b101: branch_taken = ~alu_result[0];      // BGE
        3'b110: branch_taken = alu_result[0];       // BLTU
        3'b111: branch_taken = ~alu_result[0];      // BGEU
        default: branch_taken = 1'b0;
      endcase
    end
  end

  assign take_branch_o   = ctrl_i.jump | branch_taken;
  assign branch_target_o = ctrl_i.jump ? 
                           (ctrl_i.alu_src ? (rs1_data_i + imm_i) & ~32'd1 : (pc_i + imm_i)) :
                           (pc_i + imm_i);

  // Load / Store unit
  assign dmem_req_o   = ctrl_i.mem_read | ctrl_i.mem_write;
  assign dmem_we_o    = ctrl_i.mem_write;
  assign dmem_addr_o  = alu_result;
  assign dmem_wdata_o = rs2_data_i;

  // Simple byte enable (word only for now – can be extended)
  assign dmem_be_o = 4'b1111;

  // Write-back data selection
  logic [XLEN-1:0] wb_data;

  always_comb begin
    if (ctrl_i.mem_read)
      wb_data = dmem_rdata_i;
    else if (ctrl_i.jump)
      wb_data = pc_plus4_i;          // return address
    else
      wb_data = alu_result;
  end

  assign reg_we_o    = ctrl_i.reg_write;
  assign reg_waddr_o = rd_i;
  assign reg_wdata_o = wb_data;

endmodule