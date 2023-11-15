module gold_router(
input wire clk,
input wire reset,
output reg polarity,
//Clockwise Input Buffer/Virtual Channels
input wire [63:0] cwdi,
input wire cwsi,
output reg cwri,
//CounterClockwise Input Buffer/Virtual Channels
input wire [63:0] ccwdi,
input wire ccwsi,
output reg ccwri,
//Processor Input Buffer/Virtual Channels
input wire [63:0] pedi,
input wire pesi,
output reg peri,
//Clockwise Output Buffer/Virtual Channels
output reg [63:0] cwdo,
output reg cwso,
input wire cwro,
//CounterClockwise Output Buffer/Virtual Channels
output reg [63:0] ccwdo,
output reg ccwso,
input wire ccwro,
//Processor Output Buffer/Virtual Channels
output reg [63:0] pedo,
output reg peso,
input wire pero,
output reg dump_packet,
output reg [63:0] dump_data
);
//---------------------------------------------------------------------------------------------------------------------

//Direction:Needed for Switching from Input to Output Buffer
//Need to check Hop as well
//assign dir_cw_in = cwdi[62];
//assign dir_ccw_in = ccwdi[62];
//assign dir_pe_in = pedi [62];

//Hop Cycles:Needed for deciding whether to send to the appointed direction or to the processor output buffer
//if hop[0]==0, then to processor; if hop[0] != 0, then hop[7:0] shifts right and to the directed buffer
//assign hop_cw_in[7:0] = cwdi[55:48];
//assign hop_ccw_in[7:0] = ccwdi[55:48];
//assign hop_pe_in[7:0] = pedi [55:48];

//Source Value: Needed for Future Assignment. Will Modify Functionality in Phase 2
//assign source_cw_in[15:0] = cwdi[47:32];
//assign source_ccw_in[15:0] = ccwdi[47:32];
//assign source_pe_in[15:0] = pedi[47:32];

//------------------------------------------------------------------------------------------------------------------------
//Minimal Routing Logic: Only for pe packets as they are just introduced into the ring
//Also with a Basic Hop Count fault check(dump_packet)
reg [63:0] updated_pedi;


always @(*) begin
if (reset == 0) begin
	if (pedi [55:48] == 8'b0000_0001) begin//Only One Hop 
		updated_pedi = pedi;//No need to Change
		dump_packet = 0;//No dump
	end
	else if ( pedi [55:48] == 8'b0000_0011) begin//There are 2 hops
		updated_pedi = {pedi[63],1'b0,pedi[61:0]}; //Automatically Clockwise regardless of original direction
		dump_packet = 0;//No dump
	end
	else if ( pedi [55:48] == 8'b0000_0111) begin//There are 3 hops
		updated_pedi = {pedi[63],~pedi[62],pedi[61:51], 1'b0, 1'b0, pedi[48:0]}; //Change to opposite direction
		//and set to 1 hop instead of 3 (updated_pedi bit [50:49] becomes 0
		dump_packet = 0;
	end
	else begin //All other conditions means packet contains fault
		dump_packet = 1;//Dump the packet
	end
end

end


always @(*) begin
  if (dump_packet) begin
  dump_data = pedi;

  end
end
//------------------------------------------------------------------------------------------------------------------------
//Input Buffer Read Enable, Full/Empty Status
reg cw_even_input_wen;
reg cw_odd_input_wen;
reg ccw_even_input_wen;
reg ccw_odd_input_wen;
reg pe_even_input_wen;
reg pe_odd_input_wen;

reg cw_even_input_ren;
reg cw_odd_input_ren;
reg ccw_even_input_ren;
reg ccw_odd_input_ren;
reg pe_even_input_ren;
reg pe_odd_input_ren;

wire cw_odd_input_empty;
wire cw_even_input_empty;
wire ccw_odd_input_empty;
wire ccw_even_input_empty;
wire pe_odd_input_empty;
wire pe_even_input_empty;

wire cw_odd_input_full;
wire cw_even_input_full;
wire ccw_odd_input_full;
wire ccw_even_input_full;
wire pe_odd_input_full;
wire pe_even_input_full;

//input buffer data output
wire [63:0] cw_input_buffer_odd;
wire [63:0] cw_input_buffer_even;
wire [63:0] ccw_input_buffer_odd;
wire [63:0] ccw_input_buffer_even;
wire [63:0] pe_input_buffer_odd;
wire [63:0] pe_input_buffer_even;


//Input Buffer Instantiations
buffer cw_odd_input (
    .clk(clk),
    .reset(reset),
    .full(cw_odd_input_full),
    .empty(cw_odd_input_empty),
    .ren(cw_odd_input_ren),
    .wen(cw_odd_input_wen),
    .d_in(cwdi),
    .d_out(cw_input_buffer_odd)
);

buffer cw_even_input (
    .clk(clk),
    .reset(reset),
    .full(cw_even_input_full),
    .empty(cw_even_input_empty),
    .ren(cw_even_input_ren),
    .wen(cw_even_input_wen),
    .d_in(cwdi),
    .d_out(cw_input_buffer_even)
);

buffer ccw_odd_input (
    .clk(clk),
    .reset(reset),
    .full(ccw_odd_input_full),
    .empty(ccw_odd_input_empty),
    .ren(ccw_odd_input_ren),
    .wen(ccw_odd_input_wen),
    .d_in(ccwdi),
    .d_out(ccw_input_buffer_odd)
);

buffer ccw_even_input (
    .clk(clk),
    .reset(reset),
    .full(ccw_even_input_full),
    .empty(ccw_even_input_empty),
    .ren(ccw_even_input_ren),
    .wen(ccw_even_input_wen),
    .d_in(ccwdi),
    .d_out(ccw_input_buffer_even)
);

buffer pe_odd_input (
    .clk(clk),
    .reset(reset),
    .full(pe_odd_input_full),
    .empty(pe_odd_input_empty),
    .ren(pe_odd_input_ren),
    .wen(pe_odd_input_wen),
    .d_in(updated_pedi),
    .d_out(pe_input_buffer_odd)
);

buffer pe_even_input (
    .clk(clk),
    .reset(reset),
    .full(pe_even_input_full),
    .empty(pe_even_input_empty),
    .ren(pe_even_input_ren),
    .wen(pe_even_input_wen),
    .d_in(updated_pedi),
    .d_out(pe_input_buffer_even)
);


//------------------------------------------------------------------
//Ready Write For Input Buffers Combinational Logic 
//Input Buffer empty status sent to sender router

always @(*) begin
	if (!polarity) begin//in the even phase check if odd channels are ready for input
		if (cw_odd_input_empty)
			cwri = 1;
		else
			cwri = 0;
		
		if (ccw_odd_input_empty)
			ccwri = 1;
		else
			ccwri = 0;
		
		if (pe_odd_input_empty)
			peri = 1;
		else
			peri = 0;
	end
	else begin
		if (cw_even_input_empty)
			cwri = 1;
		else
			cwri = 0;
		if (ccw_even_input_empty)
			ccwri = 1;
		else
			ccwri = 0;
		if (pe_even_input_empty)
			peri = 1;
		else
			peri = 0;
	end
end
//-------------------------------------------------------------------
//Input Buffer Write Enables that allows the buffer to write
always @(*) begin
    if (polarity) begin//in the odd phase enable even channel write if condition allowed
		//in odd phase reset all odd input buffer write enable
		cw_odd_input_wen = 0;
		ccw_odd_input_wen = 0;
		pe_odd_input_wen = 0;

        if (cwsi && cwri) begin
            cw_even_input_wen = 1;
        end
        else begin
            cw_even_input_wen = 0;
        end

        if (ccwsi && ccwri) begin
            ccw_even_input_wen = 1;
        end
        else begin
            ccw_even_input_wen = 0;
        end

        if (pesi && peri && !dump_packet) begin
            pe_even_input_wen = 1;
        end
        else begin
            pe_even_input_wen = 0;
        end
    end
    else begin
		//in even phase reset all even input buffer write enable
		cw_even_input_wen = 0;
		ccw_even_input_wen = 0;
		pe_even_input_wen = 0;

        if (cwsi && cwri) begin
            cw_odd_input_wen = 1;
        end
        else begin
            cw_odd_input_wen = 0;
        end

        if (ccwsi && ccwri) begin
            ccw_odd_input_wen = 1;
        end
        else begin
            ccw_odd_input_wen = 0;
        end

        if (pesi && peri && !dump_packet) begin
            pe_odd_input_wen = 1;
        end
        else begin
            pe_odd_input_wen = 0;
        end
    end
end

//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------------
//Output Buffer Read/Write Enables, and empty/full status
reg cw_even_output_ren;
reg cw_odd_output_ren;
reg ccw_even_output_ren;
reg ccw_odd_output_ren;
reg pe_even_output_ren;
reg pe_odd_output_ren;

reg cw_even_output_wen;
reg cw_odd_output_wen;
reg ccw_even_output_wen;
reg ccw_odd_output_wen;
reg pe_even_output_wen;
reg pe_odd_output_wen;

wire cw_odd_output_empty;
wire cw_even_output_empty;
wire ccw_odd_output_empty;
wire ccw_even_output_empty;
wire pe_odd_output_empty;
wire pe_even_output_empty;

wire cw_odd_output_full;
wire cw_even_output_full;
wire ccw_odd_output_full;
wire ccw_even_output_full;
wire pe_odd_output_full;
wire pe_even_output_full;

//data in for output buffers
reg [63:0] cwin_output_buffer_odd;
reg [63:0] cwin_output_buffer_even;
reg [63:0] ccwin_output_buffer_odd;
reg [63:0] ccwin_output_buffer_even;
reg [63:0] pein_output_buffer_odd;
reg [63:0] pein_output_buffer_even;
//data out for output buffers
wire [63:0] cw_output_buffer_odd;
wire [63:0] cw_output_buffer_even;
wire [63:0] ccw_output_buffer_odd;
wire [63:0] ccw_output_buffer_even;
wire [63:0] pe_output_buffer_odd;
wire [63:0] pe_output_buffer_even;
//Below are 6 Output Buffer Instantiations (3 Odd, 3 Evens) 
//For Example, cwin_output_buffer_even is the 64 bit data that has gone through hop value update between Input and OUtput buffer.
buffer cw_odd_output (
    .clk(clk),
    .reset(reset),
    .full(cw_odd_output_full),
    .empty(cw_odd_output_empty),
    .ren(cw_odd_output_ren),
    .wen(cw_odd_output_wen),
    .d_in(cwin_output_buffer_odd),
    .d_out(cw_output_buffer_odd)
);

buffer cw_even_output (
    .clk(clk),
    .reset(reset),
    .full(cw_even_output_full),
    .empty(cw_even_output_empty),
    .ren(cw_even_output_ren),
    .wen(cw_even_output_wen),
    .d_in(cwin_output_buffer_even),
    .d_out(cw_output_buffer_even)
);

buffer ccw_odd_output (
    .clk(clk),
    .reset(reset),
    .full(ccw_odd_output_full),
    .empty(ccw_odd_output_empty),
    .ren(ccw_odd_output_ren),
    .wen(ccw_odd_output_wen),
    .d_in(ccwin_output_buffer_odd),
    .d_out(ccw_output_buffer_odd)
);

buffer ccw_even_output (
    .clk(clk),
    .reset(reset),
    .full(ccw_even_output_full),
    .empty(ccw_even_output_empty),
    .ren(ccw_even_output_ren),
    .wen(ccw_even_output_wen),
    .d_in(ccwin_output_buffer_even),
    .d_out(ccw_output_buffer_even)
);

buffer pe_odd_output (
    .clk(clk),
    .reset(reset),
    .full(pe_odd_output_full),
    .empty(pe_odd_output_empty),
    .ren(pe_odd_output_ren),
    .wen(pe_odd_output_wen),
    .d_in(pein_output_buffer_odd),
    .d_out(pe_output_buffer_odd)
);

buffer pe_even_output (
    .clk(clk),
    .reset(reset),
    .full(pe_even_output_full),
    .empty(pe_even_output_empty),
    .ren(pe_even_output_ren),
    .wen(pe_even_output_wen),
    .d_in(pein_output_buffer_even),
    .d_out(pe_output_buffer_even)
);
//--------------------------------------------------------------------------------------------------------------------
//Input Buffer --> Output Buffer Request Logic
//If Input Buffer is full, Output Buffer is empty, and depending on the Hop value, whether the data continues to the 
//next direction buffer or goes to processor buffer
//If last bit of Hop value is 1, then data goes to directed buffer
//If last bit of Hop value is 0, then data goes to processor buffer
reg cwin_request_cwout_even;
reg cwin_request_peout_even;
reg ccwin_request_ccwout_even;
reg ccwin_request_peout_even;
reg pein_request_cwout_even;
reg pein_request_ccwout_even;

reg cwin_request_cwout_odd;
reg cwin_request_peout_odd;
reg ccwin_request_ccwout_odd;
reg ccwin_request_peout_odd;
reg pein_request_cwout_odd;
reg pein_request_ccwout_odd;

always @(*) begin
	if (!polarity) begin//in the even phase send request in even channels
		cwin_request_cwout_odd = 0;
		cwin_request_peout_odd = 0;
		ccwin_request_ccwout_odd = 0;
		ccwin_request_peout_odd = 0;
		pein_request_cwout_odd = 0;
		pein_request_ccwout_odd = 0;

		if (cw_even_input_full && (cw_input_buffer_even[48]==1) && cw_even_output_empty ) //cw to cw
			cwin_request_cwout_even = 1;
		else
			cwin_request_cwout_even = 0;
		
		if (cw_even_input_full && (cw_input_buffer_even[48]==0) && pe_even_output_empty ) //cw to pe
			cwin_request_peout_even = 1;
		else
			cwin_request_peout_even = 0;
		
		if (ccw_even_input_full && (ccw_input_buffer_even[48]==1) && ccw_even_output_empty ) //ccw to ccw
			ccwin_request_ccwout_even = 1;
		else
			ccwin_request_ccwout_even = 0;
		
		if (ccw_even_input_full && (ccw_input_buffer_even[48]==0) && pe_even_output_empty ) //ccw to pe
			ccwin_request_peout_even = 1;
		else 
			ccwin_request_peout_even = 0;
		
		if (pe_even_input_full && (pe_input_buffer_even[62]==0) && cw_even_output_empty ) //pe to cw
			pein_request_cwout_even = 1;
		else
			pein_request_cwout_even = 0;

		if (pe_even_input_full && (pe_input_buffer_even[62]==1) && ccw_even_output_empty ) //pe to ccw
			pein_request_ccwout_even = 1;
		else
			pein_request_ccwout_even = 0;
	end
	else begin
		cwin_request_cwout_even = 0;
		cwin_request_peout_even = 0;
		ccwin_request_ccwout_even = 0;
		ccwin_request_peout_even = 0;
		pein_request_cwout_even = 0;
		pein_request_ccwout_even = 0;
		if (cw_odd_input_full && (cw_input_buffer_odd[48] == 1) && cw_odd_output_empty ) // cw to cw
			cwin_request_cwout_odd = 1;
		else
			cwin_request_cwout_odd = 0;

		if (cw_odd_input_full && (cw_input_buffer_odd[48] == 0) && pe_odd_output_empty ) // cw to pe
			cwin_request_peout_odd = 1;
		else
			cwin_request_peout_odd = 0;

		if (ccw_odd_input_full && (ccw_input_buffer_odd[48] == 1) && ccw_odd_output_empty ) // ccw to ccw
			ccwin_request_ccwout_odd = 1;
		else
			ccwin_request_ccwout_odd = 0;

		if (ccw_odd_input_full && (ccw_input_buffer_odd[48] == 0) && pe_odd_output_empty ) // ccw to pe
			ccwin_request_peout_odd = 1;
		else
			ccwin_request_peout_odd = 0;

		if (pe_odd_input_full && (pe_input_buffer_odd[62] == 0) && cw_odd_output_empty ) // pe to cw
			pein_request_cwout_odd = 1;
		else
			pein_request_cwout_odd = 0;

		if (pe_odd_input_full && (pe_input_buffer_odd[62] == 1) && ccw_odd_output_empty ) // pe to ccw
			pein_request_ccwout_odd = 1;
		else
			pein_request_ccwout_odd = 0;
	end
end
//---------------------------------------------------------------------------------------------------------------------
//Arbitor Instantiation: 6 Arbitors corresponding to 6 buffers
wire cwin_grant_cwout_even;
wire cwin_grant_peout_even;
wire ccwin_grant_ccwo_even;
wire ccwin_grant_peout_even;
wire pein_grant_cwout_even;
wire pein_grant_ccwout_even;

wire cwin_grant_cwout_odd;
wire cwin_grant_peout_odd;
wire ccwin_grant_ccwo_odd;
wire ccwin_grant_peout_odd;
wire pein_grant_cwout_odd;
wire pein_grant_ccwout_odd;



arbiter cw_arbiter_even (
    .clk(clk),
    .reset(reset),
    .rq0(cwin_request_cwout_even),
    .rq1(cwin_request_peout_even),
    .gt0(cwin_grant_cwout_even),
    .gt1(cwin_grant_peout_even)
);

arbiter ccw_arbiter_even (
    .clk(clk),
    .reset(reset),
    .rq0(ccwin_request_ccwout_even),
    .rq1(ccwin_request_peout_even),
    .gt0(ccwin_grant_ccwout_even),
    .gt1(ccwin_grant_peout_even)
);

arbiter pe_arbiter_even(
    .clk(clk),
    .reset(reset),
    .rq0(pein_request_cwout_even),
    .rq1(pein_request_ccwout_even),
    .gt0(pein_grant_cwout_even),
    .gt1(pein_grant_ccwout_even)
);

arbiter cw_arbiter_odd (
    .clk(clk),	
    .reset(reset),
    .rq0(cwin_request_cwout_odd),
    .rq1(cwin_request_peout_odd),
    .gt0(cwin_grant_cwout_odd),
    .gt1(cwin_grant_peout_odd)
);

arbiter ccw_arbiter_odd (
    .clk(clk),
    .reset(reset),
    .rq0(ccwin_request_ccwout_odd),
    .rq1(ccwin_request_peout_odd),
    .gt0(ccwin_grant_ccwout_odd),
    .gt1(ccwin_grant_peout_odd)
);

arbiter pe_arbiter_odd (
    .clk(clk),
    .reset(reset),
    .rq0(pein_request_cwout_odd),
    .rq1(pein_request_ccwout_odd),
    .gt0(pein_grant_cwout_odd),
    .gt1(pein_grant_ccwout_odd)
);

//--------------------------------------------------------------------------------------------------------------------
//With Grant from arbiter, input buffer transfers data to output buffer
always @(*) begin
	if (polarity==0) begin//in the even phase forward content in even input buffer to even output buffer
		if (cwin_grant_cwout_even || cwin_grant_peout_even) begin//either cw even in -> out buffer or cw even in -> pe buffer request is granted
			cw_even_input_ren = 1;
			if (cwin_grant_cwout_even) begin
				cwin_output_buffer_even[63:0] = cw_input_buffer_even[63:0];
				cwin_output_buffer_even[55:48] = cw_input_buffer_even[55:48] >> 1;
			end
			else begin
				pein_output_buffer_even[55:48] = cw_input_buffer_even[55:48] >> 1;
				pein_output_buffer_even[63:56] = cw_input_buffer_even[63:56];
				pein_output_buffer_even[47:0] = cw_input_buffer_even[47:0];
			end
		end
		else begin
			cw_even_input_ren = 0;
		end

		if (ccwin_grant_ccwout_even || ccwin_grant_peout_even) begin
			ccw_even_input_ren = 1;
			if (ccwin_grant_ccwout_even) begin
				ccwin_output_buffer_even[55:48] = ccw_input_buffer_even[55:48] >> 1;
				ccwin_output_buffer_even[63:56] = ccw_input_buffer_even[63:56];
				ccwin_output_buffer_even[47:0] = ccw_input_buffer_even[47:0];
			end
			else begin
				pein_output_buffer_even[63:0] = ccw_input_buffer_even[63:0];
				pein_output_buffer_even[55:48] = ccw_input_buffer_even[55:48] >> 1;

			end
		end
		else begin
			ccw_even_input_ren = 0;
		end

		if (pein_grant_cwout_even || pein_grant_ccwout_even) begin
			pe_even_input_ren = 1;
			if (pein_grant_cwout_even) begin
				cwin_output_buffer_even[55:48] = pe_input_buffer_even[55:48] >> 1;
				cwin_output_buffer_even[63:56] = pe_input_buffer_even[63:56];
				cwin_output_buffer_even[47:0] = pe_input_buffer_even[47:0];
			end
			else begin
				ccwin_output_buffer_even[55:48] = pe_input_buffer_even[55:48] >> 1;
				ccwin_output_buffer_even[63:56] = pe_input_buffer_even[63:56];
				ccwin_output_buffer_even[47:0] = pe_input_buffer_even[47:0];
			end
		end
		else begin
			pe_even_input_ren = 0;
		end
	end

	else begin
		if (cwin_grant_cwout_odd || cwin_grant_peout_odd) begin
			cw_odd_input_ren = 1;
			if (cwin_grant_cwout_odd) begin
				cwin_output_buffer_odd[55:48] = cw_input_buffer_odd[55:48] >> 1;
				cwin_output_buffer_odd[63:56] = cw_input_buffer_odd[63:56];
				cwin_output_buffer_odd[47:0] = cw_input_buffer_odd[47:0];
			end
			else begin
				pein_output_buffer_odd[55:48] = cw_input_buffer_odd[55:48] >> 1;
				pein_output_buffer_odd[63:56] = cw_input_buffer_odd[63:56];
				pein_output_buffer_odd[47:0] = cw_input_buffer_odd[47:0];
			end
		end
		else begin
			cw_odd_input_ren = 0;
		end

		if (ccwin_grant_ccwout_odd || ccwin_grant_peout_odd) begin
			ccw_odd_input_ren = 1;
			if (ccwin_grant_ccwout_odd) begin
				ccwin_output_buffer_odd[55:48] = ccw_input_buffer_odd[55:48] >> 1;
				ccwin_output_buffer_odd[63:56] = ccw_input_buffer_odd[63:56];
				ccwin_output_buffer_odd[47:0] = ccw_input_buffer_odd[47:0];
			end
			else begin
				pein_output_buffer_odd[55:48] = ccw_input_buffer_odd[55:48] >> 1;
				pein_output_buffer_odd[63:56] = ccw_input_buffer_odd[63:56];
				pein_output_buffer_odd[47:0] = ccw_input_buffer_odd[47:0];
			end
		end
		else begin
			ccw_odd_input_ren = 0;
		end

		if (pein_grant_cwout_odd || pein_grant_ccwout_odd) begin
			pe_odd_input_ren = 1;
			if (pein_grant_cwout_odd) begin
				cwin_output_buffer_odd[55:48] = pe_input_buffer_odd[55:48] >> 1;
				cwin_output_buffer_odd[63:56] = pe_input_buffer_odd[63:56];
				cwin_output_buffer_odd[47:0] = pe_input_buffer_odd[47:0];
			end
			else begin
				ccwin_output_buffer_odd[55:48] = pe_input_buffer_odd[55:48] >> 1;
				ccwin_output_buffer_odd[63:56] = pe_input_buffer_odd[63:56];
				ccwin_output_buffer_odd[47:0] = pe_input_buffer_odd[47:0];
			end
		end
		else begin
			pe_odd_input_ren = 0;
		end
	end

end
//--------------------------------------------------------------------------------------------------------------------
//output buffer write enable control logic
always @(*) begin
	if (!polarity) begin//in the even phase
		if (cwin_grant_cwout_even || pein_grant_cwout_even)
			cw_even_output_wen = 1;
		else
			cw_even_output_wen = 0;
		
		if (ccwin_grant_ccwout_even || pein_grant_ccwout_even)
			ccw_even_output_wen = 1;
		else
			ccw_even_output_wen = 0;
		
		if (cwin_grant_peout_even || ccwin_grant_peout_even)
			pe_even_output_wen = 1;
		else
			pe_even_output_wen = 0;
	end
	else begin
		if (cwin_grant_cwout_odd || pein_grant_cwout_odd)
			cw_odd_output_wen = 1;
		else
			cw_odd_output_wen = 0;
		
		if (ccwin_grant_ccwout_odd || pein_grant_ccwout_odd)
			ccw_odd_output_wen = 1;
		else
			ccw_odd_output_wen = 0;
		
		if (cwin_grant_peout_odd || ccwin_grant_peout_odd)
			pe_odd_output_wen = 1;
		else
			pe_odd_output_wen = 0;
	end
end

//--------------------------------------------------------------------------------------------------------------------
//Turn on Read Enable (ren) signal, showing that the buffer is capable of being read
//If Buffer is full and the target Input Buffer is ready to receive (ro == 1)
always @(*) begin
	if (polarity) begin//in odd phase enable even channel output read if condition allowed
			cw_even_output_ren = cwso & cwro;
			ccw_even_output_ren = ccwso & ccwro;
			pe_even_output_ren = peso & pero;
			cw_odd_output_ren = 0;
			ccw_odd_output_ren = 0;
			pe_odd_output_ren = 0;
	end
	else begin
			cw_odd_output_ren = cwso & cwro;
			ccw_odd_output_ren = ccwso & ccwro;
			pe_odd_output_ren = pe_odd_output_full & pero;
			cw_even_output_ren = 0;
			ccw_even_output_ren = 0;
			pe_even_output_ren = 0;
	end
end
//--------------------------------------------------------------------------------------------------------------------
// Turn on Output Send (so) signal, showing that the buffer is capable of sending packet
// If output buffer is full

always @(*) begin
	if (polarity) begin
			cwso = cw_even_output_full & cwro;
			ccwso = ccw_even_output_full & ccwro;
			peso = pe_even_output_full & pero;

	end
	else begin
			cwso = cw_odd_output_full & cwro;
			ccwso = ccw_odd_output_full & ccwro;
			peso = pe_odd_output_full & pero;
		end
end

//--------------------------------------------------------------------------------------------------------------------
//Finally, Output Buffer --> Data Out, Ready to be sent
always @(*) begin
	if (polarity) begin
		cwdo = cw_output_buffer_even;
		ccwdo = ccw_output_buffer_even;
		pedo = pe_output_buffer_even;
	end
	else begin
		cwdo = cw_output_buffer_odd;
		ccwdo = ccw_output_buffer_odd;
		pedo = pe_output_buffer_odd;
	end
end


//Polarity Generation
always @(posedge clk) begin
if (reset) begin
polarity <= 1;end
else begin
polarity <= ~polarity;
end
end

endmodule