read_db /project/physical_design/results/soc_top_sram_pdn_repaired_test.odb

set block [ord::get_db_block]

puts "\n========== PDN VIA INVENTORY =========="

set total_vias 0
set total_boxes 0

foreach net [$block getNets] {
    set net_name [$net getName]

    if {$net_name ne "VDD" && $net_name ne "VSS"} {
        continue
    }

    set via_count 0
    set box_count 0
    set via_types [dict create]

    foreach swire [$net getSWires] {
        foreach sbox [$swire getWires] {
            incr box_count

            set block_via [$sbox getBlockVia]
            set tech_via [$sbox getTechVia]

            if {$block_via ne "NULL"} {
                set via_name [$block_via getName]
                incr via_count
                dict incr via_types $via_name

            } elseif {$tech_via ne "NULL"} {
                set via_name [$tech_via getName]
                incr via_count
                dict incr via_types $via_name
            }
        }
    }

    incr total_vias $via_count
    incr total_boxes $box_count

    puts "\nNET: $net_name"
    puts "Special-wire boxes: $box_count"
    puts "Via instances: $via_count"
    puts "Via types:"

    dict for {name count} $via_types {
        puts "  $name : $count"
    }
}

puts "\n========== TOTALS =========="
puts "Total special-wire boxes: $total_boxes"
puts "Total via instances: $total_vias"

puts "\n========== INVENTORY COMPLETED =========="
