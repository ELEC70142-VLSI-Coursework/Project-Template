####################################################################
## MMMC Timing Constraints Setup
####################################################################
# Creation of the multi-mode multi-corner analysis view for the design.
# First load the SDC file contains the timing constraints for the design.
# then set the timing library for the standard cells and I/O cells. There are three
# delay corners: best, worst, and typical. The typical corner is used for functional analysis.
# Then create the RC corner for the design, which includes the capacitance table and temperature.
# Finally, create the delay corner constraints and the analysis view for the design.



create_constraint_mode -name CONSTRAINTS -sdc_files ${SDC_FILE}
create_library_set -name libs_typ -timing { \
        "/usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn65lpbwp7t_220a/tcbn65lpbwp7twc.lib" \
        "/usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn65lpnv2od3_sl_200b/tphn65lpnv2od3_sltc.lib" \
        "/usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn65lpnv2od3_sl_200b/tphn65lpnv2od3_sltc1.lib"\
        "/usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn65lpnv2od3_sl_200b/tphn65lpnv2od3_sltc2.lib"\
        "/usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn65lpnv2od3_sl_200b/tphn65lpnv2od3_sltc3.lib"\
        "/usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn65lpnv2od3_sl_200b/tphn65lpnv2od3_sltc4.lib"\
    }
create_rc_corner -name tsmc65_rc_corner_typ \
            -cap_table {/usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tcbn65lpbwp7t_141a/techfiles/captable/cln65lp_1p09m+alrdl_top2_typical.captable} \
            -T 25 
create_delay_corner -name corner_typ -library_set {libs_typ} -rc_corner {tsmc65_rc_corner_typ}
create_analysis_view -name {functional_typ} -delay_corner {corner_typ} -constraint_mode {CONSTRAINTS} 
set_analysis_view -setup {functional_typ} -hold {functional_typ}






