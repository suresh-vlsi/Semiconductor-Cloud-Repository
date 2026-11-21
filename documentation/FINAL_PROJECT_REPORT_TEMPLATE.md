# RV32IM Processor SoC with INT8 Systolic Accelerator and 64 KiB SKY130 SRAM

**Author:** [Your name]  
**Repository:** https://github.com/suresh-vlsi/Semiconductor-Cloud-Repository  
**Branch:** `feature/sky130-sram-integration`  
**Integration commit:** `0e62be9`

## Abstract

This project implements a five-stage RV32IM processor SoC with an INT8 systolic
array accelerator, memory-mapped peripherals, and a 64 KiB synchronous SRAM
subsystem built from 32 SKY130 2 KiB SRAM macros. The design is verified using
an instruction-set simulator and RTL regression programs. The SRAM wrapper is
verified independently with directed functional tests.

## 1. Architecture

Describe the IF/ID/EX/MEM/WB pipeline, forwarding and hazard handling, SRAM
instruction/data ports, 32-bank address mapping, accelerator interface, UART,
GPIO, and system-control registers. Insert a block diagram here.

## 2. SRAM organization

- Macro count: 32
- Capacity per macro: 2 KiB (512 x 32 bits)
- Total capacity: 64 KiB
- Byte address `[15:11]`: bank select
- Byte address `[10:2]`: word address within bank
- Byte address `[1:0]`: byte offset
- Instruction path: dedicated read port
- Data path: read/write port with byte write masks

State the exact macro model and PDK revision used for simulation and physical
implementation. Explain that the behavioral model's delay is not a substitute
for characterized timing data.

## 3. Verification methodology and results

Use `documentation/VALIDATION_RESULTS.md` as the current result record. Include
raw simulator logs and commit hashes when preparing a formal submission.
Explain the ISS-versus-RTL comparison and the 30 directed SRAM tests.

## 4. Synthesis methodology

Record Yosys version, PDK revision, Liberty corner, top module, `ACCEL_N`, and
exact source commit. Attach the generated synthesis report and mapped netlist.
Keep standard-cell area and SRAM macro area in separate rows.

## 5. Physical-design methodology

Complete this section only after the SRAM LEF/liberty views are integrated.
Document floorplan dimensions, utilization, macro locations/orientations,
power-grid strategy, pin placement, CTS, routing, extraction, DRC, LVS, and
setup/hold timing results.

## 6. Results

| Metric | Result | Evidence |
|---|---:|---|
| Standard-cell area | [TBD] | Yosys/OpenROAD report |
| SRAM macro area | [TBD] | Macro LEF |
| Total core area | [TBD] | Floorplan report |
| Clock period | [TBD] | SDC |
| Worst setup slack | [TBD] | STA report |
| Worst hold slack | [TBD] | STA report |
| DRC violations | [TBD] | DRC report |
| LVS result | [TBD] | LVS report |

Do not fill unknown values with estimates unless clearly labeled as estimates.

## 7. Limitations and future work

Discuss unsupported architectural features, absence of exceptions/CSRs if
applicable, synthesis/physical-design limitations, timing closure, power
analysis, and future optimization opportunities.

## 8. Reproducibility

List OS, tool versions, PDK revision, environment variables, exact commands,
Git commit hashes, and artifact locations. Include `make test`, `make sram_test`,
and the synthesis command where applicable.
