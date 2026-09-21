class read_sequencer2 extends uvm_sequencer #(read_xtn);

  `uvm_component_utils(read_sequencer2)

  //constructor
  function new(string name = "read_sequencer2", uvm_component parent);
    super.new(name,parent);
    `uvm_info("read sequencer2","constructor",UVM_MEDIUM)
  endfunction

endclass