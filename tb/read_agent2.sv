class read_agent2 extends uvm_agent;

  `uvm_component_utils(read_agent2)

  read_sequencer2 seqr;
  read_driver2 drv;
  read_monitor2 mon;

  //constructor
  function new(string name = "read_agent2", uvm_component parent);
    super.new(name,parent);
    `uvm_info("read agent2","constructor",UVM_MEDIUM)
  endfunction

  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    seqr = read_sequencer2::type_id::create("seqr",this);
    drv = read_driver2::type_id::create("drv",this);
    mon = read_monitor2::type_id::create("mon",this);

  endfunction

  //connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    drv.seq_item_port.connect(seqr.seq_item_export);

  endfunction

endclass