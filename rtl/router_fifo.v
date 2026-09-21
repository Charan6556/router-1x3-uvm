module router_fifo (
  clock,
  resetn,
  soft_reset,
  write_enb,
  read_enb,
  data_in,
  lfd_state,
  empty,
  full,
  data_out
);

input clock;
input resetn;
input soft_reset;
input write_enb;
input read_enb;
input lfd_state;
input [7:0] data_in;

output empty;
output full;
output reg [7:0] data_out;

reg [8:0] mem [15:0];

reg [3:0] rd_ptr;
reg [3:0] wrt_ptr;

reg [4:0] count;

reg [5:0] pl_count;


//full and empty
assign empty = (count == 5'd0);
assign full  = (count == 5'd16);


//write operation
always @(posedge clock)
begin

  if(!resetn)
  begin
    wrt_ptr <= 4'b0;
  end

  else if(soft_reset)
  begin
    wrt_ptr <= 4'b0;
  end

  else if(write_enb && !full)
  begin
    mem[wrt_ptr] <= {lfd_state,data_in};
    wrt_ptr <= wrt_ptr + 1'b1;
  end

end


//read operation
always @(posedge clock)
begin

  if(!resetn)
  begin
    rd_ptr <= 4'b0;
    data_out <= 8'b0;
    pl_count <= 6'b0;
  end

  else if(soft_reset)
  begin
    rd_ptr <= 4'b0;
    data_out <= 8'bz;
    pl_count <= 6'b0;
  end

  else if(read_enb && !empty)
  begin

    data_out <= mem[rd_ptr][7:0];
    rd_ptr <= rd_ptr + 1'b1;

    //header
    if(mem[rd_ptr][8])
    begin
      pl_count <= mem[rd_ptr][7:2] + 1'b1;
    end

    else if(pl_count != 6'b0)
    begin
      pl_count <= pl_count - 1'b1;
    end

  end

  else
  begin

    if(pl_count == 6'b0)
      data_out <= 8'bz;

  end

end


//fifo count
always @(posedge clock)
begin

  if(!resetn)
  begin
    count <= 5'b0;
  end

  else if(soft_reset)
  begin
    count <= 5'b0;
  end

  else
  begin

    case({write_enb && !full, read_enb && !empty})

      //write only
      2'b10:
        count <= count + 1'b1;

      //read only
      2'b01:
        count <= count - 1'b1;

      //read and write
      2'b11:
        count <= count;

      default:
        count <= count;

    endcase

  end

end

endmodule
