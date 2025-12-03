####################################################################
##
##          INNOVUS PnR FLOW SCRIPT
## 
####################################################################


####################################################################
## Design Variables Setup
####################################################################

#Top-level module name
set DESIGN TOP
set VERILOG_FILES [list DATA/TOP.v]

set IO_FILE DATA/chip_pads.io

# Set Power Ring parameters (in um)
# The power ring is a rectangular area around the core that provides power and ground connections.
# -width: Width of the wires
# -spacing: Spacing between the wires
# -offset: Offset from the core boundary
set POWER_RING_WIDTH 8
set POWER_RING_SPACING 4
set POWER_RING_OFFSET 1


####################################################################
## Environment Setup
####################################################################

set init_verilog ${VERILOG_FILES}
set init_top_cell ${DESIGN}
set init_lef_file { \
    /usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tcbn65lpbwp7t_141a/lef/tcbn65lpbwp7t_9lmT2.lef \
    /usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tphn65lpnv2od3_sl_200b/mt_2/9lm/lef/tphn65lpnv2od3_sl_9lm.lef \
    /usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tpbn65v_200b/cup/9m/9M_6X1Z1U/lef/tpbn65v_9lm.lef \
    ./DATA/PLL_25M_400M.lef \
    }

set init_gnd_net {VSS}
set init_pwr_net {VDD}


set init_io_file ${IO_FILE}


setDesignMode -process 65

init_design


#####################################################################
## Floorplan Setup  
#####################################################################
floorplan -b {0 0 1000 1000 75 75 925 925 105 105 895 895}

## Place PLL macro
placeInstance TOP/pll 118 691


## IO Pads filler
addIoFiller -cell {PFILLER0005 PFILLER05 PFILLER1 PFILLER5 PFILLER10 PFILLER20} -prefix FILLER -side n -row 1
addIoFiller -cell {PFILLER0005 PFILLER05 PFILLER1 PFILLER5 PFILLER10 PFILLER20} -prefix FILLER -side e -row 1
addIoFiller -cell {PFILLER0005 PFILLER05 PFILLER1 PFILLER5 PFILLER10 PFILLER20} -prefix FILLER -side w -row 1
addIoFiller -cell {PFILLER0005 PFILLER05 PFILLER1 PFILLER5 PFILLER10 PFILLER20} -prefix FILLER -side s -row 1

## Power/Ground Connections
globalNetConnect VSS -type pgpin -pin VSS -all -override
globalNetConnect VDD -type pgpin -pin VDD -all -override
globalNetConnect VDD -type tiehi -pin VDD -all -override
globalNetConnect VSS -type tielo -pin VSS -all -override

## Load IO file
loadIoFile ./DATA/chip_pads.io


addRing -width ${POWER_RING_WIDTH} -spacing ${POWER_RING_SPACING} -offset ${POWER_RING_OFFSET} -layer {top M5 bottom M5 left M6 right M6} -center 1 -nets { VSS VDD }

## Add power ring and halo around PLL block
addRing -around each_block -type block_rings -width 3 -spacing 2 -offset 1 -layer {top M1 bottom M1 left M2 right M2} -nets { VSS VDD }
addHaloToBlock 10 10 10 10 pll

## Special routing for power and ground nets
sroute -nets { VSS VDD} -allowJogging true -allowLayerChange true -blockPin useLef -connect {blockPin padPin padRing corePin floatingStripe } -padPinPortConnect {allGeom} 

# ## Well Tap Insertion
addWellTap -cell TAPCELLBWP7T -prefix welltap -cellInterval 60 -checkerBoard

## Save Floorplan
saveFPlan floorplan.fp