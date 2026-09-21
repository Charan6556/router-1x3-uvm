class read_sequencer3 extends uvm_sequencer #(read_xtn);

  `uvm_component_utils(read_sequencer3)

  //constructor
  function new(string name = "read_sequencer3", uvm_component parent);
    super.new(name,parent);
    `uvm_info("read sequencer3","constructor",UVM_MEDIUM)
  endfunction

endclass