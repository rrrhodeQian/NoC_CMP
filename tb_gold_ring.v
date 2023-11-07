module tb_gold_ring;
reg clk;
reg reset;
wire polarity;
//Node 0
wire peri_node0;
reg pesi_node0;
reg pero_node0;
wire peso_node0;
wire [63:0] pedi_node0;
wire [63:0] pedo_node0;
//Node 1
wire peri_node1;
reg pesi_node1;
reg pero_node1;
wire peso_node1;
wire [63:0] pedi_node1;
wire [63:0] pedo_node1;
//Node 2
wire peri_node2;
reg pesi_node2;
reg pero_node2;
wire peso_node2;
wire [63:0] pedi_node2;
wire [63:0] pedo_node2;
//Node 3
wire peri_node3;
reg pesi_node3;
reg pero_node3;
wire peso_node3;
wire [63:0] pedi_node3;
wire [63:0] pedo_node3;
//------------------------------------------------------------------------------------------
//Clock Generation
always #2 clk = ~clk;
reg [63:0] time_keep;
always @(posedge clk) begin
time_keep <= time_keep + 1;
end
//------------------------------------------------------------------------------------------
//VC bit, Direction bit, Hop bit, Reserved_bit for inputs of pe buffers for all four Nodes
wire [5:0] pe_reserve;
assign pe_reserve = 6'b0;
//Pein
reg pedi_dir_node0, pedi_dir_node1, pedi_dir_node2, pedi_dir_node3;
reg pedi_vc_node0, pedi_vc_node1, pedi_vc_node2, pedi_vc_node3;
reg[7:0]pedi_hop_node0, pedi_hop_node1, pedi_hop_node2, pedi_hop_node3;
reg[15:0] pedi_source_node0,pedi_source_node1,pedi_source_node2,pedi_source_node3;
reg[31:0] pedi_payload_node0,pedi_payload_node1,pedi_payload_node2,pedi_payload_node3;
assign pedi_node0 = {pedi_vc_node0, pedi_dir_node0, pe_reserve, pedi_hop_node0, pedi_source_node0, pedi_payload_node0};
assign pedi_node1 = {pedi_vc_node1, pedi_dir_node1, pe_reserve, pedi_hop_node1, pedi_source_node1, pedi_payload_node1};
assign pedi_node2 = {pedi_vc_node2, pedi_dir_node2, pe_reserve, pedi_hop_node2, pedi_source_node2, pedi_payload_node2};
assign pedi_node3 = {pedi_vc_node3, pedi_dir_node3, pe_reserve, pedi_hop_node3, pedi_source_node3, pedi_payload_node3};
//Peout 
wire pedo_dir_node0, pedo_dir_node1, pedo_dir_node2, pedo_dir_node3;
wire pedo_vc_node0, pedo_vc_node1, pedo_vc_node2, pedo_vc_node3;
wire [7:0] pedo_hop_node0, pedo_hop_node1, pedo_hop_node2, pedo_hop_node3;
wire [15:0] pedo_source_node0, pedo_source_node1, pedo_source_node2, pedo_source_node3;
wire [31:0] pedo_payload_node0, pedo_payload_node1, pedo_payload_node2, pedo_payload_node3;
assign pedo_dir_node0 = pedo_node0[62];
assign pedo_vc_node0 = pedo_node0[63];
assign pedo_hop_node0[7:0] = pedo_node0[55:48];
assign pedo_source_node0[15:0] = pedo_node0[47:32];
assign pedo_payload_node0[31:0] = pedo_node0[31:0];
assign pedo_dir_node1 = pedo_node1[62];
assign pedo_vc_node1 = pedo_node1[63];
assign pedo_hop_node1[7:0] = pedo_node1[55:48];
assign pedo_source_node1[15:0] = pedo_node1[47:32];
assign pedo_payload_node1[31:0] = pedo_node1[31:0];
assign pedo_dir_node2 = pedo_node2[62];
assign pedo_vc_node2 = pedo_node2[63];
assign pedo_hop_node2[7:0] = pedo_node2[55:48];
assign pedo_source_node2[15:0] = pedo_node2[47:32];
assign pedo_payload_node2[31:0] = pedo_node2[31:0];
assign pedo_dir_node3 = pedo_node3[62];
assign pedo_vc_node3 = pedo_node3[63];
assign pedo_hop_node3[7:0] = pedo_node3[55:48];
assign pedo_source_node3[15:0] = pedo_node3[47:32];
assign pedo_payload_node3[31:0] = pedo_node3[31:0];


//assign pedo_node0 = {pedo_vc_node0, pedo_dir_node0, pe_reserve, pedo_hop_node0, pedo_source_node0, pedo_payload_node0};
//assign pedo_node1 = {pedo_vc_node1, pedo_dir_node1, pe_reserve, pedo_hop_node1, pedo_source_node1, pedo_payload_node1};
//assign pedo_node2 = {pedo_vc_node2, pedo_dir_node2, pe_reserve, pedo_hop_node2, pedo_source_node2, pedo_payload_node2};
//assign pedo_node3 = {pedo_vc_node3, pedo_dir_node3, pe_reserve, pedo_hop_node3, pedo_source_node3, pedo_payload_node3};
//------------------------------------------------------------------------------------------
//Open files for gather phases and start-end-time 

//------------------------------------------------------------------------------------------
// Instantiate Gold_Ring
gold_ring ring(
.clk(clk),
.reset(reset),
.polarity(polarity),
// Node 0
.peri_node0(peri_node0),
.pesi_node0(pesi_node0),
.pedi_node0(pedi_node0),
.pero_node0(pero_node0),
.peso_node0(peso_node0),
.pedo_node0(pedo_node0),
// Node 1
.peri_node1(peri_node1),
.pesi_node1(pesi_node1),
.pedi_node1(pedi_node1),
.pero_node1(pero_node1),
.peso_node1(peso_node1),
.pedo_node1(pedo_node1),
// Node 2
.peri_node2(peri_node2),
.pesi_node2(pesi_node2),
.pedi_node2(pedi_node2),
.pero_node2(pero_node2),
.peso_node2(peso_node2),
.pedo_node2(pedo_node2),
// Node 3
.peri_node3(peri_node3),
.pesi_node3(pesi_node3),
.pedi_node3(pedi_node3),
.pero_node3(pero_node3),
.peso_node3(peso_node3),
.pedo_node3(pedo_node3)
);
//--------------------------------------------------------------------
//Below are tasks for packet sending of the "gather" mechanism of the test during each phase
localparam phase0 = 2'b00;
localparam phase1 = 2'b01;
localparam phase2 = 2'b10;
localparam phase3 = 2'b11;
reg finish_send;

task packet_send;
input [1:0] phase;
begin
//Even Polarity: Node 0 and 1 inject
//Odd Polarity: Node 2 and 3 inject
//Node 0
pedi_vc_node0 = 0;
pedi_source_node0=0;
pedi_vc_node1 = 0;
pedi_source_node1=1;
pedi_vc_node2 = 0;
pedi_source_node2=2;
pedi_vc_node3 = 0;
pedi_source_node3=3;
pesi_node0 = 1;
pesi_node1 = 1;
pesi_node2 = 1;
pesi_node3 = 1;

case (phase)
phase0: begin
pesi_node0 = 1;
pedi_dir_node1 = 1;
pedi_hop_node1 = 8'b0000_0001;
pedi_payload_node1 = 1;
#4
pedi_dir_node2 = 0;
pedi_hop_node2 = 8'b0000_0011;
pedi_payload_node2 = 0;
pedi_dir_node3 = 0;
pedi_hop_node3 = 8'b0000_0001;
pedi_payload_node3 = 0;
pesi_node2 = 1;
pesi_node3 = 1;
pesi_node1 = 0;
#4
pesi_node2 = 0;
pesi_node3 = 0;
end

phase1: begin
pesi_node0 = 1;
pedi_dir_node0 = 0;
pedi_hop_node0 = 8'b0000_0001;
pedi_payload_node0 = 1;
#4
pedi_dir_node2 = 1;
pedi_hop_node2 = 8'b0000_0001;
pedi_payload_node2 = 1;
pedi_dir_node3 = 0;
pedi_hop_node3 = 8'b0000_0011;
pedi_payload_node3 = 1;
pesi_node2 = 1;
pesi_node3 = 1;
pesi_node0 = 0;
#4
pesi_node2 = 0;
pesi_node3 = 0;
end

phase2: begin
pesi_node1 = 1;
pesi_node0 = 1;
pedi_dir_node0 = 0;
pedi_hop_node0 = 8'b0000_0011;
pedi_payload_node0 = 2;
pedi_dir_node1 = 0;
pedi_hop_node1 = 8'b0000_0001;
pedi_payload_node1 = 2;
#4
pedi_dir_node3 = 1;
pedi_hop_node3 = 8'b0000_0001;
pedi_payload_node3 = 2;
pesi_node3 = 1;
pesi_node1 = 0;
pesi_node0 = 0;
#4
pesi_node3 = 0;
end

phase3: begin
pesi_node1 = 1;
pesi_node0 = 1;
pedi_dir_node0 = 1;//To see if Minimal Router functions
pedi_hop_node0 = 8'b0000_0001;
pedi_payload_node0 = 3;
pedi_dir_node1 = 0;
pedi_hop_node1 = 8'b0000_0011;
pedi_payload_node1 = 3;
#4
pedi_dir_node2 = 0;
pedi_hop_node2 = 8'b0000_0001;
pedi_payload_node2 = 3;
pesi_node2 = 1;
pesi_node1 = 0;
pesi_node0 = 0;
#4
pesi_node2 = 0;
end

default: begin
end

endcase



end
endtask

//-------------------------------------------------------------------------------------------------------------------------
always @(posedge clk) begin
if (reset == 0) begin
if (peso_node0)
$fdisplay(gather0, "Phase=%d , Time=%d , Destination=%b , Source=%b , Packet Value=%b", 0, time_keep, pedo_vc_node0,  pedo_source_node0, pedo_node0);

if (peso_node1) 
$fdisplay(gather1, "Phase=%d , Time=%d , Destination=%b , Source=%b , Packet Value=%b", 1, time_keep, pedo_vc_node1,  pedo_source_node1, pedo_node1);

if (peso_node2) 
$fdisplay(gather2, "Phase=%d , Time=%d , Destination=%b , Source=%b , Packet Value=%b", 2, time_keep, pedo_vc_node2,  pedo_source_node2, pedo_node2);

if (peso_node3) 
$fdisplay(gather3, "Phase=%d , Time=%d , Destination=%b , Source=%b , Packet Value=%b", 3, time_keep, pedo_vc_node3,  pedo_source_node3, pedo_node3);

end
end
//-------------------------------------------------------------------------------------------------------------------------
//Begin Test
//Test_Number:Total of 4 gather tests
//Phase_Number: Total of 4 phases in each test
//2 for loops to be used to run the test
integer test_number;
integer phase_number;
integer gather0, gather1, gather2, gather3, start_end_time;

initial begin
gather0 = $fopen("gather_phase0.out", "w");
gather1 = $fopen("gather_phase1.out", "w");
gather2 = $fopen("gather_phase2.out", "w");
gather3 = $fopen("gather_phase3.out", "w");
start_end_time = $fopen("start_end_time.out", "w");
clk = 1;
reset = 1;
pesi_node0 = 0;
pero_node0 = 1;
pesi_node1 = 0;
pero_node1 = 1;
pesi_node2 = 0;
pero_node2 = 1;
pesi_node3 = 0;
pero_node3 = 1;
time_keep = 0;
#14
reset = 0;
#2
//for loop to run the test, we can commit 8 tests, and log into start_end_time.out file
for (test_number = 0; test_number < 8; test_number = test_number + 1) begin
	
	for (phase_number = 0; phase_number < 4; phase_number = phase_number + 1) begin
	$fdisplay(start_end_time, "Phase Number: %d; Start time = %d ns", phase_number, time_keep);
	packet_send(phase_number);
	#34
	$fdisplay(start_end_time, "Phase Number: %d; End time = %d ns", phase_number, time_keep);
	
	end
	
end

#320

$fclose(gather0);
$fclose(gather1);
$fclose(gather2);
$fclose(gather3);
$fclose(start_end_time);
$finish;
end

endmodule