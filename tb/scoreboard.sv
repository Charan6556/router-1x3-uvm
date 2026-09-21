//each suffix creates a separate callback for the corresponding monitor
//write_write receives input packets; write_read1/2/3 receive output packets
`uvm_analysis_imp_decl(_write)
`uvm_analysis_imp_decl(_read1)
`uvm_analysis_imp_decl(_read2)
`uvm_analysis_imp_decl(_read3)


class router_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(router_scoreboard)


  //analysis ports
  uvm_analysis_imp_write #(write_xtn,router_scoreboard) write_export;

  uvm_analysis_imp_read1 #(read_xtn,router_scoreboard) read1_export;
  uvm_analysis_imp_read2 #(read_xtn,router_scoreboard) read2_export;
  uvm_analysis_imp_read3 #(read_xtn,router_scoreboard) read3_export;


  //match packets in arrival order within each destination
  //separate queues allow the three output ports to finish independently
  //expected queues
  write_xtn expected_q0[$];
  write_xtn expected_q1[$];
  write_xtn expected_q2[$];


  //an output monitor may publish before the input monitor finishes its packet
  //save that actual packet here until its expected packet arrives
  //actual queues
  read_xtn actual_q0[$];
  read_xtn actual_q1[$];
  read_xtn actual_q2[$];


  //transaction handles
  write_xtn exp_tx;
  read_xtn act_tx;


  //packet counters
  int expected_count;
  int actual_count;
  int matched_count;
  int mismatch_count;


  //constructor
  function new(string name = "router_scoreboard", uvm_component parent);

    super.new(name,parent);

    write_export = new("write_export",this);

    read1_export = new("read1_export",this);
    read2_export = new("read2_export",this);
    read3_export = new("read3_export",this);

    expected_count = 0;
    actual_count = 0;
    matched_count = 0;
    mismatch_count = 0;

    `uvm_info("scoreboard","constructor",UVM_MEDIUM)

  endfunction


  //the reference packet comes from the input monitor, not the sequence
  //this checks the data seen on the interface against the routed output
  //monitors allocate a new object per packet, so queued handles stay valid
  //write monitor packet
  function void write_write(write_xtn tx);

    expected_count++;

    case(tx.header[1:0])

      //destination 0
      2'b00:
        begin

          if(actual_q0.size() != 0)
            begin

              //pair with the oldest output packet for this destination
              //the same pairing rule is used for destinations 1 and 2
              act_tx = actual_q0.pop_front();

              compare_packet(tx,act_tx);

            end
          else
            begin

              expected_q0.push_back(tx);

            end

        end


      //destination 1
      2'b01:
        begin

          if(actual_q1.size() != 0)
            begin

              act_tx = actual_q1.pop_front();

              compare_packet(tx,act_tx);

            end
          else
            begin

              expected_q1.push_back(tx);

            end

        end


      //destination 2
      2'b10:
        begin

          if(actual_q2.size() != 0)
            begin

              act_tx = actual_q2.pop_front();

              compare_packet(tx,act_tx);

            end
          else
            begin

              expected_q2.push_back(tx);

            end

        end


      default:
        begin

          `uvm_error("scoreboard",$sformatf("invalid destination=%0d",tx.header[1:0]))

        end

    endcase

  endfunction


  //agent numbering starts at 1; router destination numbering starts at 0
  //read1 -> output0, read2 -> output1, read3 -> output2
  //read monitor 1
  function void write_read1(read_xtn tx);

    actual_count++;

    if(expected_q0.size() != 0)
      begin

        exp_tx = expected_q0.pop_front();

        compare_packet(exp_tx,tx);

      end
    else
      begin

        actual_q0.push_back(tx);

      end

  endfunction


  //read monitor 2
  function void write_read2(read_xtn tx);

    actual_count++;

    if(expected_q1.size() != 0)
      begin

        exp_tx = expected_q1.pop_front();

        compare_packet(exp_tx,tx);

      end
    else
      begin

        actual_q1.push_back(tx);

      end

  endfunction


  //read monitor 3
  function void write_read3(read_xtn tx);

    actual_count++;

    if(expected_q2.size() != 0)
      begin

        exp_tx = expected_q2.pop_front();

        compare_packet(exp_tx,tx);

      end
    else
      begin

        actual_q2.push_back(tx);

      end

  endfunction


  //compare packet
  function void compare_packet(write_xtn exp, read_xtn act);

    bit packet_match;

    packet_match = 1;


    //compare header
    if(exp.header != act.header)
      begin

        packet_match = 0;

        `uvm_error("scoreboard",$sformatf("header mismatch expected=%h actual=%h",exp.header,act.header))

      end


    //compare payload size
    if(exp.payload_data.size() != act.payload_data.size())
      begin

        packet_match = 0;

        `uvm_error("scoreboard",$sformatf("payload size mismatch expected=%0d actual=%0d",exp.payload_data.size(),act.payload_data.size()))

      end


    //only index both arrays after checking their sizes are equal
    //compare payload data
    if(exp.payload_data.size() == act.payload_data.size())
      begin

        foreach(exp.payload_data[i])
          begin

            if(exp.payload_data[i] != act.payload_data[i])
              begin

                packet_match = 0;

                `uvm_error("scoreboard",$sformatf("payload mismatch index=%0d expected=%h actual=%h",i,exp.payload_data[i],act.payload_data[i]))

              end

          end

      end


    //compare the transmitted parity byte, including intentionally bad parity
    //this checks forwarding; the DUT error output is not checked here
    //compare parity
    if(exp.parity != act.parity)
      begin

        packet_match = 0;

        `uvm_error("scoreboard",$sformatf("parity mismatch expected=%h actual=%h",exp.parity,act.parity))

      end


    //one packet can report several byte errors but counts as one mismatch
    //packet result
    if(packet_match)
      begin

        matched_count++;

        `uvm_info("scoreboard","packet matched",UVM_HIGH)

      end
    else
      begin

        mismatch_count++;

      end

  endfunction


  //check phase
  function void check_phase(uvm_phase phase);

    super.check_phase(phase);


    //leftover expected packets indicate missing outputs or incomplete reads
    //leftover actual packets indicate outputs without matching inputs
    //check expected queues
    if(expected_q0.size() != 0 ||
       expected_q1.size() != 0 ||
       expected_q2.size() != 0)
      begin

        `uvm_error("scoreboard",$sformatf("expected packets left exp0=%0d exp1=%0d exp2=%0d",expected_q0.size(),expected_q1.size(),expected_q2.size()))

      end


    //check actual queues
    if(actual_q0.size() != 0 ||
       actual_q1.size() != 0 ||
       actual_q2.size() != 0)
      begin

        `uvm_error("scoreboard",$sformatf("actual packets left act0=%0d act1=%0d act2=%0d",actual_q0.size(),actual_q1.size(),actual_q2.size()))

      end


    //check packet count
    if(expected_count != actual_count)
      begin

        `uvm_error("scoreboard",$sformatf("packet count mismatch expected=%0d actual=%0d",expected_count,actual_count))

      end


    //check mismatched packets
    if(mismatch_count != 0)
      begin

        `uvm_error("scoreboard",$sformatf("mismatched packets=%0d",mismatch_count))

      end


    //equal input/output counts alone do not prove every packet was compared
    //check all packets were compared
    if((matched_count + mismatch_count) != expected_count)
      begin

        `uvm_error("scoreboard",$sformatf("not all packets compared expected=%0d compared=%0d",expected_count,(matched_count + mismatch_count)))

      end

  endfunction


  //report phase
  function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info("scoreboard",$sformatf("expected=%0d actual=%0d matched=%0d mismatched=%0d",expected_count,actual_count,matched_count,mismatch_count),UVM_LOW)

    `uvm_info("scoreboard",$sformatf("remaining queues exp0=%0d exp1=%0d exp2=%0d act0=%0d act1=%0d act2=%0d",expected_q0.size(),expected_q1.size(),expected_q2.size(),actual_q0.size(),actual_q1.size(),actual_q2.size()),UVM_LOW)

  endfunction


endclass