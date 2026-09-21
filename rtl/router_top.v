`include "router_fifo.v"
`include "router_fsm.v"
`include "router_reg.v"
`include "router_sync.v"

module router_top (
  input clock,
  resetn,

  input read_enb_0,
  read_enb_1,
  read_enb_2,

  input [7:0] data_in,
  input pkt_valid,

  output [7:0] data_out_0,
  data_out_1,
  data_out_2,

  output vld_out_0,
  vld_out_1,
  vld_out_2,

  output error,
  busy
);

//fsm output wires
wire detect_add;
wire ld_state;
wire laf_state;
wire full_state;
wire write_enb_reg;
wire rst_int_reg;
wire lfd_state;

//register output wires
wire parity_done;
wire low_pkt_valid;
wire [7:0] dout;

//synchronizer output wires
wire soft_reset_0;
wire soft_reset_1;
wire soft_reset_2;
wire [2:0] write_enb;
wire fifo_full;

//fifo output wires
wire full_0;
wire full_1;
wire full_2;

wire empty_0;
wire empty_1;
wire empty_2;


//register instantiation
router_reg reg_inst(
  .clock(clock),
  .resetn(resetn),
  .pkt_valid(pkt_valid),
  .data_in(data_in),
  .fifo_full(fifo_full),
  .rst_int_reg(rst_int_reg),
  .detect_add(detect_add),
  .ld_state(ld_state),
  .laf_state(laf_state),
  .full_state(full_state),
  .lfd_state(lfd_state),
  .parity_done(parity_done),
  .low_pkt_valid(low_pkt_valid),
  .err(error),
  .dout(dout)
);


//fsm instantiation
router_fsm fsm_inst(
  .clock(clock),
  .resetn(resetn),
  .pkt_valid(pkt_valid),
  .parity_done(parity_done),
  .data_in(data_in[1:0]),

  .soft_reset_0(soft_reset_0),
  .soft_reset_1(soft_reset_1),
  .soft_reset_2(soft_reset_2),

  .fifo_full(fifo_full),
  .low_pkt_valid(low_pkt_valid),

  .fifo_empty_0(empty_0),
  .fifo_empty_1(empty_1),
  .fifo_empty_2(empty_2),

  .rst_int_reg(rst_int_reg),
  .detect_add(detect_add),
  .ld_state(ld_state),
  .laf_state(laf_state),
  .full_state(full_state),
  .lfd_state(lfd_state),
  .write_enb_reg(write_enb_reg),
  .busy(busy)
);


//sync instantiation
router_sync sync_inst(
  .clock(clock),
  .resetn(resetn),
  .detect_add(detect_add),
  .write_enb_reg(write_enb_reg),
  .data_in(data_in[1:0]),

  .vld_out_0(vld_out_0),
  .vld_out_1(vld_out_1),
  .vld_out_2(vld_out_2),

  .read_enb_0(read_enb_0),
  .read_enb_1(read_enb_1),
  .read_enb_2(read_enb_2),

  .write_enb(write_enb),
  .fifo_full(fifo_full),

  .empty_0(empty_0),
  .full_0(full_0),

  .empty_1(empty_1),
  .full_1(full_1),

  .empty_2(empty_2),
  .full_2(full_2),

  .soft_reset_0(soft_reset_0),
  .soft_reset_1(soft_reset_1),
  .soft_reset_2(soft_reset_2)
);


//fifo0
router_fifo fifo0_inst(
  .clock(clock),
  .resetn(resetn),
  .soft_reset(soft_reset_0),
  .write_enb(write_enb[0]),
  .read_enb(read_enb_0),
  .lfd_state(lfd_state),
  .data_in(dout),
  .empty(empty_0),
  .data_out(data_out_0),
  .full(full_0)
);


//fifo1
router_fifo fifo1_inst(
  .clock(clock),
  .resetn(resetn),
  .soft_reset(soft_reset_1),
  .write_enb(write_enb[1]),
  .read_enb(read_enb_1),
  .lfd_state(lfd_state),
  .data_in(dout),
  .empty(empty_1),
  .data_out(data_out_1),
  .full(full_1)
);


//fifo2
router_fifo fifo2_inst(
  .clock(clock),
  .resetn(resetn),
  .soft_reset(soft_reset_2),
  .write_enb(write_enb[2]),
  .read_enb(read_enb_2),
  .lfd_state(lfd_state),
  .data_in(dout),
  .empty(empty_2),
  .data_out(data_out_2),
  .full(full_2)
);

endmodule
