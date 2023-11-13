module cardinal_cmp(
input clk, reset,
input [0:31] node0_inst_in, node1_inst_in, node2_inst_in, node3_inst_in; // Instruction Input
input [0:63] node0_din, node1_din, node2_din, node3_din; // Data Input
output node0_memEn, node1_memEn, node2_memEn, node3_memEn; // Data Memory Enable
output node0_memWrEn, node1_memWrEn, node2_memWrEn, node3_memWrEn; // Data Memory Write Enable
output [0:63] node0_dout, node1_dout, node2_dout, node3_dout; // Data Out
output [0:31] node0_addr_out, node1_addr_out, node2_addr_out, node3_addr_out; // Address Output
output [0:31] node0_pc_out, node1_pc_out, node2_pc_out, node3_pc_out; // Instruction Pointer

);

//Connecting NIC and Ring
wire net_si_node0,net_si_node1,net_si_node2,net_si_node3;
wire net_ri_node0, net_ri_node1, net_ri_node2, net_ri_node3;
wire net_so_node0,net_so_node1,net_so_node2,net_so_node3;
wire net_ro_node0,net_ro_node1,net_ro_node2,net_ro_node3,
wire [0:63]net_di_node0,net_di_node1,net_di_node2,net_di_node3;
wire [0:63]net_do_node0,net_do_node1,net_do_node2,net_do_node3;
wire polarity;

//Connecting NIC and Processor
wire nic_en_node0, nic_en_node1, nic_en_node2, nic_en_node3;
wire nic_write_en_node0,nic_write_en_node1,nic_write_en_node2,nic_write_en_node3;
wire [0:63] nic_din_node0, nic_din_node1, nic_din_node2, nic_din_node3;
wire [0:63] nic_dout_node0, nic_dout_node1, nic_dout_node2, nic_dout_node3;
wire [0:1] nic_addr_node0, nic_addr_node1, nic_addr_node2, nic_addr_node3;


//Ring Dump Files and Signal
wire dump_data_node0,dump_data_node1,dump_data_node2,dump_data_node3;
wire dump_packet_node0,dump_packet_node1,dump_packet_node2,dump_packet_node3;
//Instantiate Ring
gold_ring ring_cmp(
gold_ring ring(
.clk(clk),
.reset(reset),
/*Dump Packet Signal and Data*/
.dump_data_node0(dump_data_node0),
.dump_data_node1(dump_data_node1),
.dump_data_node2(dump_data_node2),
.dump_data_node3(dump_data_node3),
.dump_packet_node0(dump_packet_node0),
.dump_packet_node1(dump_packet_node1),
.dump_packet_node2(dump_packet_node2),
.dump_packet_node3(dump_packet_node3),
// Node 0
.peri_node0(net_ro_node0),
.pesi_node0(net_so_node0),
.pedi_node0(net_do_node0),
.pero_node0(net_ri_node0),
.peso_node0(net_si_node0),
.pedo_node0(net_di_node0),
// Node 1
.peri_node1(net_ro_node1),
.pesi_node1(net_so_node1),
.pedi_node1(net_do_node1),
.pero_node1(net_ri_node1),
.peso_node1(net_si_node1),
.pedo_node1(net_di_node1),

// Node 2
.peri_node2(net_ro_node2),
.pesi_node2(net_so_node2),
.pedi_node2(net_do_node2),
.pero_node2(net_ri_node2),
.peso_node2(net_si_node2),
.pedo_node2(net_di_node2),

// Node 3
.peri_node3(net_ro_node3),
.pesi_node3(net_so_node3),
.pedi_node3(net_do_node3),
.pero_node3(net_ri_node3),
.peso_node3(net_si_node3),
.pedo_node3(net_di_node3)
);
)
//------------------------------------------------------------------------------------
//NIC Instantiations
cardinal_nic NIC_node0(
    .reset(reset),
    .clk(clk),
    .addr(nic_addr_node0),
    .d_in(nic_din_node0),
    .d_out(nic_dout_node0),
    .nicEn(nic_en_node0),
    .nicWrEn(nic_write_en_node0),
    .net_si(net_si_node0),
    .net_ri(net_ri_node0),
    .net_di(net_di_node0),
    .net_so(net_so_node0),
    .net_ro(net_ro_node0),
    .net_do(net_do_node0),
    .net_polarity(polarity)
);

cardinal_nic NIC_node1(
    .reset(reset),
    .clk(clk),
    .addr(nic_addr_node1),
    .d_in(nic_di_node1),
    .d_out(nic_dout_node1),
    .nicEn(nic_en_node1),
    .nicWrEn(nic_write_en_node1),
    .net_si(net_si_node1),
    .net_ri(net_ri_node1),
    .net_di(net_di_node1),
    .net_so(net_so_node1),
    .net_ro(net_ro_node1),
    .net_do(net_do_node1),
    .net_polarity(polarity)
);


cardinal_nic NIC_node2(
    .reset(reset),
    .clk(clk),
    .addr(nic_addr_node2),
    .d_in(nic_di_node2),
    .d_out(nic_dout_node2),
    .nicEn(nic_en_node2),
    .nicWrEn(nic_write_en_node2),
    .net_si(net_si_node2),
    .net_ri(net_ri_node2),
    .net_di(net_di_node2),
    .net_so(net_so_node2),
    .net_ro(net_ro_node2),
    .net_do(net_do_node2),
    .net_polarity(polarity)
);


cardinal_nic NIC_node3(
    .reset(reset),
    .clk(clk),
    .addr(nic_addr_node3),
    .d_in(nic_di_node3),
    .d_out(nic_dout_node3),
    .nicEn(nic_en_node3),
    .nicWrEn(nic_write_en_node3),
    .net_si(net_si_node3),
    .net_ri(net_ri_node3),
    .net_di(net_di_node3),
    .net_so(net_so_node3),
    .net_ro(net_ro_node3),
    .net_do(net_do_node3),
    .net_polarity(polarity)
);

//------------------------------------------------------------------------------------------
//Processor Instantiation
  cardinal_processor processor0(
    .clk(clk),
    .reset(reset),
    .inst_addr(node0_pc_out),
    .inst_in(node0_inst_in),
    .dmem_En(node0_memEn),
    .dmem_WrEn(node0_memWrEn),
    .dmem_addr(node0_addr_out),
    .reg_data(node0_dout),
    .dmem_data(node0_din),
    .nic_data(node0_dout_nic),
    .nicEn(node0_nicEn),
    .nicWrEn(node0_nicWrEn),
    .nic_addr(node0_addr_nic),
    .d_out(node0_din_nic)
);

cardinal_processor processor1(
    .clk(clk),
    .reset(reset),
    .inst_addr(node1_pc_out),
    .inst_in(node1_inst_in),
    .dmem_En(node1_memEn),
    .dmem_WrEn(node1_memWrEn),
    .dmem_addr(node1_addr_out),
    .reg_data(node1_dout),
    .dmem_data(node1_din),
    .nic_data(node1_dout_nic),
    .nicEn(node1_nicEn),
    .nicWrEn(node1_nicWrEn),
    .nic_addr(node1_addr_nic),
    .d_out(node1_din_nic)
);

cardinal_processor processor2(
    .clk(clk),
    .reset(reset),
    .inst_addr(node2_pc_out),
    .inst_in(node2_inst_in),
    .dmem_En(node2_memEn),
    .dmem_WrEn(node2_memWrEn),
    .dmem_addr(node2_addr_out),
    .reg_data(node2_dout),
    .dmem_data(node2_din),
    .nic_data(node2_dout_nic),
    .nicEn(node2_nicEn),
    .nicWrEn(node2_nicWrEn),
    .nic_addr(node2_addr_nic),
    .d_out(node2_din_nic)
);

cardinal_processor processor3(
    .clk(clk),
    .reset(reset),
    .inst_addr(node3_pc_out),
    .inst_in(node3_inst_in),
    .dmem_En(node3_memEn),
    .dmem_WrEn(node3_memWrEn),
    .dmem_addr(node3_addr_out),
    .reg_data(node3_dout),
    .dmem_data(node3_din),
    .nic_data(node3_dout_nic),
    .nicEn(node3_nicEn),
    .nicWrEn(node3_nicWrEn),
    .nic_addr(node3_addr_nic),
    .d_out(node3_din_nic)
);


endmodule