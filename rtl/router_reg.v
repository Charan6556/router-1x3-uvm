module router_reg (
  input clock,
  resetn,
  pkt_valid,
  fifo_full,
  rst_int_reg,

  input detect_add,
  ld_state,
  laf_state,
  full_state,
  lfd_state,

  input [7:0] data_in,

  output reg parity_done,
  low_pkt_valid,
  err,

  output reg [7:0] dout
);

reg [7:0] header_reg;
reg [7:0] full_state_reg;
reg [7:0] parity_reg;
reg [7:0] packet_parity_reg;

//header_reg block
always @(posedge clock)
begin
  if(!resetn)
    header_reg <= 8'b0;
  else if(detect_add && pkt_valid)
    header_reg <= data_in;
end

//dout reg
always @(posedge clock)
begin
  if(!resetn)
    dout <= 8'b0;
  else if(lfd_state)
    dout <= header_reg;
  else if(ld_state && !fifo_full)
    dout <= data_in;
  else if(laf_state)
    dout <= full_state_reg;
end

//full state reg
always @(posedge clock)
begin
  if(!resetn)
    full_state_reg <= 8'b0;
  else if(ld_state && fifo_full)
    full_state_reg <= data_in;
end

//parity reg
always @(posedge clock)
begin
  if(!resetn || detect_add)
    parity_reg <= 8'b0;

  else if(lfd_state)
    parity_reg <= parity_reg ^ header_reg;

  else if(ld_state && !fifo_full)
    parity_reg <= parity_reg ^ data_in;

  else if(full_state)
    parity_reg <= parity_reg ^ full_state_reg;
end

//packet parity reg
always @(posedge clock)
begin
  if(!resetn)
    packet_parity_reg <= 8'b0;
  else if(parity_done)
    packet_parity_reg <= data_in;
end

//parity done signal
always @(posedge clock)
begin
  if(!resetn || detect_add)
    parity_done <= 1'b0;

  else if(ld_state && !fifo_full && !pkt_valid)
    parity_done <= 1'b1;

  else if(laf_state && low_pkt_valid && !parity_done)
    parity_done <= 1'b1;
end

//error signal
always @(posedge clock)
begin
  if(!resetn)
    err <= 1'b0;
  else if(parity_done)
    err <= (parity_reg != packet_parity_reg);
end

//low packet valid signal
always @(posedge clock)
begin
  if(!resetn || rst_int_reg)
    low_pkt_valid <= 1'b0;
  else if(ld_state && !pkt_valid)
    low_pkt_valid <= 1'b1;
end

endmodule
