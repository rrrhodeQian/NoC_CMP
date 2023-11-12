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

    integer fd1, fd2, count, i;
    time start_time, end_time;
    real run_time, throughput;


    initial begin
        //Test with all provided imem.fill files and compare with expected_dmem.dump
        //To change which imem.fill to be read, change the file name, as well as the dmem_content.out name
        fd1 = $fopen("./output_file/dmem_content_41.out", "w");
        fd2 = $fopen("./output_file/forwarding_help.out", "w");
        $readmemh("./test_cases/dmem.fill", dm0.MEM);
        $readmemh("./test_cases/imem_41.fill", im0.MEM);
        $fmonitor(fd2, "At time %3d ns, fw_rA_sel = %b, fw_rB_sel = %b, ALU_in_0 = %h, ALU_in_1 = %h, data_WB = %h, ID_EXM_reg[5:68] = %h, ID_EXM_reg[69:132] = %h", $time, dut.fw_rA_sel, dut.fw_rB_sel, dut.ALU_in_0, dut.ALU_in_1, dut.data_WB, dut.ID_EXM_reg[5:68], dut.ID_EXM_reg[69:132]);

        i = 0;
        while (im0.MEM[i] != 'h0) begin
            i = i + 1;
        end

        clk <= 1'b0;
        reset <= 1'b1;

        #(CLK_PERIOD*3);
        reset <= 1'b0;
        start_time = $time;

        wait (inst_in == 0);
        #(CLK_PERIOD*3);
        end_time = $time;
        repeat (8) #(CLK_PERIOD);

        run_time = end_time - start_time;
        throughput = (i/run_time)*1000;
        $display("i = %d, run_time = %d", i, run_time);
        $display("Average throughput = %f MIPS", throughput);
        for(count = 0; count < 128; count = count + 1)
            $fdisplay(fd1, "Memory location # %4d : %h", count, dm0.MEM[count]);

        $fclose(fd1|fd2);
        $finish;
    end

    initial
    begin
        //watchdog timer
        #100000;
        $fclose(fd1|fd2);
        $finish;
    end
endmodule