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
        net_polarity <= 1'b1;
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

    $fmonitor(fd, "At time %3d ns, d_in = %b, net_polarity = %b, net_so = %b, net_ro = %b, net_do = %b", $time, d_in, net_polarity, net_so, net_ro, net_do);
    $fmonitor(fd, "At time %3d ns, d_out = %b", $time, d_out);
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

    #(CLK_PERIOD*0.5);
    //non-blocking handshaking test
    $fdisplay(fd, "------non-blocking handshaking test------------");
    addr <= 2'b10;//pointing to output channel buffer
    nicEn <= 1'b1;
    nicWrEn <= 1'b1;
    net_ro <= 1'b1;//router always ready for receiving
    d_in <= {1'b1, $random, 31'b0};
    #(CLK_PERIOD*4);
    d_in <= {1'b0, $random, 31'b0};
    #(CLK_PERIOD*3);

    //blocking handshaking test
    $fdisplay(fd, "------blocking handshaking test----------------");
    net_ro <= 1'b0;
    d_in <= {1'b1, $random, 31'b0};
    #(CLK_PERIOD*2);
    net_ro <= 1'b1;
    #(CLK_PERIOD*4);

    //load operation
    $fdisplay(fd, "------------load operation test----------------");
    net_ro <= 1'b0;
    d_in <= {$random, $random};
    #(CLK_PERIOD*2);
    addr <= 2'b11;//pointing to output channel status register
    nicWrEn <= 1'b0;//disable writing
    #(CLK_PERIOD*2);
    //attempt to load again 
    addr <= 2'b10;
    nicWrEn <= 1'b1;
    d_in <= {$random, $random};
    #(CLK_PERIOD*2);
    addr <= 2'b11;//pointing to output channel status register
    nicWrEn <= 1'b0;//disable writing
    #(CLK_PERIOD);

    //store opration
    $fdisplay(fd, "-----------store operation test----------------");
    net_si <= 1'b1;//router sending
    addr <= 2'b00;//pointing to input channel buffer
    net_di <= {$random, $random};
    #(CLK_PERIOD*2);
    addr <= 2'b01;
    #(CLK_PERIOD*2);
    net_si <= 1'b1;//attempt to send again
    net_di <= {$random, $random};
    #(CLK_PERIOD*4);
    $fclose(fd);
    $finish();
end

endmodule