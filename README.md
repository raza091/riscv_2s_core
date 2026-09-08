# RISC-V 2-Stage Pipelined Core (RV32I)

A lightweight, high-frequency, low-power **2-stage pipelined RV32I** processor core written in SystemVerilog.  
Designed for easy integration with AXI4 and targeting **200–210 MHz** operation with power consumption **< 1 mW** in modern low-power processes.

**Author:** Ali Raza Tariq  
**GitHub:** [raza091/riscv_2s_core](https://github.com/raza091/riscv_2s_core)

---

## Features

- 2-stage pipeline (IF/ID → EX/WB)
- Full RV32I base integer instruction set
- Hazard detection (load-use stall)
- Data forwarding
- Branch / Jump flush
- Clean native memory interface (easy to wrap with AXI4)
- Low-power coding style (clock-gating friendly)
- Professional SystemVerilog coding practices
- Ready for open-source (iverilog) and industrial tools (Questa / Xcelium / Cadence)

---

## Pipeline Overview

| Stage | Description                          |
|-------|--------------------------------------|
| IF/ID | Instruction Fetch + Decode + Reg Read |
| EX/WB | Execute + Memory + Write-back        |

- Only one pipeline register → low area & power
- Full forwarding from EX result
- 1-cycle penalty on taken branches / load-use hazards

---

## Directory Structure

```text
riscv_2s_core/
├── rtl/
│   ├── include/
│   │   └── riscv_pkg.sv          # Package (parameters, opcodes, structs)
│   ├── core/
│   │   ├── if_stage.sv
│   │   ├── id_stage.sv
│   │   ├── ex_stage.sv
│   │   ├── pipeline_reg_if_id.sv
│   │   ├── regfile.sv
│   │   ├── alu.sv
│   │   ├── imm_gen.sv
│   │   ├── decoder.sv
│   │   ├── control.sv
│   │   ├── hazard_unit.sv
│   │   ├── forwarding_unit.sv
│   │   └── riscv_2s_top.sv       # Core top
│   └── mem/
│       ├── imem.sv               # Instruction memory (simulation model)
│       └── dmem.sv               # Data memory (simulation model)
├── tb/
│   └── tb_riscv_2s.sv            # Basic testbench
├── sim/                          # Simulation outputs (ignored by git)
├── Makefile
└── README.md
```

---

## Requirements

### Open-source flow (default)
- `iverilog` (Icarus Verilog)
- `vvp`
- `gtkwave`

### Optional industrial tools
- Siemens Questa / ModelSim
- Cadence Xcelium

---

## How to Simulate

```bash
# Clone the repository
git clone https://github.com/raza091/riscv_2s_core.git
cd riscv_2s_core

# Compile + Simulate (iverilog)
make

# Open waveform
make wave GUI=1
# or
gtkwave sim/core.vcd &
```

### Using other tools

```bash
make TOOL=questa          # Questa / ModelSim
make TOOL=xcelium         # Cadence Xcelium
make lint                 # Lint with iverilog
make clean                # Clean simulation files
```

---

## Memory Interface (AXI4-ready)

The core exposes a simple native interface that can be easily wrapped with AXI4:

**Instruction side**
- `imem_req_o`, `imem_addr_o`, `imem_gnt_i`, `imem_rdata_i`

**Data side**
- `dmem_req_o`, `dmem_we_o`, `dmem_be_o`, `dmem_addr_o`, `dmem_wdata_o`
- `dmem_gnt_i`, `dmem_rdata_i`

---

## Current Status

- [x] Complete 2-stage pipeline
- [x] Hazard detection & forwarding
- [x] Basic testbench + memory models
- [x] Makefile (iverilog / Questa / Xcelium)
- [ ] AXI4 adapters
- [ ] Formal verification
- [ ] Synthesis scripts (Genus) + timing closure at 200 MHz
- [ ] Power analysis

---

## License

This project is released under the MIT License.

---

## Contact

**Ali Raza Tariq**  
Email: artraza@gmail.com  
GitHub: [raza091](https://github.com/raza091)
```
