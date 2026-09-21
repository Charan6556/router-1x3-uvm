module router_fsm (
  input clock,
  resetn,
  pkt_valid,
  parity_done,
  fifo_full,
  low_pkt_valid,

  input soft_reset_0,
  soft_reset_1,
  soft_reset_2,

  input fifo_empty_0,
  fifo_empty_1,
  fifo_empty_2,

  input [1:0] data_in,

  output reg busy,
  detect_add,
  ld_state,
  laf_state,
  full_state,
  write_enb_reg,
  rst_int_reg,
  lfd_state
);

parameter DECODE_ADDRESS      = 3'b000,
          LOAD_FIRST_DATA     = 3'b001,
          LOAD_DATA           = 3'b010,
          LOAD_PARITY         = 3'b011,
          FIFO_FULL_STATE     = 3'b100,
          LOAD_AFTER_FULL     = 3'b101,
          WAIT_TILL_EMPTY     = 3'b110,
          CHECK_PARITY_ERROR  = 3'b111;

reg [2:0] pre_state, next_state;

//present state logic
always @(posedge clock)
begin
  if(!resetn || soft_reset_0 || soft_reset_1 || soft_reset_2)
    pre_state <= 3'b000;
  else
    pre_state <= next_state;
end

//next state decoder logic
always @(*)
begin
  case(pre_state)

    DECODE_ADDRESS:
    begin
      if(pkt_valid && data_in[1:0]==0 && fifo_empty_0 ||
         pkt_valid && data_in[1:0]==1 && fifo_empty_1 ||
         pkt_valid && data_in[1:0]==2 && fifo_empty_2)
        next_state = LOAD_FIRST_DATA;

      else if(pkt_valid && data_in[1:0]==0 && !fifo_empty_0 ||
              pkt_valid && data_in[1:0]==1 && !fifo_empty_1 ||
              pkt_valid && data_in[1:0]==2 && !fifo_empty_2)
        next_state = WAIT_TILL_EMPTY;

      else
        next_state = DECODE_ADDRESS;
    end

    LOAD_FIRST_DATA:
      next_state = LOAD_DATA;

    LOAD_DATA:
    begin
      if(fifo_full)
        next_state = FIFO_FULL_STATE;
      else if(!fifo_full && !pkt_valid)
        next_state = LOAD_PARITY;
      else
        next_state = LOAD_DATA;
    end

    FIFO_FULL_STATE:
    begin
      if(!fifo_full)
        next_state = LOAD_AFTER_FULL;
      else
        next_state = FIFO_FULL_STATE;
    end

    LOAD_AFTER_FULL:
    begin
      if(!parity_done && low_pkt_valid)
        next_state = LOAD_PARITY;
      else if(!parity_done && !low_pkt_valid)
        next_state = LOAD_DATA;
      else if(parity_done)
        next_state = DECODE_ADDRESS;
      else
        next_state = LOAD_AFTER_FULL;
    end

    LOAD_PARITY:
      next_state = CHECK_PARITY_ERROR;

    CHECK_PARITY_ERROR:
    begin
      if(fifo_full)
        next_state = FIFO_FULL_STATE;
      else
        next_state = DECODE_ADDRESS;
    end

    WAIT_TILL_EMPTY:
    begin
      if(fifo_empty_0 && data_in[1:0]==0 ||
         fifo_empty_1 && data_in[1:0]==1 ||
         fifo_empty_2 && data_in[1:0]==2)
        next_state = LOAD_FIRST_DATA;
      else
        next_state = WAIT_TILL_EMPTY;
    end

    default:
      next_state = DECODE_ADDRESS;

  endcase
end

//output logic
always @(*)
begin
  detect_add = 1'b0;
  lfd_state = 1'b0;
  ld_state = 1'b0;
  write_enb_reg = 1'b0;
  full_state = 1'b0;
  laf_state = 1'b0;
  rst_int_reg = 1'b0;
  busy = 1'b0;

  case(pre_state)

    DECODE_ADDRESS:
      detect_add = 1'b1;

    LOAD_FIRST_DATA:
    begin
      lfd_state = 1'b1;
      busy = 1'b1;
    end

    LOAD_DATA:
    begin
      ld_state = 1'b1;
      write_enb_reg = 1'b1;
    end

    LOAD_PARITY:
    begin
      busy = 1'b1;
      write_enb_reg = 1'b1;
    end

    FIFO_FULL_STATE:
    begin
      busy = 1'b1;
      full_state = 1'b1;
    end

    LOAD_AFTER_FULL:
    begin
      busy = 1'b1;
      laf_state = 1'b1;
      write_enb_reg = 1'b1;
    end

    WAIT_TILL_EMPTY:
      busy = 1'b1;

    CHECK_PARITY_ERROR:
    begin
      busy = 1'b1;
      rst_int_reg = 1'b1;
    end

    default:
      detect_add = 1'b1;

  endcase
end

endmodule
