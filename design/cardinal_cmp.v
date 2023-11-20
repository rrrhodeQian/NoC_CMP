module cardinal_cmp(
input clk, reset,
input [0:31] node0_inst_in, node1_inst_in, node2_inst_in, node3_inst_in,//Instruction from instruction memory to the processor
input [0:63] node0_d_in, node1_d_in, node2_d_in, node3_d_in,//Input data from data memory to the processor
output [0:31] node0_pc_out, node1_pc_out, node2_pc_out, node3_pc_out,//Program counter to the instruction memory
output [0:63] node0_d_out, node1_d_out, node2_d_out, node3_d_out,//Output data to the write port of data memory
output [0:31] node0_addr_out, node1_addr_out, node2_addr_out, node3_addr_out,//Output address to the data memory
output node0_memWrEn, node1_memWrEn, node2_memWrEn, node3_memWrEn,//Data memory write enable signal
output node0_memEn, node1_memEn, node2_memEn, node3_memEn,//Data memory enable signal
output [0:1] node0_addr_nic, node1_addr_nic, node2_addr_nic, node3_addr_nic,//2-bit address to the NIC
output [0:63] node0_din_nic, node1_din_nic, node2_din_nic, node3_din_nic,//ports to monitor data input port of the NIC
output [0:63] node0_dout_nic, node1_dout_nic, node2_dout_nic, node3_dout_nic,//ports to monitor data output port of the NIC
output node0_nicEn, node1_nicEn, node2_nicEn, node3_nicEn,//ports to monitor NIC enable signal
output node0_nicWrEn, node1_nicWrEn, node2_nicWrEn, node3_nicWrEn//ports to monitor NIC write enable signal
);

//Connecting NIC and Ring
wire node0_si_net, node1_si_net, node2_si_net, node3_si_net;
wire node0_ri_net, node1_ri_net, node2_ri_net, node3_ri_net;
wire node0_so_net, node1_so_net, node2_so_net, node3_so_net;
wire node0_ro_net, node1_ro_net, node2_ro_net, node3_ro_net;
wire [0:63] node0_di_net, node1_di_net, node2_di_net, node3_di_net;
wire [0:63] node0_do_net, node1_do_net, node2_do_net, node3_do_net;
wire polarity;

//Connecting NIC and Processor
wire node0_en_nic, node1_en_nic, node2_en_nic, node3_en_nic;
wire node0_write_en_nic, node1_write_en_nic, node2_write_en_nic, node3_write_en_nic;
wire [0:63] node0_din_proc_nic, node1_din_proc_nic, node2_din_proc_nic, node3_din_proc_nic;
wire [0:63] node0_dout_nic_proc, node1_dout_nic_proc, node2_dout_nic_proc, node3_dout_nic_proc;
wire [0:1] node0_addr_proc_nic, node1_addr_proc_nic, node2_addr_proc_nic, node3_addr_proc_nic;

//Ring Dump Files and Signal
wire [0:63] dump_data_node0,dump_data_node1,dump_data_node2,dump_data_node3;
wire dump_packet_node0,dump_packet_node1,dump_packet_node2,dump_packet_node3;

assign node0_addr_nic = node0_addr_proc_nic;
assign node1_addr_nic = node1_addr_proc_nic;
assign node2_addr_nic = node2_addr_proc_nic;
assign node3_addr_nic = node3_addr_proc_nic;

assign node0_din_nic = node0_din_proc_nic;
assign node1_din_nic = node1_din_proc_nic;
assign node2_din_nic = node2_din_proc_nic;
assign node3_din_nic = node3_din_proc_nic;

assign node0_dout_nic = node0_dout_nic_proc;
assign node1_dout_nic = node1_dout_nic_proc;
assign node2_dout_nic = node2_dout_nic_proc;
assign node3_dout_nic = node3_dout_nic_proc;

assign node0_nicEn = node0_en_nic;
assign node1_nicEn = node1_en_nic;
assign node2_nicEn = node2_en_nic;
assign node3_nicEn = node3_en_nic;

assign node0_nicWrEn = node0_write_en_nic;
assign node1_nicWrEn = node1_write_en_nic;
assign node2_nicWrEn = node2_write_en_nic;
assign node3_nicWrEn = node3_write_en_nic;
//Instantiate Ring

gold_ring ring(
    .clk(clk),
    .reset(reset),
    .ring_polarity(polarity),
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
    .peri_node0(node0_ro_net),
    .pesi_node0(node0_so_net),
    .pedi_node0(node0_do_net),
    .pero_node0(node0_ri_net),
    .peso_node0(node0_si_net),
    .pedo_node0(node0_di_net),
    // Node 1
    .peri_node1(node1_ro_net),
    .pesi_node1(node1_so_net),
    .pedi_node1(node1_do_net),
    .pero_node1(node1_ri_net),
    .peso_node1(node1_si_net),
    .pedo_node1(node1_di_net),

    // Node 2
    .peri_node2(node2_ro_net),
    .pesi_node2(node2_so_net),
    .pedi_node2(node2_do_net),
    .pero_node2(node2_ri_net),
    .peso_node2(node2_si_net),
    .pedo_node2(node2_di_net),

    // Node 3
    .peri_node3(node3_ro_net),
    .pesi_node3(node3_so_net),
    .pedi_node3(node3_do_net),
    .pero_node3(node3_ri_net),
    .peso_node3(node3_si_net),
    .pedo_node3(node3_di_net)
);

//------------------------------------------------------------------------------------
//NIC Instantiations
cardinal_nic NIC_node0(
    .reset(reset),
    .clk(clk),
    .addr(node0_addr_proc_nic),
    .d_in(node0_din_proc_nic),
    .d_out(node0_dout_nic_proc),
    .nicEn(node0_en_nic),
    .nicWrEn(node0_write_en_nic),
    .net_si(node0_si_net),
    .net_ri(node0_ri_net),
    .net_di(node0_di_net),
    .net_so(node0_so_net),
    .net_ro(node0_ro_net),
    .net_do(node0_do_net),
    .net_polarity(polarity)
);

cardinal_nic NIC_node1(
    .reset(reset),
    .clk(clk),
    .addr(node1_addr_proc_nic),
    .d_in(node1_din_proc_nic),
    .d_out(node1_dout_nic_proc),
    .nicEn(node1_en_nic),
    .nicWrEn(node1_write_en_nic),
    .net_si(node1_si_net),
    .net_ri(node1_ri_net),
    .net_di(node1_di_net),
    .net_so(node1_so_net),
    .net_ro(node1_ro_net),
    .net_do(node1_do_net),
    .net_polarity(polarity)
);

cardinal_nic NIC_node2(
    .reset(reset),
    .clk(clk),
    .addr(node2_addr_proc_nic),
    .d_in(node2_din_proc_nic),
    .d_out(node2_dout_nic_proc),
    .nicEn(node2_en_nic),
    .nicWrEn(node2_write_en_nic),
    .net_si(node2_si_net),
    .net_ri(node2_ri_net),
    .net_di(node2_di_net),
    .net_so(node2_so_net),
    .net_ro(node2_ro_net),
    .net_do(node2_do_net),
    .net_polarity(polarity)
);

cardinal_nic NIC_node3(
    .reset(reset),
    .clk(clk),
    .addr(node3_addr_proc_nic),
    .d_in(node3_din_proc_nic),
    .d_out(node3_dout_nic_proc),
    .nicEn(node3_en_nic),
    .nicWrEn(node3_write_en_nic),
    .net_si(node3_si_net),
    .net_ri(node3_ri_net),
    .net_di(node3_di_net),
    .net_so(node3_so_net),
    .net_ro(node3_ro_net),
    .net_do(node3_do_net),
    .net_polarity(polarity)
);

//------------------------------------------------------------------------------------------
//Processor Instantiation
cardinal_processor cmp_processor0(
    .clk(clk),
    .reset(reset),
    .inst_addr(node0_pc_out),
    .inst_in(node0_inst_in),
    .dmem_En(node0_memEn),
    .dmem_WrEn(node0_memWrEn),
    .dmem_addr(node0_addr_out),
    .reg_data(node0_d_out),
    .dmem_data(node0_d_in),
    .nic_data(node0_dout_nic_proc),
    .nicEn(node0_en_nic),
    .nicWrEn(node0_write_en_nic),
    .nic_addr(node0_addr_proc_nic),
    .d_out(node0_din_proc_nic)
  );
  
  cardinal_processor cmp_processor1(
    .clk(clk),
    .reset(reset),
    .inst_addr(node1_pc_out),
    .inst_in(node1_inst_in),
    .dmem_En(node1_memEn),
    .dmem_WrEn(node1_memWrEn),
    .dmem_addr(node1_addr_out),
    .reg_data(node1_d_out),
    .dmem_data(node1_d_in),
    .nic_data(node1_dout_nic_proc),
    .nicEn(node1_en_nic),
    .nicWrEn(node1_write_en_nic),
    .nic_addr(node1_addr_proc_nic),
    .d_out(node1_din_proc_nic)
  );
  
  cardinal_processor cmp_processor2(
    .clk(clk),
    .reset(reset),
    .inst_addr(node2_pc_out),
    .inst_in(node2_inst_in),
    .dmem_En(node2_memEn),
    .dmem_WrEn(node2_memWrEn),
    .dmem_addr(node2_addr_out),
    .reg_data(node2_d_out),
    .dmem_data(node2_d_in),
    .nic_data(node2_dout_nic_proc),
    .nicEn(node2_en_nic),
    .nicWrEn(node2_write_en_nic),
    .nic_addr(node2_addr_proc_nic),
    .d_out(node2_din_proc_nic)
  );
  
  cardinal_processor cmp_processor3(
    .clk(clk),
    .reset(reset),
    .inst_addr(node3_pc_out),
    .inst_in(node3_inst_in),
    .dmem_En(node3_memEn),
    .dmem_WrEn(node3_memWrEn),
    .dmem_addr(node3_addr_out),
    .reg_data(node3_d_out),
    .dmem_data(node3_d_in),
    .nic_data(node3_dout_nic_proc),
    .nicEn(node3_en_nic),
    .nicWrEn(node3_write_en_nic),
    .nic_addr(node3_addr_proc_nic),
    .d_out(node3_din_proc_nic)
  );
  

endmodule