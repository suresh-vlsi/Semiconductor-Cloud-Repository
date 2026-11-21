# Timing fix: iterative multiply/divide unit

## Problem
`physical_design/results/placement.log` (preliminary timing after global + detailed placement,
`constraints.sdc`: 20 ns clock) reported

    slack (VIOLATED) = -130.08 ns   (data arrival 149.6 ns, required 19.5 ns)

The path is a long chain of `a21oi / o21ai / nor4 / nand4b` cells ending in a core flip-flop:
the single-cycle behavioural `*`, `/` and `%` of the RV32M extension. A 32-bit divider as pure
combinational logic cannot meet 20 ns in SKY130 HD.

## Fix
* `rtl/muldiv_unit.v` - new iterative unit: 32-cycle shift-add multiplier and 32-cycle restoring
  divider on magnitudes, sign fix afterwards. 34 cycles from start to done; the result is held
  until `ack`.
* `rtl/rv32im_core.v` and `rtl/rv32im_core_sram.v` - the combinational M logic is replaced by the
  unit. While a MUL/DIV/REM is in EX (`md_stall`): PC, IF/ID and ID/EX hold, MEM receives bubbles,
  and the instruction leaves EX in the cycle `done` is high. The unit latches its operands in its first
  cycle, so later changes on the forwarding network do not matter. In the SRAM core the unit's `ack`
  is `done && step_en`, so the result survives cycles in which the pipeline is not stepping.
* RISC-V corner cases are unchanged: x/0 = -1, x%0 = x, INT_MIN/-1 = INT_MIN, INT_MIN%-1 = 0.

## Cost
Every MUL/DIV/REM now takes ~34 cycles instead of 1. `matmul_sw` (96 multiplies) gets slower by
roughly 3000 cycles, so the accelerator speed-up grows (software baseline gets slower, accelerator
kernel is unchanged). Re-measure; do not reuse the old 3.8x figure.
A faster multiplier (radix-4 or a pipelined array) is the next step if software MUL speed matters.

## Verify (in this order)
```bash
python3 python/test_muldiv_model.py   # algorithm, bit-accurate Python mirror (already passing)
make muldiv_tb                        # unit RTL vs behavioural reference, ~7,000 operations
make test                             # 6 programs incl. new muldiv_hazard on the plain SoC
make sram_test                        # same 6 programs on the SRAM-backed SoC
bash synthesis/run_sky130_sram_synth.sh   # then redo floorplan/PDN/placement and re-read the timing
```
After the fix the divider path should disappear. The next-longest path (ALU + forwarding + branch
redirect, or the SRAM wrapper address/bank decode) will set the new worst slack - that number can
only come from re-running placement/STA.
