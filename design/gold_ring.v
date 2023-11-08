module gold_ring(
input clk,
input reset,
output polarity,
//Node0
input pesi_node0,
output peri_node0,
input [63:0] pedi_node0,
output peso_node0,
output [63:0] pedo_node0,
input pero_node0,
//Node1
input pesi_node1,
output peri_node1,
input [63:0] pedi_node1,
output peso_node1,
output [63:0] pedo_node1,
input pero_node1,
//Node2
input pesi_node2,
output peri_node2,
input [63:0] pedi_node2,
output peso_node2,
output [63:0] pedo_node2,
input pero_node2,
//Node3
input pesi_node3,
output peri_node3,
input [63:0] pedi_node3,
output peso_node3,
output [63:0] pedo_node3,
input pero_node3
);

//-----------------------------------------------------------------------------------------
//Wire signals from node 0 to node 4
// Node 0
wire cwr_node0;
wire cws_node0;
wire [63:0] cwd_node0;

wire ccwr_node0;
wire ccws_node0;
wire [63:0] ccwd_node0;

// Node 1
wire cwr_node1;
wire cws_node1;
wire [63:0] cwd_node1;

wire ccwr_node1;
wire ccws_node1;
wire [63:0] ccwd_node1;


// Node 2
wire cwr_node2;
wire cws_node2;
wire [63:0] cwd_node2;

wire ccwr_node2;
wire ccws_node2;
wire [63:0] ccwd_node2;


// Node 3
wire cwr_node3;
wire cws_node3;
wire [63:0] cwd_node3;

wire ccwr_node3;
wire ccws_node3;
wire [63:0] ccwd_node3;

//-----------------------------------------------------------------------------------------
//Router Instantiations
//Node 0
gold_router router_node0(
.clk(clk),
.reset(reset),
.polarity(polarity),

.cwdi(cwd_node3),
.cwsi(cws_node3),
.cwri(cwr_node3),
.ccwdi(ccwd_node1),
.ccwsi(ccws_node1),
.ccwri(ccwr_node1),
.pedi(pedi_node0),
.pesi(pesi_node0),
.peri(peri_node0),

.cwdo(cwd_node0),
.cwso(cws_node0),
.cwro(cwr_node0),
.ccwdo(ccwd_node0),
.ccwso(ccws_node0),
.ccwro(ccwr_node0),

.pedo(pedo_node0),
.peso(peso_node0),
.pero(pero_node0)
);

//Node 1
gold_router router_node1 (
.clk(clk),
.reset(reset),
.polarity(polarity),

.cwdi(cwd_node0),
.cwsi(cws_node0),
.cwri(cwr_node0),
.ccwdi(ccwd_node2),
.ccwsi(ccws_node2),
.ccwri(ccwr_node2),
.pedi(pedi_node1),
.pesi(pesi_node1),
.peri(peri_node1),

.cwdo(cwd_node1),
.cwso(cws_node1),
.cwro(cwr_node1),
.ccwdo(ccwd_node1),
.ccwso(ccws_node1),
.ccwro(ccwr_node1),
.pedo(pedo_node1),
.peso(peso_node1),
.pero(pero_node1)
);

//Node 2
gold_router router_node2 (
.clk(clk),
.reset(reset),
.polarity(polarity),

.cwdi(cwd_node1),
.cwsi(cws_node1),
.cwri(cwr_node1),
.ccwdi(ccwd_node3),
.ccwsi(ccws_node3),
.ccwri(ccwr_node3),
.pedi(pedi_node2),
.pesi(pesi_node2),
.peri(peri_node2),

.cwdo(cwd_node2),
.cwso(cws_node2),
.cwro(cwr_node2),
.ccwdo(ccwd_node2),
.ccwso(ccws_node2),
.ccwro(ccwr_node2),
.pedo(pedo_node2),
.peso(peso_node2),
.pero(pero_node2)
);

// Node 3
gold_router router_node3 (
.clk(clk),
.reset(reset),
.polarity(polarity),

.cwdi(cwd_node2),
.cwsi(cws_node2),
.cwri(cwr_node2),
.ccwdi(ccwd_node0),
.ccwsi(ccws_node0),
.ccwri(ccwr_node0),
.pedi(pedi_node3),
.pesi(pesi_node3),
.peri(peri_node3),

.cwdo(cwd_node3),
.cwso(cws_node3),
.cwro(cwr_node3),
.ccwdo(ccwd_node3),
.ccwso(ccws_node3),
.ccwro(ccwr_node3),
.pedo(pedo_node3),
.peso(peso_node3),
.pero(pero_node3)
);

//-----------------------------------------------------------------------------------------

endmodule

