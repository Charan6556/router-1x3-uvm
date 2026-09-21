interface router_if(input logic clock);
 
  logic resetn;
  logic [7:0] data_in;
  logic pkt_valid;
  logic busy;
  logic error;
  logic read_enb_0;
  logic read_enb_1;
  logic read_enb_2;
  logic vld_out_0;
  logic vld_out_1;
  logic vld_out_2;
  logic [7:0] data_out_0;
  logic [7:0] data_out_1;
  logic [7:0] data_out_2;

  //drivers use the falling edge; monitors observe around the rising edge
  //#1 input skew samples before the event; #1 output skew drives after it
  //write driver clocking block
  clocking wdr_cb @(negedge clock);
    default input #1 output #1;
    output data_in;
    output pkt_valid;
    input busy;
    input resetn;
  endclocking

  //write monitor clocking block
  clocking wmon_cb @(posedge clock);
    default input #1 output #1;
    input data_in;
    input pkt_valid;
    input busy;
    input error;
    input resetn;
  endclocking


  //read driver0 clocking block
  clocking rdr0_cb @(negedge clock);
    default input #1 output #1;
    output read_enb_0;
    input vld_out_0;
    input resetn;
  endclocking

  //read monitor0 clocking block
  clocking rmon0_cb @(posedge clock);
    default input #1 output #1;
    input data_out_0;
    input vld_out_0;
    input read_enb_0;
    input resetn;
  endclocking

  //read driver1 clocking block
  clocking rdr1_cb @(negedge clock);
    default input #1 output #1;
    output read_enb_1;
    input vld_out_1;
    input resetn;
  endclocking

  //read monitor1 clocking block
  clocking rmon1_cb @(posedge clock);
    default input #1 output #1;
    input data_out_1;
    input vld_out_1;
    input read_enb_1;
    input resetn;
  endclocking

  //read driver2 clocking block
  clocking rdr2_cb @(negedge clock);
    default input #1 output #1;
    output read_enb_2;
    input vld_out_2;
    input resetn;
  endclocking

  //read monitor2 clocking block
  clocking rmon2_cb @(posedge clock);
    default input #1 output #1;
    input data_out_2;
    input vld_out_2;
    input read_enb_2;
    input resetn;
  endclocking

  //each component gets only its driver or monitor view of the shared signals
  //modports
  modport WDR_MP  (clocking wdr_cb);
  modport WMON_MP (clocking wmon_cb);

  modport RDR0_MP  (clocking rdr0_cb);
  modport RMON0_MP (clocking rmon0_cb);

  modport RDR1_MP  (clocking rdr1_cb);
  modport RMON1_MP (clocking rmon1_cb);

  modport RDR2_MP  (clocking rdr2_cb);
  modport RMON2_MP (clocking rmon2_cb);

endinterface