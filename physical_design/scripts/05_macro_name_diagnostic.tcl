set pdk $::env(PDK_DIR)

read_lef /OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd.tlef
read_lef /OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef
read_lef $pdk/libs.ref/sky130_sram_macros/lef/sky130_sram_2kbyte_1rw1r_32x512_8.lef

read_liberty /OpenROAD-flow-scripts/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_liberty $pdk/libs.ref/sky130_sram_macros/lib/sky130_sram_2kbyte_1rw1r_32x512_8_TT_1p8V_25C.lib

read_verilog /project/physical_design/soc_top_sram_openroad.v
link_design soc_top_sram

initialize_floorplan \
    -die_area {0 0 4700 4300} \
    -core_area {200 200 4500 4100} \
    -site unithd

puts "\n========== INSTANCE COLLECTION =========="
set macros [get_cells -hierarchical *sram_macro]
puts "Count: [llength $macros]"
foreach inst $macros {
    puts "STA name: [get_name $inst]"
}

write_def /project/physical_design/results/soc_top_sram_preplacement.def
puts "\nDEF exported."
