#clock
create_clock -name clk -period 10.000 [get_ports clock]

#clock uncertainty
set_clock_uncertainty 0.200 [get_clocks clk]


#input delays
set_input_delay 1.000 -clock clk [get_ports {data_in[*]}]
set_input_delay 1.000 -clock clk [get_ports pkt_valid]

set_input_delay 1.000 -clock clk [get_ports read_enb_0]
set_input_delay 1.000 -clock clk [get_ports read_enb_1]
set_input_delay 1.000 -clock clk [get_ports read_enb_2]

set_input_delay 1.000 -clock clk [get_ports resetn]


#output delays
set_output_delay 1.000 -clock clk [get_ports {data_out_0[*]}]
set_output_delay 1.000 -clock clk [get_ports {data_out_1[*]}]
set_output_delay 1.000 -clock clk [get_ports {data_out_2[*]}]

set_output_delay 1.000 -clock clk [get_ports vld_out_0]
set_output_delay 1.000 -clock clk [get_ports vld_out_1]
set_output_delay 1.000 -clock clk [get_ports vld_out_2]

set_output_delay 1.000 -clock clk [get_ports error]
set_output_delay 1.000 -clock clk [get_ports busy]
