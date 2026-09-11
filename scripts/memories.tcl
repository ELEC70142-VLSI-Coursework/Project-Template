####################################################################
##
##  Where a compiled memory's views are, relative to the directory
##  memcomp wrote. The memories themselves are listed in design.tcl.
##
##  Author:   Sne Samal
##  Version:  2.0
##  Date:     2026-09-10
##
####################################################################

proc mem_lef {dir} { return $dir/LEF/${dir}_5m.lef }
proc mem_lib {dir corner} { return $dir/SYNOPSYS/${dir}_${corner}.lib }
proc mem_gds {dir} { return $dir/GDSII/${dir}.gds }
proc mem_db  {dir} { return $dir/DB/${dir}.db }
proc mem_ndm {dir} { return $dir/NDM/${dir}.ndm }
proc mem_v   {dir corner} { return $dir/VERILOG/${dir}_${corner}.v }

# The TestMAX model; the behavioural one is for VCS only.
proc mem_tmax {dir} { return $dir/DFT/ATPG/${dir}_tmax.v }

# The library name declared inside the Liberty is not reliably the filename.

proc mem_lib_name {path} {
    set fh [open $path r]
    while { [gets $fh line] >= 0 } {
        if { [regexp {^\s*library\s*\(\s*"?([^")]+)"?\s*\)} $line -> name] } {
            close $fh
            return [string trim $name]
        }
    }
    close $fh
    error "No library declaration found in $path"
}

proc mem_ndm_list {} {
    global MEMORIES
    set l {}
    foreach m $MEMORIES { lappend l [mem_ndm [lindex $m 1]] }
    return $l
}

proc mem_gds_list {} {
    global MEMORIES
    set l {}
    foreach m $MEMORIES { lappend l [mem_gds [lindex $m 1]] }
    return $l
}
