module hazard_unit
  import riscv_pkg::*;
(
  // From ID stage
  input  logic [REG_ADDR_W-1:0] id_rs1_i,
  input  logic [REG_ADDR_W-1:0] id_rs2_i,

  // From EX stage
  input  logic                  ex_mem_read_i,
  input  logic [REG_ADDR_W-1:0] ex_rd_i,
  input  logic                  take_branch_i,

  // Outputs
  output logic                  stall_o,
  output logic                  flush_o
);

  // Load-use hazard detection
  logic load_use_hazard;

  assign load_use_hazard = ex_mem_read_i &&
                           (ex_rd_i != '0) &&
                           ((ex_rd_i == id_rs1_i) || (ex_rd_i == id_rs2_i));

  assign stall_o = load_use_hazard;
  assign flush_o = take_branch_i;     // flush IF/ID on taken branch/jump

endmodule