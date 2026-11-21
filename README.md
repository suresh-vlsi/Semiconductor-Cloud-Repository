cd /mnt/d/Azure-VLSI-Projects/Semiconductor-Cloud-Repository

cat > README.md <<'EOF'
# Semiconductor Cloud Repository
## RV32IM SoC with INT8 Systolic Accelerator and SKY130 SRAM Physical Design

An open-source RTL-to-physical-design project integrating a five-stage RV32IM processor, an INT8 systolic-array accelerator, memory-mapped peripherals, and a 64 KiB banked SKY130 SRAM subsystem.

The project includes Verilog RTL, Python reference models, self-checking simulation, Yosys synthesis, and an OpenROAD-based SKY130 HD floorplan, macro placement, power-grid generation, and standard-cell placement flow.

> **Project status:** Functional regressions pass. Integrated synthesis, SRAM macro integration, floorplanning, PDN generation, and placement have been demonstrated. The current placement-estimated timing still has substantial negative slack. CTS, detailed routing, extracted signoff STA, DRC, and LVS are not claimed.

---

## 1. Design overview

| Component | Implementation |
|---|---|
| Processor | RV32IM, five-stage in-order pipeline |
| Multiply/divide | Iterative multiply/divide unit |
| Accelerator | Output-stationary INT8 systolic array |
| Accelerator configurations | N=4 and N=8 |
| Accumulator | 32-bit |
| SRAM subsystem | 64 KiB, 32 banks × 2 KiB |
| SRAM macro | `sky130_sram_2kbyte_1rw1r_32x512_8` |
| SRAM interface | Separate instruction-read and data-read/write ports |
| Peripherals | UART, GPIO, SYSCON, accelerator MMIO |
| RTL simulation | Icarus Verilog |
| Synthesis | Yosys |
| Physical design | OpenROAD / SKY130 HD |

## 2. Architecture

The processor uses a five-stage IF/ID/EX/MEM/WB pipeline with forwarding, load-use hazard handling, and branch/jump control.

The M extension uses an iterative unit rather than a single-cycle combinational divider and multiplier. Multiply, divide, and remainder operations take approximately 34 cycles, with the pipeline stalled while the operation completes.

The accelerator is an output-stationary systolic array. Operand skewing aligns matrix operands as they propagate through the processing elements. Its modeled RUN latency is `3N-2` cycles: 10 cycles for N=4 and 22 cycles for N=8, in addition to the clear cycle.

The SRAM subsystem contains 32 banks of 2 KiB each, providing 64 KiB total capacity. The macro provides a read/write port and a separate read port. The wrapper performs bank selection and connects the SRAM macros to the SoC.

See [architecture documentation](documentation/architecture.md) for the memory map, pipeline behavior, accelerator programming model, and SRAM organization.

## 3. Functional verification

The final release regression runs completed on 21 November 2026.

### Standard SoC regression

| Program | ISS | RTL | RTL cycles |
|---|---:|---:|---:|
| hello | PASS | PASS | 603 |
| alu_test | PASS | PASS | 8,143 |
| mem_hazard | PASS | PASS | 250 |
| muldiv_hazard | PASS | PASS | 1,271 |
| matmul_sw | PASS | PASS | 4,392 |
| matmul_accel | PASS | PASS | 456 |

### SRAM-backed SoC regression

| Program | ISS | SRAM RTL | RTL cycles |
|---|---:|---:|---:|
| hello | PASS | PASS | 973 |
| alu_test | PASS | PASS | 18,429 |
| mem_hazard | PASS | PASS | 1,001 |
| muldiv_hazard | PASS | PASS | 1,965 |
| matmul_sw | PASS | PASS | 7,585 |
| matmul_accel | PASS | PASS | 1,801 |

Additional checks:
- Python toolchain self-test passed.
- Multiply/divide reference model passed 34,048 operations across all eight RV32M `funct3` values.
- Systolic timing model matched NumPy for 200 random INT8 matrix multiplications at each of N=2, 4, and 8.
- The 4×4 accelerator workload reported a 17.3× speed-up over the software kernel in the standard RTL regression (4,173 versus 241 kernel cycles).

These are simulation and model results, not measured silicon performance.

Raw final logs:
- `simulation_logs/final_release_regression.log`
- `simulation_logs/final_release_sram_regression.log`

## 4. Synthesis and physical design

The integrated SRAM-backed SoC was synthesized with Yosys while preserving the 32 SRAM macro instances.

The current accelerator write-decode candidate reports:
- Mapped standard-cell area: **225,984.2368 µm²**
- Sequential area: **75,880.2752 µm²**
- Sequential fraction: **33.58%**
- Mapped cell count reported by Yosys: **24,587** (includes macro blackboxes and scope-information cells)

The OpenROAD flow completed:
1. Technology and standard-cell LEF/Liberty loading.
2. SRAM macro LEF integration.
3. Floorplanning and placement of 32 SRAM macros.
4. Standard-cell row cutting around macro obstructions.
5. PDN generation and macro power-pin connection.
6. Global placement.
7. Detailed placement and legality checks.
8. Placement-based parasitic estimation and timing analysis.

The accelerator write-decode candidate completed detailed placement with **zero illegal standard cells**.

### Placement-estimated timing

| Metric | Result |
|---|---:|
| WNS | −78.43 ns |
| TNS | −87,555.66 ns |
| Data arrival on worst path | 97.9908 ns |
| Data required | 19.5657 ns |

This is placement-estimated timing using the SKY130 RC layer configuration. It is not routed timing or signoff STA. The worst path includes a high-fanout decode net. Timing closure has **not** been achieved.

The accelerator write-decode candidate is the best of the measured experimental candidates in WNS and TNS. It is retained as the final experimental implementation, not represented as a signoff-ready design.

### Physical-design completion boundary

Completed: synthesis, macro-aware floorplan, macro placement, PDN generation, standard-cell placement, placement legality checks, and placement-estimated timing analysis.

Not claimed: clock-tree synthesis, detailed routing, extracted post-route timing, hold closure, DRC, LVS, antenna checks, metal-density checks, or tapeout signoff.

See `physical_design/` and `synthesis_reports/` for scripts, netlists, databases, DEF files, and reports.

## 5. Repository layout

| Directory | Contents |
|---|---|
| `rtl/` | Processor, accelerator, peripherals, SRAM wrapper, multiply/divide unit |
| `testbench/` | RTL testbenches and assembly test programs |
| `python/` | Assembler, ISS, generators, reference models, regression scripts |
| `synthesis/` | Yosys synthesis scripts |
| `synthesis_reports/` | Mapped netlist, cell statistics, synthesis logs |
| `physical_design/scripts/` | OpenROAD floorplan, PDN, placement, timing, and utility scripts |
| `physical_design/results/` | ODB, DEF, and physical-design run artifacts |
| `physical_design/reports/` | Physical-design diagnostic logs |
| `simulation_logs/` | Final regression logs and simulation evidence |
| `documentation/` | Architecture, validation, timing, and implementation notes |
| `backup/` | Preserved pre-experiment source snapshots |

## 6. Reproducing the functional tests

The commands below assume Ubuntu/WSL, Python 3, NumPy, Icarus Verilog, and the RISC-V toolchain required by the project scripts are installed.

```bash
# Install the Python dependency
python3 -m pip install numpy

# Run toolchain/model checks and standard ISS + RTL regression
make test

# Run the SRAM-backed ISS + RTL regression
make sram_test

# Run the dedicated multiply/divide RTL testbench
make muldiv_tb