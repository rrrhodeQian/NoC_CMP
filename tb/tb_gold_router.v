module tb_gold_router;
    parameter PAC_WIDTH = 64;
    reg clk, reset;
    reg cwsi, ccwsi, pesi;
    wire cwri, ccwri, peri;
    reg [PAC_WIDTH-1:0] cwdi, ccwdi, pedi;
    reg cwro, ccwro, pero;
    wire cwso, ccwso, peso;
    wire [PAC_WIDTH-1:0] cwdo, ccwdo, pedo;
    wire polarity;
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

    initial begin
        fd = $fopen("./output_file/gold_router.out", "w");
        if (!fd) begin
            $fdisplay(fd, "File cannot be opened.");
            $finish;
        end
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
        cwsi <= 1;
        $fdisplay(fd, "clockwise data flow, hop = 1");
        for(i = 0; i < 10; i = i + 1) begin
            $fdisplay(fd, "At time %3d ns, polarity = %b, cwdi = %h, cwdo = %h", $time, polarity, cwdi, cwdo);
            cwdi[63] <= ~cwdi[63];// vc
            cwdi[62] <= 1'b0; // dir = clockwise
            cwdi[55:48] <= 8'b0000_0001; // hop
            cwdi[47:0] <= $random;
            #(CLK_PERIOD);
        end

        #(CLK_PERIOD*6);
        cwsi <= 0;
        ccwsi <= 1;
        $fdisplay(fd, "counter-clockwise data flow, hop = 2");
        for(i = 0; i < 10; i = i + 1) begin
            $fdisplay(fd, "At time %3d ns, polarity = %b, ccwdi = %h, ccwdo = %h", $time, polarity, ccwdi, ccwdo);
            ccwdi[63] <= ~ccwdi[63];// vc
            ccwdi[62] <= 1'b1; // dir = counter clockwise
            ccwdi[55:48] <= 8'b0000_0011; // hop
            ccwdi[47:0] <= $random;
            #(CLK_PERIOD);
        end

        #(CLK_PERIOD*6);
        $fdisplay(fd, "counter-clockwise data flow, hop = 0");
        for(i = 0; i < 10; i = i + 1) begin
            $fdisplay(fd, "At time %3d ns, polarity = %b, ccwdi = %h, pedo = %h", $time, polarity, ccwdi, pedo);
            ccwdi[63] <= ~ccwdi[63];// vc
            ccwdi[62] <= 1'b1; // dir = counter clockwise
            ccwdi[55:48] <= 8'b0000_0000; // hop
            ccwdi[47:0] <= $random;
            #(CLK_PERIOD);
        end

        #(CLK_PERIOD*6);
        ccwsi <= 0;
        pesi <= 1;
        $fdisplay(fd, "data from pe, hop = 1");
        for(i = 0; i < 10; i = i + 1) begin
            $fdisplay(fd, "At time %3d ns, polarity = %b, pedi = %h, cwdo = %h, ccwdo = %h", $time, polarity, pedi, cwdo, ccwdo);
            pedi[63] <= ~pedi[63];//change virtual channel every clock cycle
            pedi[62] <= ~pedi[62];//change direction every clock cycle
            pedi[55:48] <= 8'b0000_0001; //hop
            pedi[47:0] = $random;
            #(CLK_PERIOD);
        end

        #(CLK_PERIOD*6);
        ccwsi <= 1;
        pesi <= 0;
        cwsi <= 1;
        pedi <= 'b0;
        cwdi <= 'b0;
        $fdisplay(fd, "data congestion test");
        // for(i = 0; i < 10; i = i + 1) begin
            ccwdi[62] <= 0;
            ccwdi[55:48] <= 8'b0000_0000;
            ccwdi[47:0] = $random;
            cwdi[62] <= 0;
            cwdi[55:48] <= 8'b0000_0000;
            cwdi[47:0] <= $random;
            #(CLK_PERIOD);
            $fdisplay(fd, "At time %3d ns, polarity = %b, pedi = %h, cwdi = %h, ccwdi = %h, cwdo = %h, ccwdo = %h, pedo = %h", $time, polarity, pedi, cwdi, ccwdi, cwdo, ccwdo, pedo);
            #(CLK_PERIOD*2);
            $fdisplay(fd, "At time %3d ns, polarity = %b, pedi = %h, cwdi = %h, ccwdi = %h, cwdo = %h, ccwdo = %h, pedo = %h", $time, polarity, pedi, cwdi, ccwdi, cwdo, ccwdo, pedo);
        // end

        #(CLK_PERIOD*4);
        $fclose(fd);
        $finish;
    end
endmodule