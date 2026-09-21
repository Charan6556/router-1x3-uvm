class router_environment extends uvm_env;

  `uvm_component_utils(router_environment)

  write_agent wr_agent;

  read_agent1 rd_agent1;
  read_agent2 rd_agent2;
  read_agent3 rd_agent3;

  virtual_seqr vseqr;

  router_scoreboard scoreboard;
  router_coverage coverage;

  //constructor
  function new(string name = "router_environment", uvm_component parent);
    super.new(name,parent);
    `uvm_info("environment class","constructor",UVM_MEDIUM)
  endfunction

  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    wr_agent = write_agent::type_id::create("wr_agent",this);

    rd_agent1 = read_agent1::type_id::create("rd_agent1",this);
    rd_agent2 = read_agent2::type_id::create("rd_agent2",this);
    rd_agent3 = read_agent3::type_id::create("rd_agent3",this);

    vseqr = virtual_seqr::type_id::create("vseqr",this);

    scoreboard = router_scoreboard::type_id::create("scoreboard",this);

    coverage = router_coverage::type_id::create("coverage",this);

  endfunction

  //connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    `uvm_info("environment class","connect phase",UVM_MEDIUM)

    //connect sequencers to virtual sequencer
    vseqr.wr_seqr = wr_agent.seqr;

    vseqr.rd_seqr1 = rd_agent1.seqr;
    vseqr.rd_seqr2 = rd_agent2.seqr;
    vseqr.rd_seqr3 = rd_agent3.seqr;

    //analysis connections broadcast observed packets without blocking stimulus
    //write monitor to scoreboard
    wr_agent.mon.item_collected_port.connect(
      scoreboard.write_export
    );

    //read monitors to scoreboard
    rd_agent1.mon.item_collected_port.connect(
      scoreboard.read1_export
    );

    rd_agent2.mon.item_collected_port.connect(
      scoreboard.read2_export
    );

    rd_agent3.mon.item_collected_port.connect(
      scoreboard.read3_export
    );

    //coverage uses the same observed input stream as the scoreboard reference
    //write monitor to coverage
    wr_agent.mon.item_collected_port.connect(
      coverage.analysis_export
    );

  endfunction

endclass