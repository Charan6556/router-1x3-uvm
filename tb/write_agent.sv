class write_agent extends uvm_agent;

  `uvm_component_utils(write_agent)

  write_sequencer seqr;
  write_driver drv;
  write_monitor mon;

  //constructor
  function new(string name = "write_agent", uvm_component parent);
    super.new(name,parent);
    `uvm_info("write agent", "constructor",UVM_MEDIUM)
  endfunction


  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    seqr = write_sequencer::type_id::create("seqr",this);

    drv = write_driver::type_id::create("drv",this);

    mon = write_monitor::type_id::create("mon",this);

  endfunction


  //connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    drv.seq_item_port.connect(
      seqr.seq_item_export
    );

  endfunction

endclass