####################################################################
#
#  Reference library builds and flow entry points for the chip.
#
#  Author:   Sne Samal
#  Version:  2.1
#  Date:     2026-09-10
#
#  Load the PDK first, once per shell:  syn tsmc65LP
#
####################################################################

# The design file; the test vehicle names another with setenv DESIGN_TCL.
DESIGN_TCL ?= design.tcl
export DESIGN_TCL

.DEFAULT_GOAL := help
.PHONY: pll sram synth dft atpg lec padring floorplan fusion lec_chip clean help

## pll: build the PLL reference library, once
pll:
	lm_shell -f scripts/pll_ndm.tcl

## padring: die and padring only, no power plan, no design needed
padring: PLL/NDM/PLL_25M_400M.ndm
	mkdir -p logs
	fc_shell -f scripts/padring.tcl -output_log_file logs/padring.log

## sram: build the memory reference libraries listed in design.tcl, once
sram:
	lc_shell -f scripts/sram_lib.tcl
	lm_shell -f scripts/sram_ndm.tcl

## synth: logical synthesis of the design on its own
synth:
	mkdir -p logs
	fc_shell -f scripts/synth.tcl -output_log_file logs/synth.log

## dft: scan insertion into the synthesized design, and its test protocol
dft:
	mkdir -p logs
	fc_shell -f scripts/dft.tcl -output_log_file logs/dft.log

## atpg: stuck-at patterns on the design, needs make dft
atpg:
	mkdir -p logs
	tmax -shell -nostartup scripts/atpg.tcl

## lec: Formality, the scan-inserted netlist against the RTL, needs make dft
lec:
	mkdir -p logs
	fm_shell -f scripts/lec.tcl | tee logs/lec.log

## floorplan: padring plus the power plan
floorplan: PLL/NDM/PLL_25M_400M.ndm
	mkdir -p logs
	fc_shell -f scripts/chip_floorplan.tcl -output_log_file logs/floorplan.log

PLL/NDM/PLL_25M_400M.ndm:
	$(MAKE) pll

## fusion: the chip, TOP.v around the design's netlist, to GDS in one session
fusion: PLL/NDM/PLL_25M_400M.ndm
	mkdir -p logs
	fc_shell -f scripts/fusion.tcl -output_log_file logs/fusion.log

## lec_chip: Formality, the layout netlist against TOP.v and the design's netlist, needs make fusion
lec_chip:
	mkdir -p logs
	fm_shell -f scripts/lec_chip.tcl | tee logs/lec_chip.log

## clean: remove everything the flow writes, keeping built libraries
clean:
	rm -rf work outputs reports logs
	rm -rf fm_shell_command.log FM_WORK *_formal_equivalence formality.log
	rm -rf fc_command.log fc_output.txt lc_command.log lm_command.log tmax_command.log

help:
	@grep -E '^## ' Makefile | sed 's/## //'
