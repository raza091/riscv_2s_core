module regfile
  import riscv_pkg::*;
(
  input  logic                  clk_i,
  input  logic                  rst_ni,

  // Write port
  input  logic                  we_i,
  input  logic [REG_ADDR_W-1:0] waddr_i,
  input  logic [XLEN-1:0]       wdata_i,

  // Read port 1
  input  logic [REG_ADDR_W-1:0] raddr_a_i,
  output logic [XLEN-1:0]       rdata_a_o,

  // Read port 2
  input  logic [REG_ADDR_W-1:0] raddr_b_i,
  output logic [XLEN-1:0]       rdata_b_o
);

  // ------------------------------------------------------------
  // Register file storage
  // ------------------------------------------------------------
  logic [XLEN-1:0] mem [REG_NUM];

  // ------------------------------------------------------------
  // Write port with clock gating style (we only write when needed)
  // ------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      for (int i = 0; i < REG_NUM; i++) begin
        mem[i] <= '0;
      end
    end
    else if (we_i && (waddr_i != '0)) begin
      mem[waddr_i] <= wdata_i;
    end
  end

  // ------------------------------------------------------------
  // Asynchronous read ports (x0 hardwired to zero)
  // ------------------------------------------------------------
  assign rdata_a_o = (raddr_a_i == '0) ? '0 : mem[raddr_a_i];
  assign rdata_b_o = (raddr_b_i == '0) ? '0 : mem[raddr_b_i];

endmodule