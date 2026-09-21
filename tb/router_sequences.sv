//router packet sequence
class router_packet_sequence extends uvm_sequence #(write_xtn);

  `uvm_object_utils(router_packet_sequence)

  bit [1:0] destination;

  int min_length;
  int max_length;

  bit inject_error;

  //constructor
  function new(string name = "router_packet_sequence");
    super.new(name);
    `uvm_info("router packet sequence","constructor",UVM_MEDIUM)
  endfunction

  //body
  task body();

    write_xtn req;

    req = write_xtn::type_id::create("req");

    start_item(req);

    //local:: selects the sequence settings inside the item constraint scope
    //payload contents remain random while destination, size and error are set
    if(!req.randomize() with
    {
      header[1:0] == local::destination;

      header[7:2] >= local::min_length;
      header[7:2] <= local::max_length;

      error_packet == local::inject_error;
    })
      `uvm_fatal("router packet sequence","randomization failed")

    `uvm_info("router packet sequence",
    $sformatf("dest=%0d length=%0d error=%0d",
    req.header[1:0],req.header[7:2],req.error_packet),UVM_MEDIUM)

    //wait for the driver to complete this item before the sequence returns
    finish_item(req);

  endtask

endclass


//read sequence
class read_sequence extends uvm_sequence #(read_xtn);

  `uvm_object_utils(read_sequence)

  //constructor
  function new(string name = "read_sequence");
    super.new(name);
    `uvm_info("read sequence","constructor",UVM_MEDIUM)
  endfunction

  //body
  task body();

    read_xtn req;

    req = read_xtn::type_id::create("req");

    start_item(req);

    if(!req.randomize() with
    {
      //vary receiver latency while staying below the output timeout
      no_of_cycles inside {[1:5]};
    })
      `uvm_fatal("read sequence","randomization failed")

    //wait for the driver to complete this item before the sequence returns
    finish_item(req);

  endtask

endclass


//delays near the 30-cycle timeout for a future directed timeout test
//the default virtual sequence does not start this sequence
//timeout read sequence
class timeout_read_sequence extends uvm_sequence #(read_xtn);

  `uvm_object_utils(timeout_read_sequence)

  //constructor
  function new(string name = "timeout_read_sequence");
    super.new(name);
    `uvm_info("timeout read sequence","constructor",UVM_MEDIUM)
  endfunction

  //body
  task body();

    read_xtn req;

    req = read_xtn::type_id::create("req");

    start_item(req);

    if(!req.randomize() with
    {
      no_of_cycles inside {[30:35]};
    })
      `uvm_fatal("timeout read sequence","randomization failed")

    //wait for the driver to complete this item before the sequence returns
    finish_item(req);

  endtask

endclass