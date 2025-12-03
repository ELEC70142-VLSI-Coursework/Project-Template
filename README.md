# ELEC70142 Digital VLSI Design Project

This repository provides source files and step-by-step guidelines for synthesis and place-and-route flows for the ELEC70142 Digital VLSI Design project.  
All projects must use the supplied floorplan to ensure compatibility with packaging.  
The floorplan specifies the padring, power planning, and required clocking resources.

#### Directory Structure

- `synth/`: Genus synthesis flow folder
    - `genus_synth.tcl`: Synthesis script
    - `genus_dft.tcl`: Scan chain insertion script
- `layout/`: Innovus place-and-route flow folder
    - `innovus_pnr.tcl`: PnR flow script
    - `DATA/`:
        - `TOP.v`: Top-level module with padring and PLL
        - `floorplan/`: Floorplan files for Innovus
- `PLL/`: PLL GDSII and LEF files
- `docs/`: Supplementary documentation

#### Floorplan

The provided floorplan implements a padring with 44 IOs, including 25 freely usable GPIOs. Additional information about the padring can be found in the [`docs/Padframe.md`](./docs/Padframe) file.  
The floorplan already includes an instance of the PLL module and implements the initial power planning. Power stripes are not included and should be added after placing the SRAM or other macro blocks.

<div align="center">
    <img src="./docs/imgs/floorplan.png" alt="Padframe layout" style="width:400px;">
    <img src="./docs/imgs/padframe_layout.PNG" alt="Padframe layout" style="width:400px;">
</div>

#### Clock Source Selection

- Two clock sources are available: an external clock via pad and a PLL-generated clock. The external signal `clk_sel` selects between them using a MUX instantiated in the TOP module. The cell used is the 2-to-1 clock multiplexer `CKMUX2D1BWP7T`. This is not glitch-safe, but dynamic switching is not required for this application.
- Only static clock source selection is supported. Dynamic switching may introduce clock glitches. Ensure the desired clock source is selected before powering up the IC.



## Genus Flow
- Use the `genus_synth.tcl` script to synthesize your design. Ensure you specify the top module name, source files, and clock constraints.
- After synthesis, use the `genus_dft.tcl` script to insert scan chains into your design.

## Innovus Flow
Follow these guidelines during the Place and Route flow:

### Required Files
- `TOP.v`: The top-level module for the IC. It instantiates the IO cells, pads, PLL module, and clock selection logic, and manages their connections.
- Floorplan files: Specify IO pad placement, power planning, and PLL macro placement.
- PLL design files: the LEF defines the PLL module geometry and pin locations. The GDS file is needed for generating the final GDS output.

### TOP File Configuration
- Instantiate your design and connect it to the IO pads:
    - Ensure clock, reset, and scan chain pins are properly connected.
    - Connect the GPIO pins.
- Configure the GPIO pads as inputs or outputs and enable pull-up resistors if needed:
    - Use the predefined `gpio_dir` assignments to set each GPIO as input (hardcoded 1) or output (hardcoded 0).
> The `TOP.v` file is a structural Verilog file. Only wires, standard cells, and synthesized modules should be defined. Do not include any behavioral Verilog constructs.




### PnR Flow Setup

- Use the `PnR.tcl` template for the Innovus flow. Adjust script parameters as needed and include the relevant SRAM libraries.
- Add the SRAM libraries to the MMMC (Multi-Mode Multi-Corner) script.
- In the SDC file generated during synthesis:
    - Change the design name to `TOP` by adding: `current_design TOP`
    - Replace the `create_clock` line with the following, setting the correct period and waveform values:
      ```
      create_clock -name "clk" -period 3.0 -waveform {0.0 1.5} [get_pins CLK_EXT/C]
      create_clock -name "pll_clk" -period 3.0 -waveform {0.0 1.5} [get_pins pll/f_out]
      ```
- Modify and extend the script as required by the design.

