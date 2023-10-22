module gold_router(clk, reset, cwdi, cwsi, cwri, ccwdi, 
ccwsi, ccwri, pedi, pesi, peri, cwdo, cwso, cwro, ccwdo, ccwso, ccwro, pedo, peso, pero);

//-------------------------------------------------------------------------
input wire clk;
input wire reset;
output reg polarity;

//Clockwise Input Buffer/Virtual Channels
input wire [63:0] cwdi;
input wire cwsi;
output reg cwri;


//CounterClockwise Input Buffer/Virtual Channels
input wire [63:0] ccwdi;
input wire ccwsi;
output reg ccwri;


//Processor Input Buffer/Virtual Channels
input wire [63:0] pedi;
input wire pesi;
output reg oeri;


//Clockwise Output Buffer/Virtual Channels
output reg [63:0] cwdo;
output reg cwso;
input wire cwro;


//CounterClockwise Output Buffer/Virtual Channels
output reg [63:0] ccwdo;
output reg ccwso;
input wire ccwro;

	
//Processor Output Buffer/Virtual Channels
output reg [63:0] pedo;
output reg peso;
input wire pero;


//---------------------------------------------------------------------------------------------------------------------
//Polarity Bit
assign wire polarity_cw_in= cwdi[63];
assign wire polarity_ccw_in = ccwdi[63];
assign wire polarity_pe_in = pedi[63];

//Direction:Needed for Switching from Input to Output Buffer
	//Need to check Hop as well
assign wire dir_cw_in = cwdi[62];
assign wire dir_ccw_in = ccdwi[62];
assign wire dir_pe_in = pedi [62];

//Hop Cycles:Needed for deciding whether to send to the appointed direction or to the processor output buffer
//if hop[0]==0, then to processor; if hop[0] != 0, then hop[7:0] shifts right and to the directed buffer
assign wire hop_cw_in[7:0] = cwdi[55:48];
assign wire hop_ccw_in[7:0] = ccwdi[55:48];
assign wire hop_pe_in[7:0] = pedi [55:48];

//Source Value: Needed for Future Assignment. Will Modify Functionality in Phase 2
assign wire source_cw_in[15:0] = cwdi[47:32];
assign wire source_ccw_in[15:0] = ccwdi[47:32];
assign wire source_pe_in[15:0] = pedi[47:32];

//------------------------------------------------------------------------------------------------------------------------
//Minimal Routing Logic
reg [63:0]updated_pedi;
reg dump_packet;

always @(*) begin
	if (hop_pe_in [7:0] == 0000_0011); begin//if 	 There are 2 hops
		updated_pedi = {pedi[63],1'b0,pedi[61:0]};
		dump_packet = 0	end//All turn to clockwise
	else if (hop_pei_in [7:0] == 0000_0011); begin
		updated_pedi = {pedi[63],~pedi[62],pedi[61:51], 1'b0, 1'b0, pedi[48:0]}; 
		dump_packet = 0 end
	else 
		dump_packet = 1;
end
//------------------------------------------------------------------------------------------------------------------------
//Input Buffer Read Enable, Full/Empty Status
reg cw_even_input_wen;
reg cw_odd_input_wen;
reg cww_even_input_wen;
reg cww_odd_input_wen;
reg pe_even_input_wen;
reg pe_odd_input_wen;

reg cw_even_input_ren;
reg cw_odd_input_ren;
reg cww_even_input_ren;
reg cww_odd_input_ren;
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
    .re(cw_odd_input_ren),
    .we(cw_odd_input_wen),
    .data_in(cwdi),
    .data_out(cw_input_buffer_odd)
);

buffer cw_even_input (
    .clk(clk),
    .reset(reset),
    .full(cw_even_input_full),
    .empty(cw_even_input_empty),
    .re(cw_even_input_ren),
    .we(cw_even_input_wen),
    .data_in(cwdi),
    .data_out(cw_input_buffer_even)
);

buffer ccw_odd_input (
    .clk(clk),
    .reset(reset),
    .full(ccw_odd_input_full),
    .empty(ccw_odd_input_empty),
    .re(ccw_odd_input_ren),
    .we(ccw_odd_input_wen),
    .data_in(ccwdi),
    .data_out(ccw_input_buffer_odd)
);

buffer ccw_even_input (
    .clk(clk),
    .reset(reset),
    .full(ccw_even_input_full),
    .empty(ccw_even_input_empty),
    .re(ccw_even_input_ren),
    .we(ccw_even_input_wen),
    .data_in(ccwdi),
    .data_out(ccw_input_buffer_even)
);

buffer pe_odd_input (
    .clk(clk),
    .reset(reset),
    .full(pe_odd_input_full),
    .empty(pe_odd_input_empty),
    .re(pe_odd_input_ren),
    .we(pe_odd_input_wen),
    .data_in(peddi),
    .data_out(pe_input_buffer_odd)
);

buffer pe_even_input (
    .clk(clk),
    .reset(reset),
    .full(pe_even_input_full),
    .empty(pe_even_input_empty),
    .re(pe_even_input_ren),
    .we(pe_even_input_wen),
    .data_in(peddi),
    .data_out(pe_input_buffer_even)
);


//------------------------------------------------------------------
//Ready Write For Input Buffers Combinational Logic 
// Input Buffer empty status sent to sender router

always @(*) begin
if (polarity) begin
	if (cw_odd_input_empty) begin
		cwri = 1; end
	else begin
		cwri = 0; end
	if (cww_odd_input_empty) begin
		cwwri = 1; end
	else begin
		cwwri = 0; end
	if (pe_odd_input_empty && (dump_packet==0)) begin
		peri = 1; end
	else begin
		peri = 0; end
end
else begin
	if (cw_even_input_empty) begin
		cwri = 1; end
	else begin
		cwri = 0; end
	if (cww_even_input_empty) begin
		cwwri = 1; end
	else begin
		cwwri = 0; end
	if (pe_even_input_empty $$(dump_packet==0)) begin
		peri = 1; end
	else begin
		peri = 0; end
end
end
//-------------------------------------------------------------------
//Input Buffer Write Enables that allows the buffer to write


always @(*) begin
    if (polarity == 0) begin
        cw_odd_input_wen = 0;
        cww_odd_input_wen = 0;
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

        if (pesi && peri ) begin
            pe_even_input_wen = 1;
        end
        else begin
            pe_even_input_wen = 0;
        end
    end
    else begin
        cw_even_input_wen = 0;
        cww_even_input_wen = 0;
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

        if (pesi && peri) begin
            pe_odd_input_wen = 1;
        end
        else begin
            pe_odd_input_wen = 0;
        end
    end
end

//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------------
//Output Buffer Read Enables, and empty/full status
reg cw_even_output_ren;
reg cw_odd_output_ren;
reg cww_even_output_ren;
reg cww_odd_output_ren;
reg pe_even_output_ren;
reg pe_odd_output_ren;

reg cw_even_output_wen;
reg cw_odd_output_wen;
reg cww_even_output_wen;
reg cww_odd_output_wen;
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

wire [63:0] cw_output_buffer_odd;
wire [63:0] cw_output_buffer_even;
wire [63:0] ccw_output_buffer_odd;
wire [63:0] ccw_output_buffer_even;
wire [63:0] pe_output_buffer_odd;
wire [63:0] pe_output_buffer_even;
//Below are 6 Output Buffer Instantiations (3 Odd, 3 Evens) 
//For Example：cwin_output_buffer_even is the 64 bit data that has gone through hop value update between Input and OUtput buffer.
buffer cw_odd_output (
    .clk(clk),
    .reset(reset),
    .full(cw_odd_output_full),
    .empty(cw_odd_output_empty),
    .re(cw_odd_output_ren),
    .we(cw_odd_output_wen),
    .data_in(cwin_output_buffer_odd),
    .data_out(cw_output_buffer_odd)
);

buffer cw_even_output (
    .clk(clk),
    .reset(reset),
    .full(cw_even_output_full),
    .empty(cw_even_output_empty),
    .re(cw_even_output_ren),
    .we(cw_even_output_wen),
    .data_in(cwin_output_buffer_even),
    .data_out(cw_output_buffer_even)
);

buffer ccw_odd_output (
    .clk(clk),
    .reset(reset),
    .full(ccw_odd_output_full),
    .empty(ccw_odd_output_empty),
    .re(ccw_odd_output_ren),
    .we(ccw_odd_output_wen),
    .data_in(ccwin_output_buffer_odd),
    .data_out(ccw_output_buffer_odd)
);

buffer ccw_even_output (
    .clk(clk),
    .reset(reset),
    .full(ccw_even_output_full),
    .empty(ccw_even_output_empty),
    .re(ccw_even_output_ren),
    .we(ccw_even_output_wen),
    .data_in(ccwin_output_buffer_even),
    .data_out(ccw_output_buffer_even)
);

buffer pe_odd_output (
    .clk(clk),
    .reset(reset),
    .full(pe_odd_output_full),
    .empty(pe_odd_output_empty),
    .re(pe_odd_output_ren),
    .we(pe_odd_output_wen),
    .data_in(pein_output_buffer_odd),
    .data_out(pe_output_buffer_odd)
);

buffer pe_even_output (
    .clk(clk),
    .reset(reset),
    .full(pe_even_output_full),
    .empty(pe_even_output_empty),
    .re(pe_even_output_ren),
    .we(pe_even_output_wen),
    .data_in(pein_output_buffer_even),
    .data_out(pe_output_buffer_even)
);
//--------------------------------------------------------------------------------------------------------------------
//Input Buffer --> Output Buffer Request Logic
//If Input Buffer is full, Output Buffer is empty, and depending on the Hop value, whether the data continues to the 
//next direction buffer or goes to processor buffer
//If last bit of Hop value is 1, then data goes to directed buffer
//If last bit of Hop value is 0, then data goes to processor buffer
reg cwin_request_cwout_even;
reg cwin_request_peout_even;
reg ccwin_request_ccwo_even;
reg ccwin_request_peout_even;
reg pein_request_cwout_even;
reg pein_request_ccwout_even;

reg cwin_request_cwout_odd;
reg cwin_request_peout_odd;
reg ccwin_request_ccwo_odd;
reg ccwin_request_peout_odd;
reg pein_request_cwout_odd;
reg pein_request_ccwout_odd;

always @(*) begin
if (polarity) begin
	if (cw_even_input_full && (cw_input_buffer_even[48]==1) && cw_even_output_empty ) begin //cw to cw
	cwin_request_cwout_even = 1; end
	else begin
	cwin_request_cwout_even = 0; end
	
	if (cw_even_input_full && (cw_input_buffer_even[48]==0) && pe_even_output_empty ) begin //cw to pe
	cwin_request_peout_even = 1;end
	else begin
	cwin_request_peout_even = 0;end
	
	if (ccw_even_input_full && (ccw_input_buffer_even[48]==1) && ccw_even_output_empty ) begin //ccw to ccw
	ccwin_request_cwout_even = 1; end
	else begin
	ccwin_request_cwout_even = 0; end
	
	if (ccw_even_input_full && (ccw_input_buffer_even[48]==0) && pe_even_output_empty ) begin //ccw to pe
	ccwin_request_peout_even = 1;end
	else begin
	ccwin_request_peout_even = 0;end
	
	if (pe_even_input_full && (pe_input_buffer_even[48]==1) && cw_even_output_empty ) begin //pe to cw
	pein_request_cwout_even = 1; end
	else begin
	pein_request_cwout_even = 0; end

	if (pe_even_input_full && (pe_input_buffer_even[48]==0) && ccw_even_output_empty ) begin //pe to ccw
	pein_request_ccwout_even = 1;end
	else begin
	pein_request_ccwout_evem = 0;end
end
else begin
	if (cw_odd_input_full && (cw_input_buffer_odd[48] == 1) && cw_odd_output_empty ) begin // cw to cw
    	cwin_request_cwout_odd = 1; end
	else begin
    	cwin_request_cwout_odd = 0; end

	if (cw_odd_input_full && (cw_input_buffer_odd[48] == 0) && pe_odd_output_empty ) begin // cw to pe
  	cwin_request_peout_odd = 1; end
	else begin
    	cwin_request_peout_odd = 0; end

	if (ccw_odd_input_full && (ccw_input_buffer_odd[48] == 1) && ccw_odd_output_empty ) begin // ccw to ccw
   	ccwin_request_cwout_odd = 1; end
	else begin
   	ccwin_request_cwout_odd = 0; end

	if (ccw_odd_input_full && (ccw_input_buffer_odd[48] == 0) && pe_odd_output_empty ) begin // ccw to pe
  	ccwin_request_peout_odd = 1; end
	else begin
    	ccwin_request_peout_odd = 0; end

	if (pe_odd_input_full && (pe_input_buffer_odd[48] == 1) && cw_odd_output_empty ) begin // pe to cw
    	pein_request_cwout_odd = 1; end
	else begin
    	pein_request_cwout_odd = 0; end

	if (pe_odd_input_full && (pe_input_buffer_odd[48] == 0) && ccw_odd_output_empty ) begin // pe to ccw
	pein_request_ccwout_odd = 1; end
	else begin
    	pein_request_ccwout_odd = 0; end
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

arbitor cw_arbitor_even (
    .clk(clk),
    .reset(reset),
    .rq0(cwin_request_cwout_even),
    .rq1(cwin_request_peout_even),
    .gt0(cwin_grant_cwout_even),
    .gt1(cwin_grant_peout_even)
);

arbitor ccw_arbitor_even (
    .clk(clk),
    .reset(reset),
    .rq0(ccwin_request_ccwout_even),
    .rq1(ccwin_request_peout_even),
    .gt0(ccwin_grant_ccwout_even),
    .gt1(ccwin_grant_peout_even)
);

arbitor pe_arbitor_even(
    .clk(clk),
    .reset(reset),
    .rq0(pein_request_cwout_even),
    .rq1(pein_request_ccwout_even),
    .gt0(pein_grant_cwout_even),
    .gt1(pein_grant_ccwout_even)
);

arbitor cw_arbitor_odd (
    .clk(clk),
    .reset(reset),
    .rq0(cwin_request_cwout_odd),
    .rq1(cwin_request_peout_odd),
    .gt0(cwin_grant_cwout_odd),
    .gt1(cwin_grant_peout_odd)
);

arbitor ccw_arbitor_odd (
    .clk(clk),
    .reset(reset),
    .rq0(ccwin_request_ccwout_odd),
    .rq1(ccwin_request_peout_odd),
    .gt0(ccwin_grant_ccwout_odd),
    .gt1(ccwin_grant_peout_odd)
);

arbitor pe_arbitor_odd (
    .clk(clk),
    .reset(reset),
    .rq0(pein_request_cwout_odd),
    .rq1(pein_request_ccwout_odd),
    .gt0(pein_grant_cwout_odd),
    .gt1(pein_grant_ccwout_odd)
);

//--------------------------------------------------------------------------------------------------------------------
//With Grant from arbitor, input buffer transfers data to output buffer


reg cwin_output_buffer_even[63:0];
reg ccwin_output_buffer_even[63:0];
reg pein_output_buffer_even[63:0];
reg cwin_output_buffer_odd[63:0];
reg ccwin_output_buffer_odd[63:0];
reg pein_output_buffer_odd[63:0];

always @(*) begin
if (polarity) begin
	if (cwin_grant_cwout) begin
	cw_even_input_ren = 1;
	cw_even_output_wen = 1;
	cwin_output_buffer_even[55:48] = cw_input_buffer_even[55:48] >> 1;
	cwin_output_buffer_even[63:56] = cw_input_buffer_even[63:56];
	cwin_output_buffer_even[47:0] = cw_input_buffer_even[47:0];end
	else begin
	cw_even_input_ren = 0;
    	cw_even_output_wen = 0;
	cwin_output_buffer_even = cwin_output_buffer_even;end
		
	if (cwin_grant_peout) begin
	cw_even_input_ren = 1;
	pe_even_output_wen = 1;
	pein_output_buffer_even[55:48] = cw_input_buffer_even[55:48] >> 1;
	pein_output_buffer_even[63:56] = cw_input_buffer_even[63:56];
	pein_output_buffer_even[47:0] = cw_input_buffer_even[47:0];end
	else begin
	cw_even_input_ren = 0;
    	pe_even_output_wen = 0;
	pein_output_buffer_even = pein_output_buffer_even;end

	if (ccwin_grant_ccwout) begin
	ccw_even_input_ren = 1;
	ccw_even_output_wen = 1;
	ccwin_output_buffer_even[55:48] = ccw_input_buffer_even[55:48] >> 1;
	ccwin_output_buffer_even[63:56] = ccw_input_buffer_even[63:56];
	ccwin_output_buffer_even[47:0] = ccw_input_buffer_even[47:0];end
	else begin
	ccw_even_input_ren = 0;
    	ccw_even_output_wen = 0;
	ccwin_output_buffer_even = ccwin_output_buffer_even;end
		
	if (cwin_grant_peout) begin
	cw_even_input_ren = 1;
	pe_even_output_wen = 1;
	pein_output_buffer_even[55:48] = ccw_input_buffer_even[55:48] >> 1;
	pein_output_buffer_even[63:56] = ccw_input_buffer_even[63:56];
	pein_output_buffer_even[47:0] = ccw_input_buffer_even[47:0];end
	else begin
	cw_even_input_ren = 0;
    	pe_even_output_wen = 0;
	cwin_output_buffer_even = cwin_output_buffer_even;end

	if (pein_grant_cwout) begin
	pe_even_input_ren = 1;
	cw_even_output_wen = 1;
	cwin_output_buffer_even[55:48] = pe_input_buffer_even[55:48] >> 1;
	cwin_output_buffer_even[63:56] = pe_input_buffer_even[63:56];
	cwin_output_buffer_even[47:0] = pe_input_buffer_even[47:0];end
	else begin
	pe_even_input_ren = 0;
    	cw_even_output_wen = 0;
	cwin_output_buffer_even = cwin_output_buffer_even;end
		
	if (pein_grant_ccwout) begin
	pe_even_input_ren = 1;
	ccw_even_output_wen = 1;
	ccwin_output_buffer_even[55:48] = pe_input_buffer_even[55:48] >> 1;
	ccwwin_output_buffer_even[63:56] = pe_input_buffer_even[63:56];
	ccwin_output_buffer_even[47:0] = pe_input_buffer_even[47:0];end	
	else begin
	pe_even_input_ren = 0;
    	ccw_even_output_wen = 0;
	ccwin_output_buffer_even = ccwin_output_buffer_even;end
end
else begin
	if (cwin_grant_cwout) begin
    	cw_odd_input_ren = 1;
    	cw_odd_output_wen = 1;
    	cwin_output_buffer_odd[55:48] = cw_input_buffer_odd[55:48] >> 1	
	cwin_output_buffer_odd[63:56] = cw_input_buffer_odd[63:56];
    	cwin_output_buffer_odd[47:0] = cw_input_buffer_odd[47:0];end
	else begin
	cw_odd_input_ren = 0;
    	cw_odd_output_wen = 0;
	cwin_output_buffer_odd = cwin_output_buffer_odd;end
	

    	if (cwin_grant_peout) begin
        cw_odd_input_ren = 1;
        pe_odd_output_wen = 1;
        pein_output_buffer_odd[55:48] = cw_input_buffer_odd[55:48] >> 1;
        pein_output_buffer_odd[63:56] = cw_input_buffer_odd[63:56];
        pein_output_buffer_odd[47:0] = cw_input_buffer_odd[47:0];
    	end
	else begin
	cw_odd_input_ren = 0;
    	pe_odd_output_wen = 0;
	pein_output_buffer_odd = pein_output_buffer_odd;end

    	if (ccwin_grant_ccwout) begin
        ccw_odd_input_ren = 1;
        ccw_odd_output_wen = 1;
        ccwin_output_buffer_odd[55:48] = ccw_input_buffer_odd[55:48] >> 1;
        ccwin_output_buffer_odd[63:56] = ccw_input_buffer_odd[63:56];
        ccwin_output_buffer_odd[47:0] = ccw_input_buffer_odd[47:0];end
	else begin
	ccw_odd_input_ren = 0;
    	ccw_odd_output_wen = 0;
	ccwin_output_buffer_odd = ccwin_output_buffer_odd;end

        if (ccwin_grant_peout) begin
        ccw_odd_input_ren = 1;
        pe_odd_output_wen = 1;
        pein_output_buffer_odd[55:48] = ccw_input_buffer_odd[55:48] >> 1;
        pein_output_buffer_odd[63:56] = ccw_input_buffer_odd[63:56];
        pein_output_buffer_odd[47:0] = ccw_input_buffer_odd[47:0];
        end
		else begin
		ccw_odd_input_ren = 0;
    	pe_odd_output_wen = 0;
		pein_output_buffer_odd = pein_output_buffer_odd;end

        if (pein_grant_cwout) begin
        pe_odd_input_ren = 1;
        cw_odd_output_wen = 1;
        cwin_output_buffer_odd[55:48] = pe_input_buffer_odd[55:48] >> 1;
        cwin_output_buffer_odd[63:56] = pe_input_buffer_odd[63:56];
        cwin_output_buffer_odd[47:0] = pe_input_buffer_odd[47:0];end
	else begin
	pe_odd_input_ren = 0;
    	cw_odd_output_wen = 0;
	cwin_output_buffer_odd = cwin_output_buffer_odd;end

        if (pein_grant_ccwout) begin
        pe_odd_input_ren = 1;
        ccw_odd_output_wen = 1;
        ccwin_output_buffer_odd[55:48] = pe_input_buffer_odd[55:48] >> 1;
        ccwin_output_buffer_odd[63:56] = pe_input_buffer_odd[63:56];
        ccwin_output_buffer_odd[47:0] = pe_input_buffer_odd[47:0];
        end
	else begin
	pe_odd_input_ren = 0;
    	ccw_odd_output_wen = 0;
	ccwin_output_buffer_odd = ccwin_output_buffer_odd;end
end

end
//--------------------------------------------------------------------------------------------------------------------
  // Polarity 
always @ (posedge clk) begin
if (reset) begin
polarity <= 1'b0;
//Input Buffer Read and Write Enables
cw_even_input_wen = 0;
cw_odd_input_wen = 0;
cww_even_input_wen = 0;
cww_odd_input_wen = 0;
pe_even_input_wen = 0;
pe_odd_input_wen = 0;
cw_even_input_ren = 0;
cw_odd_input_ren = 0;
cww_even_input_ren = 0;
cww_odd_input_ren = 0;
pe_even_input_ren = 0;
pe_odd_input_ren = 0;
//Output Buffer Read and Write Enable
cw_even_output_ren = 0;
cw_odd_output_ren = 0;
cww_even_output_ren = 0;
cww_odd_output_ren = 0;
pe_even_output_ren = 0;
pe_odd_output_ren = 0;
cw_even_output_wen = 0;
cw_odd_output_wen = 0;
cww_even_output_wen = 0;
cww_odd_output_wen = 0;
pe_even_output_wen = 0;
pe_odd_output_wen = 0;
//xxin_output_buffer_even: Hop Value Updated Packet
//Hop Value Updated Packet
cwin_output_buffer_even[63:0] = 0;
ccwin_output_buffer_even[63:0] = 0;
pein_output_buffer_even[63:0] = 0;
cwin_output_buffer_odd[63:0] = 0;
ccwin_output_buffer_odd[63:0] = 0;
pein_output_buffer_odd[63:0] = 0;
//Requests for Arbitor
cwin_request_cwout_even = 0;
cwin_request_peout_even = 0;
ccwin_request_ccwo_even = 0;
ccwin_request_peout_even = 0;
pein_request_cwout_even = 0;
pein_request_ccwout_even = 0;
cwin_request_cwout_odd = 0;
cwin_request_peout_odd = 0;
ccwin_request_ccwo_odd = 0;
ccwin_request_peout_odd = 0;
pein_request_cwout_odd = 0;
pein_request_ccwout_odd = 0;




 end // Even cycle during reset
    else begin
	polarity <= ~polarity; // Toggle the polarity
    end
  end



endmodule

