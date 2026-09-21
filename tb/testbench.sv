`timescale 1ns/1ps
`include "interface.sv" 

module testbench;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  //include order defines each transaction/component before its users
  //compile this top file once; the included class files are not separate tops
  //transactions
  `include "write_xtn.sv"
  `include "read_xtn.sv"
  `include "router_sequences.sv"

  //write side
  `include "write_sequencer.sv"
  `include "write_driver.sv"
  `include "write_monitor.sv"
  `include "write_agent.sv"

  //read side 1
  `include "read_sequencer1.sv"
  `include "read_driver1.sv"
  `include "read_monitor1.sv"
  `include "read_agent1.sv"

  //read side 2
  `include "read_sequencer2.sv"
  `include "read_driver2.sv"
  `include "read_monitor2.sv"
  `include "read_agent2.sv"

  //read side 3
  `include "read_sequencer3.sv"
  `include "read_driver3.sv"
  `include "read_monitor3.sv"
  `include "read_agent3.sv"

  //virtual sequencer and sequence
  `include "virtual_seqr.sv"
  `include "virtual_sequence.sv"

  //scoreboard and coverage
  `include "scoreboard.sv"
  `include "functional_coverage.sv"

  //environment and test
  `include "environment.sv"
  `include "test.sv"


  logic clock;


  //clock generation
  initial
    begin
      clock = 0;
      forever #5 clock = ~clock;
    end


  //interface
  router_if intf(clock);


  //DUT
  router_top dut(

    .clock(clock),
    .resetn(intf.resetn),

    .data_in(intf.data_in),
    .pkt_valid(intf.pkt_valid),

    .read_enb_0(intf.read_enb_0),
    .read_enb_1(intf.read_enb_1),
    .read_enb_2(intf.read_enb_2),

    .data_out_0(intf.data_out_0),
    .data_out_1(intf.data_out_1),
    .data_out_2(intf.data_out_2),

    .vld_out_0(intf.vld_out_0),
    .vld_out_1(intf.vld_out_1),
    .vld_out_2(intf.vld_out_2),

    .error(intf.error),
    .busy(intf.busy)

  );


  //reset
  initial
    begin

      intf.resetn = 0;

      intf.data_in = 0;
      intf.pkt_valid = 0;

      intf.read_enb_0 = 0;
      intf.read_enb_1 = 0;
      intf.read_enb_2 = 0;

      repeat(2)
        @(posedge clock);

      intf.resetn = 1;

    end


  //the config paths must match the environment instance names exactly
  //set every virtual interface before run_test builds the UVM hierarchy
  //set interfaces
  initial
    begin

      //write driver
      uvm_config_db #(virtual router_if.WDR_MP)::set(
        null,
        "uvm_test_top.env.wr_agent.drv",
        "vif",
        intf
      );

      //write monitor
      uvm_config_db #(virtual router_if.WMON_MP)::set(
        null,
        "uvm_test_top.env.wr_agent.mon",
        "vif",
        intf
      );


      //read driver1
      uvm_config_db #(virtual router_if.RDR0_MP)::set(
        null,
        "uvm_test_top.env.rd_agent1.drv",
        "vif",
        intf
      );

      //read monitor1
      uvm_config_db #(virtual router_if.RMON0_MP)::set(
        null,
        "uvm_test_top.env.rd_agent1.mon",
        "vif",
        intf
      );


      //read driver2
      uvm_config_db #(virtual router_if.RDR1_MP)::set(
        null,
        "uvm_test_top.env.rd_agent2.drv",
        "vif",
        intf
      );

      //read monitor2
      uvm_config_db #(virtual router_if.RMON1_MP)::set(
        null,
        "uvm_test_top.env.rd_agent2.mon",
        "vif",
        intf
      );


      //read driver3
      uvm_config_db #(virtual router_if.RDR2_MP)::set(
        null,
        "uvm_test_top.env.rd_agent3.drv",
        "vif",
        intf
      );

      //read monitor3
      uvm_config_db #(virtual router_if.RMON2_MP)::set(
        null,
        "uvm_test_top.env.rd_agent3.mon",
        "vif",
        intf
      );


      run_test("router_test");

    end
   // Waveform
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, dut);
  end

endmodule