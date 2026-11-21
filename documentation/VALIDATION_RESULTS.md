# Validation Results
## RV32IM SoC, INT8 Accelerator and SKY130 SRAM

**Validation date:** 21 November 2026

This document records functional verification, synthesis and physical-design results. Simulation results are not silicon measurements.

---

## 1. Python and reference-model validation

| Test | Result |
|---|---|
| Toolchain self-test | PASS |
| Multiply/divide reference model | PASS |
| Multiply/divide operations | 34,048 |
| RV32M funct3 values covered | 8 |
| Systolic reference model | PASS |
| Random INT8 matrix tests per configuration | 200 |
| Systolic configurations | N=2, N=4, N=8 |

The systolic model was checked against NumPy.

## 2. Standard SoC regression

Command: `make test`

| Program | ISS | RTL | RTL cycles |
|---|---|---|---:|
| hello | PASS | PASS | 603 |
| alu_test | PASS | PASS | 8,143 |
| mem_hazard | PASS | PASS | 250 |
| muldiv_hazard | PASS | PASS | 1,271 |
| matmul_sw | PASS | PASS | 4,392 |
| matmul_accel | PASS | PASS | 456 |

All six programs passed in both ISS and RTL simulation.

### Accelerator comparison

For the 4x4 INT8 matrix multiplication workload:

- Software kernel: 4,173 cycles
- Accelerator kernel: 241 cycles
- Simulation-derived speed-up: 17.3x

This is a simulation result, not measured silicon performance.

Log: `simulation_logs/final_release_regression.log`

## 3. SRAM-backed SoC regression

Command: `make sram_test`

| Program | ISS | SRAM RTL | RTL cycles |
|---|---|---|---:|
| hello | PASS | PASS | 973 |
| alu_test | PASS | PASS | 18,429 |
| mem_hazard | PASS | PASS | 1,001 |
| muldiv_hazard | PASS | PASS | 1,965 |
| matmul_sw | PASS | PASS | 7,585 |
| matmul_accel | PASS | PASS | 1,801 |

All six programs passed in both ISS and SRAM-backed RTL simulation.

Log: `simulation_logs/final_release_sram_regression.log`

---

## 4. Multiply/divide unit

- Python reference model: 34,048 operations passed.
- All eight RV32M funct3 operations were covered.
- Dedicated RTL testbench: 5,248 operations passed.
- `muldiv_hazard` passed in both SoC regression configurations.
- Iterative multiply/divide operations take approximately 34 cycles.

## 5. SRAM wrapper verification

The SRAM wrapper functional test reported 30/30 passing checks, covering banked accesses, byte masks, simultaneous reads, consecutive requests, boundary addresses, invalid-address rejection and read/write collision ordering.

## 6. Integrated SKY130 synthesis

Integrated top: `soc_top_sram`

| Metric | Result |
|---|---:|
| Mapped standard-cell area | 225,984.2368 um^2 |
| Sequential area | 75,880.2752 um^2 |
| Sequential area fraction | 33.58% |
| Yosys final CHECK | 0 problems |

The synthesis contains 32 SRAM macro instances. SRAM macros remain black boxes for standard-cell area reporting.

Artifacts:
- `synthesis_reports/soc_top_sram_sky130_stat.txt`
- `synthesis_reports/soc_top_sram_sky130_mapped.v`
- `synthesis_reports/soc_top_sram_sky130_yosys.log`

## 7. Physical-design implementation

Demonstrated OpenROAD stages:

1. SRAM macro-aware floorplanning.
2. Placement of 32 SRAM macros.
3. Standard-cell row cutting around macro obstructions.
4. Power-delivery network generation.
5. Standard-cell global placement.
6. Detailed placement and legality checks.
7. Placement-based parasitic estimation and timing analysis.

Detailed placement reported zero illegal standard cells.

### Placement-estimated timing

| Metric | Result |
|---|---:|
| WNS | -78.43 ns |
| TNS | -87,555.66 ns |
| Worst-path data arrival | 97.9908 ns |
| Worst-path required time | 19.5657 ns |
| Worst-path slack | -78.4251 ns |

These are placement-estimated results, not routed or extracted signoff timing. The design has not achieved timing closure.

### Remaining physical-design stages

The following are not claimed as completed:

- Clock-tree synthesis.
- Detailed routing.
- Extracted post-route setup/hold STA.
- DRC and LVS signoff.
- Antenna and metal-density signoff.
- Tapeout readiness.

## 8. Overall assessment

The project demonstrates functional verification of the standard and SRAM-backed SoC, integrated SKY130 synthesis, SRAM macro integration, and early physical-design implementation.

The accelerator write-decode candidate is retained as the best measured placement candidate among the experiments performed. It remains timing-failing.

Simulation cycles are not silicon performance, mapped standard-cell area is not total die area, and placement-estimated timing is not routed signoff timing.
