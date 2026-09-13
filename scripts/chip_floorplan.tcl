####################################################################
##
##  The complete floorplan: padring, hard macros and power plan.
##  Everything that must exist before the core is placed.
##
##  Author:   Sne Samal
##  Version:  1.1
##  Date:     2026-09-10
##
##      fc_shell -f scripts/chip_floorplan.tcl
##
####################################################################

source scripts/padring.tcl
source scripts/powerplan.tcl

write_def $OUT_DIR/${DESIGN}_chip_floorplan.def
