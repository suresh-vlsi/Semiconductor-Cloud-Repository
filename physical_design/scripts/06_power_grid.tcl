set pdk $::env(PDK_DIR)

# Load technology, standard-cell and SRAM abstracts.
read_lef /OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd.tlef
read_lef /OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef
read_lef $pdk/libs.ref/sky130_sram_macros/lef/sky130_sram_2kbyte_1rw1r_32x512_8.lef

# Load timing libraries.
read_liberty /OpenROAD-flow-scripts/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_liberty $pdk/libs.ref/sky130_sram_macros/lib/sky130_sram_2kbyte_1rw1r_32x512_8_TT_1p8V_25C.lib

# Restore the previously saved macro-placed database.
read_db /project/physical_design/results/soc_top_sram_floorplan.odb

# Add SRAM macro power-pin mappings.
# The platform PDN script will add standard-cell mappings.
add_global_connection \
    -net VDD -inst_pattern {.*} -pin_pattern {^vccd1$} -power

add_global_connection \
    -net VSS -inst_pattern {.*} -pin_pattern {^vssd1$} -ground

# Reuse the official SKY130HD platform PDN configuration.
# It defines standard-cell grids and macro grids.
source /OpenROAD-flow-scripts/flow/platforms/sky130hd/pdn.tcl

puts "\n========== GENERATING POWER GRID =========="

pdngen

puts "\n========== VERIFY FIXED INSTANCES =========="
check_placement -fixed -verbose

# Save powered database.
write_def /project/physical_design/results/soc_top_sram_pdn.def
write_db /project/physical_design/results/soc_top_sram_pdn.odb

puts "\n========== PDN COMPLETE =========="
