####################################################################
##
##  Logic equivalence check of the scan-inserted netlist against the
##  RTL, in Formality.
##
##  Author:   Sne Samal
##  Version:  1.1
##  Date:     2026-09-10
##
##      fm_shell -f scripts/lec.tcl
##
####################################################################

source scripts/setup.tcl
need_design

set_host_options -max_cores $MAX_CORES

if { ![file exists $DFT_V] } { error "No $DFT_V. Run make dft first." }

# The synthesis conventions, undriven signals included. Before set_svf.
set_app_var synopsys_auto_setup true

set_svf $SYNTH_SVF $DFT_SVF

# Synthesis put clock gating cells in front of the registers; without
# this every gated register is a failing point.
set_app_var verification_clock_gate_hold_mode collapse_all_cg_cells

set_app_var verification_assume_reg_init none
set_app_var verification_failing_point_limit 0

####################################################################
## Libraries
####################################################################

set lib_base [file tail [file dirname $STD_DB_DIR]]
set LIB_DB   $STD_DB_DIR/${lib_base}tc.db
if { ![file exists $LIB_DB] } { error "No library at $LIB_DB. Check STD_DB_DIR in the kit." }

set MEM_DBS {}
foreach m $MEMORIES {
    lassign $m cell dir corner
    lappend MEM_DBS [mem_db $dir]
}

####################################################################
## Reference: the RTL
####################################################################

if { [read_db -r $LIB_DB] != 1 } { error "read_db -r failed for $LIB_DB." }
foreach db $MEM_DBS { read_db -r $db }
if { [read_sverilog -r $DESIGN_RTL] != 1 } { error "read_sverilog -r failed." }
if { [set_top r:/WORK/$DESIGN_TOP] != 1 } { error "Could not link the RTL as r:/WORK/$DESIGN_TOP." }

####################################################################
## Implementation: the scan-inserted netlist
####################################################################

if { [read_db -i $LIB_DB] != 1 } { error "read_db -i failed for $LIB_DB." }
foreach db $MEM_DBS { read_db -i $db }
if { [read_verilog -i $DFT_V] != 1 } { error "read_verilog -i failed for $DFT_V." }
if { [set_top i:/WORK/$DESIGN_TOP] != 1 } {
    error "Could not link the netlist as i:/WORK/$DESIGN_TOP. Look for FE-LINK-2\
           warnings above: they name the cells that could not be resolved."
}

# The RTL has no test logic; held off, the scan path is transparent.
set_constant i:/WORK/$DESIGN_TOP/$SCAN_EN_PORT   0
set_constant i:/WORK/$DESIGN_TOP/$TEST_MODE_PORT 0

####################################################################
## Match and verify
####################################################################

set_reference_design      r:/WORK/$DESIGN_TOP
set_implementation_design i:/WORK/$DESIGN_TOP

set match_log $RPT_DIR/lec_match.log
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

redirect -file $RPT_DIR/lec_matched.rpt   {report_matched_points}
redirect -file $RPT_DIR/lec_unmatched.rpt {report_unmatched_points}
report_setup_status

verify

redirect -file $RPT_DIR/lec_passing.rpt   {report_passing_points}
redirect -file $RPT_DIR/lec_failing.rpt   {report_failing_points}
redirect -file $RPT_DIR/lec_aborted.rpt   {report_aborted_points}
redirect -file $RPT_DIR/lec_constants.rpt {report_constants}
redirect -file $RPT_DIR/lec_guidance.rpt  {report_guidance -summary}
redirect -file $RPT_DIR/lec_analysis.rpt  {analyze_points -all}

report_status
print_message_info
