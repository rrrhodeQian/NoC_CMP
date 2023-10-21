module cardinal_nic #(
    parameter PAC_WIDTH = 64
) (
    input [0:1] addr,//memory address mapped registers
    input [0:PAC_WIDTH-1] d_in,//input packet from the PE
    output reg [0:PAC_WIDTH-1] d_out,//content of the register specified by addr[0:1]
    input nicEn,//enable signal to the NIC
    input nicWrEn,//write enable signal to the NIC
    input net_si,//send handshaking signal for the network input channel
    output net_ri,//ready handshaking singal for the network input channel
    input [0:PAC_WIDTH-1] net_di,//packet data from the network input channel
    output net_so,//send handshaking signal for the network output channel
    input net_ro,//ready handshaking signal for the network output channel
    output [0:PAC_WIDTH-1] net_do,//packet data for the network output channel
    input net_polarity,//polarity input from the router connnected to the NIC
    input clk,
    input reset//sync high active reset
);
    wire [0:PAC_WIDTH-1] in_buf_d_out, out_buf_d_out;//data ouput of input and output buffer
    wire in_buf_status, out_buf_status;//status reg of input and out buffer
    wire in_buf_wen, in_buf_ren, out_buf_wen, out_buf_ren;//write and read enables for input and output buffer
    //buffer instantiating
    buffer in_buffer(
        .clk(clk),
        .reset(reset),
        .wen(in_buf_wen),
        .ren(in_buf_ren),
        .d_in(net_di),
        .full(in_buf_status),
        .empty(),
        .d_out(in_buf_d_out)
    );

    buffer out_buffer(
        .clk(clk),
        .reset(reset),
        .wen(out_buf_wen),
        .ren(out_buf_ren),
        .d_in(d_in),
        .full(out_buf_status),
        .empty(),
        .d_out(out_buf_d_out)
    );

    assign net_ri = ~in_buf_status;//input buffer status = 0 -> input buffer is empty -> NIC input channel is ready
    assign net_do = out_buf_d_out;
    assign net_so = out_buf_ren;//same as output buffer read enable
    
    assign in_buf_wen = (~in_buf_status) & net_si;//enable writing input buffer when input buffer is empty and net_si is asserted
    assign in_buf_ren = (nicEn && (~nicWrEn) && addr == 2'b00) ? 1'b1 : 1'b0;//enable read only if processor wants to
    //enable writing output buffer when nicEn and nicWrEn are asserted and address is pointed to output buffer
    assign out_buf_wen = (nicEn && nicWrEn && addr == 2'b10) ? 1'b1 : 1'b0;
    //enable reading output buffer only when router input channel is ready, output buffer is full and data vc bit matches with router polarity
    assign out_buf_ren = (net_ro && out_buf_status && ((net_polarity && !out_buf_d_out[0]) || (!net_polarity && out_buf_d_out[0]))) ? 1'b1 : 1'b0;

    //logic for d_out
    always @(*) begin
        if (nicEn && !nicWrEn) begin
            case (addr)
                2'b00: d_out = in_buf_d_out;
                2'b01: d_out = {63'b0, in_buf_status};
                2'b11: d_out = {63'b0, out_buf_status};
                default: d_out = 'b0;
            endcase
        end
        else d_out = 'b0;
    end
endmodule