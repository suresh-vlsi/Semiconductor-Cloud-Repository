read_db /project/physical_design/results/soc_top_sram_pdn_repaired_test.odb

puts "\n========== SRAM POWER PIN VERIFICATION =========="

set block [ord::get_db_block]

set macro_count 0
set vdd_count 0
set vss_count 0
set vdd_connected 0
set vss_connected 0
set errors 0

foreach inst [$block getInsts] {

    set inst_name [$inst getName]

    if {[string match "sram_macro_*" $inst_name]} {

        incr macro_count
        puts "\nMACRO: $inst_name"

        foreach iterm [$inst getITerms] {

            set mterm [$iterm getMTerm]
            set pin_name [$mterm getName]
            set net [$iterm getNet]

            if {$net eq "NULL"} {
                set net_name "UNCONNECTED"
            } else {
                set net_name [$net getName]
            }

            if {$pin_name eq "vccd1"} {
                incr vdd_count
                if {$net_name eq "VDD"} {
                    incr vdd_connected
                } else {
                    incr errors
                }
            }

            if {$pin_name eq "vssd1"} {
                incr vss_count
                if {$net_name eq "VSS"} {
                    incr vss_connected
                } else {
                    incr errors
                }
            }

            if {$pin_name eq "vccd1" || $pin_name eq "vssd1"} {
                puts "  $pin_name -> $net_name"
            }
        }
    }
}

puts "\n========== SUMMARY =========="
puts "SRAM macros found       : $macro_count"
puts "VDD terminals found     : $vdd_count"
puts "VDD correctly connected: $vdd_connected"
puts "VSS terminals found     : $vss_count"
puts "VSS correctly connected: $vss_connected"
puts "Connection errors       : $errors"

puts "\n========== POWER GRID CONNECTIVITY =========="
check_power_grid -net VDD
check_power_grid -net VSS

puts "\n========== CHECK COMPLETED =========="
