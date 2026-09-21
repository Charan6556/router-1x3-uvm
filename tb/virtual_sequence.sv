class virtual_sequence extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(virtual_sequence)

  virtual_seqr vseqr;

  write_sequencer wr_seqr;

  read_sequencer1 rd_seqr1;
  read_sequencer2 rd_seqr2;
  read_sequencer3 rd_seqr3;

  //24 directed packets below are followed by these random packets
  int stress_packet_count = 5000;


  //constructor
  function new(string name = "virtual_sequence");
    super.new(name);
    `uvm_info("virtual sequence","constructor",UVM_MEDIUM)
  endfunction


  //start read
  task start_read(bit [1:0] dest);

    read_sequence rd_seq;

    rd_seq = read_sequence::type_id::create("rd_seq");

    case(dest)

      2'b00:
        rd_seq.start(rd_seqr1);

      2'b01:
        rd_seq.start(rd_seqr2);

      2'b10:
        rd_seq.start(rd_seqr3);

      default:
        `uvm_error("virtual sequence","invalid destination")

    endcase

  endtask


  //run packet
  task run_packet(
    bit [1:0] dest,
    int min_len,
    int max_len,
    bit error_en
  );

    router_packet_sequence wr_seq;

    wr_seq = router_packet_sequence::type_id::create("wr_seq");

    wr_seq.destination = dest;
    wr_seq.min_length = min_len;
    wr_seq.max_length = max_len;
    wr_seq.inject_error = error_en;

    //write and read concurrently so packets larger than the FIFO can drain
    //join waits for both sequences before starting the next packet
    fork

      wr_seq.start(wr_seqr);

      start_read(dest);

    join

  endtask


  //random stress
  task random_stress(int packet_count);

    bit [1:0] dest;
    int packet_length;
    bit error_en;

    repeat(packet_count)
      begin

        dest = $urandom_range(0,2);

        packet_length = $urandom_range(1,63);

        //approximately 10 percent of random packets get bad parity
        if($urandom_range(0,9) == 0)
          error_en = 1;
        else
          error_en = 0;

        run_packet(dest,packet_length,packet_length,error_en);

      end

  endtask


  //body
  task body();

    //recover the virtual sequencer to access all four physical sequencers
    if(!$cast(vseqr,m_sequencer))
      `uvm_fatal("virtual sequence","unable to cast virtual sequencer")

    wr_seqr = vseqr.wr_seqr;

    rd_seqr1 = vseqr.rd_seqr1;
    rd_seqr2 = vseqr.rd_seqr2;
    rd_seqr3 = vseqr.rd_seqr3;


    //18 directed packets cover 3 destinations x 3 size groups x 2 error types
    //small normal
    run_packet(2'b00,1,13,0);
    run_packet(2'b01,1,13,0);
    run_packet(2'b10,1,13,0);


    //medium normal
    run_packet(2'b00,14,30,0);
    run_packet(2'b01,14,30,0);
    run_packet(2'b10,14,30,0);


    //large normal
    run_packet(2'b00,31,63,0);
    run_packet(2'b01,31,63,0);
    run_packet(2'b10,31,63,0);


    //small error
    run_packet(2'b00,1,13,1);
    run_packet(2'b01,1,13,1);
    run_packet(2'b10,1,13,1);


    //medium error
    run_packet(2'b00,14,30,1);
    run_packet(2'b01,14,30,1);
    run_packet(2'b10,14,30,1);


    //large error
    run_packet(2'b00,31,63,1);
    run_packet(2'b01,31,63,1);
    run_packet(2'b10,31,63,1);


    //hit both ends of each size group explicitly instead of relying on luck
    //boundary packets
    run_packet(2'b00,1,1,0);
    run_packet(2'b01,13,13,0);
    run_packet(2'b10,14,14,0);
    run_packet(2'b00,30,30,0);
    run_packet(2'b01,31,31,0);
    run_packet(2'b10,63,63,0);


    //random packets
    `uvm_info("virtual sequence",$sformatf("starting %0d random packets",stress_packet_count),UVM_LOW)

    random_stress(stress_packet_count);

    `uvm_info("virtual sequence",$sformatf("completed %0d random packets",stress_packet_count),UVM_LOW)

  endtask

endclass