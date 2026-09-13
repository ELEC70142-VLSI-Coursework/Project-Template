####################################################################
##
##  Logic equivalence check of the layout netlist against TOP.v with
##  the design's scan-inserted netlist inside it, in Formality.
##
##  Author:   Sne Samal
##  Version:  1.1
##  Date:     2026-09-10
##
##      fm_shell -f scripts/lec_chip.tcl
##
####################################################################
# The PLL and the bond pads have no model and are black boxes.

source scripts/setup.tcl
need_design

set_host_options -max_cores $MAX_CORES

foreach f [list $DFT_V $LAYOUT_V] {
    if { ![file exists $f] } { error "No $f. Run make dft and make fusion first." }
}

set_app_var synopsys_auto_setup true

set_svf $LAYOUT_SVF

set_app_var verification_clock_gate_hold_mode collapse_all_cg_cells
set_app_var verification_assume_reg_init none
set_app_var verification_failing_point_limit 0
set_app_var hdlin_unresolved_modules black_box

####################################################################
## Libraries
####################################################################

set lib_base [file tail [file dirname $STD_DB_DIR]]
set DBS [list $STD_DB_DIR/${lib_base}tc.db [io_db tc]]
foreach m $MEMORIES {
    lassign $m cell dir corner
    lappend DBS [mem_db $dir]
}
foreach db $DBS {
    if { ![file exists $db] } { error "No library at $db." }
}

####################################################################
## Reference: TOP.v around the design's netlist
####################################################################

foreach db $DBS { if { [read_db -r $db] != 1 } { error "read_db -r failed for $db." } }
if { [read_verilog -r [list $TOP_V $DFT_V]] != 1 } { error "read_verilog -r failed." }
if { [set_top r:/WORK/$DESIGN] != 1 } { error "Could not link the reference as r:/WORK/$DESIGN." }

####################################################################
## Implementation: the layout netlist
####################################################################

foreach db $DBS { if { [read_db -i $db] != 1 } { error "read_db -i failed for $db." } }
if { [read_verilog -i $LAYOUT_V] != 1 } { error "read_verilog -i failed for $LAYOUT_V." }
if { [set_top i:/WORK/$DESIGN] != 1 } {
    error "Could not link the layout netlist as i:/WORK/$DESIGN. Look for FE-LINK-2\
           warnings above."
}

####################################################################
## Match and verify
####################################################################

set_reference_design      r:/WORK/$DESIGN
set_implementation_design i:/WORK/$DESIGN

set match_log $RPT_DIR/lec_chip_match.log
redirect -tee -file $match_log { match }
set fh [open $match_log r]
set match_text [read $fh]
close $fh
set n_matched 0
regexp {([0-9]+) +Compare points matched by name} $match_text -> n_matched
if { $n_matched == 0 } {
    error "match paired up no compare points, so there is nothing to verify.\
           Look for FE-LINK warnings above."
}

redirect -file $RPT_DIR/lec_chip_unmatched.rpt {report_unmatched_points}
report_setup_status

verify

redirect -file $RPT_DIR/lec_chip_failing.rpt  {report_failing_points}
redirect -file $RPT_DIR/lec_chip_aborted.rpt  {report_aborted_points}
redirect -file $RPT_DIR/lec_chip_analysis.rpt {analyze_points -all}

report_status
print_message_info
