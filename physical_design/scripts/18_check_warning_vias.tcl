read_db /project/physical_design/results/soc_top_sram_pdn_repaired_test.odb

set block [ord::get_db_block]

# Coordinates are in DBU: 1000 DBU = 1 micron.
set vdd_target_y 2949220
set vss_target_y 2988480
set tolerance 3000

puts "\n========== WARNING-REGION VIA ANALYSIS =========="

foreach net [$block getNets] {
    set net_name [$net getName]

    if {$net_name eq "VDD"} {
        set target_y $vdd_target_y
    } elseif {$net_name eq "VSS"} {
        set target_y $vss_target_y
    } else {
        continue
    }

    set nearby_count 0
    set printed_count 0

    puts "\nNET: $net_name"
    puts "Target Y: [expr {$target_y / 1000.0}] um"
    puts "Tolerance: [expr {$tolerance / 1000.0}] um"

    foreach swire [$net getSWires] {
        foreach sbox [$swire getWires] {

            if {![$sbox isVia]} {
                continue
            }

            set xy [$sbox getViaXY]
            set via_x [lindex $xy 0]
            set via_y [lindex $xy 1]

            if {abs($via_y - $target_y) > $tolerance} {
                continue
            }

            incr nearby_count

            if {$printed_count >= 15} {
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
            puts "Centre DBU: $xy"
            puts "Centre um: [expr {$via_x / 1000.0}], [expr {$via_y / 1000.0}]"

            set shapes [$sbox getViaBoxes shapes]

            foreach shape $shapes {
                set layer [[$shape getTechLayer] getName]

                puts "  Layer: $layer"
                puts "  Box DBU: [$shape xMin] [$shape yMin] [$shape xMax] [$shape yMax]"
            }

            incr printed_count
        }
    }

    puts "\nNearby via instances: $nearby_count"
    puts "Detailed instances printed: $printed_count"
}

puts "\n========== ANALYSIS COMPLETED =========="
