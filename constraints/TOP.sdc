####################################################################
##
##  Chip level constraints. Clocks are defined at pad and macro
##  pins, not at ports. Set the period to your design's.
##
##  Author:   Sne Samal
##  Version:  1.0
##  Date:     2026-09-10
##
####################################################################

# Both clock sources, exclusive because the mux selects one.
create_clock -name clk     -period 10.0 -waveform {0.0 5.0} [get_pins CLK_EXT/C]
create_clock -name pll_clk -period 10.0 -waveform {0.0 5.0} [get_pins pll/f_out]

set_clock_groups -logically_exclusive \
    -group [get_clocks clk] -group [get_clocks pll_clk]

set_clock_uncertainty -setup 0.08 [all_clocks]
set_clock_uncertainty -hold  0.08 [all_clocks]

# Reset is asynchronous; synchronise it inside the design.
set_false_path -from [get_pins RESET_N/C]

# Pad to core and core to pad. An output pad and the clock tree take
# about 2.7 ns together, so at short periods a register to pad path
# needs a second cycle:
#   set_multicycle_path 2 -setup -to [get_ports pad_gpio]
#   set_multicycle_path 1 -hold  -to [get_ports pad_gpio]
set_input_delay  2.0 -clock clk [get_ports pad_gpio]
set_output_delay 2.0 -clock clk [get_ports pad_gpio]
