class read_sequencer1 extends uvm_sequencer #(read_xtn);

  `uvm_component_utils(read_sequencer1)

  //constructor
  function new(string name = "read_sequencer1", uvm_component parent);
    super.new(name,parent);
    `uvm_info("read sequencer1","constructor",UVM_MEDIUM)
  endfunction

endclass