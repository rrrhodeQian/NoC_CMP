module cardinal_processor (
    clk, reset, inst_addr, inst_in, dmem_En, dmem_WrEn, dmem_addr, reg_data, dmem_data,
    nic_data, nicEn, nicWrEn, nic_addr, d_out 
);
    parameter ADDR_WIDTH = 32;
    parameter INST_WIDTH = 32;
    parameter DATA_WIDTH = 64;

    input clk, reset;
    output [0:ADDR_WIDTH-1] inst_addr;//instruction memory address
    input [0:INST_WIDTH-1] inst_in;//instruction input from imem
    output reg dmem_En, dmem_WrEn;//dmem enable and write enable
    output [0:ADDR_WIDTH-1] dmem_addr;//dmem address
    output [0:DATA_WIDTH-1] reg_data;//data output from register file to dmem
    input [0:DATA_WIDTH-1] dmem_data;//data input from dmem to processor
    input [0:DATA_WIDTH-1] nic_data;//data input from nic
    output nicEn, nicWrEn;//nic enable and write enable output
    output [0:2] nic_addr;//nic register file address
    output [0:DATA_WIDTH-1] d_out;//data output from register file to nic

    localparam  R_ALU = 6'b101010,
                R_BEZ = 6'b100010,
                R_BNEZ = 6'b100011,
                R_NOP = 6'b111100,
                M_LD = 6'b100000,
                M_SD = 6'b100001;
    
    localparam  mode_a = 3'b000,//all subfield participate
                mode_u = 3'b001,//upper 32-bit participate
                mode_d = 3'b010,//lower 32-bit participate
                mode_e = 3'b011,//subfields with even index participate
                mode_o = 3'b100;//subfields with odd index participate
    
    reg [0:32] IF_ID_reg;//IF_ID stage register
    reg [0:160] ID_EXM_reg;//ID_EXM stage register
    reg [0:137] EXM_WB_reg;//EXM_WB stage register

    //signals generated in IF stage
    reg [0:ADDR_WIDTH-1] PC;//program counter

    //signals generated in ID stage
    reg beq;//raw branch if equal signal
    reg bneq;//raw branch if not equal signal
    wire branch_q;//qulified branch signal
    reg stall;//stall signal
    reg reg_write_ID;//register write signal
    reg rB_rD_sel;//select signal for reading address rB or rD, 0 means rB
    reg L_local_external_ID;//load local dmem or external nic data, 0 means local
    reg R_L_mode_ID;//R type or LD operation mode select, 0 means R type
    reg nicEn_ID;//nic enable signal
    reg nicWrEn_ID;//nic write enable signal
    reg store;//indicate a store register instruction
    wire [0:1] nic_addr_ID;//nic read address
    wire flush_ID;//flush signal
    wire [0:ADDR_WIDTH-1] imme_addr;//immediate address
    wire [0:DATA_WIDTH-1] reg_file_dout_0;//register file data on data output port 0
    wire [0:DATA_WIDTH-1] reg_file_dout_1;//register file data on data output port 1
    wire [0:ADDR_WIDTH-1] br_addr;//branch address
    wire [0:4] rD_ID;//rD in ID stage
    wire [0:4] rA_ID;//rA in ID stage
    wire [0:4] rB_ID;//rB in ID stage
    wire [0:4] source_ID_1;

    //signals generated in EXM stage
    reg fw_rA_sel, fw_rB_sel;//select signal for forward mux pair in EXM stage
    wire [0:4] rD_EXM;
    wire [0:DATA_WIDTH-1] ALU_in_0, ALU_in_1;//ALU input 0 and 1 after forwarding mux
    wire [0:DATA_WIDTH-1] ALU_out;//ALU output
    wire [0:4] rA_EXM;//rA in EXM stage
    wire [0:4] rB_EXM;//rB in EXM stage
    wire [0:2] PPP_EXM;
    wire [0:1] WW_EXM;
    wire [0:5] func_EXM;
    wire [0:DATA_WIDTH-1] load_data;//data to be loaded in EXM_WB stage register after mux
    wire reg_write_EXM;
    wire L_local_external_EXM;

    //signals generated in WB stage
    wire [0:4] rD_WB;
    wire [0:DATA_WIDTH-1] alu_result_WB;
    wire [0:DATA_WIDTH-1] load_data_WB;
    wire [0:DATA_WIDTH-1] data_WB;//data to be write back to RF
    wire [0:2] PPP_WB;
    wire reg_write_WB;
    wire R_L_mode_WB;


    //register file instantiation
    register_file RF(
        .clk(clk),
        .reset(reset),
        .wen(reg_write_WB),
        .data_in(data_WB),
        .PPP_sel(PPP_WB),
        .wr_addr(rD_WB),
        .data_out_0(reg_file_dout_0),
        .data_out_1(reg_file_dout_1),
        .rd_addr_0(rA_ID),
        .rd_addr_1(source_ID_1)
    );

    //ALU instantiation
    alu alu1(
        .ALU_in_0(ALU_in_0),
        .ALU_in_1(ALU_in_1),
        .WW(WW_EXM),
        .func_code(func_EXM),
        .ALU_out(ALU_out)
    );

    assign inst_addr = PC;
    //control logic in ID stage
    assign flush_ID = ~IF_ID_reg[32];
    assign imme_addr = {16'b0, IF_ID_reg[16:31]};//0 append immediate address from instruction[16:31]
    assign nic_addr_ID = imme_addr[30:31];//address for nic registers
    assign branch_q = ((beq && (reg_file_dout_0 == 64'b0)) || (bneq && (reg_file_dout_0 != 64'b0))) ? 1'b1 : 1'b0;//assert branch qualified if beq and (rD) == 0 or bneq and (rD) != 0
    assign reg_data = reg_file_dout_1;
    assign d_out = reg_file_dout_1;
    assign dmem_addr = imme_addr;
    assign br_addr = imme_addr;
    assign source_ID_1 = (!rB_rD_sel) ? IF_ID_reg[16:20] : IF_ID_reg[6:10];//select rB for read address 1 if rB_rD_sel is 0
    assign rD_ID = IF_ID_reg[6:10];
    assign rA_ID = IF_ID_reg[11:15];
    assign rB_ID = IF_ID_reg[16:20];

    //control logic in EXM stage
    assign rD_EXM = ID_EXM_reg[0:4];
    assign ALU_in_0 = (!fw_rA_sel) ? ID_EXM_reg[5:68] : data_WB;
    assign ALU_in_1 = (!fw_rB_sel) ? ID_EXM_reg[69:132] : data_WB;
    assign rA_EXM = ID_EXM_reg[133:137];
    assign rB_EXM = ID_EXM_reg[138:142];
    assign PPP_EXM = ID_EXM_reg[143:145];
    assign WW_EXM = ID_EXM_reg[146:147];
    assign func_EXM = ID_EXM_reg[148:153];
    assign nic_addr = ID_EXM_reg[154:155];
    assign nicEn = ID_EXM_reg[156];
    assign nicWrEn = ID_EXM_reg[157];
    assign reg_write_EXM = ID_EXM_reg[158];
    assign L_local_external_EXM = ID_EXM_reg[159];
    assign load_data = (!L_local_external_EXM) ? dmem_data : nic_data;
    assign R_L_mode_EXM = ID_EXM_reg[160];

    //control logic in WB stage
    assign rD_WB = EXM_WB_reg[0:4];
    assign alu_result_WB = EXM_WB_reg[5:68];
    assign load_data_WB = EXM_WB_reg[69:132];
    assign PPP_WB = EXM_WB_reg[133:135];
    assign reg_write_WB = EXM_WB_reg[136];
    assign R_L_mode_WB = EXM_WB_reg[137];
    assign data_WB = (!R_L_mode_WB) ? alu_result_WB : load_data_WB;


    always @(*) begin
        //Harzard Detection Unit
        //if there's a store inst in ID stage, R type/load inst in EXM stage, source ID = destination ID    OR    there's a branch inst in ID stage and R type/load inst in EXM stage, two sources ID = destination ID
        if ((store && reg_write_EXM && (rD_EXM == rD_ID)) || (branch_q && reg_write_EXM && ((rD_EXM == rA_ID) || (rD_EXM == rB_ID))))
            stall = 1'b1;
        else
            stall = 1'b0;

        //Forwarding Unit
        if (reg_write_WB && (rA_EXM == rD_WB))
            fw_rA_sel = 1'b1;
        else
            fw_rA_sel = 1'b0;
        
        if (reg_write_WB && (rB_EXM == rD_WB))
            fw_rB_sel = 1'b1;
        else
            fw_rB_sel = 1'b0;

        //control signals in ID stage generation
        if (stall) begin//if stalled, clear all control signals
            reg_write_ID = 1'b0;
            nicEn_ID = 1'b0;
            nicWrEn_ID = 1'b0;
            dmem_En = 1'b0;
            dmem_WrEn = 1'b0;
            beq = 1'b0;
            bneq = 1'b0;
            rB_rD_sel = 1'b0;
            L_local_external_ID = 1'b0;
            R_L_mode_ID = 1'b0;
            store = 1'b0;
        end
        else begin//if not stalled
            if (flush_ID) begin//if branch is taken, clear all control signals
                reg_write_ID = 1'b0;
                nicEn_ID = 1'b0;
                nicWrEn_ID = 1'b0;
                dmem_En = 1'b0;
                dmem_WrEn = 1'b0;
                beq = 1'b0;
                bneq = 1'b0;
                rB_rD_sel = 1'b0;
                L_local_external_ID = 1'b0;
                R_L_mode_ID = 1'b0;
                store = 1'b0;
            end
            else begin
                case (IF_ID_reg[0:5])
                    R_ALU: begin
                        reg_write_ID = 1'b1;
                        nicEn_ID = 1'b0;
                        nicWrEn_ID = 1'b0;
                        dmem_En = 1'b0;
                        dmem_WrEn = 1'b0;
                        beq = 1'b0;
                        bneq = 1'b0;
                        rB_rD_sel = 1'b0;
                        L_local_external_ID = 1'b0;
                        R_L_mode_ID = 1'b0;
                        store = 1'b0;
                    end
                    M_LD: begin
                        reg_write_ID = 1'b1;
                        beq = 1'b0;
                        bneq = 1'b0;
                        rB_rD_sel = 1'b0;//don't care in this mode, set to 0
                        R_L_mode_ID = 1'b1;//load mode
                        store = 1'b0;
                        if (IF_ID_reg[16:17] == 2'b11) begin//the address refers to nic register
                            //enable read from nic input channel buffer
                            nicEn_ID = 1'b1;
                            nicWrEn_ID = 1'b0;
                            //disable read from dmem
                            dmem_En = 1'b0;
                            dmem_WrEn = 1'b0;
                            L_local_external_ID = 1'b1;//select data from external nic
                        end
                        else begin//the address refers to local dmem
                            //disable read from nic input channel buffer
                            nicEn_ID = 1'b0;
                            nicWrEn_ID = 1'b0;
                            //enable read from dmem
                            dmem_En = 1'b1;
                            dmem_WrEn = 1'b0;
                            L_local_external_ID = 1'b0;//select data form dmem
                        end
                    end
                    M_SD: begin
                        reg_write_ID = 1'b0;
                        beq = 1'b0;
                        bneq = 1'b0;
                        rB_rD_sel = 1'b1;//select rD as read source address
                        R_L_mode_ID = 1'b0;
                        store = 1'b1;
                        if (IF_ID_reg[16:17] == 2'b11) begin//the address refers to nic register
                            //enable write to nic output channel buffer
                            nicEn_ID = 1'b1;
                            nicWrEn_ID = 1'b1;
                            //disable write to dmem
                            dmem_En = 1'b0;
                            dmem_WrEn = 1'b0;
                            L_local_external_ID = 1'b0;
                        end
                        else begin//the address refers to local dmem
                            //disable write to output channle buffer
                            nicEn_ID = 1'b0;
                            nicWrEn_ID = 1'b0;
                            //enable write to dmem
                            dmem_En = 1'b1;
                            dmem_WrEn = 1'b1;
                            L_local_external_ID = 1'b0;
                        end
                    end
                    R_BEZ: begin
                        reg_write_ID = 1'b0;//not register writing
                        beq = 1'b1;
                        bneq = 1'b0;
                        rB_rD_sel = 1'b1;//select rD as read source address
                        R_L_mode_ID = 1'b0;//don't care, set to 0
                        //nither a nic or dmem operation
                        nicEn_ID = 1'b0;
                        nicWrEn_ID = 1'b0;
                        dmem_En = 1'b0;
                        dmem_WrEn = 1'b0;
                        L_local_external_ID = 1'b0;
                        store = 1'b0;
                    end
                    R_BNEZ: begin//same as R_BNEZ
                        reg_write_ID = 1'b0;//not register writing
                        beq = 1'b0;
                        bneq = 1'b1;
                        rB_rD_sel = 1'b1;//select rD as read source address
                        R_L_mode_ID = 1'b0;//don't care, set to 0
                        //nither a nic or dmem operation
                        nicEn_ID = 1'b0;
                        nicWrEn_ID = 1'b0;
                        dmem_En = 1'b0;
                        dmem_WrEn = 1'b0;
                        L_local_external_ID = 1'b0;
                        store = 1'b0;
                    end
                    R_NOP: begin//NOP, set all control signals to 0
                        reg_write_ID = 1'b0;
                        nicEn_ID = 1'b0;
                        nicWrEn_ID = 1'b0;
                        dmem_En = 1'b0;
                        dmem_WrEn = 1'b0;
                        beq = 1'b0;
                        bneq = 1'b0;
                        rB_rD_sel = 1'b0;
                        L_local_external_ID = 1'b0;
                        R_L_mode_ID = 1'b0;
                        store = 1'b0;
                    end
                    default: begin//invalid opcode, clear all control signals
                        reg_write_ID = 1'b0;
                        nicEn_ID = 1'b0;
                        nicWrEn_ID = 1'b0;
                        dmem_En = 1'b0;
                        dmem_WrEn = 1'b0;
                        beq = 1'b0;
                        bneq = 1'b0;
                        rB_rD_sel = 1'b0;
                        L_local_external_ID = 1'b0;
                        R_L_mode_ID = 1'b0;
                        store = 1'b0;
                    end
                endcase
            end
        end
    end

    /*IF_ID stage register bits allocation
    IF_ID_reg[0:5] = opcode
    IF_ID_reg[6:10] = rD
    IF_ID_reg[11:15] = rA
    IF_ID_reg[16:20] = rB
    IF_ID_reg[21:23] = PPP
    IF_ID_reg[24:25] = WW
    IF_ID_reg[26:31] = func
    IF_ID_reg[32] = WBFF
    ------------------------------------*/

    /*ID_EXM stage register bits allocation
    ID_EXM_reg[0:4] = rD
    ID_EXM_reg[5:68] = (rA)
    ID_EXM_reg[69:132] = (rB)
    ID_EXM_reg[133:137] = rA
    ID_EXM_reg[138:142] = rB
    ID_EXM_reg[143:145] = PPP
    ID_EXM_reg[146:147] = WW
    ID_EXM_reg[148:153] = func
    ID_EXM_reg[154:155] = nic_addr
    ID_EXM_reg[156] = nicEn
    ID_EXM_reg[157] = nicWrEn
    ID_EXM_reg[158] = reg_write
    ID_EXM_reg[159] = L_local_external
    ID_EXM_reg[160] = R_L_mode
    ------------------------------------*/

    always @(posedge clk) begin
        if (reset) begin
            PC <= 'b0;
            IF_ID_reg <= 'b0;
            ID_EXM_reg <= 'b0;
            EXM_WB_reg <= 'b0;
        end
        else begin
            //PC and IF_ID register update
            if (!stall) begin
                //if not stalled, update IF_ID stage register
                IF_ID_reg[0:31] <= inst_in;
                IF_ID_reg[32] <= ~branch_q;
                //program counter
                if (branch_q)
                    PC <= imme_addr;
                else
                    PC <= PC + 4;
            end
            else begin//if stalled, keep the last value
                PC <= PC;
                IF_ID_reg <= IF_ID_reg;
            end

            //ID_EXM and EXM_WB register update
            ID_EXM_reg <= {rD_ID, reg_file_dout_0, reg_file_dout_1, IF_ID_reg[11:15], IF_ID_reg[16:20], IF_ID_reg[21:23], IF_ID_reg[24:25], IF_ID_reg[26:31], 
                            nic_addr_ID, nicEn_ID, nicWrEn_ID, reg_write_ID, L_local_external_ID, R_L_mode_ID};
            
            EXM_WB_reg <= {rD_EXM, ALU_out, load_data, PPP_EXM, reg_write_EXM, R_L_mode_EXM};
        end
    end
    
endmodule