####################################################################
##
##  Supply nets, core ring, supply pad straps, mesh, macro rings
##  and tap cells. Sourced after the padring exists.
##
##  Author:   Sne Samal
##  Version:  1.2
##  Date:     2026-09-10
##
####################################################################

if { ![info exists MACROS] } { error "Source scripts/floorplan.tcl first; MACROS is unset." }

####################################################################
## Supply nets
####################################################################
# TOP.v does not name the supplies; a netlist that did would make
# them signal nets, so both are guarded.

if { [sizeof_collection [get_nets -quiet $PWR_NET]] == 0 } { create_net -power  $PWR_NET }
if { [sizeof_collection [get_nets -quiet $GND_NET]] == 0 } { create_net -ground $GND_NET }

connect_pg_net -automatic

# The PLL's digital supply pin has no net of its own name.
connect_pg_net -net [get_nets $PWR_NET] [get_pins $PLL_INST/DVDD]

####################################################################
## Via rules
####################################################################

set_pg_strategy_via_rule pg_via_rule \
    -via_rule [list [list intersection: adjacent] [list via_master: default]]

# For layers that are not neighbours: M1 rails to an M5/M6 ring.
set_pg_strategy_via_rule pg_stack_via_rule \
    -via_rule [list [list intersection: all] [list via_master: default]]

####################################################################
## Core ring
####################################################################

create_pg_ring_pattern chip_ring_pattern \
    -horizontal_layer   $CHIP_RING_H_LAYER \
    -horizontal_width   [list $CHIP_RING_WIDTH] \
    -horizontal_spacing [list $CHIP_RING_SPACING] \
    -vertical_layer     $CHIP_RING_V_LAYER \
    -vertical_width     [list $CHIP_RING_WIDTH] \
    -vertical_spacing   [list $CHIP_RING_SPACING]

# No extension to the pads: their die-edge pin taps are unreachable.
# The supply pads are strapped from their core-side fingers below.
set_pg_strategy chip_ring_strategy -core \
    -pattern   [list [list pattern: chip_ring_pattern] \
                     [list nets: [list $GND_NET $PWR_NET]] \
                     [list offset: [list $CHIP_RING_OFFSET $CHIP_RING_OFFSET]]]

compile_pg -strategies chip_ring_strategy -via_rule pg_via_rule

####################################################################
## Supply pads
####################################################################
# A supply pad's fingers, on M1 and M2 along its core-side edge, are
# the only reachable part of its pin: the pad obstructs M3 and above
# to its edge. Per pad: an M2 stub on each finger out to an M2
# collector bar just outside the pad, then wide trunks from the
# collector to the ring on a layer the channel does not use.

set via_all [list [list intersection: all] [list via_master: default]]

# The first net in the ring pattern is innermost.
proc chip_ring_inner_offset {net} {
    global GND_NET CHIP_RING_OFFSET CHIP_RING_WIDTH CHIP_RING_SPACING
    if { $net eq $GND_NET } { return $CHIP_RING_OFFSET }
    return [expr {$CHIP_RING_OFFSET + $CHIP_RING_WIDTH + $CHIP_RING_SPACING}]
}

proc chip_pad_connect {pad net} {
    global DIE_BOX CORE_BOX PAD_STUB_LAYER PAD_COLLECTOR_GAP PAD_COLLECTOR_WIDTH
    global PAD_TRUNK_LAYER_H PAD_TRUNK_LAYER_V PAD_TRUNK_WIDTH PAD_TRUNK_COUNT via_all

    lassign $DIE_BOX  dx1 dy1 dx2 dy2
    lassign $CORE_BOX cx1 cy1 cx2 cy2
    lassign [get_attribute $pad bbox] ll ur
    lassign $ll px1 py1
    lassign $ur px2 py2
    set name [get_object_name $pad]

    # The die edge the pad sits on sets the axis and direction.
    if { $px1 <= $dx1 } {
        set axis x; set sign  1; set edge $px2; set ring [expr {$cx1 - [chip_ring_inner_offset $net]}]
    } elseif { $px2 >= $dx2 } {
        set axis x; set sign -1; set edge $px1; set ring [expr {$cx2 + [chip_ring_inner_offset $net]}]
    } elseif { $py1 <= $dy1 } {
        set axis y; set sign  1; set edge $py2; set ring [expr {$cy1 - [chip_ring_inner_offset $net]}]
    } else {
        set axis y; set sign -1; set edge $py1; set ring [expr {$cy2 + [chip_ring_inner_offset $net]}]
    }
    if { $axis eq "x" } {
        set stub_dir horizontal; set coll_dir vertical;   set trunk_layer $PAD_TRUNK_LAYER_H
    } else {
        set stub_dir vertical;   set coll_dir horizontal; set trunk_layer $PAD_TRUNK_LAYER_V
    }

    # The fingers are the pin's M1 shapes, each listed twice in the LEF.
    set fingers {}
    set seen {}
    foreach_in_collection sh [get_shapes -of_objects [get_pins $name/$net]] {
        if { [get_attribute $sh layer_name] ne "M1" } { continue }
        set bb [get_attribute $sh bbox]
        if { [lsearch -exact $seen $bb] >= 0 } { continue }
        lappend seen $bb
        lassign $bb fll fur
        lassign $fll fx1 fy1
        lassign $fur fx2 fy2
        if { $axis eq "x" } {
            lappend fingers [list [expr {($fy1 + $fy2) / 2.0}] [expr {$fy2 - $fy1}] $fy1 $fy2 $fx1 $fx2]
        } else {
            lappend fingers [list [expr {($fx1 + $fx2) / 2.0}] [expr {$fx2 - $fx1}] $fx1 $fx2 $fy1 $fy2]
        }
    }
    if { ![llength $fingers] } { error "$name: no M1 finger on pin $net" }

    set c_near [expr {$edge + $sign * $PAD_COLLECTOR_GAP}]
    set c_far  [expr {$c_near + $sign * $PAD_COLLECTOR_WIDTH}]
    set c_lo [expr {min($c_near, $c_far)}]
    set c_hi [expr {max($c_near, $c_far)}]
    set span_lo 1e9
    set span_hi -1e9
    foreach f $fingers {
        lassign $f fc fw f1 f2
        if { $f1 < $span_lo } { set span_lo $f1 }
        if { $f2 > $span_hi } { set span_hi $f2 }
    }

    # No vias on stubs or collector: the finger is already joined to
    # its M1 inside the pad, and a second array on top of it is a DRC
    # error per cut.
    set via_none [list [list intersection: all] [list via_master: NIL]]

    create_pg_strap -net $net -layer $PAD_STUB_LAYER -direction $coll_dir \
        -width $PAD_COLLECTOR_WIDTH -start [expr {($c_lo + $c_hi) / 2.0}] \
        -low_end $span_lo -high_end $span_hi \
        -via_rule $via_none -mark_as macro_conn

    # A stub per finger, its own width, abutting the finger at the pad edge.
    foreach f $fingers {
        lassign $f fc fw f1 f2 g1 g2
        set inner [expr {$sign > 0 ? $g2 : $g1}]
        create_pg_strap -net $net -layer $PAD_STUB_LAYER -direction $stub_dir \
            -width $fw -start $fc \
            -low_end [expr {min($inner, $c_far)}] -high_end [expr {max($inner, $c_far)}] \
            -via_rule $via_none -mark_as macro_conn
    }

    # Trunks spread along the collector, clear of its ends and so of
    # the ring corners, with vias at both crossings.
    set step [expr {($span_hi - $span_lo) / double($PAD_TRUNK_COUNT + 1)}]
    for {set i 0} {$i < $PAD_TRUNK_COUNT} {incr i} {
        set tc [expr {$span_lo + ($i + 1) * $step}]
        create_pg_strap -net $net -layer $trunk_layer -direction $stub_dir \
            -width $PAD_TRUNK_WIDTH -start $tc \
            -low_end [expr {min($c_near, $ring)}] -high_end [expr {max($c_near, $ring)}] \
            -via_rule $via_all -mark_as strap
    }
}

foreach_in_collection pad [get_cells -filter "ref_name == $IO_PWR_CELL"] { chip_pad_connect $pad $PWR_NET }
foreach_in_collection pad [get_cells -filter "ref_name == $IO_GND_CELL"] { chip_pad_connect $pad $GND_NET }

####################################################################
## Mesh
####################################################################
# -layers takes one braced group per key. trim: false keeps the straps
# that end on the PLL, which obstructs M6; they feed its ring.

create_pg_mesh_pattern chip_mesh_pattern \
    -layers [list [list [list vertical_layer: $CHIP_MESH_LAYER] \
                        [list width:          $CHIP_MESH_WIDTH] \
                        [list spacing:        $CHIP_MESH_SPACING] \
                        [list pitch:          $CHIP_MESH_PITCH] \
                        [list offset:         $CHIP_MESH_OFFSET] \
                        [list trim:           false]]]

set_pg_strategy chip_mesh_strategy -core \
    -pattern [list [list pattern: chip_mesh_pattern] \
                   [list nets: [list $PWR_NET $GND_NET]]] \
    -extension [list [list stop: outermost_ring]]

compile_pg -strategies chip_mesh_strategy -via_rule pg_via_rule

####################################################################
## PLL ring and pin straps
####################################################################
# The PLL obstructs every layer, so its ring is fed from the channel
# around it, and its supply pins are too small to hold a via. Each
# pin is strapped north on its own layer into its net's segment; for
# that the horizontal segments are on M5 with VDD innermost.

create_pg_ring_pattern pll_ring_pattern \
    -horizontal_layer   $PLL_RING_H_LAYER \
    -horizontal_width   [list $MACRO_RING_WIDTH] \
    -horizontal_spacing [list $MACRO_RING_SPACING] \
    -vertical_layer     $PLL_RING_V_LAYER \
    -vertical_width     [list $MACRO_RING_WIDTH] \
    -vertical_spacing   [list $MACRO_RING_SPACING]

# Only the vertical sides extend to the core ring. Extending the
# horizontal ones would take the channel the cell rails beside the
# PLL need to reach the ring; the mesh straps via into them instead.
set_pg_strategy pll_ring_strategy \
    -macros    $MACRO \
    -pattern   [list [list pattern: pll_ring_pattern] \
                     [list nets: [list $PWR_NET $GND_NET]] \
                     [list offset: [list $PLL_RING_OFFSET_X $PLL_RING_OFFSET_Y]]] \
    -extension [list [list [list side: 1] [list stop: first_target]] \
                     [list [list side: 3] [list stop: first_target]]]

compile_pg -strategies pll_ring_strategy -via_rule pg_stack_via_rule

set pll_top   [expr {$macro_y + [get_attribute $MACRO height]}]
set ring_in   [expr {$pll_top + $PLL_RING_OFFSET_Y + $MACRO_RING_WIDTH}]
set ring_out  [expr {$ring_in + $MACRO_RING_SPACING + $MACRO_RING_WIDTH}]

foreach p $PLL_PG_PINS {
    set pin [get_pins $PLL_INST/$p]
    set net [get_object_name [get_nets -of_objects $pin]]
    set far [expr {$net eq $PWR_NET ? $ring_in : $ring_out}]

    foreach_in_collection sh [get_shapes -of_objects $pin] {
        lassign [get_attribute $sh bbox] ll ur
        lassign $ll x1 y1
        lassign $ur x2 y2
        create_pg_strap -net $net \
            -layer     [get_attribute $sh layer_name] \
            -direction vertical \
            -width     [expr {$x2 - $x1}] \
            -start     [expr {($x1 + $x2) / 2.0}] \
            -low_end   $y1 \
            -high_end  $far \
            -via_rule  $via_all \
            -mark_as   macro_conn
    }
}

####################################################################
## Design macro rings
####################################################################
# These macros obstruct M1 to M5 only, so the M6 mesh crosses their
# rings and vias into them; no extension is needed, and one would
# take the channel the cell rails beside them need.

set DESIGN_MACRO_CELLS [remove_from_collection $MACROS $MACRO]

if { $MACRO_RING && [sizeof_collection $DESIGN_MACRO_CELLS] } {

create_pg_ring_pattern macro_ring_pattern \
    -horizontal_layer   $MACRO_RING_H_LAYER \
    -horizontal_width   [list $MACRO_RING_WIDTH] \
    -horizontal_spacing [list $MACRO_RING_SPACING] \
    -vertical_layer     $MACRO_RING_V_LAYER \
    -vertical_width     [list $MACRO_RING_WIDTH] \
    -vertical_spacing   [list $MACRO_RING_SPACING]

set_pg_strategy macro_ring_strategy \
    -macros    $DESIGN_MACRO_CELLS \
    -pattern   [list [list pattern: macro_ring_pattern] \
                     [list nets: [list $GND_NET $PWR_NET]] \
                     [list offset: [list $MACRO_RING_OFFSET $MACRO_RING_OFFSET]]]

compile_pg -strategies macro_ring_strategy -via_rule pg_stack_via_rule
}

if { [sizeof_collection $DESIGN_MACRO_CELLS] } {

# Pins on the ring layers only; a pin on M5 is the mesh's to connect.
create_pg_macro_conn_pattern macro_conn_pattern \
    -pin_conn_type scattered_pin \
    -layers        $MACRO_CONN_LAYERS \
    -pin_layers    $MACRO_CONN_LAYERS

set_pg_strategy macro_conn_strategy \
    -macros  $DESIGN_MACRO_CELLS \
    -pattern [list [list pattern: macro_conn_pattern] \
                   [list nets: [list $PWR_NET $GND_NET]]]

compile_pg -strategies macro_conn_strategy -via_rule pg_stack_via_rule
}

connect_pg_net

####################################################################
## Tap cells
####################################################################

create_tap_cells \
    -lib_cell [get_lib_cells */$TAP_CELL] \
    -distance $TAP_DISTANCE \
    -pattern  stagger

# Every inserted cell must be on its net before the rails are built,
# or its pins count as foreign metal and the rail is cut around them.
connect_pg_net -automatic

####################################################################
## Checks
####################################################################
# 33 spacing errors are the pad library's own pin taps against its
# own obstructions, present from here on. See the flow notes.

redirect -tee -file $RPT_DIR/powerplan_connectivity.rpt \
    {check_pg_connectivity -check_std_cell_pins none}
redirect -tee -file $RPT_DIR/powerplan_drc.rpt \
    {check_pg_drc -output $RPT_DIR/powerplan_drc_errors.txt}

save_block -label powerplan
save_lib
