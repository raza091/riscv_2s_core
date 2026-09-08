module dmem
  import riscv_pkg::*;
(
  input  logic          clk_i,
  input  logic          rst_ni,

  input  logic          req_i,
  input  logic          we_i,
  input  logic [3:0]    be_i,
  input  logic [XLEN-1:0] addr_i,
  input  logic [XLEN-1:0] wdata_i,
  output logic          gnt_o,
  output logic [XLEN-1:0] rdata_o
);

  logic [XLEN-1:0] mem [0:1023];

  // Initialize memory to zero
  initial begin
    for (int i = 0; i < 1024; i++) begin
      mem[i] = '0;
    end
  end

  assign gnt_o = req_i;   // always ready

  // Write logic
  always_ff @(posedge clk_i) begin
    if (req_i && we_i) begin
      if (be_i[0]) mem[addr_i[11:2]][ 7: 0] <= wdata_i[ 7: 0];
      if (be_i[1]) mem[addr_i[11:2]][15: 8] <= wdata_i[15: 8];
      if (be_i[2]) mem[addr_i[11:2]][23:16] <= wdata_i[23:16];
      if (be_i[3]) mem[addr_i[11:2]][31:24] <= wdata_i[31:24];
    end
  end

  // Read logic – registered + default value
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)
      rdata_o <= '0;
    else if (req_i && !we_i)
      rdata_o <= mem[addr_i[11:2]];
  end

endmodule