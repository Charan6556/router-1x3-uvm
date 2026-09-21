//read agent 3 controls router output 2
class read_driver3 extends uvm_driver #(read_xtn);

  `uvm_component_utils(read_driver3)

  virtual router_if.RDR2_MP vif;

  read_xtn req;

  //constructor
  function new(string name = "read_driver3", uvm_component parent);
    super.new(name,parent);
    `uvm_info("read driver3","constructor",UVM_MEDIUM)
  endfunction

  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(virtual router_if.RDR2_MP)::get(this,"","vif",vif))
      `uvm_fatal("read driver3","unable to get interface")

  endfunction

  //run phase
  task run_phase(uvm_phase phase);

    vif.rdr2_cb.read_enb_2 <= 0;

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
    while(!vif.rdr2_cb.vld_out_2)
      @(vif.rdr2_cb);

    //delay read to vary when this receiver accepts the packet
    repeat(req.no_of_cycles)
      @(vif.rdr2_cb);

    //keep read enable high until this FIFO becomes empty
    //start reading
    if(vif.rdr2_cb.vld_out_2)
      begin

        vif.rdr2_cb.read_enb_2 <= 1'b1;

        while(vif.rdr2_cb.vld_out_2)
          @(vif.rdr2_cb);

        vif.rdr2_cb.read_enb_2 <= 1'b0;

      end

  endtask

endclass
