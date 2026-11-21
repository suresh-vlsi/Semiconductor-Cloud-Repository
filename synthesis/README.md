# SRAM-backed SKY130 SoC synthesis

This directory contains a synthesis starter flow for `soc_top_sram`.

## Required PDK files

The script expects the SKY130 HD typical Liberty file at:

`$PDK_DIR/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib`

It also expects the RTL source files from the SRAM integration branch to be
present in the repository. `rtl/sky130_sram_macro_blackbox.v` is a synthesis-only
black-box declaration. Do not compile it together with the behavioral SRAM
model in simulation.

## Run

```bash
export PDK_DIR=/mnt/d/EDA/pdk/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A
export ACCEL_N=4
bash synthesis/run_sky130_sram_synth.sh
```

Outputs are written to `synthesis_reports/`:

- `soc_top_sram_sky130_stat.txt`
- `soc_top_sram_sky130_mapped.v`
- `soc_top_sram_sky130_yosys.log`

The 32 SRAM macros are black boxes in this flow. The standard-cell report does
not include the SRAM macro area unless the macro Liberty model is separately
included in the physical implementation flow. Do not add macro area to the
standard-cell area without labeling the two separately.

## Important limitations

This script is a logic-synthesis starting point, not a complete OpenLane/OpenROAD
hard-macro implementation configuration. Physical implementation also requires
the SRAM macro LEF, timing Liberty, pin/obstruction data, macro placement, power
connections, routing setup, clock constraints, and DRC/LVS configuration.
