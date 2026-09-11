####################################################################
##
##  Standard cell power rails, built once cells exist to follow.
##  Sourced after placement, not with the rest of the power plan.
##
##  Author:   Sne Samal
##  Version:  1.2
##  Date:     2026-09-10
##
####################################################################

# Every cell inserted since the last connection must be on its net,
# or the rail is cut short of its pins.
connect_pg_net -automatic

create_pg_std_cell_conn_pattern rail_pattern \
    -layers             $RAIL_LAYER \
    -mark_as_follow_pin true \
    -check_std_cell_drc true

# Rows exist under the macros, so their keepouts block the rails.
# macros_with_keepout rather than macros: rails let into the keepout
# become stubs between the ring segments.
set macro_names {}
foreach c [get_object_name $MACROS] { lappend macro_names $c }

set_pg_strategy rail_strategy -core \
    -pattern   [list [list pattern: rail_pattern] \
                     [list nets: [list $PWR_NET $GND_NET]]] \
    -extension [list [list stop: first_target]] \
    -blockage  [list [list [list nets: [list $PWR_NET $GND_NET]] \
                           [list macros_with_keepout: $macro_names]]]

# M1 rails to an M5/M6 ring need the stacking rule.
compile_pg -strategies rail_strategy -via_rule pg_stack_via_rule

connect_pg_net

####################################################################
## Checks
####################################################################
# Anything floating here is a defect in scripts/powerplan.tcl; no
# router pass covers for it. Standard cell internals are excluded
# from the DRC, which otherwise reports every follow-pin rail against
# the pins it sits on; the 33 that remain are the pad library's.

redirect -tee -file $RPT_DIR/rails_connectivity.rpt \
    {check_pg_connectivity -write_connectivity_file $RPT_DIR/rails_pg_floating.txt}
redirect -tee -file $RPT_DIR/rails_pg_drc.rpt \
    {check_pg_drc -ignore_std_cells -output $RPT_DIR/rails_pg_drc_errors.txt}
redirect -tee -file $RPT_DIR/rails_pg_drc_all.rpt {check_pg_drc}
