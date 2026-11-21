# Architecture and verification notes

## 1. Block diagram
```
          +--------------------------- soc_top ----------------------------+
          |  rv32im_core --imem--> RAM (64 KiB, 2 read ports)               |
          |   IF|ID|EX|MEM|WB  --dmem--> address decoder --> RAM            |
          |                                              |-> UART TX        |
          |                                              |-> GPIO           |
          |                                              |-> SYSCON/cycles  |
          |                                              '-> accel_top      |
          |                                                  FSM + skew feeders + systolic_array (NxN PEs) |
          +-----------------------------------------------------------------+
```

## 2. Memory map
| base | size | device | registers |
|---|---|---|---|
| 0x0000_0000 | 64 KiB | RAM (code + data) | - |
| 0x2000_0000 | | UART | +0 W tx byte, +4 R bit0 busy |
| 0x3000_0000 | | GPIO | +0 R/W 32-bit register |
| 0x4000_0000 | | SYSCON | +0 W finish (1 = PASS), +8 R cycle counter |
| 0x5000_0000 | 4 KiB | Accelerator | see section 4 |

## 3. Core (rtl/rv32im_core.v)
* RV32IM, 5 stages, in-order. No CSRs, exceptions, or interrupts; ECALL/EBREAK/FENCE are NOPs.
* Hazards: forwarding EX/MEM->EX and MEM/WB->EX; register-file write-through bypass (WB->ID);
  1-cycle stall for load-use. Control: branches and jumps resolve in EX, static not-taken, 2-cycle penalty.
* M extension uses behavioural `*`, `/`, `%` in one cycle (correct but long critical path).
  Replace with a pipelined multiplier and an iterative divider (stall the pipe) for timing closure.
* RISC-V corner cases implemented: x/0 = -1, x%0 = x, INT_MIN/-1 = INT_MIN, INT_MIN%-1 = 0.
* Memories are asynchronous-read. For FPGA BRAM / SRAM macros make fetch and load synchronous
  (adds a wait-state or an extra pipeline stage).

## 4. Accelerator (rtl/accel_top.v, rtl/systolic_array.v, rtl/pe.v)
Output-stationary NxN array (N = 4 or 8), INT8 x INT8 -> INT32 accumulators.
Row i is fed A[i][k] at cycle k+i and column j is fed B[k][j] at cycle k+j, so PE(i,j) sees matching
operands at cycle k+i+j. Total RUN time = 3N-2 cycles (10 for N=4, 22 for N=8); plus 1 clear cycle.
| offset | access | meaning |
|---|---|---|
| 0x000 | W | CTRL bit0 = start |
| 0x004 | R | STATUS bit0 busy, bit1 done (cleared by start) |
| 0x008 | R | N |
| 0x100 | W (byte strobes) | A row-major, A[i][k] at 0x100 + i*N + k |
| 0x200 | W (byte strobes) | B row-major, B[k][j] at 0x200 + k*N + j |
| 0x300 | R | C[i][j] at 0x300 + 4*(i*N+j), int32 |
Software flow: copy A and B, write 1 to CTRL, poll STATUS.done, read C (see matmul_accel.S).
Larger matrices: tile into NxN blocks and accumulate in software (or add a DMA + accumulate mode).

## 5. Verification plan
| level | method | status |
|---|---|---|
| assembler | hand-verified encodings, li round-trip through ISS | done (python/test_toolchain.py) |
| ISS | passes all programs against independently-computed expected values; a tampered test fails | done |
| accelerator timing | cycle-accurate Python model vs NumPy (N=2,4,8) | done (python/golden_systolic.py) |
| accelerator RTL | tb_accel.v, 200 random matmuls + -128/127 corners | written, run `make accel_tb` |
| core + SoC RTL | tb_soc.v running the 5 programs, PASS via SYSCON | written, run `make test` |
| co-simulation | ISS vs RTL final state (PASS code, GPIO kernel cycles) | done by regression script |
Suggested additions: riscv-arch-test compliance (needs the RISC-V GCC toolchain), per-retire trace
comparison between RTL and ISS, SVA assertions (x0 never written, pipeline never stalls and flushes
together), cocotb or UVM-style constrained-random instruction streams, code/functional coverage.

## 6. Physical design
* Synthesize the core and accelerator separately (the 64 KiB behavioural RAM would become 500k flops);
  use an SRAM macro (OpenRAM sky130) for a full-chip flow.
* `make synth` -> Yosys generic stats. `openlane/<block>/config.json` -> OpenLane 1.x (sky130A), run with
  `flow.tcl -design <path>`. CLOCK_PERIOD is 25 ns; expect the single-cycle divider to limit fmax.
* Record area / WNS / TNS / power with `python/parse_reports.py`; sweep CLOCK_PERIOD for a frequency/area curve.

## 7. Roadmap
1. Get the RTL regression green (`make test`).
2. Replace the divider/multiplier with multi-cycle units; measure fmax before/after.
3. Add gshare predictor + I/D caches; compare CPI on matmul_sw.
4. Add DMA + AXI4-Lite wrapper; stream operands and tile large matrices.
5. riscv-arch-test, SVA, coverage; CI via GitHub Actions (iverilog + yosys containers).
6. FPGA prototype + MNIST (8x8 digits fit an 8x8 array) firmware; GOPS/W vs software.
