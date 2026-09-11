####################################################################
##
##  Clock tree, routing, chip finish and export.
##  Sourced by scripts/fusion.tcl once the core is placed.
##
##  Author:   Sne Samal
##  Version:  1.2
##  Date:     2026-09-10
##
####################################################################

####################################################################
## Clock tree synthesis
####################################################################
# Clock buffers and inverters only: exclude everything, then add back.

set cts_cells {}
foreach c [concat $CTS_BUFFERS $CTS_INVERTERS] { lappend cts_cells */$c }

suppress_message ATTR-12
set_lib_cell_purpose -exclude cts [get_lib_cells]
set_lib_cell_purpose -include cts [get_lib_cells $cts_cells]
unsuppress_message ATTR-12

set_clock_tree_options -target_skew 0.2 -clocks [all_clocks]
set_max_transition 0.13 -clock_path [all_clocks]
set_app_options -name cts.common.max_fanout -value 20

clock_opt

catch {redirect -file $RPT_DIR/cts_clock_qor.rpt  {report_clock_qor}}
catch {redirect -file $RPT_DIR/cts_clock_skew.rpt {report_clock_timing -type skew}}

lab_reports cts
save_block -label cts
save_lib

####################################################################
## Routing
####################################################################

route_auto
route_opt

redirect -tee -file $RPT_DIR/route_check.rpt {check_routes}

# Repair whatever check_routes found, until it finds nothing or four
# passes have run.
set pass 0
while { $pass < 4 } {
    incr pass
    if { [catch {route_detail -incremental true -initial_drc_from_input true} msg] } {
        puts "route_detail repair pass $pass skipped: $msg"
        break
    }
    redirect -tee -file $RPT_DIR/route_check_repaired.rpt {check_routes}
    set fh [open $RPT_DIR/route_check_repaired.rpt r]
    set out [read $fh]
    close $fh
    if { [regexp {TOTAL VIOLATIONS =\s+0\M} $out] } { break }
}

# What the repairs could not fix, with layer, place and net, one
# section per error data set. The sets exist in this session only.
if { [catch {
    redirect -file $RPT_DIR/route_drc_errors.rpt {
        foreach_in_collection ed [get_drc_error_data] {
            report_drc_errors -error_data $ed -report_type detailed
        }
    }
} msg] } {
    puts "route DRC listing skipped: $msg"
}

# Optimization is over: the signoff derate from here on.
foreach corner $CORNER_LABELS {
    current_scenario func_$corner
    set_timing_derate -late $DERATE_LATE -cell_delay -net_delay
}
current_scenario func_[lindex $CORNER_LABELS 0]

lab_reports route
save_block -label route
save_lib

####################################################################
## Chip finish
####################################################################
# Largest filler first, which the tool requires. The IO row fillers
# are already placed, from the padframe.

set fillers {}
foreach c $FILLER_CELLS { lappend fillers */$c }

create_stdcell_fillers -lib_cells [get_lib_cells $fillers]
connect_pg_net -automatic

save_block -label finish
save_lib

####################################################################
## Checks
####################################################################
# These report and do not stop the flow. Expected: 50 legality
# overlaps, the bond pads on their IO cells, and 33 PG DRC errors,
# the pad library's own. Standard cell internals are excluded from
# the PG DRC; the unfiltered count is kept for the record.

redirect -tee -file $RPT_DIR/finish_legality.rpt        {check_legality}
redirect -tee -file $RPT_DIR/finish_routes.rpt          {check_routes}
redirect -tee -file $RPT_DIR/finish_pg_drc.rpt \
    {check_pg_drc -ignore_std_cells -output $RPT_DIR/finish_pg_drc_errors.txt}
redirect -tee -file $RPT_DIR/finish_pg_drc_all.rpt      {check_pg_drc}
redirect -tee -file $RPT_DIR/finish_pg_connectivity.rpt \
    {check_pg_connectivity -write_connectivity_file $RPT_DIR/finish_pg_floating.txt}
redirect -tee -file $RPT_DIR/finish_lvs.rpt             {check_lvs -max_errors 0}

update_timing

lab_reports finish

####################################################################
## Export
####################################################################

# Legal Verilog names before anything is written, or the SDF carries
# escaped bus bits that VCS cannot match to the netlist.
change_names -rules verilog -hierarchy

# Fillers, taps, corners and bond pads have no Verilog models and
# the models declare no power ports, so both are left out. Not
# all_physical_cells: that class takes the IO pads with it.
set_svf -off
write_verilog -exclude {physical_only_cells pg_netlist} $LAYOUT_V

# The supply pads whose only pins are power and ground count as
# physical-only cells and are left out above, but they are devices
# in the layout, so the LVS netlist is the same file with them put
# back before the top module's endmodule.
set pg_pads {}
foreach ref [list $IO_PWR_CELL $IO_GND_CELL] {
    foreach_in_collection c [get_cells -quiet -filter "ref_name == $ref"] {
        lappend pg_pads "$ref [get_object_name $c] ( );"
    }
}
set fh [open $LAYOUT_V r]
set v [read $fh]
close $fh
set at [string first "endmodule" $v [string first "module $DESIGN" $v]]
set fh [open $LVS_V w]
puts -nonewline $fh [string range $v 0 [expr {$at - 1}]]
foreach l $pg_pads { puts $fh $l }
puts -nonewline $fh [string range $v $at end]
close $fh

write_def $OUT_DIR/${DESIGN}.def
write_sdc -output $OUT_DIR/${DESIGN}_final.sdc
write_sdf -corner $SDF_CORNER $OUT_DIR/${DESIGN}_${SDF_CORNER}.sdf
write_parasitics -corner $SDF_CORNER -output $OUT_DIR/${DESIGN}

# The database holds no cell geometry: every cell and macro stream
# has to be merged in or the GDS is a layout of empty boxes.
set merge [list $CELL_GDS $IO_GDS $BPAD_GDS $PLL_GDS]
if { [info exists DESIGN_GDS] } { set merge [concat $merge $DESIGN_GDS] }

write_gds \
    -layer_map   $GDS_MAP \
    -merge_files $merge \
    -design      $DESIGN \
    $LAYOUT_GDS

save_block -label finish
save_lib
