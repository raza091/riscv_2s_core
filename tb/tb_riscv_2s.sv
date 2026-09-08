module tb_riscv_2s;

  import riscv_pkg::*;

  logic clk;
  logic rst_n;

  // Instruction memory interface
  logic          imem_req;
  logic [31:0]   imem_addr;
  logic          imem_gnt;
  logic [31:0]   imem_rdata;

  // Data memory interface
  logic          dmem_req;
  logic          dmem_we;
  logic [3:0]    dmem_be;
  logic [31:0]   dmem_addr;
  logic [31:0]   dmem_wdata;
  logic          dmem_gnt;
  logic [31:0]   dmem_rdata;

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;   // 100 MHz for simulation (change later)

  // Reset
  initial begin
    rst_n = 0;
    #20;
    rst_n = 1;
  end

  // DUT
  riscv_2s_top u_core (
    .clk_i        ( clk        ),
    .rst_ni       ( rst_n      ),
    .imem_req_o   ( imem_req   ),
    .imem_addr_o  ( imem_addr  ),
    .imem_gnt_i   ( imem_gnt   ),
    .imem_rdata_i ( imem_rdata ),
    .dmem_req_o   ( dmem_req   ),
    .dmem_we_o    ( dmem_we    ),
    .dmem_be_o    ( dmem_be    ),
    .dmem_addr_o  ( dmem_addr  ),
    .dmem_wdata_o ( dmem_wdata ),
    .dmem_gnt_i   ( dmem_gnt   ),
    .dmem_rdata_i ( dmem_rdata )
  );

  // Memories
  imem u_imem (
    .clk_i   ( clk       ),
    .rst_ni  ( rst_n     ),
    .req_i   ( imem_req  ),
    .addr_i  ( imem_addr ),
    .gnt_o   ( imem_gnt  ),
    .rdata_o ( imem_rdata)
  );

  dmem u_dmem (
    .clk_i   ( clk       ),
    .rst_ni  ( rst_n     ),
    .req_i   ( dmem_req  ),
    .we_i    ( dmem_we   ),
    .be_i    ( dmem_be   ),
    .addr_i  ( dmem_addr ),
    .wdata_i ( dmem_wdata),
    .gnt_o   ( dmem_gnt  ),
    .rdata_o ( dmem_rdata)
  );

  // Simple timeout
  initial begin
    #5000;
    $display("Simulation finished (timeout)");
    $finish;
  end

  // Dump waves
  initial begin
    $dumpfile("sim/core.vcd");
    $dumpvars(0, tb_riscv_2s);
  end

endmodule