####################################################################
##
##  Mode, corner and scenario, and the SDC read into them.
##  Sourced once a block exists; the caller sets PHYSICAL and SDC_FILE.
##
##  Author:   Sne Samal
##  Version:  1.2
##  Date:     2026-09-10
##
####################################################################

if { ![info exists PHYSICAL] } { error "Set PHYSICAL to 1 or 0 before sourcing mcmm.tcl" }
if { ![info exists SDC_FILE] } { error "Set SDC_FILE before sourcing mcmm.tcl" }

catch {remove_scenarios -all}
catch {remove_corners   -all}
catch {remove_modes     -all}

if { $PHYSICAL } {
    read_parasitic_tech -tlup $TLUPLUS_TYP -name rctyp
}

create_mode func
current_mode func

foreach corner $CORNER_LABELS {

    create_corner $corner
    current_corner $corner

    set_process_label $corner
    set_temperature   $CORNER_TEMP($corner)

    # The core supply only: the IO rail is formed by abutment and has
    # no net to set a voltage on, hence the PVT mismatch warnings.
    set_voltage $CORNER_VOLTAGE($corner) -object_list $PWR_NET
    set_voltage 0.0                      -object_list $GND_NET

    if { $PHYSICAL } {
        set_parasitic_parameters -late_spec rctyp -early_spec rctyp
    }

    create_scenario -name func_$corner -mode func -corner $corner
    current_scenario func_$corner

    # read_sdc reports an error and carries on with the rest skipped.
    set sdc_log $RPT_DIR/read_sdc_$corner.log
    redirect -tee -file $sdc_log { read_sdc $SDC_FILE }
    set fh [open $sdc_log r]
    set sdc_out [read $fh]
    close $fh
    if { [string match {*Errors reading SDC file*} $sdc_out] } {
        error "read_sdc reported errors for scenario func_$corner.\
               The rest of $SDC_FILE was skipped. See $sdc_log."
    }

    # Inputs are driven by pads or off the board, not by a cell.
    set_input_transition 0.5 [all_inputs]

    set_timing_derate -early $DERATE_EARLY -cell_delay -net_delay
    set_timing_derate -late  $DERATE_LATE  -cell_delay -net_delay

    set_scenario_status func_$corner -active true \
        -setup true -hold true \
        -max_transition true -max_capacitance true \
        -leakage_power true  -dynamic_power true
}

current_scenario func_[lindex $CORNER_LABELS 0]

if { [sizeof_collection [all_clocks]] == 0 } {
    error "No clock after reading $SDC_FILE. Look for 'Errors reading SDC file' above."
}

report_clocks
