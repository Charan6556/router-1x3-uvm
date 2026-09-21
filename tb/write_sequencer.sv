class write_sequencer extends uvm_sequencer #(write_xtn);
  `uvm_component_utils(write_sequencer)

  //constructor
  function new(string name = "write_sequencer", uvm_component parent);
    super.new(name,parent);
    `uvm_info("write sequencer","constructor",UVM_MEDIUM)
  endfunction

endclass