read_db /project/physical_design/results/soc_top_sram_pdn_repaired_test.odb

puts "\n========== SRAM MACRO COUNT =========="
set macros [get_cells -hierarchical *sram_macro_*]
puts "SRAM macro count: [llength $macros]"

puts "\n========== POWER GRID CHECK =========="
check_power_grid -net VDD
check_power_grid -net VSS

puts "\n========== REPAIRED PDN CHECK COMPLETED =========="
