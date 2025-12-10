# Padframe

## Padframe Description
The padframe consists of 48 bond pads arranged in a square, with 12 pads per side. There are 47 IO cells in total, including one oscillator cell that occupies two bond pads. Bond pads are placed at a 70 µm pitch, directly above the IO cells, following a Circuit-under-Pad (CUP) layout. Each IO cell measures 55 µm × 75 µm, while corner cells are 75 µm wide. The pad and cell arrangement is optimized to achieve a die size of exactly 1000 µm × 1000 µm. The design supports packaging in a 44-pin package, with power and ground pads double-bonded. The usable core area within the padframe is 850 µm × 850 µm.

<div align="center">
    <img src="./imgs/padframe_layout.PNG" alt="Padframe layout" style="width:400px;">
</div>

## Padframe composition 

### IO Cells
The padframe uses the TSMC `tphn65lpnv2od3_sl_9lm` library. The primary digital I/O cell is `PDUW0408SCDG`, which provides Schmitt Trigger inputs and an enable-controlled pull-up resistor. This cell is used for all general-purpose I/O, clock, reset, scan chain, and PLL frequency selection pads, each configured for 8 mA drive strength.

Oscillator signals use the `PXOE2CDG` cell, selected for its specific drive strength and signal gain characteristics.

Power supplies are distributed as follows:
- PLL bias voltages: `PVDD2ANA` pads
- Core power: two `PVDD1CDG` pads
- I/O power: two `PVDD2CDG` pads
- Power-on control: one `PVDD2POC` pad
- Ground (for both I/O and core): two `PVSS3CDG` pads

This arrangement ensures robust signal integrity, ESD protection, and compliance with the padframe’s electrical requirements.

### Padring Cells
| Function       | Pads Cells | IO Library Cell   | Description                                                                 |
|----------------|-------------|-------------------|-----------------------------------------------------------------------------|
| GPIOxx         | 25          | `PDUW0408SCDG`   | Freely usable IO configurable as Input/Output with Pull-Up resistor.        |
| CLK_EXT        | 1           | `PDUW0408SCDG`   | External clock input pad.                                                   |
| CLK_SEL        | 1           | `PDUW0408SCDG`   | Clock select input pad.                                                     |
| CLK_OUT        | 1           | `PDUW0408SCDG`   | Clock output pad.                                                           |
| RESET_N        | 1           | `PDUW0408SCDG`   | Active-low reset input pad.                                                 |
| SCAN_EN        | 1           | `PDUW0408SCDG`   | Scan enable input pad.                                                      |
| SCAN_TSTMD     | 1           | `PDUW0408SCDG`   | Scan test mode input pad.                                                   |
| SCAN_DI        | 1           | `PDUW0408SCDG`   | Scan data input pad.                                                        |
| SCAN_DO        | 1           | `PDUW0408SCDG`   | Scan data output pad.                                                       |
| PLL_CLK_I      | 1           | `PXOE2CDG`       | PLL clock input pad.                                                        |
| PLL_CLK_O      | 1           | `PXOE2CDG`       | PLL clock output pad.                                                       |
| PLL_CTRL[3:0]  | 4           | `PDUW0408SCDG`   | PLL control input pads for frequency selection.                             |
| PLL_BIAS_1     | 1           | `PVDD2ANA`       | PLL bias voltage pad 1.                                                     |
| PLL_BIAS_2     | 1           | `PVDD2ANA`       | PLL bias voltage pad 2.                                                     |
| VDD_CORE       | 2           | `PVDD1CDG`       | Core power supply pads.                                                     |
| VDD_IO         | 2           | `PVDD2CDG`       | IO power supply pads.                                                       |
| VDD_POC        | 1           | `PVDD2POC`       | Power-on-control pad.                                                       |
| VSS            | 2           | `PVSS3CDG`       | Ground pads for both IO and core supply.                                    |


### Bond Pads
The selected bond pad is `PAD60LU_SL` from the `tpbn65v_200b` library. It measures 66×54 µm, with "60" in the name referring to minimum pad pitch. This is the largest in-line pad available, chosen to minimize packaging costs, as smaller pads would require more expensive packaging. The "L" denotes in-line configuration, while "SL" indicates the slim pad library, which matches the slim IO library used in this design.

Refer to the [Bondpad library release note] for further details.

## Design Considerations
### Power and Ground Scheme

- A unified ground approach is implemented using the `PVSS3CDG` pad, rather than separate grounds for IO and Core. While this saves two pins, it increases sensitivity to noise.
- IO and Core power are supplied by distinct cells: `PVDD1CDG` for Core and `PVDD2CDG` for IO.
- PLL bias voltage is provided by two analog cells (`PVDD2ANA`). Documentation indicates no power cut in the ring is required for these cells, and they are suitable for analog signals within the digital domain.
    > According to the IO Application Note, ESD compliance requires following the 1-ohm/3-ohm rule: "The power bus line resistance between IO and ground cells must be less than 1 Ω, calculated as $R = R_{sheet} \frac{L}{W}$, where $R_{sheet}$ is specified in the SPICE model card." In this design, resistance between ground and the furthest IO pad is slightly higher.
    
    > When `PVDD2ANA` is used for analog signals, a secondary ESD circuit is required. Although this pin is not a signal, it must maintain a stable potential—verification is recommended.
- Only one POC cell is included, as required for each digital domain. This cell does not need to be bonded out.
- Bonded ground pads are positioned on each side of a corner cell, per IO Application Note guidelines [IO Application Note].

### Packaging and Pad Selection

- Minimum pad pitch for packaging is 56 µm (per Imec instructions, 25/11/2025); a 70 µm pitch is used for this design.
- The largest available in-line bond pad is selected to minimize packaging costs, as smaller pads would increase expense.

### Signal Integrity and ESD

- The padframe includes two VDD and two VSS supply cells. Datasheet guidance indicates this is sufficient for slew-rate controlled IO cells, but may be inadequate for non-controlled slew-rate cells. Calculations assume 20 pins switching simultaneously, 15 pF load, and 5.4 nH bond wire inductance (20 µm diameter, 4 mm length).
- The `PDUW0408SCDG` cell is chosen for its lower drive strength, reducing noise on power lines during simultaneous IO switching.
- ESD protection is integrated into the pads and is most effective when pads are connected in a ring.

## IO Placement File

The IO placement file specifies the arrangement and order of IO cells and bond pads around the padframe. It defines the sequence of IO cells on each side of the padring and their exact positions. Bond pads are placed in secondary rows directly above the corresponding IO cells, with zero margin between them for optimal alignment.

For this design, the IO placement file used is `scripts/support/chip_pads.io`.


## Testing considerations
- Power up sequence: 
    - Turn on the IO voltage first and then turn on the core voltage.
    - The PLL bias voltage must be powered-up AFTER the IO power supply.
- Power down sequence: 
    - Power down the analog bias voltage before the IO.
    - No requirements for powering down IO and Core.


## References
[IO Application Note]: ("/usr/local/cadence/kits/tsmc/65n_LP/doc/LIBS/TSMC Slim IO General Application Note_1_.pdf")
[IO Standard Cells Datasheet]: (/usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Documentation/documents/tphn65lpnv2od3_sl_200b/DB_TPHN65LPNV2OD3_SL_TC.pdf)
[Bondpad library release note]: (/usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Documentation/release_note/RN_TPBN65V_200B.pdf "RN_TPBN65V_200B.pdf")

