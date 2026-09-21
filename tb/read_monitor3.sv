class read_monitor3 extends uvm_monitor;

  `uvm_component_utils(read_monitor3)

  virtual router_if.RMON2_MP vif;

  uvm_analysis_port #(read_xtn) item_collected_port;

  read_xtn tx;

  //constructor
  function new(string name = "read_monitor3", uvm_component parent);
    super.new(name,parent);
    `uvm_info("read monitor3","constructor",UVM_MEDIUM)
  endfunction

  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    item_collected_port = new("item_collected_port",this);

    if(!uvm_config_db #(virtual router_if.RMON2_MP)::get(this,"","vif",vif))
      `uvm_fatal("read monitor3","unable to get interface")

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

    //a fresh packet object keeps previously queued scoreboard data unchanged
    tx = read_xtn::type_id::create("tx");

    //wait for reading
    do
      @(vif.rmon2_cb);
    while(!vif.rmon2_cb.resetn ||
          !vif.rmon2_cb.vld_out_2 ||
          !vif.rmon2_cb.read_enb_2);

    //the FIFO registers its output on the read edge
    //the clocking block samples before that edge, so wait once more for header
    //wait for header
    @(vif.rmon2_cb);

    //header
    tx.header = vif.rmon2_cb.data_out_2;

    `uvm_info("read monitor3",$sformatf("header=%h length=%0d",tx.header,tx.header[7:2]),UVM_MEDIUM)

    //create payload array
    tx.payload_data = new[tx.header[7:2]];

    //this collector assumes continuous byte reads after the header
    //payload
    foreach(tx.payload_data[i])
      begin

        @(vif.rmon2_cb);

        tx.payload_data[i] = vif.rmon2_cb.data_out_2;

      end

    //parity
    @(vif.rmon2_cb);

    tx.parity = vif.rmon2_cb.data_out_2;

    `uvm_info("read monitor3","packet collected",UVM_MEDIUM)

    //send the completed packet to the scoreboard callback for output 2
    item_collected_port.write(tx);

  endtask

endclass