class router_test extends uvm_test;

  `uvm_component_utils(router_test)

  router_environment env;

  virtual_sequence vseq;

  //constructor
  function new(string name = "router_test", uvm_component parent);
    super.new(name,parent);
    `uvm_info("router test","constructor",UVM_MEDIUM)
  endfunction


  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = router_environment::type_id::create("env",this);

  endfunction


  //run phase
  task run_phase(uvm_phase phase);

    //keep run_phase active until the coordinated traffic sequence finishes
    phase.raise_objection(this);

    vseq = virtual_sequence::type_id::create("vseq");

    vseq.start(env.vseqr);

    //fixed drain time lets the last monitor callbacks reach the scoreboard
    //allow final monitor transactions
    #100;

    phase.drop_objection(this);

  endtask

endclass