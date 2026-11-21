# Work on a separate copy of the corrected PDN database.
read_db /project/physical_design/results/soc_top_sram_pdn_cut.odb

puts "\n========== BEFORE REPAIR =========="
check_power_grid -net VDD
check_power_grid -net VSS

puts "\n========== REPAIR VDD VIAS =========="
repair_pdn_vias -net VDD

puts "\n========== REPAIR VSS VIAS =========="
repair_pdn_vias -net VSS

puts "\n========== AFTER REPAIR =========="
check_power_grid -net VDD
check_power_grid -net VSS

write_db /project/physical_design/results/soc_top_sram_pdn_repaired_test.odb
write_def /project/physical_design/results/soc_top_sram_pdn_repaired_test.def

puts "\n========== REPAIR TEST COMPLETED =========="
