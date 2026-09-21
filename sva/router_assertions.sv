//fifo assertions
module router_fifo_sva
(
  input logic clock,
  input logic resetn,
  input logic soft_reset,
  input logic write_enb,
  input logic read_enb,
  input logic full,
  input logic empty
);


  //full and empty
  property p_full_empty;
    @(posedge clock)
    disable iff(!resetn)
    !(full && empty);
  endproperty

  a_full_empty:
  assert property(p_full_empty)
  else
    $error("fifo full and empty high");


  //reset
  property p_reset;
    @(posedge clock)
    !resetn |=> (empty && !full);
  endproperty

  a_reset:
  assert property(p_reset)
  else
    $error("fifo reset failed");


  //soft reset
  property p_soft_reset;
    @(posedge clock)
    disable iff(!resetn)
    soft_reset |=> empty;
  endproperty

  a_soft_reset:
  assert property(p_soft_reset)
  else
    $error("fifo soft reset failed");


  //full hold
  property p_full_hold;
    @(posedge clock)
    disable iff(!resetn)
    (full && !read_enb && !soft_reset) |=> full;
  endproperty

  a_full_hold:
  assert property(p_full_hold)
  else
    $error("fifo full changed without read");


  //empty hold
  property p_empty_hold;
    @(posedge clock)
    disable iff(!resetn)
    (empty && !write_enb && !soft_reset) |=> empty;
  endproperty

  a_empty_hold:
  assert property(p_empty_hold)
  else
    $error("fifo empty changed without write");


endmodule



//fsm assertions
module router_fsm_sva
(
  input logic clock,
  input logic resetn,
  input logic busy,
  input logic detect_add,
  input logic lfd_state,
  input logic full_state
);


  //decode state
  property p_decode;
    @(posedge clock)
    disable iff(!resetn)
    detect_add |-> !busy;
  endproperty

  a_decode:
  assert property(p_decode)
  else
    $error("busy high in decode state");


  //load first data
  property p_lfd;
    @(posedge clock)
    disable iff(!resetn)
    lfd_state |-> busy;
  endproperty

  a_lfd:
  assert property(p_lfd)
  else
    $error("busy low in load first data state");


  //fifo full state
  property p_full_state;
    @(posedge clock)
    disable iff(!resetn)
    full_state |-> busy;
  endproperty

  a_full_state:
  assert property(p_full_state)
  else
    $error("busy low in fifo full state");


endmodule



//bind fifo
bind router_fifo router_fifo_sva fifo_sva
(
  .clock(clock),
  .resetn(resetn),
  .soft_reset(soft_reset),
  .write_enb(write_enb),
  .read_enb(read_enb),
  .full(full),
  .empty(empty)
);


//bind fsm
bind router_fsm router_fsm_sva fsm_sva
(
  .clock(clock),
  .resetn(resetn),
  .busy(busy),
  .detect_add(detect_add),
  .lfd_state(lfd_state),
  .full_state(full_state)
);