# Signoff process

## Importing the Design into Custom Compiler

Start Custom Compiler from your project directory with `custom &`, which seeds the library list. Create a new library attached to the `tsmcN65` technology, then go to **File > Import > Stream** and fill in the **Main** tab, leaving the other tabs at their defaults:

| Section | Field | Value |
|---|---|---|
| Input | **Stream File** | `outputs/TOP.gds` |
| Input | **Top Cell** | `TOP` |
| Output | **Library** | the library you created |
| Output | **View** | `layout` |
| Technology | | **Attach**, and pick `tsmcN65` |

The stream carries every cell's geometry, so the import is complete on its own. If the dialog offers reference libraries, name `tcbn65lpbwp7t_9lm`, `tphn65lpnv2od3_sl_mt_2_9lm` and `tpbn65v_cup_9lm` from your `lib.defs`, and the standard cells, pads and bond pads become references to the vendor libraries rather than copies.

You can now open and inspect the layout view of your design.

## Label Placement

To ensure LVS passes, you must label the power nets in your layout. 

A text label on a layer with the pin purpose is what Calibre reads as a port. Select the pin layer in the layer panel (for example `M7 pin`), then **Create > Text**, enter the net name, and place it on the metal of that net.

Add a label for each of the following nets:
- VDD
- VSS
- VDDPST
- POC

Make visible only the `drawing` and `pin` layers for M3, M5 and M7. Place VDD and VSS on the power ring (metal layer M5), VDDPST inside the padring on metal 7 tracks, and POC, which you can find on a metal 3 wire on the inside of the padring.

Refer to the image for net locations.

<div align="center">
    <img src="./imgs/padring_pins_location.png" style="width:400px;">
</div>

## DRC

Run the Design Rule Check (DRC) using Calibre nmDRC, following the steps outlined in Lab 2. Your design must be free of critical DRC errors to be eligible for fabrication.

Certain DRC errors can be waived, including:
- ESD.*
- ESDIMP.*
- LUP.*
- DRM.R.1

Density-related errors (OP.DN, OD.DN, or Mx.DN) must be resolved, but these can be addressed later or by Europractice.

Additional errors that may be waived are listed in the technology release notes, under `$TSMC65_HOME/Documentation/release_note/`.

Common DRC errors that require fixing include wires placed too close to metal plates, or single vias used where multiple vias are required for upper metal layers. To resolve these, adjust wire placement, modify metal geometries, or add more/larger vias as needed.

## Extract the design SPICE model

The LVS process compares the SPICE netlist extracted from the layout with a reference netlist. For digital designs there is no schematic, so the reference SPICE netlist is generated from the Verilog netlist with the Calibre tool `v2lvs`.

Use the LVS netlist the flow writes, `outputs/TOP_lvs.v`: the layout netlist with the power and ground pads in it and without fillers, taps, corners or bond pads, so nothing needs commenting out. Add the SPICE model of any memory you use with a further `-s` option.

```
v2lvs -l $SYN_SIM_MODELS \
      -l $SYN_IO_SIM_MODELS \
      -s $TSMC65_LVS_SPICE \
      -s $TSMC65_IO_LVS_SPICE \
      -s PLL/PLL_25M_400M.sp \
      -s <path>/<of>/<the>/<memory>/<spice>/<file>.spi \
      -v outputs/TOP_lvs.v \
      -o outputs/TOP_lvs.spi
```

## LVS

In the layout window, select **Calibre > Run nmLVS**.

On the **Rules** page, set the rules file to:
```
$TSMC65_LVS_RULES
```

On the **Inputs** page, in the **Layout** tab, check that the layout is read from the layout viewer with the top cell `TOP`. In the **Netlist** tab, set the format to **SPICE**, give the path of `outputs/TOP_lvs.spi`, and make sure the top cell is `TOP`.

On the **OA/LEFDEF** page, under **Read Options**, tick **Read Net Names as Text** and **Read Pin Names as Text**. Then open **Mapping Files**, tick **Use Layer Map Files**, and enter:
```
$TSMC65_OA_LAYERMAP
```

Click **Run LVS**.

Review any warnings reported by the tool, but ensure there are no errors. The most common errors are due to missing connections. If errors are found, correct the layout in Custom Compiler and rerun LVS.

Finally, you should get a clean LVS:
```
                         #       ###################       _   _   
                        #        #                 #       *   *   
                   #   #         #     CORRECT     #         |     
                    # #          #                 #       \___/  
                     #           ###################               
```

From the Custom Compiler main window select **File > Export > Stream** and export the GDSII file that is now ready for tapeout.
