# Flow scripts

One `fc_shell` session per `make` target, each script an entry point or a stage
sourced by one. `setup.tcl` is sourced first by every entry point and ends by
sourcing `design.tcl`, the file a team edits.

| Script | Run by | Does |
|---|---|---|
| `setup.tcl` | every script | kit, pad and PLL libraries, flow settings, directories; sources `design.tcl` and `memories.tcl` |
| `memories.tcl` | `setup.tcl` | where a compiled memory's views are, from the directory memcomp wrote |
| `pll.tcl` | `setup.tcl` | the PLL's delivered views and reference library |
| `pll_ndm.tcl` | `make pll` | builds the PLL reference library from its LEF |
| `sram_lib.tcl` | `make sram` | compiles each memory's Liberty to a db |
| `sram_ndm.tcl` | `make sram` | builds each memory's reference library from LEF and db |
| `synth.tcl` | `make synth` | logical synthesis of the design on its own |
| `dft.tcl` | `make dft` | scan insertion into the synthesized netlist, and its STIL protocol |
| `atpg.tcl` | `make atpg` | TestMAX stuck-at patterns on the scan-inserted netlist |
| `lec.tcl` | `make lec` | Formality, the scan-inserted netlist against the RTL |
| `mcmm.tcl` | `synth`, `dft`, `fusion` | mode, corners, scenarios, the SDC read into them |
| `padring.tcl` | `make padring`, and the chip | library, elaboration, die and padring |
| `padframe.tcl` | `floorplan.tcl` | the frozen pad, bond pad and filler placements; generated, do not edit |
| `floorplan.tcl` | `padring.tcl` | die, padring placement, macro placement and its check |
| `powerplan.tcl` | `chip_floorplan.tcl` | supply nets, core ring, supply pad straps, mesh, macro rings, tap cells |
| `chip_floorplan.tcl` | `make floorplan`, and the chip | padring plus power plan |
| `fusion.tcl` | `make fusion` | the chip: floorplan, placement of the design's netlist, rails, then `backend.tcl` |
| `rails.tcl` | `fusion.tcl` | standard cell power rails, once cells exist |
| `backend.tcl` | `fusion.tcl` | clock tree, routing and repair, chip finish, checks, export |
| `lec_chip.tcl` | `make lec_chip` | Formality, the layout netlist against `TOP.v` with the design's netlist; proves place and route changed nothing, scan chain included |

Reports go to `reports/`, outputs to `outputs/`, logs to `logs/`. The flow notes
that explain why each script is the way it is live outside the template, in the
labs repository under `notes/`.
