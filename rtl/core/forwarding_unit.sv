module forwarding_unit
  import riscv_pkg::*;
(
  // From ID
  input  logic [REG_ADDR_W-1:0] id_rs1_i,
  input  logic [REG_ADDR_W-1:0] id_rs2_i,

  // From EX (previous instruction result)
  input  logic                  ex_reg_we_i,
  input  logic [REG_ADDR_W-1:0] ex_rd_i,
  input  logic [XLEN-1:0]       ex_alu_result_i,

  // Forwarding control & data
  output logic                  forward_rs1_en_o,
  output logic                  forward_rs2_en_o,
  output logic [XLEN-1:0]       forward_rs1_o,
  output logic [XLEN-1:0]       forward_rs2_o
);

  assign forward_rs1_en_o = ex_reg_we_i && (ex_rd_i != '0) && (ex_rd_i == id_rs1_i);
  assign forward_rs2_en_o = ex_reg_we_i && (ex_rd_i != '0) && (ex_rd_i == id_rs2_i);

  assign forward_rs1_o = ex_alu_result_i;
  assign forward_rs2_o = ex_alu_result_i;

endmodule