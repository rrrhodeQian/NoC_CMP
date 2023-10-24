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
wire pe_reserve;
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
reg pedo_dir_node0, pedo_dir_node1, pedo_dir_node2, pedo_dir_node3;
reg pedo_vc_node0, pedo_vc_node1, pedo_vc_node2, pedo_vc_node3;
reg [7:0] pedo_hop_node0, pedo_hop_node1, pedo_hop_node2, pedo_hop_node3;
reg [15:0] pedo_source_node0, pedo_source_node1, pedo_source_node2, pedo_source_node3;
reg [31:0] pedo_payload_node0, pedo_payload_node1, pedo_payload_node2, pedo_payload_node3;
assign pedo_node0 = {pedo_vc_node0, pedo_dir_node0, pe_reserve, pedo_hop_node0, pedo_source_node0, pedo_payload_node0};
assign pedo_node1 = {pedo_vc_node1, pedo_dir_node1, pe_reserve, pedo_hop_node1, pedo_source_node1, pedo_payload_node1};
assign pedo_node2 = {pedo_vc_node2, pedo_dir_node2, pe_reserve, pedo_hop_node2, pedo_source_node2, pedo_payload_node2};
assign pedo_node3 = {pedo_vc_node3, pedo_dir_node3, pe_reserve, pedo_hop_node3, pedo_source_node3, pedo_payload_node3};
//------------------------------------------------------------------------------------------
//Open files for gather phases and start-end-time 
integer gather0, gather1, gather2, gather3, start_end_time;
initial begin
gather0 = $fopen("gather_phase0.res", "w");
gather1 = $fopen("gather_phase1.res", "w");
gather2 = $fopen("gather_phase2.res", "w");
gather3 = $fopen("gather_phase3.res", "w");
start_end_time = $fopen("start_end_time.out", "w");
end
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
parameter phase0 = 2'b00;
parameter phase1 = 2'b01;
parameter phase2 = 2'b10;
parameter phase3 = 2'b11;
reg finish_send;

task packet_send;
input [1:0] phase;
output finish_send;
begin
finish_send = 0;

//Phase 0
wait(!polarity && peri_node0)
if (phase != phase0) begin
pedi_vc_node0 = 0;
pesi_node0 = 1;
pedi_source_node0=0;

case (phase)
phase1: begin
pedi_dir_node0 = 0;
pedi_hop_node0 = 8'b0000_0001;
pedi_payload_node0 = 1;
end

phase2: begin
pedi_dir_node0 = 0;
pedi_hop_node0 = 8'b0000_0011;
pedi_payload_node0 = 2;
end

phase3: begin
pedi_dir_node0 = 0;//To see if Minimal Routing functions
pedi_hop_node0 = 8'b0000_0111;
pedi_payload_node0 = 3;
end
endcase
#4
pesi_node0 = 0;
end

//Phase 1
wait(!polarity && peri_node1)
if (phase != phase1) begin
pedi_vc_node1 = 0;
pesi_node1 = 1;
pedi_source_node1=1;

case (phase)
phase0: begin
pedi_dir_node1 = 1;
pedi_hop_node1 = 8'b0000_0001;
pedi_payload_node1 = 0;
end

phase2: begin
pedi_dir_node1 = 0;
pedi_hop_node1 = 8'b0000_0001;
pedi_payload_node1 = 2;
end

phase3: begin
pedi_dir_node1 = 0;
pedi_hop_node1 = 8'b0000_0011;
pedi_payload_node1 = 3;
end
endcase
#4
pesi_node1 = 0;
end

//Phase 2
wait(!polarity && peri_node2)
if (phase != phase2) begin
pedi_vc_node2 = 0;
pesi_node2 = 1;
pedi_source_node2=2;

case (phase)
phase0: begin
pedi_dir_node2 = 0;
pedi_hop_node2 = 8'b0000_0011;
pedi_payload_node2 = 0;
end

phase1: begin
pedi_dir_node2 = 1;
pedi_hop_node2 = 8'b0000_0011;
pedi_payload_node2 = 1;
end

phase3: begin
pedi_dir_node2 = 0;
pedi_hop_node2 = 8'b0000_0111;
pedi_payload_node2 = 3;
end
endcase
#4
pesi_node2 = 0;
end

//Phase 3
wait(!polarity && peri_node3)
if (phase != phase3) begin
pedi_vc_node3 = 0;
pesi_node3 = 1;
pedi_source_node3=3;
case (phase)
phase0: begin
pedi_dir_node3 = 0;
pedi_hop_node3 = 8'b0000_0001;
pedi_payload_node3 = 0;

end

phase1: begin
pedi_dir_node3 = 0;
pedi_hop_node3 = 8'b0000_0011;
pedi_payload_node3 = 1;
end

phase2: begin
pedi_dir_node3 = 1;
pedi_hop_node3 = 8'b0000_0001;
pedi_payload_node3 = 2;
end
endcase
#4
pesi_node3 = 0;
end

finish_send = 1;
end
endtask

//-------------------------------------------------------------------------------------------------------------------------
always @(posedge clk) begin
if (reset == 0) begin
if (peso_node0) begin
$fdisplay(gather0, "Phase=%d , Time=%d , Destination=%d , Source=%d , Packet Value=%b", 0, time_keep, pedo_vc_node0, pedo_payload_node0, pedo_source_node0, pedo_node0);
end
if (peso_node1) begin
$fdisplay(gather1, "Phase=%d , Time=%d , Destination=%d , Source=%d , Packet Value=%b", 1, time_keep, pedo_vc_node1, pedo_payload_node1, pedo_source_node1, pedo_node1);
end
if (peso_node2) begin
$fdisplay(gather2, "Phase=%d , Time=%d , Destination=%d , Source=%d , Packet Value=%b", 2, time_keep, pedo_vc_node2, pedo_payload_node2, pedo_source_node2, pedo_node2);
end
if (peso_node3) begin
$fdisplay(gather3, "Phase=%d , Time=%d , Destination=%d , Source=%d , Packet Value=%b", 3, time_keep, pedo_vc_node3, pedo_payload_node3, pedo_source_node3, pedo_node3);
end
end
end
//-------------------------------------------------------------------------------------------------------------------------
//Begin Test
//Test_Number:Total of 4 gather tests
//Phase_Number: Total of 4 phases in each test
//2 for loops to be used to run the test
integer test_number;
integer phase_number;
initial begin

clk = 1;
reset = 1;
pesi_node0 = 0;
pero_node0 = 0;
pesi_node1 = 0;
pero_node1 = 0;
pesi_node2 = 0;
pero_node2 = 0;
pesi_node3 = 0;
pero_node3 = 0;
time_keep = 0;
#22
reset = 0;
//for loop to run the test, we can commit 8 tests, and log into start_end_time.out file
for (test_number = 0; test_number < 7; test_number = test_number + 1) begin
	for (phase_number = 0; phase_number < 4; phase_number = phase_number + 1) begin
	$fdisplay(start_end_time, "Phase Number: %d; Start time = %d ns", phase_number, time_keep);
	packet_send(phase_number, finish_send);
	$fdisplay(start_end_time, "Phase Number: %d; End time = %d ns", phase_number, time_keep);
	end
end

#300

$fclose(gather0);
$fclose(gather1);
$fclose(gather2);
$fclose(gather3);
$fclose(start_end_time);
$finish;
end

endmodule
