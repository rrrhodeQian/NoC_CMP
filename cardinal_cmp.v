module cardinal_cmp(
input clk, reset,
input [0:31]inst_in_node0, inst_in_node1, inst_in_node2, inst_in_node3, 
input [0:63]din_node0,din_node1,din_node2,din_node3,
output mem_en_node0, em_en_node1, em_en_node2, em_en_mode3,
output mem_write_en_node0, mem_write_en_node1, mem_write_en_node2, mem_write_en_node3,
output [0:63]dout_node0, dout_node1, dout_node2, dout_node3,
output [0:31]addr_out_node0,addr_out_node1,addr_out_node2,addr_out_node3,
output [0:31]pc_out_node0,pc_out_node1,pc_out_node2,pc_out_node3
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
    cardinal_processor cmp_processor0(
        .clk(clk),
        .reset(reset),
        .inst_addr(pc_out_node0),
        .inst_in(inst_in_node0),
        .dmem_En(dmem_en_node0),
        .dmem_WrEn(dmem_write_en_node0),
        .dmem_addr(addr_out_node0),
        .reg_data(dout_node0),
        .dmem_data(din_node0),
        .nic_data(nic_dout_node0),
        .nicEn(nic_en_node0),
        .nicWrEn(nic_write_en_node0),
        .nic_addr(nic_addr_node0),
        .d_out(nic_din_node0)
    );

cardinal_processor cmp_processor1(
    .clk(clk),
    .reset(reset),
    .inst_addr(pc_out_node1),
    .inst_in(inst_in_node1),
    .dmem_En(dmem_en_node1),
    .dmem_WrEn(dmem_write_en_node1),
    .dmem_addr(addr_out_node1),
    .reg_data(dout_node1),
    .dmem_data(din_node1),
    .nic_data(nic_dout_node1),
    .nicEn(nic_en_node1),
    .nicWrEn(nic_write_en_node1),
    .nic_addr(nic_addr_node1),
    .d_out(nic_din_node1)
);

cardinal_processor cmp_processor2(
    .clk(clk),
    .reset(reset),
    .inst_addr(pc_out_node2),
    .inst_in(inst_in_node2),
    .dmem_En(dmem_en_node2),
    .dmem_WrEn(dmem_write_en_node2),
    .dmem_addr(addr_out_node2),
    .reg_data(dout_node2),
    .dmem_data(din_node2),
    .nic_data(nic_dout_node2),
    .nicEn(nic_en_node2),
    .nicWrEn(nic_write_en_node2),
    .nic_addr(nic_addr_node2),
    .d_out(nic_din_node2)
);

cardinal_processor cmp_processor3(
    .clk(clk),
    .reset(reset),
    .inst_addr(pc_out_node3),
    .inst_in(inst_in_node3),
    .dmem_En(dmem_en_node3),
    .dmem_WrEn(dmem_write_en_node3),
    .dmem_addr(addr_out_node3),
    .reg_data(dout_node3),
    .dmem_data(din_node3),
    .nic_data(nic_dout_node3),
    .nicEn(nic_en_node3),
    .nicWrEn(nic_write_en_node3),
    .nic_addr(nic_addr_node3),
    .d_out(nic_din_node3)
);

endmodule