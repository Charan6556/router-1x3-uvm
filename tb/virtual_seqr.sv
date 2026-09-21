
  class virtual_seqr extends uvm_sequencer #(uvm_sequence_item);

  `uvm_component_utils(virtual_seqr)

  //these handles coordinate existing agent sequencers; no driver connects here
  write_sequencer wr_seqr;

  read_sequencer1 rd_seqr1;
  read_sequencer2 rd_seqr2;
  read_sequencer3 rd_seqr3;

  //constructor
  function new(string name = "virtual_seqr", uvm_component parent);
    super.new(name,parent);
    `uvm_info("virtual sequencer","constructor",UVM_MEDIUM)
  endfunction

endclass