class read_agent3 extends uvm_agent;

  `uvm_component_utils(read_agent3)

  read_sequencer3 seqr;
  read_driver3 drv;
  read_monitor3 mon;

  //constructor
  function new(string name = "read_agent3", uvm_component parent);
    super.new(name,parent);
    `uvm_info("read agent3","constructor",UVM_MEDIUM)
  endfunction

  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    seqr = read_sequencer3::type_id::create("seqr",this);
    drv = read_driver3::type_id::create("drv",this);
    mon = read_monitor3::type_id::create("mon",this);

  endfunction

  //connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    drv.seq_item_port.connect(seqr.seq_item_export);

  endfunction

endclass