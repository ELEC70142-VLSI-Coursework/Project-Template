####################################################################
##
##  Compile each memory's Liberty to a Synopsys database.
##  Library Manager reads db, and memcomp delivers only lib.
##
##  Author:   Sne Samal
##  Version:  1.1
##  Date:     2026-09-10
##
##      lc_shell -f scripts/sram_lib.tcl
##
####################################################################

source scripts/setup.tcl

# read_lib on a missing path leaves the shell interactive.
set missing {}
foreach m $MEMORIES {
    lassign $m cell dir corner
    if { ![file exists [mem_lib $dir $corner]] } { lappend missing [mem_lib $dir $corner] }
}
if { [llength $missing] } {
    puts "No Liberty at:"
    foreach f $missing { puts "  $f" }
    puts "Check the filenames memcomp wrote and correct design.tcl."
    exit 1
}

foreach m $MEMORIES {
    lassign $m cell dir corner
    file mkdir [file dirname [mem_db $dir]]
    set lib [mem_lib $dir $corner]
    read_lib $lib
    write_lib [mem_lib_name $lib] -format db -output [mem_db $dir]
}

exit 0
