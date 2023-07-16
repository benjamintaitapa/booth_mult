SIM ?= verilator
TOPLEVEL_LANG ?= verilog
EXTRA_ARGS += --trace --trace-structs --coverage

VERILOG_SOURCES ?= $(PWD)/../booth_radix4.sv

TOPLEVEL = booth_radix4

MODULE = tb

include $(shell cocotb-config --makefiles)/Makefile.sim
