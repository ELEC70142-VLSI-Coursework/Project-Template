####################################################################
##
##  The chip: TOP.v around the design's netlist, placed, clocked,
##  routed and finished in one session.
##
##  Author:   Sne Samal
##  Version:  2.1
##  Date:     2026-09-10
##
##      fc_shell -f scripts/fusion.tcl
##
####################################################################

source scripts/chip_floorplan.tcl

set PHYSICAL 1
set SDC_FILE $CHIP_SDC
source scripts/mcmm.tcl

# Optimization runs against a stiffer late derate than signoff, see
# setup.tcl; backend.tcl restores DERATE_LATE once routing is done.
foreach corner $CORNER_LABELS {
    current_scenario func_$corner
    set_timing_derate -late [expr {$DERATE_LATE + $PREROUTE_DERATE_MARGIN}] \
        -cell_delay -net_delay
}
current_scenario func_[lindex $CORNER_LABELS 0]

redirect -tee -file $RPT_DIR/place_pre_check.rpt \
    "check_design -checks pre_placement_stage -log_file $RPT_DIR/place_check.log"

####################################################################
## Synthesis and placement
####################################################################
# The design arrives with its scan chain in it. The placer would
# reorder that chain given a scan definition, and the patterns were
# generated for the order it has, so it runs without one.
set_app_options -name place.coarse.continue_on_missing_scandef -value true

# A failure here is a bare "Error: 1" whose reason is in error_info.
if { [catch {compile_fusion} msg] } {
    puts "compile_fusion failed: $msg"
    catch {redirect -tee -file $RPT_DIR/compile_error_info.rpt {error_info}}
    error "compile_fusion failed. See $RPT_DIR/compile_error_info.rpt."
}

add_tie_cells \
    -tie_high_lib_cells [get_lib_cells */$TIE_HI_CELL] \
    -tie_low_lib_cells  [get_lib_cells */$TIE_LO_CELL]

# Before the rails, or the tie cells' pins cut them.
connect_pg_net -automatic

legalize_placement

source scripts/rails.tcl

# 50 overlaps here are the bond pads on their IO cells.
redirect -tee -file $RPT_DIR/place_legality.rpt {check_legality}

lab_reports place
save_block -label place
save_lib

source scripts/backend.tcl
