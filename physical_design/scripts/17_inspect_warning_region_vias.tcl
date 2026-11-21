read_db /project/physical_design/results/soc_top_sram_pdn_repaired_test.odb

set block [ord::get_db_block]

puts "\n========== VIA SHAPE INSPECTION =========="

set inspected 0

foreach net [$block getNets] {
    set net_name [$net getName]

    if {$net_name ne "VDD" && $net_name ne "VSS"} {
        continue
    }

    foreach swire [$net getSWires] {
        foreach sbox [$swire getWires] {

            if {![$sbox isVia]} {
                continue
            }

            set xy [$sbox getViaXY]
            set shapes [$sbox getViaBoxes shapes]

            puts "\nNET: $net_name"
            puts "Via centre: $xy"
            puts "Number of shapes: [llength $shapes]"

            foreach shape $shapes {
                puts "\nShape: $shape"

                foreach method {
                    getTechLayer
                    getBox
                    xMin
                    yMin
                    xMax
                    yMax
                } {
                    if {[catch {$shape $method} value]} {
                        puts "  $method : unavailable"
                    } else {
                        puts "  $method : $value"
                    }
                }
            }

            incr inspected
            if {$inspected >= 2} {
                break
            }
        }

        if {$inspected >= 2} {
            break
        }
    }

    if {$inspected >= 2} {
        break
    }
}

puts "\n========== INSPECTION COMPLETED =========="
