module tb_gold_ring;
reg clk,
reg reset,
wire polarity,
//Node 0
reg peri_node0,
reg pesi_node0,
reg [63:0] pedi_node0,
//Node 1
reg peri_node1,
reg pesi_node1,
reg [63:0] pedi_node1,
//Node 2
reg peri_node2,
reg pesi_node2,
reg [63:0] pedi_node2,
//Node 3
reg peri_node3,
reg pesi_node3,
reg [63:0] pedi_node3
//------------------------------------------------------------------------------------------
//VC bit, Direction bit, Hop bit, Reserved_bit for inputs of pe buffers for all four Nodes
wire pe_reserve;
assign pe_reserve = 6'b0;
reg pedi_dir_node0, pedi_dir_node1, pedi_dir_node2, pedi_dir_node3;
reg pedi_vc_node0, pedi_vc_node1, pedi_vc_node2, pedi_vc_node3;
reg[7:0]pedi_hop_node0, pedi_hop_node1, pedi_hop_node2, pedi_hop_node3;
assign pedi_node0 = {pedi_vc_node0, pedi_dir_node0, pe_reserve, pe_hop_node0, 48'b0};
assign pedi_node1 = {pedi_vc_node1, pedi_dir_node1, pe_reserve, pe_hop_node1, 48'b1};
assign pedi_node2 = {pedi_vc_node2, pedi_dir_node2, pe_reserve, pe_hop_node2, 48'b11};
assign pedi_node3 = {pedi_vc_node3, pedi_dir_node3, pe_reserve, pe_hop_node3, 48'b111};
//------------------------------------------------------------------------------------------
always #1 clk = ~clk;



