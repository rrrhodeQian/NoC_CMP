module tb_arbiter;
reg clk, reset, rq0, rq1;
wire gt0, gt1;
integer fd;

arbiter dut(
    .reset(reset),
    .clk(clk),
    .rq0(rq0),
    .rq1(rq1),
    .gt0(gt0),
    .gt1(gt1)
);

localparam CLK_PERIOD = 4;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    fd = $fopen("./output_file/arbiter.out", "w");

    if (!fd) begin
        $fdisplay(fd, "File cannot be opened");
    end

    $fmonitor(fd, "At time %2d ns, rq0 = %b, rq1 = %b, gt0 = %b, gt1 = %b", $time, rq0, rq1, gt0, gt1);
end

initial begin
    reset <= 1'b1;
    clk <= 1'b0;
    rq0 <= 1'b0;
    rq1 <= 1'b0;
    #(CLK_PERIOD*2) reset <= 1'b0;
    rq0 <= 1'b1;
    rq1 <= 1'b1;
    #(CLK_PERIOD*6);
    rq0 <= 1'b0;
    #(CLK_PERIOD*4);
    rq1 <= 1'b0;
    #(CLK_PERIOD*4);
    $finish(2);
end

endmodule