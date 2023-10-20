module CardinalRouter (clk, reset, cwdi, cwsi, cwri, ccwdi, 
ccwsi, ccwri, pedi, pesi, peri, cwdo, cwso, cwro, ccwdo, ccwso, ccwro, pedo, peso, pero);

input wire clk;
input wire reset;
output reg polarity;

//Clockwise Input Buffer/Virtual Channels
input wire [63:0] cwdi;
input wire cwsi;
output reg cwri;
reg [63:0] cw_input_buffer_odd;
reg [63:0] cw_input_buffer_even;

//CounterClockwise Input Buffer/Virtual Channels
input wire [63:0] ccwdi;
input wire ccwsi;
output reg ccwri;
reg [63:0] ccw_input_buffer_odd;
reg [63:0] ccw_input_buffer_even;

//Processor Input Buffer/Virtual Channels
input wire [63:0] pedi;
input wire pesi;
output reg oeri;
reg [63:0] pe_input_buffer_odd;
reg [63:0] pe_input_buffer_even;

//Clockwise Output Buffer/Virtual Channels
output reg [63:0] cwdo;
output reg cwso;
input wire cwro;
reg [63:0] cw_output_buffer_odd;
reg [63:0] cw_output_buffer_even;

//CounterClockwise Output Buffer/Virtual Channels
output reg [63:0] ccwdo;
output reg ccwso;
input wire ccwro;
reg [63:0] ccw_output_buffer_odd;
reg [63:0] ccw_output_buffer_even;
	
//Processor Output Buffer/Virtual Channels
output reg [63:0] pedo;
output reg peso;
input wire pero;
reg [63:0] pe_output_buffer_odd;
reg [63:0] pe_output_buffer_even;

//Direction:Needed for Switching from Input to Output Buffer
	//Need to check Hop as well
assign wire dir_cw_odd = cw_input_buffer_odd[30];
assign wire dir_cw_even = cw_input_buffer_even[30];
assign wire dir_ccw_odd = ccw_input_buffer_odd[30];
assign wire dir_ccw_even = ccw_input_buffer_even[30];
assign wire dir_pe_odd[7:0] = pe_input_buffer_odd [30];
assign wire dir_pe_even[7:0] = pe_input_buffer_even [30];

//Hop Cycles:Needed for deciding whether to send to the appointed direction or to the processor output buffer
	//if hop[0]==0, then to processor; if hop[0] != 0, then hop[7:0] shifts right and to the directed buffer
assign wire hop_cw_odd[7:0] = cw_input_buffer_odd[25:18];
assign wire hop_cw_even[7:0] = cw_input_buffer_even[25:18];	
assign wire hop_ccw_odd[7:0] = ccw_input_buffer_odd[25:18];
assign wire hop_ccw_even[7:0] = ccw_input_buffer_even[25:18];
assign wire hop_pe_odd[7:0] = pe_input_buffer_odd [25:18];
assign wire hop_pe_even[7:0] = pe_input_buffer_even [25:18];


//wire [7:0] hop;
//assign hop = packet[25:18];
// Signals to track the state of the router
reg [1:0] cw_requestor;
reg [1:0] ccw_requestor;
reg pe_requestor;
reg cw_granted;
reg ccw_granted;
reg pe_granted;
reg [1:0] cw_priority;
reg [1:0] ccw_priority;
reg pe_priority;


// Buffer full/empty status
  wire cw_input_empty = (cw_requestor == 0);
  wire ccw_input_empty = (ccw_requestor == 0);
  wire pe_input_empty = (pe_requestor == 0);
  wire cw_output_empty = (cw_granted == 0);
  wire ccw_output_empty = (ccw_granted == 0);
  wire pe_output_empty = (pe_granted == 0);

assign wire cw_even_wen = cwri & polarity;
assign wire cw_odd_wen = cwri & ~polarity;
assign wire cww_even_wen = cwwri & polarity;
assign wire cww_odd_wen = cwwri & ~polarity;
assign wire pe_even_wen = peri & polarity;
assign wire pe_odd_wen = peri & ~polarity;
//Input Buffer Instantiation
buffer cw_odd_in(clk, reset, cw_odd_wen, ,cwdi[63:0], cw_input_empty, ~cw_input_empty, cw_input_buffer_odd[63:0]); 
buffer cw_even_in(clk, reset, cw_eveb_wen, ,cwdi[63:0], ~cw_input_empty, cw_input_empty, cw_input_buffer_even[63:0]);
buffer ccw_odd_in(clk, reset, ccw_odd_wen, ,ccwdi[63:0], ccw_input_empty, ~ccw_input_empty, ccw_input_buffer_odd[63:0]);
buffer ccw_even_in(clk, reset, ccw_even_wen, ,ccwdi[63:0], ~ccw_input_empty, ccw_input_empty, ccw_input_buffer_even[63:0]);
buffer pe_odd_in(clk, reset, pe_odd_wen, ,pedi[63:0], pe_input_empty, ~pe_input_empty, pe_input_buffer_odd[63:0]);
buffer pe_even_in(clk, reset, pe_odd_wen, ,pedi[63:0], ~pe_input_empty, pe_input_empty, pe_input_buffer_odd[63:0]);

//Output Buffer Instantiation

// Routing logic
always @ (posedge clk or posedge reset) begin
	if (reset) begin
	cwdo = 0;
	cwso = 0;
	ccwdo = 0;
	ccwso = 0;
	pedo = 0;
	
      // Reset the router's state
      //cw_requestor <= 2'b00;
     // ccw_requestor <= 2'b00;
    // pe_requestor <= 0;
     // cw_granted <= 0;
      //ccw_granted <= 0;
     // pe_granted <= 0;
     // cw_priority <= 2'b01;
    //  ccw_priority <= 2'b01;
     // pe_priority <= 1'b1; 
	end 
	else begin
		if (cwdi[63:0] == 0) begin
		cwri <= 1;
		else if (ccwsi [63:0] == 0) begin
      // Handle input requests and grant access
      	

      // Handle output requests and grant access
      // ...
    end
  end

  // Additional logic for data forwarding, header updates, and polarity tracking
  // ...
//Input Ready Combinational Logic
always @(*) begin
end

		
always @(posedge clk) begin
        if (reset) begin
            mem <= 'b0;
            flag <= 1'b0;
//Clockwise Input Buffer
if (cwsi && cwri) begin
	
	if (polarity) begin
		cw_input_buffer_even[63:0] = cwdi[63:0]; end
	else begin
		cw_input_buffer_odd[63:0] = cwdi[63:0];

end
// Combinational Logic for Routing
always @(*)

	if (polarity) begin
		if (cwsi && cwri) begin
			
//Clock-Wise Check


  // Polarity 
  always @ (posedge clk or posedge reset) begin
    if (reset) begin
	polarity <= 1'b0; end // Even cycle during reset
    else begin
	polarity <= ~polarity; // Toggle the polarity
    end
  end
endmodule

