# SoC Architecture and Implementation

**Top-level designs:** `soc_top` and `soc_top_sram`
**Processor:** RV32IM, five-stage in-order pipeline
**Accelerator:** INT8 output-stationary systolic array
**Physical-design platform:** SKY130 HD

---

## 1. System architecture

The SoC integrates:

- RV32IM processor core.
- Instruction and data memory interfaces.
- 64 KiB SRAM subsystem in the SRAM-backed configuration.
- UART transmitter.
- GPIO register.
- System-control and cycle-counter registers.
- Memory-mapped INT8 systolic accelerator.

The SRAM-backed top-level design is `soc_top_sram`. Its SRAM wrapper is implemented in `rtl/sky130_sram_64kb.v`.

## 2. Memory map

| Base address | Size | Device | Registers |
|---|---:|---|---|
| 0x0000_0000 | 64 KiB | RAM | Code and data |
| 0x2000_0000 | — | UART | +0 W: TX byte; +4 R: bit 0 busy |
| 0x3000_0000 | — | GPIO | +0 R/W: 32-bit register |
| 0x4000_0000 | — | SYSCON | +0 W: finish; +8 R: cycle counter |
| 0x5000_0000 | 4 KiB | Accelerator | See Section 4 |

SYSCON finish register: writing 1 indicates PASS.

## 3. Processor core

Source: `rtl/rv32im_core.v`, `rtl/rv32im_core_sram.v`

The processor implements a five-stage, in-order RV32IM pipeline:

1. IF — instruction fetch.
2. ID — instruction decode and register read.
3. EX — arithmetic, logic, address generation and branch resolution.
4. MEM — data-memory access.
5. WB — register write-back.

### Hazard handling

- EX/MEM-to-EX forwarding.
- MEM/WB-to-EX forwarding.
- Register-file write-through bypass from WB to ID.
- One-cycle load-use stall.
- Branches and jumps resolve in EX.
- Static not-taken branch policy.

### Multiply/divide

The RISC-V M extension uses the iterative `muldiv_unit` rather than a large single-cycle combinational multiply/divide datapath.

The pipeline stalls while an operation is in progress. The implementation uses approximately 34 cycles per operation.

Implemented corner cases include:

- Division by zero: quotient is -1.
- Remainder by zero: remainder equals the dividend.
- INT_MIN / -1: quotient is INT_MIN.
- INT_MIN % -1: remainder is zero.

The iterative unit is functionally exercised by the dedicated MDU tests and the `muldiv_hazard` SoC regression.

## 4. INT8 systolic accelerator

Sources: `rtl/accel_top.v`, `rtl/systolic_array.v`, `rtl/pe.v`

The accelerator is an output-stationary N×N systolic array supporting N=4 and N=8 configurations.

- Input operands: signed INT8.
- Accumulators: signed INT32.
- Dataflow: output stationary.
- Operand delivery: skewed rows and columns.
- Modeled RUN latency: 3N-2 cycles.
- Additional clear cycle before RUN.

For N=4, RUN takes 10 cycles. For N=8, RUN takes 22 cycles.

### Accelerator register map

| Offset | Access | Meaning |
|---|---|---|
| 0x000 | W | CTRL bit 0: start |
| 0x004 | R | STATUS bit 0: busy; bit 1: done |
| 0x008 | R | Array dimension N |
| 0x100 | W | Matrix A, row-major, byte strobes |
| 0x200 | W | Matrix B, row-major, byte strobes |
| 0x300 | R | Matrix C, signed INT32 results |

Addressing:

- A[i][k] = 0x100 + i×N + k
- B[k][j] = 0x200 + k×N + j
- C[i][j] = 0x300 + 4×(i×N+j)

### Software operation

1. Write matrix A.
2. Write matrix B.
3. Write 1 to CTRL.
4. Poll STATUS until done.
5. Read the output matrix C.

The software reference and accelerator test programs include `matmul_sw` and `matmul_accel`.

## 5. SRAM subsystem

Sources: `rtl/sky130_sram_64kb.v`, `rtl/soc_top_sram.v`

The SRAM-backed SoC integrates 64 KiB of memory using 32 banks of 2 KiB each.

| Property | Configuration |
|---|---|
| Total capacity | 64 KiB |
| Number of banks | 32 |
| Capacity per bank | 2 KiB |
| Macro | `sky130_sram_2kbyte_1rw1r_32x512_8` |
| Macro organization | 512 × 32 bits |
| Macro ports | One read/write port and one read port |
| Total macro instances | 32 |

The wrapper performs bank selection and connects the SRAM macros to the SoC memory interfaces.

The SRAM-backed implementation is functionally verified using the `make sram_test` regression.

## 6. Verification

### Standard SoC regression

Command: `make test`

The regression runs six programs:

- `hello`
- `alu_test`
- `mem_hazard`
- `muldiv_hazard`
- `matmul_sw`
- `matmul_accel`

All six passed in ISS and RTL simulation in the final recorded regression.

### SRAM-backed regression

Command: `make sram_test`

The same six programs passed in ISS and SRAM-backed RTL simulation.

### Reference-model tests

- Multiply/divide Python model: 34,048 operations passed.
- Dedicated MDU RTL testbench: 5,248 operations passed.
- Systolic reference model: 200 random INT8 matrix tests per N configuration for N=2, 4 and 8, checked against NumPy.

See `documentation/VALIDATION_RESULTS.md` for the recorded results and log paths.

## 7. Synthesis and physical design

The integrated SRAM-backed top is synthesized as `soc_top_sram`.

The recorded implementation includes:

- Yosys synthesis with 32 SRAM macro instances preserved.
- SKY130 HD standard-cell and SRAM macro physical views.
- Macro-aware floorplanning.
- 4-column × 8-row SRAM macro placement.
- Power-delivery network generation.
- Standard-cell global and detailed placement.
- Placement legality checks.
- Placement-based parasitic estimation and timing analysis.

The retained accelerator write-decode candidate has placement-estimated WNS of -78.43 ns and TNS of -87,555.66 ns. It is not timing-closed.

Clock-tree synthesis, detailed routing, extracted post-route STA, DRC and LVS signoff are not claimed as completed.

See `documentation/PHYSICAL_DESIGN_CHECKLIST.md` and `documentation/VALIDATION_RESULTS.md`.

## 8. Known limitations and future work

The current repository is an early physical-design implementation, not a tapeout-ready design.

Potential future work, outside the completed release scope:

1. CTS and clock-tree analysis.
2. Global and detailed routing.
3. Post-route extraction and setup/hold timing closure.
4. DRC, LVS, antenna and metal-density signoff.
5. Further architectural performance improvements after the current release baseline is preserved.
