class write_xtn extends uvm_sequence_item;

  `uvm_object_utils(write_xtn)

  //header[7:2] is payload length; header[1:0] selects output 0, 1 or 2
  rand bit [7:0] header;
  rand bit [7:0] payload_data[];

  bit [7:0] parity;
  bit [7:0] good_parity;

  rand bit error_packet;

  //keep the allocated payload consistent with the encoded packet length
  //constraints
  constraint c1
  {
    header[1:0] != 2'b11;
  }

  constraint c2
  {
    payload_data.size() == header[7:2];
  }

  constraint c3
  {
    header[7:2] inside {[1:63]};
  }

  //constructor
  function new(string name = "write_xtn");
    super.new(name);
    `uvm_info("write transaction","constructor",UVM_MEDIUM)
  endfunction

  //post_randomize runs after the header and payload have been selected
  //xor the header and every payload byte to calculate the expected parity
  //calculate parity
  function void post_randomize();

    good_parity = header;

    foreach(payload_data[i])
      good_parity = good_parity ^ payload_data[i];

    parity = good_parity;

    //flip one parity bit to create a controlled bad-parity packet
    if(error_packet)
      parity = parity ^ 8'h01;

  endfunction

endclass