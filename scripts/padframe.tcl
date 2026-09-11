####################################################################
##
##  Frozen padframe: every pad, bond pad and filler placement.
##  Extracted from the signed off Cadence floorplan, not authored.
##
##  Author:   Sne Samal
##  Version:  1.0
##  Date:     2026-09-07
##
####################################################################
##
##  Source: layout/DATA/floorplan/floorplan.fp, written by
##  saveFPlan under Innovus 18.10-p002_1 on 9 December 2025. The
##  coordinates below are that file's IO: and Block: records
##  transcribed unchanged, so the Fusion Compiler padring is the
##  Cadence padring rather than a new one that resembles it.
##
##  Do not edit. The padring is fixed for every team so that one
##  bonding diagram serves every chip.
##
##  Every entry is { instance cell side llx lly orientation }, the
##  coordinates in um and the lower left corner as Innovus recorded
##  it. Orientation is fixed by the side and both tools spell it the
##  same way: N R180, E R90, S R0, W R270.
##
##  The side is carried in the entry rather than written as a comment
##  between them, because a "#" inside a braced Tcl list is data and
##  would be read back as a placement.
##
####################################################################

####################################################################
## Die
####################################################################

set DIE_BOX  { 0 0 1000 1000 }
set IO_BOX   { 75 75 925 925 }
set CORE_BOX { 105 105 895 895 }

####################################################################
## Corner cells
####################################################################
# Not instantiated in TOP.v, so these are created before they are
# placed. The ring has to be continuous for ESD current to reach a
# supply pad from anywhere on it, and the corners close it.

set PADFRAME_CORNERS {
    { CORNER_BL  PCORNER  SW    0    0  R0 }
    { CORNER_BR  PCORNER  SE  925    0  R90 }
    { CORNER_TR  PCORNER  NE  925  925  R180 }
    { CORNER_TL  PCORNER  NW    0  925  R270 }
}

####################################################################
## IO cells
####################################################################
# Instantiated in TOP.v, so these are placed and never created.

set PADFRAME_IO {
    { PLL_BIAS_1  PVDD2ANA      N    90  925  R180 }
    { PLL_BIAS_2  PVDD2ANA      N   160  925  R180 }
    { PLL_CLK_IN  PXOE2CDG      N   235  925  R180 }
    { PLL_CTRL_0  PDUW0408SCDG  N   370  925  R180 }
    { PLL_CTRL_1  PDUW0408SCDG  N   440  925  R180 }
    { PLL_CTRL_2  PDUW0408SCDG  N   510  925  R180 }
    { PLL_CTRL_3  PDUW0408SCDG  N   580  925  R180 }
    { GPIO_0      PDUW0408SCDG  N   650  925  R180 }
    { GPIO_1      PDUW0408SCDG  N   720  925  R180 }
    { GPIO_2      PDUW0408SCDG  N   790  925  R180 }
    { GPIO_3      PDUW0408SCDG  N   860  925  R180 }

    { GPIO_4      PDUW0408SCDG  E   925  860  R90 }
    { GPIO_5      PDUW0408SCDG  E   925  790  R90 }
    { GPIO_6      PDUW0408SCDG  E   925  720  R90 }
    { GPIO_7      PDUW0408SCDG  E   925  650  R90 }
    { GPIO_8      PDUW0408SCDG  E   925  580  R90 }
    { GPIO_9      PDUW0408SCDG  E   925  510  R90 }
    { GPIO_10     PDUW0408SCDG  E   925  440  R90 }
    { GPIO_11     PDUW0408SCDG  E   925  370  R90 }
    { GPIO_12     PDUW0408SCDG  E   925  300  R90 }
    { GPIO_13     PDUW0408SCDG  E   925  230  R90 }
    { GPIO_14     PDUW0408SCDG  E   925  160  R90 }
    { GPIO_15     PDUW0408SCDG  E   925   90  R90 }

    { vss_1       PVSS3CDG      S    90    0  R0 }
    { GPIO_24     PDUW0408SCDG  S   160    0  R0 }
    { GPIO_23     PDUW0408SCDG  S   230    0  R0 }
    { GPIO_22     PDUW0408SCDG  S   300    0  R0 }
    { vdd_io_1    PVDD2CDG      S   370    0  R0 }
    { vdd_io_2    PVDD2CDG      S   440    0  R0 }
    { GPIO_21     PDUW0408SCDG  S   510    0  R0 }
    { GPIO_20     PDUW0408SCDG  S   580    0  R0 }
    { GPIO_19     PDUW0408SCDG  S   650    0  R0 }
    { GPIO_18     PDUW0408SCDG  S   720    0  R0 }
    { GPIO_17     PDUW0408SCDG  S   790    0  R0 }
    { GPIO_16     PDUW0408SCDG  S   860    0  R0 }

    { CLK_OUT     PDUW0408SCDG  W     0  860  R270 }
    { CLK_SEL     PDUW0408SCDG  W     0  790  R270 }
    { CLK_EXT     PDUW0408SCDG  W     0  720  R270 }
    { RESET_N     PDUW0408SCDG  W     0  650  R270 }
    { SCAN_DO     PDUW0408SCDG  W     0  580  R270 }
    { SCAN_DI     PDUW0408SCDG  W     0  510  R270 }
    { SCAN_TSTMD  PDUW0408SCDG  W     0  440  R270 }
    { SCAN_EN     PDUW0408SCDG  W     0  370  R270 }
    { vdd_core_2  PVDD1CDG      W     0  300  R270 }
    { vdd_core_1  PVDD1CDG      W     0  230  R270 }
    { vdd_poc     PVDD2POC      W     0  160  R270 }
    { vss_2       PVSS3CDG      W     0   90  R270 }
}

####################################################################
## Bond pads
####################################################################
# Circuit under pad: each bond pad sits 3 um above its IO cell's
# origin, overlapping it on the upper metals. Two cells occupying one
# footprint is intentional and is what the packaging house bonds to.
# Also instantiated in TOP.v.

set PADFRAME_BPADS {
    { BPAD_PLL_BIAS_1  PAD60LU_SL  N    90  928  R180 }
    { BPAD_PLL_BIAS_2  PAD60LU_SL  N   160  928  R180 }
    { BPAD_PLL_CLK_I   PAD60LU_SL  N   230  928  R180 }
    { BPAD_PLL_CLK_O   PAD60LU_SL  N   300  928  R180 }
    { BPAD_PLL_CTRL_0  PAD60LU_SL  N   370  928  R180 }
    { BPAD_PLL_CTRL_1  PAD60LU_SL  N   440  928  R180 }
    { BPAD_PLL_CTRL_2  PAD60LU_SL  N   510  928  R180 }
    { BPAD_PLL_CTRL_3  PAD60LU_SL  N   580  928  R180 }
    { BPAD_GPIO_0      PAD60LU_SL  N   650  928  R180 }
    { BPAD_GPIO_1      PAD60LU_SL  N   720  928  R180 }
    { BPAD_GPIO_2      PAD60LU_SL  N   790  928  R180 }
    { BPAD_GPIO_3      PAD60LU_SL  N   860  928  R180 }

    { BPAD_GPIO_4      PAD60LU_SL  E   928  860  R90 }
    { BPAD_GPIO_5      PAD60LU_SL  E   928  790  R90 }
    { BPAD_GPIO_6      PAD60LU_SL  E   928  720  R90 }
    { BPAD_GPIO_7      PAD60LU_SL  E   928  650  R90 }
    { BPAD_GPIO_8      PAD60LU_SL  E   928  580  R90 }
    { BPAD_GPIO_9      PAD60LU_SL  E   928  510  R90 }
    { BPAD_GPIO_10     PAD60LU_SL  E   928  440  R90 }
    { BPAD_GPIO_11     PAD60LU_SL  E   928  370  R90 }
    { BPAD_GPIO_12     PAD60LU_SL  E   928  300  R90 }
    { BPAD_GPIO_13     PAD60LU_SL  E   928  230  R90 }
    { BPAD_GPIO_14     PAD60LU_SL  E   928  160  R90 }
    { BPAD_GPIO_15     PAD60LU_SL  E   928   90  R90 }

    { BPAD_vss_1       PAD60LU_SL  S    90    0  R0 }
    { BPAD_GPIO_24     PAD60LU_SL  S   160    0  R0 }
    { BPAD_GPIO_23     PAD60LU_SL  S   230    0  R0 }
    { BPAD_GPIO_22     PAD60LU_SL  S   300    0  R0 }
    { BPAD_vdd_io_1    PAD60LU_SL  S   370    0  R0 }
    { BPAD_vdd_io_2    PAD60LU_SL  S   440    0  R0 }
    { BPAD_GPIO_21     PAD60LU_SL  S   510    0  R0 }
    { BPAD_GPIO_20     PAD60LU_SL  S   580    0  R0 }
    { BPAD_GPIO_19     PAD60LU_SL  S   650    0  R0 }
    { BPAD_GPIO_18     PAD60LU_SL  S   720    0  R0 }
    { BPAD_GPIO_17     PAD60LU_SL  S   790    0  R0 }
    { BPAD_GPIO_16     PAD60LU_SL  S   860    0  R0 }

    { BPAD_CLK_OUT     PAD60LU_SL  W     0  860  R270 }
    { BPAD_CLK_SEL     PAD60LU_SL  W     0  790  R270 }
    { BPAD_CLK_EXT     PAD60LU_SL  W     0  720  R270 }
    { BPAD_RESET_N     PAD60LU_SL  W     0  650  R270 }
    { BPAD_SCAN_DO     PAD60LU_SL  W     0  580  R270 }
    { BPAD_SCAN_DI     PAD60LU_SL  W     0  510  R270 }
    { BPAD_SCAN_TSTMD  PAD60LU_SL  W     0  440  R270 }
    { BPAD_SCAN_EN     PAD60LU_SL  W     0  370  R270 }
    { BPAD_vdd_core_2  PAD60LU_SL  W     0  300  R270 }
    { BPAD_vdd_core_1  PAD60LU_SL  W     0  230  R270 }
    { BPAD_vdd_poc     PAD60LU_SL  W     0  160  R270 }
    { BPAD_vss_2       PAD60LU_SL  W     0   90  R270 }
}

####################################################################
## IO fillers
####################################################################
# Created, not instantiated. These carry the supply rails across the
# gaps between pads, so omitting them breaks the ring.

set PADFRAME_FILLERS {
    { FILLER_N_2   PFILLER10  N    75  925  R180 }
    { FILLER_N_12  PFILLER5   N    85  925  R180 }
    { FILLER_N_3   PFILLER10  N   145  925  R180 }
    { FILLER_N_13  PFILLER5   N   155  925  R180 }
    { FILLER_N_0   PFILLER20  N   215  925  R180 }
    { FILLER_N_1   PFILLER20  N   350  925  R180 }
    { FILLER_N_4   PFILLER10  N   425  925  R180 }
    { FILLER_N_14  PFILLER5   N   435  925  R180 }
    { FILLER_N_5   PFILLER10  N   495  925  R180 }
    { FILLER_N_15  PFILLER5   N   505  925  R180 }
    { FILLER_N_6   PFILLER10  N   565  925  R180 }
    { FILLER_N_16  PFILLER5   N   575  925  R180 }
    { FILLER_N_7   PFILLER10  N   635  925  R180 }
    { FILLER_N_17  PFILLER5   N   645  925  R180 }
    { FILLER_N_8   PFILLER10  N   705  925  R180 }
    { FILLER_N_18  PFILLER5   N   715  925  R180 }
    { FILLER_N_9   PFILLER10  N   775  925  R180 }
    { FILLER_N_19  PFILLER5   N   785  925  R180 }
    { FILLER_N_10  PFILLER10  N   845  925  R180 }
    { FILLER_N_20  PFILLER5   N   855  925  R180 }
    { FILLER_N_11  PFILLER10  N   915  925  R180 }

    { FILLER_E_12  PFILLER10  E   925  915  R90 }
    { FILLER_E_24  PFILLER5   E   925  855  R90 }
    { FILLER_E_11  PFILLER10  E   925  845  R90 }
    { FILLER_E_23  PFILLER5   E   925  785  R90 }
    { FILLER_E_10  PFILLER10  E   925  775  R90 }
    { FILLER_E_22  PFILLER5   E   925  715  R90 }
    { FILLER_E_9   PFILLER10  E   925  705  R90 }
    { FILLER_E_21  PFILLER5   E   925  645  R90 }
    { FILLER_E_8   PFILLER10  E   925  635  R90 }
    { FILLER_E_20  PFILLER5   E   925  575  R90 }
    { FILLER_E_7   PFILLER10  E   925  565  R90 }
    { FILLER_E_19  PFILLER5   E   925  505  R90 }
    { FILLER_E_6   PFILLER10  E   925  495  R90 }
    { FILLER_E_18  PFILLER5   E   925  435  R90 }
    { FILLER_E_5   PFILLER10  E   925  425  R90 }
    { FILLER_E_17  PFILLER5   E   925  365  R90 }
    { FILLER_E_4   PFILLER10  E   925  355  R90 }
    { FILLER_E_16  PFILLER5   E   925  295  R90 }
    { FILLER_E_3   PFILLER10  E   925  285  R90 }
    { FILLER_E_15  PFILLER5   E   925  225  R90 }
    { FILLER_E_2   PFILLER10  E   925  215  R90 }
    { FILLER_E_14  PFILLER5   E   925  155  R90 }
    { FILLER_E_1   PFILLER10  E   925  145  R90 }
    { FILLER_E_13  PFILLER5   E   925   85  R90 }
    { FILLER_E_0   PFILLER10  E   925   75  R90 }

    { FILLER_S_0   PFILLER10  S    75    0  R0 }
    { FILLER_S_13  PFILLER5   S    85    0  R0 }
    { FILLER_S_1   PFILLER10  S   145    0  R0 }
    { FILLER_S_14  PFILLER5   S   155    0  R0 }
    { FILLER_S_2   PFILLER10  S   215    0  R0 }
    { FILLER_S_15  PFILLER5   S   225    0  R0 }
    { FILLER_S_3   PFILLER10  S   285    0  R0 }
    { FILLER_S_16  PFILLER5   S   295    0  R0 }
    { FILLER_S_4   PFILLER10  S   355    0  R0 }
    { FILLER_S_17  PFILLER5   S   365    0  R0 }
    { FILLER_S_5   PFILLER10  S   425    0  R0 }
    { FILLER_S_18  PFILLER5   S   435    0  R0 }
    { FILLER_S_6   PFILLER10  S   495    0  R0 }
    { FILLER_S_19  PFILLER5   S   505    0  R0 }
    { FILLER_S_7   PFILLER10  S   565    0  R0 }
    { FILLER_S_20  PFILLER5   S   575    0  R0 }
    { FILLER_S_8   PFILLER10  S   635    0  R0 }
    { FILLER_S_21  PFILLER5   S   645    0  R0 }
    { FILLER_S_9   PFILLER10  S   705    0  R0 }
    { FILLER_S_22  PFILLER5   S   715    0  R0 }
    { FILLER_S_10  PFILLER10  S   775    0  R0 }
    { FILLER_S_23  PFILLER5   S   785    0  R0 }
    { FILLER_S_11  PFILLER10  S   845    0  R0 }
    { FILLER_S_24  PFILLER5   S   855    0  R0 }
    { FILLER_S_12  PFILLER10  S   915    0  R0 }

    { FILLER_W_12  PFILLER10  W     0  915  R270 }
    { FILLER_W_24  PFILLER5   W     0  855  R270 }
    { FILLER_W_11  PFILLER10  W     0  845  R270 }
    { FILLER_W_23  PFILLER5   W     0  785  R270 }
    { FILLER_W_10  PFILLER10  W     0  775  R270 }
    { FILLER_W_22  PFILLER5   W     0  715  R270 }
    { FILLER_W_9   PFILLER10  W     0  705  R270 }
    { FILLER_W_21  PFILLER5   W     0  645  R270 }
    { FILLER_W_8   PFILLER10  W     0  635  R270 }
    { FILLER_W_20  PFILLER5   W     0  575  R270 }
    { FILLER_W_7   PFILLER10  W     0  565  R270 }
    { FILLER_W_19  PFILLER5   W     0  505  R270 }
    { FILLER_W_6   PFILLER10  W     0  495  R270 }
    { FILLER_W_18  PFILLER5   W     0  435  R270 }
    { FILLER_W_5   PFILLER10  W     0  425  R270 }
    { FILLER_W_17  PFILLER5   W     0  365  R270 }
    { FILLER_W_4   PFILLER10  W     0  355  R270 }
    { FILLER_W_16  PFILLER5   W     0  295  R270 }
    { FILLER_W_3   PFILLER10  W     0  285  R270 }
    { FILLER_W_15  PFILLER5   W     0  225  R270 }
    { FILLER_W_2   PFILLER10  W     0  215  R270 }
    { FILLER_W_14  PFILLER5   W     0  155  R270 }
    { FILLER_W_1   PFILLER10  W     0  145  R270 }
    { FILLER_W_13  PFILLER5   W     0   85  R270 }
    { FILLER_W_0   PFILLER10  W     0   75  R270 }
}

####################################################################
## Hard macros
####################################################################
# The PLL, placed and fixed before anything else is. The halo is the
# keepout Innovus recorded, in um, as left bottom right top.

set PADFRAME_MACRO { pll  118 691  R0 }
set PADFRAME_MACRO_HALO { 10 10 10 10 }
