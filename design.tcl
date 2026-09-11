####################################################################
##
##  Design settings: the one file a team edits. Sourced by
##  scripts/setup.tcl after every default, so anything set here wins.
##
##  Author:   Sne Samal
##  Version:  1.1
##  Date:     2026-09-10
##
####################################################################

####################################################################
## The design
####################################################################
# Top module, RTL and constraints of the design TOP.v wraps. Empty
# in the template, which then builds the padframe with nothing inside.
#
#   set DESIGN_TOP mychip
#   set DESIGN_RTL [glob rtl/*.sv]
#   set DESIGN_SDC constraints/mychip.sdc

set DESIGN_TOP ""
set DESIGN_RTL [list]
set DESIGN_SDC ""

####################################################################
## The chip
####################################################################

set TOP_V    layout/DATA/TOP.v
set CHIP_SDC constraints/TOP.sdc

####################################################################
## Scan
####################################################################
# The design's clock ports scan shifts on, and its reset port.

set DESIGN_SCAN_CLOCKS {clk}
set DESIGN_RESET_PORT  rst_n

####################################################################
## Memories
####################################################################
# { cell  directory memcomp wrote  characterisation corner }
#
#   set MEMORIES {
#       { TS1N65LPLL256X32M4  ts1n65lpll256x32m4_220a  tt1p2v25c }
#   }

set MEMORIES {}

# The kit corner the memories stand in for; with memories present
# every scenario stands at this one.
set SRAM_LABEL tc

# { lib_cell  llx  lly  orientation } in um. Keep macros 25 um inside
# the core, 105 to 895, and clear of the PLL, 118 to 405 by 691 to 885.
#
#   set DESIGN_MACROS {
#       { TS1N65LPLL256X32M4  563 556  R0 }
#   }

set DESIGN_MACROS {}
