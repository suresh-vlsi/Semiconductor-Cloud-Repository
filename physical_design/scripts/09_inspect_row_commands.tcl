puts "\n========== ROW CUTTING COMMANDS =========="
puts [lsort [info commands *row*]]

puts "\n========== CUT ROWS HELP =========="
if {[llength [info commands cut_rows]] > 0} {
    help cut_rows
}

puts "\n========== FLOORPLAN COMMANDS =========="
puts [lsort [info commands *floorplan*]]

puts "\n========== BLOCKAGE COMMANDS =========="
puts [lsort [info commands *blockage*]]
