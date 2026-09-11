####################################################################
##
##  Kit, pad libraries, flow settings and directories, then the
##  design file. Sourced first by every flow script.
##
##  Author:   Sne Samal
##  Version:  2.2
##  Date:     2026-09-10
##
####################################################################

if { ![info exists env(SYN_KIT_TCL)] } { error "SYN_KIT_TCL is not set. Load the PDK first." }

source $env(SYN_KIT_TCL)
source scripts/pll.tcl

# The IO, bond pad and PLL libraries, which the labs leave out.
set REF_LIBS [concat $REF_LIBS $PAD_REF_LIBS $PLL_NDM]

set DESIGN TOP

set DESIGN_SIM_MODELS  {}
set DESIGN_ATPG_MODELS {}

proc need_design {} {
    global DESIGN_TOP
    if { $DESIGN_TOP eq "" } {
        error "No design. design.tcl must set DESIGN_TOP, DESIGN_RTL and DESIGN_SDC."
    }
}

####################################################################
## Power plan
####################################################################
# Numbers from the floorplan this chip is ported from. A full die
# carries its supplies on the thick upper metals, not on the kit's
# RING_* layers, which are chosen for a small block.

set CHIP_RING_H_LAYER M5     ;# top and bottom segments
set CHIP_RING_V_LAYER M6     ;# left and right segments
set CHIP_RING_WIDTH   8
set CHIP_RING_SPACING 4
set CHIP_RING_OFFSET  1

set CHIP_MESH_LAYER   M6
set CHIP_MESH_WIDTH   6
set CHIP_MESH_SPACING 3
set CHIP_MESH_PITCH   100
set CHIP_MESH_OFFSET  50

# Rings around the hard macros, inside their keepouts. Offsets are
# from the macro edge outward, and at least 1.5 um, the fat metal
# spacing to any wide metal at the macro's edge.
set MACRO_RING_WIDTH   3
set MACRO_RING_SPACING 2

# Design macros: rings on M3/M4, joined from above by the M6 mesh.
# MACRO_RING 0 leaves them out; the PLL is not affected.
set MACRO_RING          1
set MACRO_RING_H_LAYER  M3
set MACRO_RING_V_LAYER  M4
set MACRO_RING_OFFSET   1.5
set MACRO_CONN_LAYERS   { M3 M4 }

# The PLL ring: horizontal segments on M5 so that each of its pins
# can be strapped north on its own layer, see scripts/powerplan.tcl.
# 1 um at top and bottom keeps the outer segment 1.5 um from the
# core ring above it.
set PLL_RING_H_LAYER  M5
set PLL_RING_V_LAYER  M4
set PLL_RING_OFFSET_X 1.5
set PLL_RING_OFFSET_Y 1.0

# Supply pads, strapped from their core-side fingers.
set PAD_STUB_LAYER      M2
set PAD_COLLECTOR_GAP   1.6    ;# fat metal spacing to the pad's obstructions
set PAD_COLLECTOR_WIDTH 2
set PAD_TRUNK_LAYER_H   M7     ;# west and east pads
set PAD_TRUNK_LAYER_V   M6     ;# south and north pads
set PAD_TRUNK_WIDTH     4
set PAD_TRUNK_COUNT     2

# Keepout around a design macro, in um, as left bottom right top.
set DESIGN_MACRO_HALO { 10 10 10 10 }

####################################################################
## DFT
####################################################################
# The ports make dft creates on the design; TOP.v connects each to
# the pad of the same name. Scan clocks and reset are in design.tcl.

set SCAN_EN_PORT   scan_en
set TEST_MODE_PORT scan_testmode
set SCAN_IN_PORT   scan_di
set SCAN_OUT_PORT  scan_do

set CHAIN_COUNT 1
set TEST_MODE   Internal_scan
set SCAN_CLOCK_TIMING {45 55}

####################################################################
## Analysis
####################################################################

set DERATE_EARLY 0.95
set DERATE_LATE  1.05

# Extra late derate while the chip is optimized, taken off before the
# routed reports: each stage closes to zero slack on its estimate of
# the wires and the routed wires cost a little more.
set PREROUTE_DERATE_MARGIN 0.05

set SDF_CORNER tc
set MAX_CORES  8
set POWER_SCENARIO func_tc

####################################################################
## The design
####################################################################
# design.tcl beside the Makefile, last so that it overrides anything
# above. DESIGN_TCL names another file, for the test vehicle.

set DESIGN_TCL design.tcl
if { [info exists env(DESIGN_TCL)] } { set DESIGN_TCL $env(DESIGN_TCL) }
if { ![file exists $DESIGN_TCL] } { error "No $DESIGN_TCL." }
source $DESIGN_TCL

# Said once, because a session with the wrong file builds the empty
# padframe for an hour without complaint.
puts "Design file $DESIGN_TCL: [expr {$DESIGN_TOP eq "" ? "no design, the padframe alone" : $DESIGN_TOP}]"

source scripts/memories.tcl
if { [llength $MEMORIES] } {
    set REF_LIBS      [concat $REF_LIBS [mem_ndm_list]]
    set CORNER_LABELS [list $SRAM_LABEL]
    set DESIGN_GDS    [mem_gds_list]
    foreach m $MEMORIES {
        lassign $m cell dir corner
        lappend DESIGN_SIM_MODELS  [mem_v $dir $corner]
        lappend DESIGN_ATPG_MODELS [mem_tmax $dir]
    }
}

####################################################################
## Directories and files
####################################################################

set WORK_DIR work
set OUT_DIR  outputs
set RPT_DIR  reports
set LOG_DIR  logs

foreach d [list $WORK_DIR $OUT_DIR $RPT_DIR $LOG_DIR] { file mkdir $d }

set CHIP_LIB   $WORK_DIR/${DESIGN}.dlib
set LAYOUT_V   $OUT_DIR/${DESIGN}_layout.v
set LVS_V      $OUT_DIR/${DESIGN}_lvs.v
set LAYOUT_GDS $OUT_DIR/${DESIGN}.gds
set LAYOUT_SVF $OUT_DIR/${DESIGN}_layout.svf

set SYN_LIB   $WORK_DIR/${DESIGN_TOP}_syn.dlib
set DFT_LIB   $WORK_DIR/${DESIGN_TOP}_dft.dlib
set SYNTH_V   $OUT_DIR/${DESIGN_TOP}_synth.v
set SYNTH_SDC $OUT_DIR/${DESIGN_TOP}_synth.sdc
set SYNTH_SVF $OUT_DIR/${DESIGN_TOP}_synth.svf
set DFT_V     $OUT_DIR/${DESIGN_TOP}_dft.v
set DFT_SDC   $OUT_DIR/${DESIGN_TOP}_dft.sdc
set DFT_SVF   $OUT_DIR/${DESIGN_TOP}_dft.svf
set DFT_SPF   $OUT_DIR/${DESIGN_TOP}_dft.spf
set PATTERNS  $OUT_DIR/${DESIGN_TOP}_patterns.stil

# What the chip reads in place of the design's RTL.
set DESIGN_NETLIST $DFT_V

####################################################################
## Reports
####################################################################

proc lab_reports {stage {physical 1}} {
    global RPT_DIR POWER_SCENARIO

    redirect -file $RPT_DIR/${stage}_timing_max.rpt \
        {report_timing -delay_type max -max_paths 10}
    redirect -file $RPT_DIR/${stage}_timing_min.rpt \
        {report_timing -delay_type min -max_paths 10}
    redirect -file $RPT_DIR/${stage}_area.rpt {report_area}
    redirect -file $RPT_DIR/${stage}_qor.rpt  {report_qor}
    catch {redirect -file $RPT_DIR/${stage}_power.rpt \
        "report_power -scenarios $POWER_SCENARIO"}

    if { $physical } {
        catch {redirect -file $RPT_DIR/${stage}_utilization.rpt {report_utilization}}
        catch {redirect -file $RPT_DIR/${stage}_congestion.rpt  {report_congestion}}
    }
}
