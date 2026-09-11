####################################################################
##
##  Build each memory's NDM reference library from its LEF and db.
##  One library per memory, all appended to ref_libs.
##
##  Author:   Sne Samal
##  Version:  1.1
##  Date:     2026-09-10
##
##      lm_shell -f scripts/sram_ndm.tcl
##
####################################################################

source scripts/setup.tcl

# The Liberty lacks related_power_pin on some pins; the delimiters
# must match the Verilog and the SDC.
set_app_options -as_user_default \
    -name lib.workspace.allow_missing_related_pg_pins -value true
set_app_options -as_user_default -name design.bus_delimiters -value {[]}

set missing {}
foreach m $MEMORIES {
    lassign $m cell dir corner
    foreach f [list [mem_lef $dir] [mem_db $dir]] {
        if { ![file exists $f] } { lappend missing $f }
    }
}
if { [llength $missing] } {
    puts "Missing inputs:"
    foreach f $missing { puts "  $f" }
    puts "A missing db means lc_shell -f scripts/sram_lib.tcl has not run or failed."
    exit 1
}

foreach m $MEMORIES {
    lassign $m cell dir corner

    file mkdir [file dirname [mem_ndm $dir]]

    create_workspace $cell \
        -technology   $TECH_FILE \
        -flow         normal \
        -scale_factor $SCALE_FACTOR

    read_lef [mem_lef $dir]
    read_db  [mem_db $dir] -process_label $SRAM_LABEL

    process_workspaces -force -directory [file dirname [mem_ndm $dir]] \
        -output [file tail [mem_ndm $dir]]

    remove_workspace
}

set missing {}
foreach n [mem_ndm_list] { if { ![file exists $n] } { lappend missing $n } }

if { [llength $missing] } {
    puts "BUILD FAILED. Not written:"
    foreach n $missing { puts "  $n" }
    exit 1
}

puts "BUILD OK:"
foreach n [mem_ndm_list] { puts "  $n" }
exit 0
