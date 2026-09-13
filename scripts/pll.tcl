####################################################################
##
##  Paths to the PLL's delivered views and its built reference
##  library. The only place the PLL is named.
##
##  Author:   Sne Samal
##  Version:  1.1
##  Date:     2026-09-10
##
####################################################################

set PLL_DIR  PLL
set PLL_CELL PLL_25M_400M
set PLL_INST pll

# No Liberty and no Verilog model: the output is constrained with
# create_clock on pll/f_out, and ATPG treats the PLL as a black box.
set PLL_LEF $PLL_DIR/${PLL_CELL}.lef
set PLL_GDS $PLL_DIR/${PLL_CELL}.gds
set PLL_SPI $PLL_DIR/${PLL_CELL}.sp

set PLL_NDM $PLL_DIR/NDM/${PLL_CELL}.ndm

# The supply pins on its north edge. DVDD is the digital supply and
# shares VDD.
set PLL_PG_PINS { DVDD VDD VSS }
