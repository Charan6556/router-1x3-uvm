class read_agent1 extends uvm_agent;

  `uvm_component_utils(read_agent1)

  read_sequencer1 seqr;
  read_driver1 drv;
  read_monitor1 mon;

  //constructor
  function new(string name = "read_agent1", uvm_component parent);
    super.new(name,parent);
    `uvm_info("read agent1","constructor",UVM_MEDIUM)
  endfunction

  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    seqr = read_sequencer1::type_id::create("seqr",this);
    drv = read_driver1::type_id::create("drv",this);
    mon = read_monitor1::type_id::create("mon",this);

  endfunction

  //connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    drv.seq_item_port.connect(seqr.seq_item_export);

  endfunction

endclass