#!/usr/bin/env bash
set -euo pipefail

# Run from the repository root. Example:
# export PDK_DIR=/path/to/sky130A
# bash synthesis/run_sky130_sram_synth.sh

: "${PDK_DIR:?Set PDK_DIR to the installed sky130A directory}"
YOSYS_BIN="${YOSYS:-yosys}"
TOP="soc_top_sram"
ACCEL_N="${ACCEL_N:-4}"
LIBERTY="${PDK_DIR}/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

if [[ ! -f "$LIBERTY" ]]; then
  echo "ERROR: SKY130 HD typical Liberty file not found: $LIBERTY" >&2
  echo "Check that the sky130_fd_sc_hd library is installed under PDK_DIR." >&2
  exit 2
fi
for f in \
  rtl/sky130_sram_macro_blackbox.v \
  rtl/regfile.v rtl/rv32im_core_sram.v rtl/pe.v \
  rtl/systolic_array.v rtl/accel_top.v rtl/uart_tx.v \
  rtl/sky130_sram_64kb.v rtl/soc_top_sram.v; do
  [[ -f "$f" ]] || { echo "ERROR: missing source: $f" >&2; exit 2; }
done

mkdir -p synthesis_reports
OUT="synthesis_reports/${TOP}_sky130"

"$YOSYS_BIN" -p "
  read_verilog -lib rtl/sky130_sram_macro_blackbox.v
  read_verilog -sv -DSYNTHESIS \
    rtl/regfile.v rtl/rv32im_core_sram.v rtl/pe.v \
    rtl/systolic_array.v rtl/accel_top.v rtl/uart_tx.v \
    rtl/sky130_sram_64kb.v rtl/soc_top_sram.v
  chparam -set ACCEL_N ${ACCEL_N} ${TOP}
  hierarchy -check -top ${TOP}
  synth -top ${TOP} -flatten
  dfflibmap -liberty ${LIBERTY}
  abc -liberty ${LIBERTY}
  clean
  check
  tee -o ${OUT}_stat.txt stat -liberty ${LIBERTY}
  write_verilog -noattr ${OUT}_mapped.v
" 2>&1 | tee "${OUT}_yosys.log"

echo
echo "Synthesis completed. Outputs:"
echo "  ${OUT}_stat.txt"
echo "  ${OUT}_mapped.v"
echo "  ${OUT}_yosys.log"
echo
echo "NOTE: SRAM macros remain black boxes. This is logic synthesis only;"
echo "      macro LEF/liberty integration, floorplanning, routing, DRC/LVS,"
echo "      and sign-off timing are separate physical-design tasks."
