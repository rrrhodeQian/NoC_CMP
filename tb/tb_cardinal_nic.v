module tb_cardinal_nic;
parameter PAC_WIDTH = 64;
reg clk, reset, net_polarity, nicEn, nicWrEn, net_si, net_ro;
reg [0:PAC_WIDTH-1] d_in, net_di;
reg [0:1] addr;
wire [0:PAC_WIDTH-1] d_out, net_do;
wire net_ri, net_so;
integer fd;

cardinal_nic dut(
    .reset(reset),
    .clk(clk),
    .addr(addr),
    .d_in(d_in),
    .d_out(d_out),
    .nicEn(nicEn),
    .nicWrEn(nicWrEn),
    .net_si(net_si),
    .net_ri(net_ri),
    .net_di(net_di),
    .net_so(net_so),
    .net_ro(net_ro),
    .net_do(net_do),
    .net_polarity(net_polarity)
);

localparam CLK_PERIOD = 4;
always #(CLK_PERIOD/2) clk=~clk;

always @(posedge clk) begin
    if (reset) begin
        net_polarity <= 1'b0;
    end
    else
        net_polarity <= ~net_polarity;
end

initial begin
    fd = $fopen("./output_file/cardinal_nic.out", "w");
    if (!fd) begin
        $display("File cannot be opened!");
        $finish;
    end

end

initial begin
    reset <= 1'b0;
    clk <= 1'b0;
    nicEn <= 1'b0;
    nicWrEn <= 1'b0;
    net_si <= 1'b0;
    net_ro <= 1'b0;
    d_in <= 'b0;
    net_di <= 'b0;
    addr <= 2'bx;
    #(CLK_PERIOD) reset <= 1'b1;
    #(CLK_PERIOD) reset <= 1'b0;

    //data flow: processor -> router
    addr <= 2'b10;//pointing to output channel buffer
    nicEn <= 1'b1;
    nicWrEn <= 1'b1;
    net_ro <= 1'b1;//router always ready for receiving
    $fdisplay(fd, "------data flow: from processor to router------");
    repeat(100) begin
        d_in <= {$random, $random};
        #(CLK_PERIOD*0.5);
        $fdisplay(fd, "At time %3d ns, d_in = %b, net_polarity = %b, net_so = %b, net_do = %b", $time, d_in, net_polarity, net_so, net_do);
        #(CLK_PERIOD*0.5);
    end
    $fdisplay(fd, "-----------------------------------------------");
    nicWrEn <= 1'b0;//disable processor writing
    addr <= 2'b00;//pointing to input channle buffer
    net_ro <= 1'b0;
    net_si <= 1'b1;//router always sending
    $fdisplay(fd, "------data flow: from router to processor------");
    repeat(100) begin
        net_di <= {$random, $random};
        #(CLK_PERIOD*0.5);
        $fdisplay(fd, "At time %3d ns, net_di = %b, net_ri = %b, d_out = %b", $time, net_di, net_ri, d_out);
        #(CLK_PERIOD*0.5);
    end
    $fdisplay(fd, "-----------------------------------------------");
    $fclose(fd);
    $finish();
end

endmodule