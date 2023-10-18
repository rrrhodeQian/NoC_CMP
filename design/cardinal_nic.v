module cardinal_nic #(
    PAC_WIDTH = 64
) (
    input [0:1] addr,//memory address mapped registers
    input [0:PAC_WIDTH-1] d_in,//input packet from the PE
    output [0:PAC_WIDTH-1] d_out;//content of the register specified by addr[0:1]
    input nicEn,//enable signal to the NIC
    input nicEnWr,//write enable signal to the NIC
    input net_si,//send handshaking signal for the network input channel
    output net_ri,//ready handshaking singal for the network input channel
    input [0:PAC_WIDTH-1] net_di,//packet data from the network input channel
    output net_so,//send handshaking signal for the network output channel
    input net_ro,//ready handshaking signal for the network output channel
    output [0:PAC_WIDTH-1] net_do,//packet data for the network output channel
    input net_polarity,//polarity input from the router connnected to the NIC
    input clk,
    input reset,//sync high active reset
);
    //buffer instantiating


    //
endmodule