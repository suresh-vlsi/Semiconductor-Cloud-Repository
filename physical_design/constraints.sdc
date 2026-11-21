create_clock -name core_clk -period 20.0 [get_ports clk]

set_clock_uncertainty 0.20 [get_clocks core_clk]

# Reset is asynchronous and excluded from normal timing analysis.
set_false_path -from [get_ports rst_n]

# Exploratory external output-delay assumption.
set_output_delay -clock core_clk 2.0 [all_outputs]
