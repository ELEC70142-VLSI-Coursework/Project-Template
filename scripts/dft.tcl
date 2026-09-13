####################################################################
##
##  Muxed scan insertion into the synthesized design, and the STIL
##  protocol make atpg reads.
##
##  Author:   Sne Samal
##  Version:  2.1
##  Date:     2026-09-10
##
##      fc_shell -f scripts/dft.tcl
##
####################################################################

source scripts/setup.tcl
need_design

set_host_options -max_cores $MAX_CORES

if { ![file exists $SYNTH_V] } { error "No $SYNTH_V. Run make synth first." }

if { [file exists $DFT_LIB] } { file delete -force $DFT_LIB }
create_lib $DFT_LIB -technology $TECH_FILE -ref_libs $REF_LIBS

set_non_physical_mode

set_svf $DFT_SVF

read_verilog -top $DESIGN_TOP $SYNTH_V
link_block

set PHYSICAL 0
set SDC_FILE $DESIGN_SDC
source scripts/mcmm.tcl

####################################################################
## Test ports and scan configuration
####################################################################

create_port $SCAN_EN_PORT   -direction in
create_port $TEST_MODE_PORT -direction in
create_port $SCAN_IN_PORT   -direction in
create_port $SCAN_OUT_PORT  -direction out

# The fix_ options gate asynchronous resets, sets and internal clocks
# with the test mode signal; without them every such flip-flop is
# uncontrollable in test.
set_dft_configuration -scan enable \
    -fix_clock enable -fix_set enable -fix_reset enable

# One chain may span clock domains, with lockup latches where it
# crosses one.
set_scan_configuration -style multiplexed_flip_flop \
    -chain_count  $CHAIN_COUNT \
    -clock_mixing mix_clocks

set_dft_signal -view spec -type ScanEnable  -port $SCAN_EN_PORT   -active_state 1
set_dft_signal -view spec -type TestMode    -port $TEST_MODE_PORT -active_state 1
set_dft_signal -view spec -type ScanDataIn  -port $SCAN_IN_PORT
set_dft_signal -view spec -type ScanDataOut -port $SCAN_OUT_PORT

foreach c $DESIGN_SCAN_CLOCKS {
    set_dft_signal -view existing_dft -type ScanClock -port $c -timing $SCAN_CLOCK_TIMING
}

# Undeclared, the reset reads as uncontrolled for every flip-flop.
set_dft_signal -view existing_dft -type Reset -port $DESIGN_RESET_PORT -active_state 0

####################################################################
## Protocol, rule check, insertion
####################################################################

create_test_protocol

redirect -tee -file $RPT_DIR/dft_drc_pre.rpt {dft_drc}
catch {redirect -file $RPT_DIR/dft_drc_pre_violations.rpt {report_dft_drc_violations}}

# A report that fails with a bare error when the rule check found
# something it cannot work around; the reason is in dft_drc_pre.rpt.
catch {redirect -file $RPT_DIR/dft_preview.rpt {preview_dft}}

# A failure here is a bare "Error: 0" whose reason is in error_info.
if { [catch {insert_dft} msg] } {
    puts "insert_dft failed: $msg"
    catch {redirect -tee -file $RPT_DIR/dft_error_info.rpt {error_info}}
    error "insert_dft failed. See $RPT_DIR/dft_error_info.rpt and\
           $RPT_DIR/dft_drc_pre.rpt."
}

redirect -tee -file $RPT_DIR/dft_drc_post.rpt {dft_drc}
catch {redirect -file $RPT_DIR/dft_drc_post_violations.rpt {report_dft_drc_violations}}

catch {redirect -file $RPT_DIR/dft_scan_path.rpt {report_scan_path}}
catch {redirect -file $RPT_DIR/dft_signals.rpt   {report_dft_signal}}
catch {redirect -file $RPT_DIR/dft_summary.rpt   {report_dft}}

lab_reports dft 0

####################################################################
## Export
####################################################################

set_svf -off
write_verilog $DFT_V
write_sdc -output $DFT_SDC
write_test_protocol -test_mode $TEST_MODE -output $DFT_SPF

# A protocol without a ScanStructures block describes no chain, and
# TestMAX then reports near zero coverage without saying why.
set fh [open $DFT_SPF r]
set spf [read $fh]
close $fh
if { ![string match {*ScanStructures*} $spf] } {
    error "$DFT_SPF has no ScanStructures block. Check that TEST_MODE ($TEST_MODE)\
           is the mode named in $RPT_DIR/dft_drc_post.rpt."
}

save_block
save_lib
