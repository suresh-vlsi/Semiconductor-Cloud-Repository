# Project finalization files

Copy these files into the existing `Semiconductor-Cloud-Repository` using the
same relative paths. Keep the existing behavioral SRAM macro model out of the
synthesis source list; use the black-box declaration supplied here for Yosys.

The synthesis starter script is intentionally separate from the simulation
flow. It does not overwrite the existing Makefile or the already verified RTL.

Run from the repository root after copying:

```bash
export PDK_DIR=/mnt/d/EDA/pdk/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A
bash synthesis/run_sky130_sram_synth.sh
```

The script requires the SKY130 HD Liberty file and a working Yosys installation.
It creates a mapped netlist and synthesis statistics in `synthesis_reports/`.
This is not yet a macro-aware physical-design flow.
