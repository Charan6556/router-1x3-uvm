class router_coverage extends uvm_subscriber #(write_xtn);

  `uvm_component_utils(router_coverage)

  write_xtn tx;

  int sample_count;

  //sample complete input packets observed by the write monitor
  //100 percent means these defined bins were hit, not complete DUT verification
  //covergroup
  covergroup router_cg;

    option.per_instance = 1;

    //destination
    DESTINATION : coverpoint tx.header[1:0]
    {
      bins output0 = {2'b00};
      bins output1 = {2'b01};
      bins output2 = {2'b10};

      illegal_bins invalid = {2'b11};
    }


    //each range is one size-group bin, not one bin for every possible length
    //payload size
    PAYLOAD_SIZE : coverpoint tx.header[7:2]
    {
      bins small_pkt  = {[1:13]};
      bins medium_pkt = {[14:30]};
      bins large_pkt  = {[31:63]};

      illegal_bins zero_length = {0};
    }


    //normal or error
    ERROR_PACKET : coverpoint tx.error_packet
    {
      bins normal_pkt = {0};
      bins error_pkt  = {1};
    }


    //boundary lengths
    LENGTH_BOUNDARY : coverpoint tx.header[7:2]
    {
      bins length_1  = {1};
      bins length_13 = {13};

      bins length_14 = {14};
      bins length_30 = {30};

      bins length_31 = {31};
      bins length_63 = {63};

   
    }


    //crosses check combinations that individual coverpoints cannot show
    //the three-way cross contains 3 x 3 x 2 = 18 legal combinations
    //crosses
    DEST_SIZE :
      cross DESTINATION,PAYLOAD_SIZE;


    DEST_ERROR :
      cross DESTINATION,ERROR_PACKET;


    SIZE_ERROR :
      cross PAYLOAD_SIZE,ERROR_PACKET;


    DEST_SIZE_ERROR :
      cross DESTINATION,PAYLOAD_SIZE,ERROR_PACKET;

  endgroup


  //constructor
  function new(string name = "router_coverage", uvm_component parent);
    super.new(name,parent);

    router_cg = new();

    sample_count = 0;

    `uvm_info("coverage","constructor",UVM_MEDIUM)
  endfunction


  //write
  function void write(write_xtn t);

    tx = t;

    //sample immediately while tx refers to this completed packet
    router_cg.sample();

    sample_count++;

    `uvm_info("coverage",
    $sformatf("sample=%0d coverage=%0.2f%%",
    sample_count,router_cg.get_coverage()),UVM_MEDIUM)

  endfunction

    function void report_phase(uvm_phase phase);

  super.report_phase(phase);

  `uvm_info("coverage",$sformatf("samples = %0d",sample_count),UVM_LOW)

  `uvm_info("coverage",$sformatf("DESTINATION = %0.2f%%",router_cg.DESTINATION.get_inst_coverage()),UVM_LOW)

  `uvm_info("coverage",$sformatf("PAYLOAD_SIZE = %0.2f%%",router_cg.PAYLOAD_SIZE.get_inst_coverage()),UVM_LOW)

  `uvm_info("coverage",$sformatf("ERROR_PACKET = %0.2f%%",router_cg.ERROR_PACKET.get_inst_coverage()),UVM_LOW)

  `uvm_info("coverage",$sformatf("LENGTH_BOUNDARY = %0.2f%%",router_cg.LENGTH_BOUNDARY.get_inst_coverage()),UVM_LOW)

  `uvm_info("coverage",$sformatf("DEST_SIZE = %0.2f%%",router_cg.DEST_SIZE.get_inst_coverage()),UVM_LOW)

  `uvm_info("coverage",$sformatf("DEST_ERROR = %0.2f%%",router_cg.DEST_ERROR.get_inst_coverage()),UVM_LOW)

  `uvm_info("coverage",$sformatf("SIZE_ERROR = %0.2f%%",router_cg.SIZE_ERROR.get_inst_coverage()),UVM_LOW)

  `uvm_info("coverage",$sformatf("DEST_SIZE_ERROR = %0.2f%%",router_cg.DEST_SIZE_ERROR.get_inst_coverage()),UVM_LOW)

  `uvm_info("coverage",$sformatf("TOTAL FUNCTIONAL COVERAGE = %0.2f%%",router_cg.get_inst_coverage()),UVM_LOW)

endfunction

endclass