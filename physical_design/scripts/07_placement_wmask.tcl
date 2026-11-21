set pdk $::env(PDK_DIR)

read_lef /OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd.tlef
read_lef /OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef
read_lef $pdk/libs.ref/sky130_sram_macros/lef/sky130_sram_2kbyte_1rw1r_32x512_8.lef

read_liberty /OpenROAD-flow-scripts/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_liberty $pdk/libs.ref/sky130_sram_macros/lib/sky130_sram_2kbyte_1rw1r_32x512_8_TT_1p8V_25C.lib

# Restore PDN database.
read_db /project/physical_design/results/soc_top_sram_wmask_pdn_cut.odb

# Read timing constraints.
read_sdc /project/physical_design/constraints.sdc

# Initialize SKY130HD routing tracks.
source /OpenROAD-flow-scripts/flow/platforms/sky130hd/make_tracks.tcl


# Assign physical locations to top-level I/O pins.
puts "\n========== I/O PIN PLACEMENT =========="
place_pins -hor_layers met3 -ver_layers met2


puts "\n========== PRE-PLACEMENT CHECK =========="
check_placement -fixed -verbose

# Global placement of movable standard cells.
puts "\n========== GLOBAL PLACEMENT =========="
global_placement -density 0.55

# Legalize standard-cell locations.
puts "\n========== DETAILED PLACEMENT =========="
detailed_placement

# Check movable and fixed instances independently.
puts "\n========== MOVABLE CELL CHECK =========="
check_placement -placeable -verbose

puts "\n========== FIXED MACRO CHECK =========="
check_placement -fixed -verbose

# Report preliminary timing paths.
puts "\n========== PRELIMINARY TIMING =========="
report_checks -path_delay max -format full_clock_expanded

# Save placed design.
write_def /project/physical_design/results/soc_top_sram_wmask_placed.def
write_db /project/physical_design/results/soc_top_sram_wmask_placed.odb

puts "\n========== PLACEMENT COMPLETE =========="
