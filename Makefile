#=============================================================================
# Makefile — RV32I 2-Stage Pipelined Core
# Supports: iverilog/vvp/gtkwave (opensource) and Questa/Cadence (EDA)
# Author: Ali Raza Tariq
# Usage:
#   make                    -> compile + sim (iverilog, default)
#   make TOOL=questa        -> compile + sim (Questa/ModelSim)
#   make TOOL=xcelium       -> compile + sim (Cadence Xcelium)
#   make GUI=1              -> open waveform GUI after sim
#   make lint               -> lint with iverilog
#   make lint TOOL=hal      -> lint with Cadence HAL
#=============================================================================

#-----------------------------------------------------------------------------
# Tool selection — override on command line: make TOOL=questa
#-----------------------------------------------------------------------------
TOOL    ?= iverilog
GUI     ?= 0

#-----------------------------------------------------------------------------
# Directories
#-----------------------------------------------------------------------------
RTL_DIR   = rtl
INC_DIR   = rtl/include
CORE_DIR  = rtl/core
MEM_DIR   = rtl/mem
TB_DIR    = tb
SIM_DIR   = sim

#-----------------------------------------------------------------------------
# Source files
# PKG_FILES  — package file compiled first
# RTL_FILES  — all RTL modules
# TB_FILES   — testbench
# ALL_SRCS   — complete ordered list
#-----------------------------------------------------------------------------
PKG_FILES = $(INC_DIR)/riscv_pkg.sv

RTL_FILES = $(CORE_DIR)/pipeline_reg_if_id.sv \
            $(CORE_DIR)/regfile.sv \
            $(CORE_DIR)/imm_gen.sv \
            $(CORE_DIR)/alu.sv \
            $(CORE_DIR)/decoder.sv \
            $(CORE_DIR)/control.sv \
            $(CORE_DIR)/if_stage.sv \
            $(CORE_DIR)/id_stage.sv \
            $(CORE_DIR)/ex_stage.sv \
            $(CORE_DIR)/hazard_unit.sv \
            $(CORE_DIR)/forwarding_unit.sv \
            $(CORE_DIR)/riscv_2s_top.sv \
            $(MEM_DIR)/imem.sv \
            $(MEM_DIR)/dmem.sv

TB_FILES  = $(TB_DIR)/tb_riscv_2s.sv

# complete source list — package first
ALL_SRCS  = $(PKG_FILES) $(RTL_FILES) $(TB_FILES)

#-----------------------------------------------------------------------------
# Output files
#-----------------------------------------------------------------------------
SIM_BIN = $(SIM_DIR)/core_sim
VCD     = $(SIM_DIR)/core.vcd
LOG     = $(SIM_DIR)/sim.log

#-----------------------------------------------------------------------------
# ── TOOL: iverilog (open source) ─────────────────────────────────────────────
#-----------------------------------------------------------------------------
IVERILOG       = iverilog
VVP            = vvp
GTKWAVE        = gtkwave

IVER_FLAGS     = -Wall -Wno-timescale -g2012
IVER_INC       = -I$(INC_DIR)

#-----------------------------------------------------------------------------
# ── TOOL: Questa / ModelSim ───────────────────────────────────────────────────
#-----------------------------------------------------------------------------
VLOG           = vlog
VOPT           = vopt
VSIM           = vsim
QUESTA_LIB     = work
QUESTA_TOP     = tb_riscv_2s
VLOG_FLAGS     = -svinputport=compat -incr -64 -nologo -quiet \
                 -suppress 2583 -suppress 13262 -suppress 2986 \
                 -suppress 2879 -suppress 3999
VOPT_FLAGS     = +acc +check_synthesis
VSIM_FLAGS     = -suppress 3999 -suppress 8885

#-----------------------------------------------------------------------------
# ── TOOL: Cadence Xcelium ────────────────────────────────────────────────────
#-----------------------------------------------------------------------------
XRUN           = xrun
XRUN_FLAGS     = -access +rwc -timescale 1ns/1ps \
                 -define XCELIUM -incdir $(INC_DIR) \
                 -top tb_riscv_2s -log $(LOG)
SIMVISION      = simvision

#-----------------------------------------------------------------------------
# ── TOOL: Cadence HAL (lint only) ────────────────────────────────────────────
#-----------------------------------------------------------------------------
HAL            = hal
HAL_FLAGS      = -sv -timescale 1ns/1ps -incdir $(INC_DIR)

#-----------------------------------------------------------------------------
# Phony targets
#-----------------------------------------------------------------------------
.PHONY: all sim compile run wave lint clean help

#-----------------------------------------------------------------------------
# Default target
#-----------------------------------------------------------------------------
all: sim

sim: compile run

#=============================================================================
# ── OPEN SOURCE FLOW (iverilog + vvp + gtkwave) ──────────────────────────────
#=============================================================================
ifeq ($(TOOL),iverilog)

compile:
	@mkdir -p $(SIM_DIR)
	@echo "==> [iverilog] Compiling..."
	@$(IVERILOG) $(IVER_FLAGS) $(IVER_INC) \
	             -o $(SIM_BIN) $(ALL_SRCS)
	@echo "==> Compilation done."

run: compile
	@echo "==> [vvp] Running simulation..."
	@$(VVP) $(SIM_BIN) | tee $(LOG)

wave:
ifeq ($(GUI),1)
	@echo "==> [gtkwave] Opening waveform..."
	@$(GTKWAVE) $(VCD) &
else
	@echo "==> Run with GUI=1 to open GTKWave: make wave GUI=1"
endif

lint:
	@echo "==> [iverilog] Linting RTL..."
	@$(IVERILOG) $(IVER_FLAGS) $(IVER_INC) \
	             -t null $(PKG_FILES) $(RTL_FILES)
	@echo "==> Lint clean."

endif

#=============================================================================
# ── QUESTA / MODELSIM FLOW ───────────────────────────────────────────────────
#=============================================================================
ifeq ($(TOOL),questa)

compile:
	@mkdir -p $(SIM_DIR)
	@echo "==> [Questa] Creating library..."
	@vlib $(QUESTA_LIB)
	@echo "==> [Questa] Compiling package first..."
	@$(VLOG) $(VLOG_FLAGS) -work $(QUESTA_LIB) \
	         +incdir+$(INC_DIR) $(PKG_FILES)
	@echo "==> [Questa] Compiling RTL + TB..."
	@$(VLOG) $(VLOG_FLAGS) -timescale "1ns/1ps" \
	         -work $(QUESTA_LIB) -pedanticerrors \
	         +incdir+$(INC_DIR) \
	         $(RTL_FILES) $(TB_FILES)
	@echo "==> [Questa] Optimising design..."
	@$(VOPT) $(VLOG_FLAGS) $(VOPT_FLAGS) \
	         -work $(QUESTA_LIB) $(QUESTA_TOP) \
	         -o $(QUESTA_TOP)_opt
	@echo "==> Compilation done."

run:
ifeq ($(GUI),1)
	@echo "==> [Questa GUI] Running simulation..."
	@$(VSIM) $(VSIM_FLAGS) -work $(QUESTA_LIB) \
	         $(QUESTA_TOP)_opt \
	         -do "add wave -r /*; run -all"
else
	@echo "==> [Questa batch] Running simulation..."
	@$(VSIM) -c $(VSIM_FLAGS) -work $(QUESTA_LIB) \
	         $(QUESTA_TOP)_opt \
	         -do "run -all; quit -f" | tee $(LOG)
endif

wave:
ifeq ($(GUI),1)
	@$(VSIM) $(VSIM_FLAGS) -work $(QUESTA_LIB) \
	         $(QUESTA_TOP)_opt \
	         -do "add wave -r /*; run -all"
else
	@echo "==> Run with GUI=1: make wave TOOL=questa GUI=1"
endif

lint:
	@echo "==> [Questa] Linting RTL..."
	@$(VLOG) $(VLOG_FLAGS) -lint +incdir+$(INC_DIR) \
	         $(PKG_FILES) $(RTL_FILES)
	@echo "==> Lint done."

endif

#=============================================================================
# ── CADENCE XCELIUM FLOW ─────────────────────────────────────────────────────
#=============================================================================
ifeq ($(TOOL),xcelium)

compile:
	@mkdir -p $(SIM_DIR)
	@echo "==> [Xcelium] Compiling and elaborating..."
	@$(XRUN) $(XRUN_FLAGS) $(ALL_SRCS)
	@echo "==> Compilation done."

run:
ifeq ($(GUI),1)
	@echo "==> [SimVision] Running with GUI..."
	@$(XRUN) $(XRUN_FLAGS) -gui $(ALL_SRCS)
else
	@echo "==> [Xcelium batch] Running simulation..."
	@$(XRUN) $(XRUN_FLAGS) $(ALL_SRCS) | tee $(LOG)
endif

wave:
ifeq ($(GUI),1)
	@$(SIMVISION) $(SIM_DIR)/*.shm &
else
	@echo "==> Run with GUI=1: make wave TOOL=xcelium GUI=1"
endif

lint:
	@echo "==> [HAL] Linting RTL..."
	@$(HAL) $(HAL_FLAGS) $(PKG_FILES) $(RTL_FILES)
	@echo "==> Lint done."

endif

#=============================================================================
# ── COMMON TARGETS ───────────────────────────────────────────────────────────
#=============================================================================

clean:
	@echo "==> Cleaning..."
	@rm -rf $(SIM_DIR)/*.vcd \
	        $(SIM_DIR)/*.vvp \
	        $(SIM_DIR)/*.log \
	        $(SIM_BIN) \
	        work/ \
	        xcelium.d/ \
	        *.shm *.trn *.dsn \
	        transcript vsim.wlf
	@echo "==> Clean done."

help:
	@echo ""
	@echo "RV32I 2-Stage Core Makefile"
	@echo "---------------------------"
	@echo "Usage: make [target] [TOOL=<tool>] [GUI=1]"
	@echo ""
	@echo "TOOL options:"
	@echo "  iverilog   open source iverilog + vvp + gtkwave (default)"
	@echo "  questa     Questa / ModelSim"
	@echo "  xcelium    Cadence Xcelium"
	@echo ""
	@echo "Targets:"
	@echo "  make                      compile + sim (iverilog)"
	@echo "  make TOOL=questa          compile + sim (Questa)"
	@echo "  make TOOL=xcelium         compile + sim (Xcelium)"
	@echo "  make wave GUI=1           open waveform after sim"
	@echo "  make lint                 lint with iverilog"
	@echo "  make lint TOOL=hal        lint with Cadence HAL"
	@echo "  make clean                remove all generated files"
	@echo "  make help                 show this message"
	@echo ""