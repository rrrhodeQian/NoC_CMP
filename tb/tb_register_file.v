module tb_register_file;
parameter DATA_WIDTH = 64;
parameter ADDR_WIDTH = 5;
reg clk, reset, wen;
reg [0:2] PPP_sel;
reg [0:ADDR_WIDTH-1] wr_addr, rd_addr_0, rd_addr_1;
reg [0:DATA_WIDTH-1] data_in;
wire [0:DATA_WIDTH-1] data_out_0, data_out_1;
integer fd, i;

register_file RF(
    .reset(reset),
    .clk(clk),
    .wen(wen),
    .data_in(data_in),
    .PPP_sel(PPP_sel),
    .wr_addr(wr_addr),
    .rd_addr_0(rd_addr_0),
    .rd_addr_1(rd_addr_1),
    .data_out_0(data_out_0),
    .data_out_1(data_out_1)
);

localparam CLK_PERIOD = 4;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    fd = $fopen("./output_file/register_file.out", "w");
    if (!fd) begin
        $fdisplay(fd, "File cannot be opened.");
        $finish;
    end
end

initial begin
    reset <= 1'b1;
    clk <= 1'b0;
    wen <= 1'b0;
    PPP_sel <= 3'b0;
    wr_addr <= 'bx;
    rd_addr_0 <= 'bx;
    rd_addr_1 <= 'bx;
    data_in <= 'bx;
    i = 0;

    #(CLK_PERIOD*3) reset <= 1'b0;
    //RF writing test
    $fdisplay(fd, "RF writing test");
    while (i < 8) begin
        data_in <= {$random, $random};
        wr_addr <= $random % 32;
        wen <= 1'b1;
        PPP_sel <= i;
        #CLK_PERIOD;
        $fdisplay(fd, "At time %3d ns, data_in = %h, wr_addr = %d, PPP_sel = %b, mem_array[%d] = %h", $time, data_in, wr_addr, PPP_sel, wr_addr, RF.mem_array[wr_addr]);
        i <= i + 1;
    end
    
    data_in <= {$random, $random};
    wr_addr <= 'b0;//try to write to RF 0
    PPP_sel <= 'b0;
    $fdisplay(fd, "RF 0 write test");
    #CLK_PERIOD;
    $fdisplay(fd, "At time %3d ns, data_in = %h, wr_addr = %d, PPP_sel = %b, mem_array[%d] = %h", $time, data_in, wr_addr, PPP_sel, wr_addr, RF.mem_array[wr_addr]);

    //RF reading test
    $fdisplay(fd, "RF reading test");
    i = 1;
    PPP_sel <= 1'b0;
    // #CLK_PERIOD;
    while (i < 5) begin
        data_in <= {$random, $random};
        wr_addr <= i;
        wen <= 1'b1;
        #CLK_PERIOD;
        $fdisplay(fd, "At time %3d ns, data_in = %h, wr_addr = %d, PPP_sel = %b, mem_array[%d] = %h", $time, data_in, wr_addr, PPP_sel, wr_addr, RF.mem_array[wr_addr]);
        i = i + 1;
    end
    #CLK_PERIOD;
    i = 1;
    wen <= 1'b0;
    while (i < 5) begin
        rd_addr_0 <= i;
        rd_addr_1 <= i;
        #CLK_PERIOD;
        $fdisplay(fd, "At time %3d ns, rd_addr_0 = %d, rd_addr_1 = %d, data_out_0 = %h, data_out_1 = %h", $time, rd_addr_0, rd_addr_1, data_out_0, data_out_1);
        i = i + 1;
    end
    #(CLK_PERIOD*2);

    //internal forwarding test
    $fdisplay(fd, "Internal forwarding test");
    i = 1;
    wen <= 1'b1;
    while (i < 5) begin
        data_in <= {$random, $random};
        rd_addr_0 <= i;
        rd_addr_1 <= i;
        wr_addr <= i;
        PPP_sel <= i;
        #CLK_PERIOD;
        $fdisplay(fd, "At time %3d ns, data_in = %h, rd_addr_0 = %d, rd_addr_1 = %d, wr_addr = %d, PPP_sel = %b, data_out_0 = %h, data_out_1 = %h", $time, data_in, rd_addr_0, rd_addr_1, wr_addr, PPP_sel, data_out_0, data_out_1);
        i = i + 1;
    end
    $fclose(fd);
    $finish(2);
end

endmodule