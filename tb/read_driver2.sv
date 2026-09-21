//read agent 2 controls router output 1
class read_driver2 extends uvm_driver #(read_xtn);

  `uvm_component_utils(read_driver2)

  virtual router_if.RDR1_MP vif;

  read_xtn req;

  //constructor
  function new(string name = "read_driver2", uvm_component parent);
    super.new(name,parent);
    `uvm_info("read driver2","constructor",UVM_MEDIUM)
  endfunction

  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(virtual router_if.RDR1_MP)::get(this,"","vif",vif))
      `uvm_fatal("read driver2","unable to get interface")

  endfunction

  //run phase
  task run_phase(uvm_phase phase);

    vif.rdr1_cb.read_enb_1 <= 0;

    forever
      begin

        seq_item_port.get_next_item(req);

        read_packet(req);

        seq_item_port.item_done();

      end

  endtask

  //read packet
  task read_packet(read_xtn req);

    //wait for valid output
    while(!vif.rdr1_cb.vld_out_1)
      @(vif.rdr1_cb);

    //delay read to vary when this receiver accepts the packet
    repeat(req.no_of_cycles)
      @(vif.rdr1_cb);

    //keep read enable high until this FIFO becomes empty
    //start reading
    if(vif.rdr1_cb.vld_out_1)
      begin

        vif.rdr1_cb.read_enb_1 <= 1'b1;

        while(vif.rdr1_cb.vld_out_1)
          @(vif.rdr1_cb);

        vif.rdr1_cb.read_enb_1 <= 1'b0;

      end

  endtask

endclass
