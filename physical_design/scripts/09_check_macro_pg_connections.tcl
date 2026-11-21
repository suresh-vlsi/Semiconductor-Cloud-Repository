read_db /project/physical_design/results/soc_top_sram_pdn_cut.odb

set block [ord::get_db_block]
set macro_count 0
set checked 0
set failures 0

foreach inst [$block getInsts] {
    set inst_name [$inst getName]

    if {[string match "sram_macro_*" $inst_name]} {
        incr macro_count

        foreach iterm [$inst getITerms] {
            set pin_name [[$iterm getMTerm] getName]

            if {$pin_name eq "vccd1" || $pin_name eq "vssd1"} {
                incr checked
                set expected "VDD"
                if {$pin_name eq "vssd1"} {
                    set expected "VSS"
                }

                set net_name "UNCONNECTED"
                if {![catch {set net_name [[$iterm getNet] getName]}]} {
                    # Net name successfully retrieved
                }

                if {$net_name ne $expected} {
                    puts "FAIL: $inst_name/$pin_name -> $net_name (expected $expected)"
                    incr failures
                }
            }
        }
    }
}

puts "\n========== SRAM PG CONNECTION REPORT =========="
puts "SRAM macros found : $macro_count"
puts "PG pins checked  : $checked"
puts "Connection errors: $failures"

if {$macro_count != 32 || $checked != 64 || $failures != 0} {
    puts "RESULT: FAILED"
    exit 1
}

puts "RESULT: ALL 32 SRAM MACROS HAVE CORRECT PG CONNECTIONS"
