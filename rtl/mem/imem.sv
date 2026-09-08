module imem
  import riscv_pkg::*;
(
  input  logic          clk_i,
  input  logic          rst_ni,

  input  logic          req_i,
  input  logic [XLEN-1:0] addr_i,
  output logic          gnt_o,
  output logic [XLEN-1:0] rdata_o
);

  // Simple synchronous memory (4 KB)
  logic [XLEN-1:0] mem [0:1023];

  // Load program here (or use $readmemh in testbench)
  initial begin
    for (int i = 0; i < 1024; i++) mem[i] = 32'h0000_0013; // NOP
  end

  assign gnt_o = req_i;   // always ready in this simple model

  always_ff @(posedge clk_i) begin
    if (req_i)
      rdata_o <= mem[addr_i[11:2]];   // word addressed
  end

endmodule