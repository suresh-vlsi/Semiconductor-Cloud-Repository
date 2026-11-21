set pdk $::env(PDK_DIR)

read_lef /OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd.tlef
read_lef /OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef
read_lef $pdk/libs.ref/sky130_sram_macros/lef/sky130_sram_2kbyte_1rw1r_32x512_8.lef

read_liberty /OpenROAD-flow-scripts/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_liberty $pdk/libs.ref/sky130_sram_macros/lib/sky130_sram_2kbyte_1rw1r_32x512_8_TT_1p8V_25C.lib

read_db /project/physical_design/results/soc_top_sram_optimized_placed.odb
read_sdc /project/physical_design/constraints.sdc

# Apply official SKY130HD wire resistance and capacitance settings.
source /OpenROAD-flow-scripts/flow/platforms/sky130hd/setRC.tcl

estimate_parasitics -placement

puts "\n========== DETAILED CRITICAL PATH =========="
report_checks -path_delay max \
  -format full_clock_expanded \
  -fields {slew cap fanout input_pin net} \
  -digits 4

puts "\n========== WORST SETUP PATH =========="
report_checks -path_delay max -group_path_count 5

puts "\n========== TIMING SUMMARY =========="
report_worst_slack -max
report_tns
