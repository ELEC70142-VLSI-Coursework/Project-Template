####################################################################
##
##  The die and padring on their own, with no power plan.
##  The only stage that needs no design.
##
##  Author:   Sne Samal
##  Version:  1.1
##  Date:     2026-09-10
##
##      fc_shell -f scripts/padring.tcl
##
####################################################################

source scripts/setup.tcl

set_host_options -max_cores $MAX_CORES

if { [file exists $CHIP_LIB] } { file delete -force $CHIP_LIB }

create_lib $CHIP_LIB -technology $TECH_FILE -ref_libs $REF_LIBS
report_ref_libs

# Every renaming from here to the layout netlist, for make lec_chip.
set_svf $LAYOUT_SVF

# With no design, TOP.v elaborates to a padring around an empty core.
analyze -format verilog $TOP_V
if { $DESIGN_TOP ne "" } {
    if { ![file exists $DESIGN_NETLIST] } {
        error "No $DESIGN_NETLIST. Run make synth and make dft first."
    }
    analyze -format verilog $DESIGN_NETLIST
}
elaborate $DESIGN
set_top_module $DESIGN

redirect -tee -file $RPT_DIR/padring_netlist.rpt \
    "check_design -checks netlist -log_file $RPT_DIR/padring_netlist.log"

# The technology file leaves every layer's direction and the site's
# symmetry unset.
suppress_message ATTR-12
set_attribute [get_layers $HORIZONTAL_LAYERS] routing_direction horizontal
set_attribute [get_layers $VERTICAL_LAYERS]   routing_direction vertical
set_attribute [get_site_defs $SITE_NAME] symmetry "$SITE_SYMMETRY"
unsuppress_message ATTR-12

source scripts/floorplan.tcl

# The DEF is what to diff against, since the padring must not move.
write_def $OUT_DIR/${DESIGN}_floorplan.def

save_block -label floorplan
save_lib
