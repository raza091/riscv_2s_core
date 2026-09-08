module if_stage
  import riscv_pkg::*;
(
  input  logic          clk_i,
  input  logic          rst_ni,

  // Control from hazard unit
  input  logic          stall_i,
  input  logic          flush_i,

  // Branch / Jump control from EX stage
  input  logic          take_branch_i,
  input  logic [XLEN-1:0] branch_target_i,

  // Instruction memory interface
  output logic          imem_req_o,
  output logic [XLEN-1:0] imem_addr_o,
  input  logic          imem_gnt_i,
  input  logic [XLEN-1:0] imem_rdata_i,

  // To IF/ID pipeline register
  output if_id_t        if_id_o
);

  logic [XLEN-1:0] pc_q, pc_d;
  logic [XLEN-1:0] pc_plus4;

  assign pc_plus4 = pc_q + 32'd4;

  // Next PC selection
  always_comb begin
    if (take_branch_i)
      pc_d = branch_target_i;
    else
      pc_d = pc_plus4;
  end

  // PC register
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)
      pc_q <= 32'h0000_0000;
    else if (!stall_i)
      pc_q <= pc_d;
  end

  // Instruction memory request
  assign imem_req_o  = rst_ni;           // always request after reset
  assign imem_addr_o = pc_q;

  // Output to pipeline register
  assign if_id_o.pc       = pc_q;
  assign if_id_o.pc_plus4 = pc_plus4;
  assign if_id_o.instr    = imem_rdata_i;

endmodule