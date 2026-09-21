class write_monitor extends uvm_monitor;

  `uvm_component_utils(write_monitor)

  virtual router_if.WMON_MP vif;

  uvm_analysis_port #(write_xtn) item_collected_port;

  write_xtn tx;

  //constructor
  function new(string name = "write_monitor", uvm_component parent);
    super.new(name,parent);
    `uvm_info("write monitor","constructor",UVM_MEDIUM)
  endfunction

  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    item_collected_port = new("item_collected_port",this);

    if(!uvm_config_db #(virtual router_if.WMON_MP)::get(this,"","vif",vif))
      `uvm_fatal("write monitor","unable to get interface")

  endfunction

  //run phase
  task run_phase(uvm_phase phase);

    forever
      begin
        collect_packet();
      end

  endtask

  //collect packet
  task collect_packet();

    //allocate a fresh object because analysis subscribers retain this handle
    tx = write_xtn::type_id::create("tx");

    //observe accepted input bytes rather than copying the driver's request
    //wait for header
    do
      @(vif.wmon_cb);
    while(!vif.wmon_cb.resetn ||
          vif.wmon_cb.busy ||
          !vif.wmon_cb.pkt_valid);

    //header
    tx.header = vif.wmon_cb.data_in;

    `uvm_info("write monitor",$sformatf("header=%h length=%0d destination=%0d",tx.header,tx.header[7:2],tx.header[1:0]),UVM_MEDIUM)

    //create payload array
    tx.payload_data = new[tx.header[7:2]];

    //skip busy cycles so a held byte is not counted twice
    //payload
    foreach(tx.payload_data[i])
      begin

        do
          @(vif.wmon_cb);
        while(!vif.wmon_cb.resetn ||
              vif.wmon_cb.busy ||
              !vif.wmon_cb.pkt_valid);

        tx.payload_data[i] = vif.wmon_cb.data_in;

        if(i < 8)
          `uvm_info("write monitor",$sformatf("payload[%0d]=%h",i,tx.payload_data[i]),UVM_MEDIUM)

      end

    //packet length determines the payload count; pkt_valid low marks parity
    //this parity wait uses resetn and pkt_valid, without a busy condition
    //wait for parity
    do
      @(vif.wmon_cb);
    while(!vif.wmon_cb.resetn ||
          vif.wmon_cb.pkt_valid);

    //parity
    tx.parity = vif.wmon_cb.data_in;

    `uvm_info("write monitor",$sformatf("parity=%h",tx.parity),UVM_MEDIUM)

    //calculate good parity
    tx.good_parity = tx.header;

    foreach(tx.payload_data[i])
      tx.good_parity = tx.good_parity ^ tx.payload_data[i];

    //classify observed parity for coverage independently of stimulus settings
    //error_packet describes the bytes; it is not a sample of the DUT error pin
    //check error packet
    if(tx.parity != tx.good_parity)
      tx.error_packet = 1;
    else
      tx.error_packet = 0;

    `uvm_info("write monitor",$sformatf("packet collected dest=%0d length=%0d error=%0d",tx.header[1:0],tx.header[7:2],tx.error_packet),UVM_MEDIUM)

    //publish one complete packet to the scoreboard and coverage subscriber
    item_collected_port.write(tx);

  endtask

endclass