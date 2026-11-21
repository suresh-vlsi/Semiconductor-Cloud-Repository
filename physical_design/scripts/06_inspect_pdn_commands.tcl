read_db /project/physical_design/results/soc_top_sram_pdn.odb

puts "\n========== POWER-RELATED COMMANDS =========="
puts [lsort [info commands *power*]]

puts "\n========== PDN-RELATED COMMANDS =========="
puts [lsort [info commands *pdn*]]

puts "\n========== DESIGN DATABASE LOADED =========="
