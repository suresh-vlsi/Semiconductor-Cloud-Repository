read_db /project/physical_design/results/soc_top_sram_pdn_cut.odb

set macros [get_cells -hierarchical *sram_macro_*]

puts "\n========== SRAM INSTANCE VERIFICATION =========="
puts "SRAM macro count: [llength $macros]"

if {[llength $macros] != 32} {
    error "SRAM macro count mismatch!"
}

puts "All 32 SRAM instances are present."
