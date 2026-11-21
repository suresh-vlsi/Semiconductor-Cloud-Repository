read_db /project/physical_design/results/soc_top_sram_pdn_repaired_test.odb

set block [ord::get_db_block]

puts "\n========== VIA GEOMETRY DIAGNOSTIC =========="

foreach net [$block getNets] {
    set net_name [$net getName]

    if {$net_name ne "VDD" && $net_name ne "VSS"} {
        continue
    }

    puts "\nNET: $net_name"
    set shown 0

    foreach swire [$net getSWires] {
        foreach sbox [$swire getWires] {

            if {![$sbox isVia]} {
                continue
            }

            set block_via [$sbox getBlockVia]
            set tech_via [$sbox getTechVia]

            if {$block_via ne "NULL"} {
                set via_name [$block_via getName]
            } elseif {$tech_via ne "NULL"} {
                set via_name [$tech_via getName]
            } else {
                set via_name "UNKNOWN"
            }

            puts "\nVia: $via_name"
            puts "SBox: $sbox"

            foreach method {xMin yMin xMax yMax} {
                if {[catch {$sbox $method} value]} {
                    puts "  $method : ERROR $value"
                } else {
                    puts "  $method : $value"
                }
            }

            foreach method {getViaXY getViaBoxes getViaLayerBoxes} {
                if {[catch {$sbox $method} value]} {
                    puts "  $method : ERROR $value"
                } else {
                    puts "  $method : $value"
                }
            }

            incr shown
            if {$shown >= 3} {
                break
            }
        }

        if {$shown >= 3} {
            break
        }
    }
}

puts "\n========== DIAGNOSTIC COMPLETED =========="
