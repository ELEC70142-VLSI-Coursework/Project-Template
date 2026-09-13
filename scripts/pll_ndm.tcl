####################################################################
##
##  Build the PLL's reference library from its LEF.
##  Physical only, because the macro ships no timing model.
##
##  Author:   Sne Samal
##  Version:  1.1
##  Date:     2026-09-10
##
##      lm_shell -f scripts/pll_ndm.tcl
##
####################################################################

source $env(SYN_KIT_TCL)
source scripts/pll.tcl

file mkdir [file dirname $PLL_NDM]

# Must match the Verilog and the SDC, or div_sel[0] is two pins.
set_app_options -as_user_default -name design.bus_delimiters -value {[]}

create_workspace $PLL_CELL \
    -technology   $TECH_FILE \
    -flow         physical_only \
    -scale_factor $SCALE_FACTOR

read_lef $PLL_LEF

process_workspaces -force -directory [file dirname $PLL_NDM] \
    -output [file tail $PLL_NDM]

remove_workspace

if { ![file exists $PLL_NDM] } {
    puts "BUILD FAILED. $PLL_NDM was not written."
    exit 1
}

puts "BUILD OK. $PLL_NDM"
exit 0
