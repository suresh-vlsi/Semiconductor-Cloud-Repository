# Validation results — RV32IM + INT8 accelerator + SKY130 SRAM

This record reflects the results reported from the user's local WSL environment
on 21 November 2026. It is not a substitute for retaining the raw logs in the
project repository.

## SRAM macro wrapper

- SKY130 64 KiB SRAM wrapper functional test: **30/30 passed**.
- Tested banked reads/writes, byte masks, simultaneous reads, consecutive
  requests, final valid address, invalid-address rejection, and read/write
  collision ordering.
- Icarus Verilog emitted inherited-timescale warnings; these were non-fatal.

## SRAM-backed SoC software regression

| Program | ISS | SRAM-backed RTL | Cycles |
|---|---:|---:|---:|
| hello | PASS | PASS | 973 |
| alu_test | PASS | PASS | 14,077 |
| mem_hazard | PASS | PASS | 1,001 |
| matmul_sw | PASS | PASS | 4,513 |
| matmul_accel | PASS | PASS | 1,801 |

## Original behavioral-RAM SoC regression

| Program | ISS | RTL | RTL cycles |
|---|---:|---:|---:|
| hello | PASS | PASS | 603 |
| alu_test | PASS | PASS | 3,519 |
| mem_hazard | PASS | PASS | 250 |
| matmul_sw | PASS | PASS | 1,128 |
| matmul_accel | PASS | PASS | 456 |

Additional checks reported:

- Python toolchain self-test passed.
- Golden systolic model: 200 random INT8 matmuls matched NumPy for each of
  N=2, N=4, and N=8.
- Original behavioral-RAM simulation reported 3.8x accelerator speed-up for
  the 4x4 INT8 matmul workload (909 software kernel cycles vs 241 accelerator
  kernel cycles). This is a simulation result, not measured silicon performance
  and not a comparison of the new SRAM-backed implementation.

## Existing synthesis baseline — keep separate from integrated SoC results

Previously reported SKY130 mapped results for the CPU and accelerator as
separate blocks:

| Block | Cell count | Cell area (um^2) | Sequential cells |
|---|---:|---:|---:|
| RV32IM core | 46,013 | 283,571.968 | 1,361 |
| INT8 accelerator N=4 | 26,127 | 164,520.288 | 971 |

These are separate-block results from the earlier design. They are **not** an
integrated `soc_top_sram` synthesis result and must not be presented as such.

## Not yet demonstrated

- SKY130 standard-cell synthesis of the integrated SRAM-backed SoC.
- Hard-macro LEF/liberty integration in OpenLane/OpenROAD.
- Integrated floorplan and macro placement.
- Clock-tree synthesis and routed timing.
- DRC/LVS and post-route sign-off.
