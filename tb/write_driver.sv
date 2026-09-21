class write_driver extends uvm_driver #(write_xtn);

  `uvm_component_utils(write_driver)

  virtual router_if.WDR_MP vif;

  write_xtn req;

  //constructor
  function new(string name = "write_driver", uvm_component parent);
    super.new(name,parent);
    `uvm_info("write driver","constructor",UVM_MEDIUM)
  endfunction

  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(virtual router_if.WDR_MP)::get(this,"","vif",vif))
      `uvm_fatal("write driver","unable to get interface")

  endfunction

  //run phase
  task run_phase(uvm_phase phase);

    while(vif.wdr_cb.resetn !== 1'b1)
      @(vif.wdr_cb);

    forever
      begin

        seq_item_port.get_next_item(req);

        send_packet(req);

        //release the sequence only after all bytes have been driven
        seq_item_port.item_done();

      end

  endtask

  //send packet
  task send_packet(write_xtn req);

    //drive on the falling edge so data is ready for the DUT rising edge
    //busy stalls the driver without advancing to the next byte
    //header
    @(vif.wdr_cb);

    while(vif.wdr_cb.busy === 1'b1)
      @(vif.wdr_cb);

    vif.wdr_cb.pkt_valid <= 1'b1;
    vif.wdr_cb.data_in <= req.header;

    `uvm_info("write driver",
    $sformatf("header=%h length=%0d destination=%0d",
    req.header,req.header[7:2],req.header[1:0]),UVM_MEDIUM)


    //payload
    foreach(req.payload_data[i])
      begin

        @(vif.wdr_cb);

        while(vif.wdr_cb.busy === 1'b1)
          @(vif.wdr_cb);

        vif.wdr_cb.pkt_valid <= 1'b1;
        vif.wdr_cb.data_in <= req.payload_data[i];

        if(i < 8)
          `uvm_info("write driver",
          $sformatf("payload[%0d]=%h",i,req.payload_data[i]),UVM_MEDIUM)

      end


    //pkt_valid stays high for header/payload and goes low for the parity byte
    //parity
    @(vif.wdr_cb);

    while(vif.wdr_cb.busy === 1'b1)
      @(vif.wdr_cb);

    vif.wdr_cb.pkt_valid <= 1'b0;
    vif.wdr_cb.data_in <= req.parity;

    `uvm_info("write driver",
    $sformatf("parity=%h",req.parity),UVM_MEDIUM)


    //finish packet
    @(vif.wdr_cb);

    vif.wdr_cb.pkt_valid <= 1'b0;

  endtask

endclass