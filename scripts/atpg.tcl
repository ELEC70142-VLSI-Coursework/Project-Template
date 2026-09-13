####################################################################
##
##  Stuck-at pattern generation on the design's scan chain, written
##  as STIL for stil2verilog to turn into a testbench.
##
##  Author:   Sne Samal
##  Version:  2.1
##  Date:     2026-09-10
##
##      tmax -shell -nostartup scripts/atpg.tcl
##
####################################################################

source scripts/setup.tcl
need_design

set_messages -log $LOG_DIR/tmax.log -replace

foreach f [list $DFT_V $DFT_SPF] {
    if { ![file exists $f] } {
        puts "No $f. Run make dft first."
        exit 1
    }
}

####################################################################
## Model
####################################################################
# The memories come from the compiler's ATPG view; TestMAX cannot
# read the behavioural one.

read_netlist $SIM_MODELS -library
foreach v $DESIGN_ATPG_MODELS { read_netlist $v -library }
read_netlist $DFT_V

run_build_model $DESIGN_TOP

run_drc $DFT_SPF

####################################################################
## Patterns
####################################################################

set_faults -model stuck
add_faults -all

# Basic scan treats RAM contents as unknown, so a few capture cycles
# let a pattern write a RAM and read it back.
set_atpg -capture_cycles 4
run_atpg -auto

set_faults -summary verbose
report_summaries

write_faults $OUT_DIR/${DESIGN_TOP}_faults.rpt -all -replace
write_patterns $PATTERNS -format stil -serial -unified_stil_flow -replace
