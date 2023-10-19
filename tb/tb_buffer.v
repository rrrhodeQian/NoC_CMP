module tb_buffer;
parameter PAC_WIDTH = 64;
reg clk, reset, wen, ren;
reg [PAC_WIDTH-1:0] d_in;
wire full, empty;
wire [PAC_WIDTH-1:0] d_out;
// integer fd;

buffer dut(
    .reset(reset),
    .clk(clk),
    .wen(wen),
    .ren(ren),
    .d_in(d_in),
    .full(full),
    .empty(empty),
    .d_out(d_out)
);

localparam CLK_PERIOD = 4;
always #(CLK_PERIOD/2) clk=~clk;


initial begin
    reset <= 1'b0;
    clk <= 1'b0;
    wen <= 1'b0;
    ren <= 1'b0;
    d_in <= 'b0;
    #(CLK_PERIOD) reset <= 1'b1;
    #(CLK_PERIOD) reset <= 1'b0;
    //writing test
    d_in <= {$random, $random} ;
    wen <= 1'b1;
    #(CLK_PERIOD) wen <= 1'b0;
    //reading test
    #(CLK_PERIOD*3) ren <= 1'b1;
    #(CLK_PERIOD*2) d_in <= {$random, $random};
    ren <= 1'b0;
    #(CLK_PERIOD*2) wen <= 1'b1;
    #(CLK_PERIOD);
    repeat(2) begin
        d_in <= {$random, $random};//data should not be stored because the buffer is full
    end
    #(CLK_PERIOD*3);
    $finish;
end

endmodule