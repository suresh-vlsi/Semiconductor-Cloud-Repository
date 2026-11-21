read_db /project/physical_design/results/soc_top_sram_pdn_repaired_test.odb

puts "\n========== OPENROAD COMMAND AVAILABILITY =========="

foreach cmd {
    get_db
    get_cells
    get_pins
    get_nets
    get_full_name
    odb::dbBlock
    odb::dbInst
    odb::dbITerm
} {
    puts "$cmd : [expr {[llength [info commands $cmd]] > 0 ? "AVAILABLE" : "NOT AVAILABLE"}]"
}

puts "\n========== DESIGN INFORMATION =========="
puts "Design: [ord::get_db_block]"

puts "\n========== CHECK COMPLETED =========="
