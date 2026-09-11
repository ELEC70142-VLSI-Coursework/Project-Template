####################################################################
##
##  Logical synthesis of the design on its own. The netlist and SDC
##  it writes are what make dft reads.
##
##  Author:   Sne Samal
##  Version:  1.1
##  Date:     2026-09-10
##
##      fc_shell -f scripts/synth.tcl
##
####################################################################

source scripts/setup.tcl
need_design

set_host_options -max_cores $MAX_CORES

if { [file exists $SYN_LIB] } { file delete -force $SYN_LIB }
create_lib $SYN_LIB -technology $TECH_FILE -ref_libs $REF_LIBS
report_ref_libs

# Before the design is read. Nothing here is placed.
set_non_physical_mode

# Records every transformation between here and the netlist, for
# make lec.
set_svf $SYNTH_SVF

analyze -format sverilog $DESIGN_RTL
elaborate $DESIGN_TOP
set_top_module $DESIGN_TOP

redirect -tee -file $RPT_DIR/synth_check.rpt \
    "check_design -checks netlist -log_file $RPT_DIR/synth_check_netlist.log"

set PHYSICAL 0
set SDC_FILE $DESIGN_SDC
source scripts/mcmm.tcl

compile_logical

lab_reports synth 0

set_svf -off
write_verilog $SYNTH_V
write_sdc -output $SYNTH_SDC

save_block
save_lib
