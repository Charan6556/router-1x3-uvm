 class read_xtn extends uvm_sequence_item;

  `uvm_object_utils(read_xtn)

  bit [7:0] header;
  bit [7:0] payload_data[];
  bit [7:0] parity;

  //the sequence uses this delay to control when the receiver starts reading
  //the read monitor fills header, payload and parity from the actual output
  rand bit [5:0] no_of_cycles;


  //constructor
  function new(string name = "read_xtn");
    super.new(name);
    `uvm_info("read transaction","constructor",UVM_MEDIUM)
  endfunction

endclass