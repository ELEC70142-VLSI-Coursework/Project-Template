####################################################################
##
##  Die, padring and hard macro placement.
##  Replays the frozen padframe; nothing here is computed.
##
##  Author:   Sne Samal
##  Version:  1.1
##  Date:     2026-09-10
##
####################################################################

source scripts/padframe.tcl

####################################################################
## Die
####################################################################

lassign $DIE_BOX  die_llx die_lly die_urx die_ury
lassign $CORE_BOX core_llx core_lly core_urx core_ury

initialize_floorplan \
    -site_def     $SITE_NAME \
    -control_type die \
    -boundary     [list [list $die_llx $die_lly] [list $die_urx $die_ury]] \
    -core_offset  [expr {$core_llx - $die_llx}]

####################################################################
## Padring
####################################################################
# Corner and filler cells are not in TOP.v and are created here. The
# pads that are in the netlist get dont_touch; a bond pad has no
# connections and would otherwise be removed as unloaded.
# physical_status fixed: is_fixed is read only in this release.

proc padframe_place {entries create} {
    foreach e $entries {
        lassign $e name cell side x y orient

        if { $create } {
            if { [sizeof_collection [get_cells -quiet $name]] == 0 } {
                create_cell $name $cell
            }
        } elseif { [sizeof_collection [get_cells -quiet $name]] == 0 } {
            error "$name is in the padframe but not in the netlist.\
                   scripts/padframe.tcl and TOP.v have diverged."
        }

        set c [get_cells $name]
        set_cell_location -coordinates [list $x $y] -orientation $orient $c
        set_attribute $c physical_status fixed
        if { !$create } { set_dont_touch $c true }
    }
}

padframe_place $PADFRAME_CORNERS 1
padframe_place $PADFRAME_IO      0
padframe_place $PADFRAME_BPADS   0
padframe_place $PADFRAME_FILLERS 1

####################################################################
## Hard macros
####################################################################

# A rotated macro presents its height as width.
proc macro_place {c x y orient halo} {
    global CORE_BOX
    set w [get_attribute $c width]
    set h [get_attribute $c height]
    if { $orient eq "R90" || $orient eq "R270" } { set t $w; set w $h; set h $t }

    set_cell_location -coordinates [list $x $y] -orientation $orient $c
    set_attribute $c physical_status fixed
    create_keepout_margin -type hard -outer $halo $c

    return [list [get_attribute $c full_name] \
                 $x $y [expr {$x + $w}] [expr {$y + $h}]]
}

lassign $PADFRAME_MACRO MACRO_NAME macro_x macro_y macro_orient

set MACRO  [get_cells $MACRO_NAME]
set MACROS $MACRO

set boxes [list [macro_place $MACRO $macro_x $macro_y $macro_orient \
                             $PADFRAME_MACRO_HALO]]

# Design macros are found by reference, so the placement survives
# whatever hierarchy the netlist has.
if { [info exists DESIGN_MACROS] } {
    foreach m $DESIGN_MACROS {
        lassign $m ref x y orient

        set c [get_cells -quiet -hierarchical * -filter "ref_name == $ref"]
        if { [sizeof_collection $c] != 1 } {
            error "[sizeof_collection $c] instances of $ref in the netlist,\
                   expected exactly one. Check design.tcl."
        }

        lappend boxes [macro_place $c $x $y $orient $DESIGN_MACRO_HALO]
        set MACROS [add_to_collection $MACROS $c]
    }
}

####################################################################
## Macro placement check
####################################################################
# A macro over the core edge or over another is otherwise reported
# much later, as a routing or legality failure.

lassign $CORE_BOX core_llx core_lly core_urx core_ury

set bad 0
foreach b $boxes {
    lassign $b name llx lly urx ury
    if { $llx < $core_llx || $lly < $core_lly ||
         $urx > $core_urx || $ury > $core_ury } {
        puts "MACRO OUTSIDE CORE: $name ($llx $lly) ($urx $ury)"
        incr bad
    }
}

for {set i 0} {$i < [llength $boxes]} {incr i} {
    for {set j [expr {$i + 1}]} {$j < [llength $boxes]} {incr j} {
        lassign [lindex $boxes $i] n1 a1 b1 c1 d1
        lassign [lindex $boxes $j] n2 a2 b2 c2 d2
        if { $a1 < $c2 && $a2 < $c1 && $b1 < $d2 && $b2 < $d1 } {
            puts "MACROS OVERLAP: $n1 and $n2"
            incr bad
        }
    }
}

if { $bad } { error "$bad macro placement problem(s). Fix design.tcl." }

foreach b $boxes {
    lassign $b name llx lly urx ury
    puts [format "  macro %-32s %7.1f %7.1f  %7.1f %7.1f" $name $llx $lly $urx $ury]
}

####################################################################
## Checks
####################################################################
# check_io_placement reports one flip violation per IO cell, because
# the pads sit on no IO guide; Overlap, Gap, Min Pitch and Unplaced
# Pads are the checks that matter.

redirect -tee -file $RPT_DIR/floorplan_check.rpt \
    "check_design -checks dp_pre_pin_placement \
         -log_file $RPT_DIR/floorplan_check.log"
catch {redirect -tee -file $RPT_DIR/floorplan_io.rpt {check_io_placement}}

save_block -label floorplan
save_lib
