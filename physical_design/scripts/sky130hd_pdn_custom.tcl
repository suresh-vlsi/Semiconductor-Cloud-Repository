####################################
# Voltage domains
####################################
set_voltage_domain -name {CORE} -power {VDD} -ground {VSS}

####################################
# Standard-cell grid
####################################
define_pdn_grid -name {grid} -voltage_domains {CORE} -pins {met5}

add_pdn_stripe -grid {grid} -layer {met1} -width {0.48} -pitch {5.44} -offset {0} -followpins
add_pdn_stripe -grid {grid} -layer {met4} -width {1.600} -pitch {27.140} -offset {13.570}
add_pdn_stripe -grid {grid} -layer {met5} -width {1.600} -pitch {27.200} -offset {13.600}

add_pdn_connect -grid {grid} -layers {met1 met4}
add_pdn_connect -grid {grid} -layers {met4 met5}

####################################
# SRAM macro grid: R0/R180/MX/MY
# Reduced halo to fit existing rows
####################################
define_pdn_grid -name {CORE_macro_grid_1} \
    -voltage_domains {CORE} \
    -macro \
    -orient {R0 R180 MX MY} \
    -halo {0 0 0 0} \
    -default \
    -grid_over_boundary

add_pdn_connect -grid {CORE_macro_grid_1} -layers {met4 met5}

####################################
# SRAM macro grid: rotated orientations
####################################
define_pdn_grid -name {CORE_macro_grid_2} \
    -voltage_domains {CORE} \
    -macro \
    -orient {R90 R270 MXR90 MYR90} \
    -halo {0 0 0 0} \
    -default \
    -grid_over_boundary

add_pdn_connect -grid {CORE_macro_grid_2} -layers {met4 met5}
