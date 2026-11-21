# SKY130 SRAM SoC Physical-Design Status

**Design:** `soc_top_sram`
**Platform:** SKY130 HD
**SRAM macro:** `sky130_sram_2kbyte_1rw1r_32x512_8`
**Status:** Early physical-design implementation completed; signoff incomplete.

This document distinguishes demonstrated implementation stages from work that has not been completed. A checked item means there is project evidence for that stage; it does not imply foundry signoff.

---

## 1. Required inputs and views

- [x] SKY130 HD standard-cell Liberty and LEF views used by the flow.
- [x] SKY130 technology LEF used by the flow.
- [x] SRAM macro LEF integrated into the physical-design flow.
- [x] SRAM macro timing Liberty integrated into the synthesis/physical-design setup.
- [x] SRAM macro pin names and power/ground conventions inspected.
- [x] Timing constraints supplied to the implementation flow.
- [ ] Final signoff review of all clock, uncertainty, input/output delay, false-path and multicycle constraints.
- [ ] Completed power-intent and power-integrity signoff.
- [ ] Macro GDS stream-out and signoff DRC/LVS verification.

## 2. Demonstrated implementation stages

- [x] Integrated `soc_top_sram` synthesis.
- [x] Exactly 32 SRAM macro instances preserved in the synthesized design.
- [x] Macro-aware OpenROAD floorplan.
- [x] SRAM macro placement: 4 columns × 8 rows.
- [x] Macro orientation and placement constraints applied.
- [x] Standard-cell rows cut around macro obstructions.
- [x] Power-delivery network generated.
- [x] Macro power-pin connectivity checked by the implementation flow.
- [x] Standard-cell global placement.
- [x] Detailed placement.
- [x] Detailed-placement legality check: zero illegal standard cells.
- [x] Placement-based parasitic estimation and timing analysis.

## 3. Physical-design results

The retained accelerator write-decode placement candidate reports:

| Metric | Result |
|---|---:|
| Standard-cell area | 225,984.24 um^2 |
| Fixed macro area | 9,105,231.17 um^2 |
| Placement utilization | 55.7% |
| WNS | -78.43 ns |
| TNS | -87,555.66 ns |
| Detailed-placement illegal cells | 0 |

Timing is placement-estimated and remains negative. It is not post-route timing closure.

The PDN flow reported macro-boundary PDN-0110 warnings. The power-grid connectivity checks reported macro power pins connected, but these warnings must remain documented and must not be described as a clean PDN signoff.

## 4. Not yet completed

- [ ] Clock-tree synthesis (CTS).
- [ ] Clock skew and insertion-delay signoff.
- [ ] Global and detailed routing.
- [ ] Post-route parasitic extraction.
- [ ] Extracted post-route setup and hold STA.
- [ ] Timing closure.
- [ ] DRC signoff.
- [ ] LVS signoff.
- [ ] Antenna checks and repair.
- [ ] Metal-density checks.
- [ ] Final GDS stream-out and signoff review.
- [ ] Tapeout readiness approval.

## 5. Area-accounting rules

Keep the following quantities separate:

1. Mapped standard-cell area.
2. SRAM macro area.
3. Core area.
4. Die area.

Do not infer total die area from standard-cell area or utilization alone. Do not combine separately synthesized CPU and accelerator block areas and report the result as integrated SoC area.

## 6. Release interpretation

This repository demonstrates an integrated SRAM-backed SoC through synthesis, macro-aware floorplanning, PDN generation, placement and placement-based timing analysis.

It is an early physical-design implementation, not a completed place-and-route or tapeout-ready design. The retained candidate has negative timing slack, and physical signoff remains future work.
