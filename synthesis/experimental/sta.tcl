#experimental timing setup; no successful timing result is recorded
#use a standalone OpenSTA installation; the original OpenROAD run failed
#OpenROAD needs technology setup that is not supplied by this script
set SCRIPT_DIR [file dirname [file normalize [info script]]]
if {![info exists ::env(SKY130_LIB)]} {
  error "Set SKY130_LIB to the SKY130 HD Liberty file path"
}
set LIB_FILE $::env(SKY130_LIB)

#read library
read_liberty $LIB_FILE

#read netlist
read_verilog [file join $SCRIPT_DIR .. router_sky130_netlist.v]

#top module
link_design router_top

#read constraints
read_sdc [file join $SCRIPT_DIR constraints.sdc]

#timing report
report_checks -path_delay max -group_count 10

#worst setup slack
report_worst_slack -max
