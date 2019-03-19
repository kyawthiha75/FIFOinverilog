module fifo(input reset,flush,clk_in,clk_out,insert,remove,input [7:0]data_in,output reg full,empty,output reg [7:0]data_out);
//state register
reg[1:0] wt_state,wt_next_state;
reg[1:0] rd_state,rd_next_state;
// counter for empty and full flag check
integer counter;
// state  declaration
parameter wt_idle = 2'd0;
parameter rd_idle = 2'd0;
parameter write_check = 2'd1;
parameter write = 2'd2;
parameter read_check = 2'd1;
parameter read = 2'd2;
parameter mem_size =8;
// internal variable declaration
integer rd_pointer,wr_prointer;
reg [7:0] fifo_mem[7:0];
reg rd_cycle;
reg wt_cycle;
reg temp1,temp2;
//state transaction  for  write domain)
always@( posedge clk_in, negedge reset)
if( !reset)
wt_state <= wt_idle;
else if( flush)
wt_state <= wt_idle;
else
wt_state <= wt_next_state;
// next state and output function for write
always@(*)
begin
case(wt_state)
wt_idle:
	begin	
	// reset or flush check
	if( !reset | flush)	
	begin	
	flush_out;
	empty = 1'b1;	
	wr_prointer = 0;
	counter = 0;
	end
	else;
	if( insert)
	wt_next_state = write_check ;
	else
	;
	end
write_check:
	begin
	if(!full)
	wt_next_state = write;
	else
	;
	end
write:
	begin	
	fifo_mem[wr_prointer] = data_in;
	wr_prointer = wr_prointer+1;
	if(wr_prointer == mem_size)
	begin
	wt_cycle = ~wt_cycle;
	wr_prointer = 0;
	end
	// check for full condition
	if( wr_prointer == rd_pointer)
	 if( wt_cycle != rd_cycle)
	 full = 1'b1;
	 else
	 ;
	@(posedge clk_in) temp1 = 1'b0;
	@(posedge clk_in) empty = temp1;	
	wt_next_state = wt_idle;
	
	end
default:
	begin
    wt_next_state = wt_idle;
	wr_prointer = 0;
	//counter = 0;	
	wt_cycle = 1'b0;
	full =1'b0;
	end

endcase

end
// task flush out the fifo
task flush_out;
for( wr_prointer = 0; wr_prointer < mem_size; wr_prointer = wr_prointer+1)
 fifo_mem[wr_prointer] = 8'b0;
//@(posedge clk_in) fifo_mem[wr_prointer] = 32'b0;
endtask


//state transaction  for read domain)
always@( posedge clk_out, negedge reset)
if( !reset)
rd_state <= rd_idle;
else
rd_state <= rd_next_state;
//next state and output function for read
always@(*)
begin
case(rd_state)
rd_idle:
	begin	
	// reset  check
	if( !reset)	
	begin	
	full = 1'b0;
	rd_pointer = 0;
	end
	else;
	if( remove)
	rd_next_state = read_check ;
	else
	;
	end
read_check:
	begin
	if(!empty)
	rd_next_state = read;
	else
	;
	end
read:
	begin
	//full = 1'b0;
	data_out = fifo_mem[rd_pointer];
	rd_pointer = rd_pointer+1;
	if(rd_pointer == mem_size)
	begin
	rd_pointer = 0;
	rd_cycle = ~rd_cycle;
	end
	// check for empty condition
	if( rd_pointer == wr_prointer)
	 if( rd_cycle == wt_cycle)	 
	 empty = 1'b1;	
	 else ;
	@(posedge clk_in) temp2 = 1'b0;
	@(posedge clk_in) full = temp2;	
	rd_next_state = rd_idle;
	
	end
default:
	begin
    rd_next_state = rd_idle;
	rd_pointer = 0;
	rd_cycle = 1'b0;
	empty =1'b1;
	//counter = 0;
	end

endcase
end


endmodule