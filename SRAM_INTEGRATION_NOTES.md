# SKY130 synchronous SRAM integration bundle

## Added files
- `rtl/rv32im_core_sram.v`: original five-stage RV32IM pipeline with a `step_en` pipeline-advance qualifier.
- `rtl/soc_top_sram.v`: instruction/data request tracking, SRAM response capture, and one-shot MMIO writes.
- `testbench/tb_soc_sram.v`: initializes the 32 macro memories from the existing contiguous program HEX image.
- `python/run_sram_regression.py`: runs the five existing programs against the SRAM-backed top.
- Makefile targets: `sram_compile`, `sram_sim`, `sram_test`.

## Build
In WSL, from the repository root:

```bash
export PDK_DIR=/mnt/d/EDA/pdk/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A
make sram_compile
make sram_test
```

Single program:

```bash
make sram_sim PROG=mem_hazard
```

## Important validation status
The standalone SRAM wrapper's 30/30 functional tests were passed in the user's WSL environment. This bundle's CPU/SoC integration has **not** been simulated in the generation environment because Icarus Verilog and the PDK macro model are not installed/mounted there. Therefore this is an implementation candidate, not a claimed verified SoC integration. Run `make sram_test` and inspect every program result before committing or relying on it.

The SRAM testbench initializes the behavioral macro model through its `mem` array. This assumes the supplied SKY130 macro behavioral model exposes that array as `mem`, as in the version used in the project.
