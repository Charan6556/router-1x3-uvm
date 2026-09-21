//read agent 1 controls router output 0
class read_driver1 extends uvm_driver #(read_xtn);

  `uvm_component_utils(read_driver1)

  virtual router_if.RDR0_MP vif;

  read_xtn req;

  //constructor
  function new(string name = "read_driver1", uvm_component parent);
    super.new(name,parent);
    `uvm_info("read driver1","constructor",UVM_MEDIUM)
  endfunction

  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(virtual router_if.RDR0_MP)::get(this,"","vif",vif))
      `uvm_fatal("read driver1","unable to get interface")

  endfunction

  //run phase
  task run_phase(uvm_phase phase);

    vif.rdr0_cb.read_enb_0 <= 0;

    forever
      begin

        seq_item_port.get_next_item(req);

        read_packet(req);

        seq_item_port.item_done();

      end

  endtask

  task read_packet(read_xtn req);

  //wait for reset
  while(vif.rdr0_cb.resetn !== 1'b1)
    @(vif.rdr0_cb);

  //wait for valid output
  while(vif.rdr0_cb.vld_out_0 !== 1'b1)
    @(vif.rdr0_cb);

  //delay read to vary when this receiver accepts the packet
  repeat(req.no_of_cycles)
    @(vif.rdr0_cb);

  //keep read enable high until this FIFO becomes empty
  //start reading
  if(vif.rdr0_cb.vld_out_0 === 1'b1)
    begin

      vif.rdr0_cb.read_enb_0 <= 1'b1;

      while(vif.rdr0_cb.vld_out_0 === 1'b1)
        @(vif.rdr0_cb);

      vif.rdr0_cb.read_enb_0 <= 1'b0;

    end

endtask
endclass