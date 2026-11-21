# SKY130 SRAM SoC physical-design checklist

Do not start full place-and-route until the following hard-macro views and
constraints are available and matched to the exact SRAM macro revision.

## Required inputs

- [ ] SKY130 HD standard-cell Liberty at the selected PVT corner.
- [ ] SKY130 HD standard-cell LEF and technology LEF.
- [ ] SRAM macro LEF for `sky130_sram_2kbyte_1rw1r_32x512_8`.
- [ ] SRAM macro timing Liberty (or approved timing model) for the selected PVT.
- [ ] SRAM macro GDS/OASIS for stream-out and DRC/LVS.
- [ ] SRAM macro LEF pin names and power/ground pin conventions verified.
- [ ] SDC clock period, uncertainty, input/output delays, and false/multicycle
      paths reviewed and justified.
- [ ] Power intent and power/ground connectivity strategy defined.

## Implementation sequence

- [ ] Synthesize the SoC while preserving SRAM instances as hard macros.
- [ ] Confirm exactly 32 macro instances survive synthesis.
- [ ] Import macro LEF and timing views into OpenROAD/OpenLane.
- [ ] Choose die/core dimensions based on actual cell and macro area.
- [ ] Place macros with legal orientation, spacing, and pin access.
- [ ] Build power grid and connect macro power pins.
- [ ] Place standard cells and repair placement violations.
- [ ] Run CTS and inspect clock skew/latency.
- [ ] Run global and detailed routing.
- [ ] Run extraction and setup/hold STA.
- [ ] Run DRC, LVS, antenna, and metal-density checks.
- [ ] Archive final reports, DEF, SPEF, GDS, and tool configuration.

## Area accounting

Report these separately:

1. Standard-cell area from the mapped netlist.
2. SRAM macro area from the macro LEF.
3. Core area from the floorplan.
4. Die area, if defined.

Do not call the sum of separately synthesized CPU and accelerator blocks the
area of the integrated SoC. Do not infer final area from utilization alone.
