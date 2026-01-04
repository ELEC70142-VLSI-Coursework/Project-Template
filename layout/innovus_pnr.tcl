####################################################################
##
##          INNOVUS PnR FLOW SCRIPT
## 
####################################################################

## This script performs Place and Route using Cadence Innovus
## Author: Luca Ridolfi
## Date: December 2025

####################################################################
## Design Variables Setup
####################################################################

#Top-level module name
set DESIGN TOP  
set VERILOG_FILES [list DATA/TOP.v DATA/YOUR_DESIGN_synth.v]
set SDC_FILE DATA/YOUR_DESIGN_synth.sdc


####################################################################
## Environment Setup
####################################################################

## Include SRAM libraries if your design uses any SRAM macros.

set init_verilog ${VERILOG_FILES}
set init_top_cell ${DESIGN}
set init_lef_file { \
    /usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tcbn65lpbwp7t_141a/lef/tcbn65lpbwp7t_9lmT2.lef \
    /usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tphn65lpnv2od3_sl_200b/mt_2/9lm/lef/tphn65lpnv2od3_sl_9lm.lef \
    /usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tpbn65v_200b/wb/9m/9M_6X2Z/lef/tpbn65v_9lm.lef \
    ../PLL/PLL_25M_400M.lef \
    }
set init_mmmc_file "./DATA/mmmc_timing.tcl"

set init_gnd_net {VSS}
set init_pwr_net {VDD}


setDesignMode -process 65
setNanoRouteMode -routeTopRoutingLayer 7

init_design

loadFPlan ./DATA/floorplan/floorplan.fp

#####################################################################
## Floorplan Setup  
#####################################################################

# # If you need to place macros, delete the well taps and the special nets then
# # place the macros and re-add well taps and special nets afterwards.

# deleteInst welltap*
# editDelete -area {103 103 896 896} -type Special

# # Place macro instances here 
# # Example:
# # placeInstance TOP/<mydesign>/memory_inst x y orientation

# addRing -around each_block -type block_rings -width 3 -spacing 2 -offset 1 -layer {top M1 bottom M1 left M2 right M2} -nets { VSS VDD }
# addHaloToBlock 10 10 10 10 -allBlock

# addWellTap -cell TAPCELLBWP7T -prefix welltap -cellInterval 60 -checkerBoard
# sroute -nets { VSS VDD} -allowJogging true -allowLayerChange true -blockPin useLef -connect {blockPin padPin padRing corePin floatingStripe } -padPinPortConnect {allGeom}


# Define power and ground connections
globalNetConnect VSS -type pgpin -pin VSS -all -override
globalNetConnect VDD -type pgpin -pin VDD -all -override
globalNetConnect VDD -type tiehi -pin VDD -all -override
globalNetConnect VSS -type tielo -pin VSS -all -override

# Add power stripes
addStripe  -nets {VDD VSS} -layer 6 -width 6 -spacing 3 -start 50 -set_to_set_distance 100 -direction vertical

# Define the scan chain
specifyScanChain scan_chain -start pad_scan_di -stop pad_scan_do
setScanReorderMode -compLogic true
scanTrace -lockup -verbose


timeDesign -prePlace -expandedViews -outDir ./REPORTS/prePlace -prefix prePlace



####################################################################
## Placement 
####################################################################


setPlaceMode -timingDriven true -congEffort auto  
place_opt_design 

setTieHiLoMode -maxFanout 10 -maxDistance 50
addTieHiLo -cell "TIEHBWP7T TIELBWP7T" 

timeDesign -preCTS -outDir REPORTS/preCTS -prefix preCTS


saveDesign ./SAVES/${DESIGN}_postPlace.enc

####################################################################
## Clock Tree Synthesis 
####################################################################

## OPTIONAL
# add_ndr -name default_2x_space -spacing {MET1 1 MET2:MET4 1.5}
# create_route_type -name leaf_rule  -non_default_rule default_2x_space -top_preferred_layer MET4 -bottom_preferred_layer MET2
# create_route_type -name trunk_rule -non_default_rule default_2x_space -top_preferred_layer MET4 -bottom_preferred_layer MET2 -shield_net GND -shield_side both_side
# create_route_type -name top_rule   -non_default_rule default_2x_space -top_preferred_layer MET4 -bottom_preferred_layer MET2 -shield_net GND -shield_side both_side
# set_ccopt_property route_type -net_type leaf  leaf_rule
# set_ccopt_property route_type -net_type trunk trunk_rule
# set_ccopt_property route_type -net_type top   top_rule


set_ccopt_property buffer_cells {CKBD0BWP7T CKBD1BWP7T CKBD2BWP7T CKBD3BWP7T CKBD4BWP7T CKBD6BWP7T CKBD8BWP7T CKBD10BWP7T CKBD12BWP7T}
set_ccopt_property inverter_cells {CKND0BWP7T CKND1BWP7T CKND2BWP7T CKND3BWP7T CKND4BWP7T CKND6BWP7T CKND8BWP7T CKND10BWP7T CKND12BWP7T}


## OPTIONAL
## Adjust the values as required
set_ccopt_property target_max_trans 130ps 
set_ccopt_property target_skew 200ps
set_ccopt_property max_fanout 20

setOptMode -usefulSkew true
setOptMode -usefulSkewCCOpt extreme

create_ccopt_clock_tree_spec -file REPORTS/ctsspec.tcl
source REPORTS/ctsspec.tcl
ccopt_design -check_prerequisites
ccopt_design

optDesign -postCTS -setup -hold -outDir REPORTS/postCTSOptTiming
timeDesign -postCTS -expandedViews -outDir REPORTS/postCTS -prefix postCTS
report_ccopt_clock_trees -file REPORTS/postCTS/clock_trees.rpt
report_ccopt_skew_groups -file REPORTS/postCTS/skew_groups.rpt

saveDesign ./SAVES/${DESIGN}_postCTS.enc


####################################################################
## Routing 
####################################################################

routeDesign 

## Set analysis on on-chip variation (OCV) mode 
setAnalysisMode -analysisType onChipVariation -skew true -clockPropagation sdcControl
optDesign -postRoute -setup
optDesign -postRoute -hold


## Saving the design
saveDesign ./SAVES/${DESIGN}_postRoute.enc

####################################################################
## Signoff 
####################################################################

# Add filler cells.
addFiller -cell {FILL1BWP7T FILL2BWP7T FILL4BWP7T FILL8BWP7T FILL16BWP7T FILL32BWP7T FILL64BWP7T} -doDRC

# Verify DRC, Connectivity, Geometry, Power Via
verify_drc -limit 100000
verifyConnectivity
verifyGeometry
verifyPowerVia


timeDesign -postRoute -expandedViews -outDir REPORTS/postRoute -prefix postRoute


## Saving the design
saveDesign ./SAVES/${DESIGN}_done.enc


####################################################################
## Export Design
####################################################################

## Export final netlist to Verilog format
saveNetlist OUTPUTS/[format "%s_soc.v" $DESIGN]

## Export delay information to SDF format
write_sdf OUTPUTS/${DESIGN}.sdf 

## Exporting the design to LEF format
write_lef_abstract OUTPUTS/${DESIGN}.lef -stripePin

# Builds a Liberty (.lib) format model for the top cell, which is the timing model
do_extract_model OUTPUTS/${DESIGN}.lib  -view functional_typ

## Export parasitics to SPEF format
extractRC -outfile ${DESIGN}.cap
rcOut -spef OUTPUTS/${DESIGN}.spef

## Exporting the design to GDSII format
streamOut OUTPUTS/${DESIGN}.gds -structureName ${DESIGN} \
                                -mode ALL  \
                                -attachInstanceName 13 -attachNetName 13 \
                                -dieAreaAsBoundary \
                                -merge { \
                                    ../PLL/PLL_25M_400M.gds \
                                    } \
                                -mapFile "./DATA/gds2.map"



####################################################################
## Other Operations 
####################################################################

########   Retrieving the design
#  restoreDesign filename.enc.dat top_cell_name


########   Add metal fill to increase the density of the design.
# setMetalFill -layer METAL2 -windowSize 10 10 -windowStep 5 5
# addMetalFill

########   Fixing DRC violations
########   delete the routing of the nets with violations and re-route them
# editDelete -regular_wire_with_drc
# routeDesign
# verify_drc -limit 10000

## Delete top Layers and re route after setting top preferred layer
# setDesignMode -topRoutingLayer 7
# editDelete -layer {M7 M8 M9}
# editDelete -floating_via

# setNanoRouteMode -drouteFixAntenna true
# setNanoRouteMode -routeAntennaDiodeCellName "ANTENNA"
# setNanoRouteMode -routeInsertAntennaDiode true
