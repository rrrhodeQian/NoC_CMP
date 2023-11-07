`include "./include/imem.v"
`include "./include/dmem.v"
module tb_cardinal_processor;
    parameter ADDR_WIDTH = 32;
    parameter INST_WIDTH = 32;
    parameter DATA_WIDTH = 64;

    reg clk, reset;
    wire [0:ADDR_WIDTH-1] inst_addr;//instruction memory address
    wire [0:INST_WIDTH-1] inst_in;//instruction input from imem
    wire dmem_En, dmem_WrEn;//dmem enable and write enable
    wire [0:ADDR_WIDTH-1] dmem_addr;//dmem address
    wire [0:DATA_WIDTH-1] reg_data;//data output from register file to dmem
    wire [0:DATA_WIDTH-1] dmem_data;//data input from dmem to processor
    wire [0:DATA_WIDTH-1] nic_data;//data input from nic
    wire nicEn, nicWrEn;//nic enable and write enable output
    wire [0:2] nic_addr;//nic register file address
    wire [0:DATA_WIDTH-1] d_out;//data output from register file to nic

    cardinal_processor dut(
        .clk(clk),
        .reset(reset),
        .inst_addr(inst_addr),
        .inst_in(inst_in),
        .dmem_En(dmem_En),
        .dmem_WrEn(dmem_WrEn),
        .dmem_addr(dmem_addr),
        .reg_data(reg_data),
        .dmem_data(dmem_data),
        .nic_data(nic_data),
        .nicEn(nicEn),
        .nicWrEn(nicWrEn),
        .nic_addr(nic_addr),
        .d_out(d_out)
    );

    imem im0(
        .memAddr(inst_addr[22:29]),
        .dataOut(inst_in)
    );

    dmem dm0(
        .clk(clk),
        .memEn(dmem_En),
        .memWrEn(dmem_WrEn),
        .memAddr(dmem_addr[24:31]),
        .dataIn(reg_data),
        .dataOut(dmem_data)
    );

    localparam CLK_PERIOD = 4;
    always #(CLK_PERIOD/2) clk=~clk;

    integer fd1, fd2, fd3, fd4, count;

    initial begin
        fd1 = $fopen("./output_file/RF_content_1.out", "w");
        fd2 = $fopen("./output_file/dmem_content_1.out", "w");

        $readmemh("./test_cases/dmem.fill", dm0.MEM);
        $readmemh("./test_cases/imem_1.fill", im0.MEM);

        clk <= 1'b0;
        reset <= 1'b1;

        #(CLK_PERIOD*3);
        reset <= 1'b0;

        wait (inst_in == 0);
        repeat (8) #(CLK_PERIOD);
    
        for(count = 1; count < 32; count = count + 1)
            $fdisplay(fd1, "%1d: %h", count, dut.RF.mem_array[count]);

        for(count = 0; count < 256; count = count + 1)
            $fdisplay(fd2, "Memory location # %4d : %h", count, dm0.MEM[count]);

        // #(CLK_PERIOD*4);
        // reset <= 1'b1;

        // #(CLK_PERIOD*3);
        // reset <= 1'b0;
        
        // fd3 = $fopen("./output_file/RF_content_2.out", "w");
        // fd4 = $fopen("./output_file/dmem_content_2.out", "w");
        // $readmemh("./test_cases/dmem.fill", dm0.MEM);
        // $readmemh("./test_cases/imem_40.fill", im0.MEM);

        // wait (inst_in == 0);
        // repeat (8) #(CLK_PERIOD);
    
        // for(count = 1; count < 32; count = count + 1)
        //     $fdisplay(fd3, "%1d: %h", count, dut.RF.mem_array[count]);

        // for(count = 0; count < 256; count = count + 1)
        //     $fdisplay(fd4, "Memory location # %4d : %h", count, dm0.MEM[count]);

        $fclose(fd1 | fd2 /*| fd3 | fd4*/);
        $finish;
    end

    initial
    begin
        #1000000;
        $fclose(fd1 | fd2 /*| fd3 | fd4*/);
        $finish;
    end  
endmodule