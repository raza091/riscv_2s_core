module pipeline_reg_if_id
  import riscv_pkg::*;
(
  input  logic          clk_i,
  input  logic          rst_ni,

  // Control
  input  logic          stall_i,     // 1 = freeze this register
  input  logic          flush_i,     // 1 = inject bubble (NOP)

  // Data from IF stage
  input  if_id_t        data_i,

  // Data to ID stage
  output if_id_t        data_o
);

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      data_o.pc       <= '0;
      data_o.pc_plus4 <= '0;
      data_o.instr    <= 32'h0000_0013;   // ADDI x0, x0, 0  (NOP)
    end
    else if (flush_i) begin
      data_o.pc       <= '0;
      data_o.pc_plus4 <= '0;
      data_o.instr    <= 32'h0000_0013;   // NOP on flush
    end
    else if (!stall_i) begin
      data_o <= data_i;
    end
    // else: stall → keep old value
  end

endmodule