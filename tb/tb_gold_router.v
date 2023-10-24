module tb_gold_router;
    parameter PAC_WIDTH = 64;
    reg clk, polarity, reset;
    reg cwsi, ccwsi, pesi;
    wire cwri, ccwri, peri;
    reg [PAC_WIDTH-1:0] cwdi, ccwdi, pedi;
    reg cwro, ccwro, pero;
    wire cwso, ccwso, peso;
    wire [PAC_WIDTH-1:0] cwdo, ccwdo, pedo;
    integer fd, i;

    gold_router dut(
        .clk(clk), .reset(reset), .polarity(polarity),
        .cwsi(cwsi), .cwri(cwri), .cwdi(cwdi),
        .ccwsi(ccwsi), .ccwri(ccwri), .ccwdi(ccwdi),
        .pesi(pesi), .peri(peri), .pedi(pedi),
        .cwso(cwso), .cwro(cwro), .cwdo(cwdo),
        .ccwso(ccwso), .ccwro(ccwro), .ccwdo(ccwdo),
        .peso(peso), .pero(pero), .pedo(pedo)
    );

    localparam CLK_PERIOD = 4;
    always #(CLK_PERIOD/2) clk=~clk;

    always @(posedge clk) begin
        if(reset) polarity <= 1'b0;
        else polarity <= ~ polarity;
    end

    initial begin
        fd = $fopen("./output_file/gold_router.out", "w");
        if (!fd) begin
            $fdisplay(fd, "File cannot be opened.");
            $finish;
        end
        $fmonitor(fd, "At time %3d ns, polarity = %b, cwdi = %h, ccwdo = %h", $time, polarity, cwdi, ccwdo);
    end
    
    initial begin
        clk <= 1;
        reset <= 1;
        cwsi <= 0;
        ccwsi <= 0;
        pesi <= 0;
        cwro <= 1;
        ccwro <= 1;
        pero <= 1;
        cwdi <= 'b0;
        ccwdi <= 'b0;
        pedi <= 'b0;

        #(CLK_PERIOD*3);
        reset <= 0;
        for(i = 0; i < 10; i = i + 1) begin
            cwsi <= 1;
            // ccwdi <= {1'b0, 1'b1, 6'b0, 8'b1111_1111, 48'b11111};
            cwdi[63] <= ~cwdi[63];// vc
            cwdi[62] <= 1'b0; // dir
            cwdi[55:48] <= 8'b0000_0001; // hop
            cwdi[47:0] <= $random;
            
            // pesi = 1;
            // pedi = {1'b0, 1'b1, 6'b0, 8'b1111_1111, 48'b0};
            // pedi[63] = {i + 1}; // vc
            // pedi[55-:8] = 0; // hop
            // pedi[62] = 1; // dir
            #(CLK_PERIOD);
        end

        #(CLK_PERIOD*3);
        $fclose(fd);
        $finish;
    end
endmodule