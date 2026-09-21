module router_sync (
  input detect_add,write_enb_reg,clock,resetn,
  input read_enb_0,read_enb_1,read_enb_2,
  input empty_0, empty_1,empty_2,
  input full_0,full_1,full_2,
  input [1:0] data_in,
  output reg [2:0] write_enb,
  output reg soft_reset_0,soft_reset_1,soft_reset_2,
  output vld_out_0,vld_out_1,vld_out_2,
  output reg fifo_full
);

reg [1:0] addr;
reg [4:0] count_0, count_1, count_2;

parameter write_enb_0 = 3'b001,
          write_enb_1 = 3'b010,
          write_enb_2 = 3'b100;

//selecting the fifo for packet routing
always @(posedge clock)
begin
  if(!resetn)
    addr <= 2'b00;
  else if(detect_add)
    addr <= data_in;
end

//full status of selected fifo
always @(*)
begin
  case(addr)
    2'b00: fifo_full = full_0;
    2'b01: fifo_full = full_1;
    2'b10: fifo_full = full_2;
    default: fifo_full = 1'b0;
  endcase
end

//valid out based on empty status
assign vld_out_0 = ~empty_0;
assign vld_out_1 = ~empty_1;
assign vld_out_2 = ~empty_2;

//write enable for selected fifo
always @(*)
begin
  if(write_enb_reg)
  begin
    case(addr)
      2'b00: write_enb = write_enb_0;
      2'b01: write_enb = write_enb_1;
      2'b10: write_enb = write_enb_2;
      default: write_enb = 3'b000;
    endcase
  end
  else
    write_enb = 3'b000;
end

//internal reset logic fifo0
always @(posedge clock)
begin
  if(!resetn || soft_reset_0 || read_enb_0)
  begin
    count_0 <= 5'b0;
    soft_reset_0 <= 1'b0;
  end
  else if(vld_out_0)
  begin
    if(count_0 == 5'd29)
    begin
      soft_reset_0 <= 1'b1;
      count_0 <= 5'b0;
    end
    else
    begin
      count_0 <= count_0 + 1;
      soft_reset_0 <= 1'b0;
    end
  end
  else
  begin
    count_0 <= 5'b0;
    soft_reset_0 <= 1'b0;
  end
end

//internal reset logic fifo1
always @(posedge clock)
begin
  if(!resetn || soft_reset_1 || read_enb_1)
  begin
    count_1 <= 5'b0;
    soft_reset_1 <= 1'b0;
  end
  else if(vld_out_1)
  begin
    if(count_1 == 5'd29)
    begin
      soft_reset_1 <= 1'b1;
      count_1 <= 5'b0;
    end
    else
    begin
      count_1 <= count_1 + 1;
      soft_reset_1 <= 1'b0;
    end
  end
  else
  begin
    count_1 <= 5'b0;
    soft_reset_1 <= 1'b0;
  end
end

//internal reset logic fifo2
always @(posedge clock)
begin
  if(!resetn || soft_reset_2 || read_enb_2)
  begin
    count_2 <= 5'b0;
    soft_reset_2 <= 1'b0;
  end
  else if(vld_out_2)
  begin
    if(count_2 == 5'd29)
    begin
      soft_reset_2 <= 1'b1;
      count_2 <= 5'b0;
    end
    else
    begin
      count_2 <= count_2 + 1;
      soft_reset_2 <= 1'b0;
    end
  end
  else
  begin
    count_2 <= 5'b0;
    soft_reset_2 <= 1'b0;
  end
end

endmodule
