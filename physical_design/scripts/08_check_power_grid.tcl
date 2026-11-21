# Load generated PDN database
read_db /project/physical_design/results/soc_top_sram_pdn_cut.odb

puts "\n========== CHECK VDD POWER GRID =========="
check_power_grid -net VDD

puts "\n========== CHECK VSS GROUND GRID =========="
check_power_grid -net VSS

puts "\n========== POWER GRID CHECKS FINISHED =========="
