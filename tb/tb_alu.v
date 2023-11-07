`include "./include/sim_ver/DW01_addsub.v"
`include "./include/sim_ver/DW02_mult.v"
`include "./include/sim_ver/DW_div.v"
`include "./include/sim_ver/DW_sqrt.v"
`include "./include/sim_ver/DW_shifter.v"
module tb_alu;
    parameter DATA_WIDTH = 64;
    reg [0:DATA_WIDTH-1] ALU_in_0, ALU_in_1;
    reg [0:5] func_code;
    reg [0:1] WW;
    wire [0:DATA_WIDTH-1] ALU_out;

    // Definition of function code
    localparam  VAND = 6'b000001,
                VOR = 6'b000010,
                VXOR = 6'b000011,
                VNOT = 6'b000100,
                VMOV = 6'b000101,
                VADD = 6'b000110,
                VSUB = 6'b000111,
                VMULEU = 6'b001000,
                VMULOU = 6'b001001,
                VSLL = 6'b001010,
                VSRL = 6'b001011,
                VSRA = 6'b001100,
                VRTTH = 6'b001101,
                VDIV = 6'b001110,
                VMOD = 6'b001111, 
                VSQEU = 6'b010000,
                VSQOU = 6'b010001,
                VSQRT = 6'b010010;

    // Participation field select mode
    localparam  b_mode = 2'b00,
                h_mode = 2'b01,
                w_mode = 2'b10,
                d_mode = 2'b11;

    // Instantiation of DUT:
    alu dut
    (
        .ALU_in_0(ALU_in_0),
        .ALU_in_1(ALU_in_1),
        .func_code(func_code),
        .WW(WW),
        .ALU_out(ALU_out)
    );

    integer fd;
    initial 
    begin
        fd = $fopen("./output_file/alu.out", "w");
//-----------------------------------------------------------------------------------------------------------------------
// ADD:
        #10
        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        ALU_in_1 = 64'b1;
        func_code = VADD;
        WW = b_mode;
        #1 
        $fdisplay(fd, "ADD: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out);

        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        ALU_in_1 = 64'b1;
        func_code = VADD;
        WW = h_mode;
        #1 
        $fdisplay(fd, "ADD: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out);     

        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        ALU_in_1 = 64'b1;
        func_code = VADD;
        WW = w_mode;
        #1 
        $fdisplay(fd, "ADD: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out);

        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        ALU_in_1 = 64'b1;
        func_code = VADD;
        WW = d_mode;
        #1 
        $fdisplay(fd, "ADD: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h\n", ALU_in_0, ALU_in_1, WW, ALU_out); 

//-----------------------------------------------------------------------------------------------------------------------
// SUB:
        ALU_in_0 = 64'h0;
        ALU_in_1 = 64'b1;
        func_code = VSUB;
        WW = b_mode;
        #1 
        $fdisplay(fd, "SUB: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out);

        ALU_in_0 = 64'h0;
        ALU_in_1 = 64'b1;
        func_code = VSUB;
        WW = h_mode;
        #1 
        $fdisplay(fd, "SUB: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out);     

        ALU_in_0 = 64'h0;
        ALU_in_1 = 64'b1;
        func_code = VSUB;
        WW = w_mode;
        #1 
        $fdisplay(fd, "SUB: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out);

        ALU_in_0 = 64'h0;
        ALU_in_1 = 64'b1;
        func_code = VSUB;
        WW = d_mode;
        #1 
        $fdisplay(fd, "SUB: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h\n", ALU_in_0, ALU_in_1, WW, ALU_out); 

//-----------------------------------------------------------------------------------------------------------------------
// AND:
        ALU_in_0 = 64'hf0_f0_f0_f0_f0_f0_f0_f0;
        ALU_in_1 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VAND;
        WW = b_mode;
        #1 
        $fdisplay(fd, "AND: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out);
//-----------------------------------------------------------------------------------------------------------------------
// OR:
        ALU_in_0 = 64'hf0_f0_f0_f0_f0_f0_f0_f0;
        ALU_in_1 = 64'b0;
        func_code = VOR;
        WW = h_mode;
        #1 
        $fdisplay(fd, "OR: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out);     
//-----------------------------------------------------------------------------------------------------------------------
// XOR:        
        ALU_in_0 = 64'h0;
        ALU_in_1 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VXOR;
        WW = w_mode;
        #1 
        $fdisplay(fd, "XOR: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out);
//-----------------------------------------------------------------------------------------------------------------------
// NOT:
        ALU_in_0 = 64'h0;
        ALU_in_1 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VNOT;
        WW = d_mode;
        #1 
        $fdisplay(fd, "NOT: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 
//-----------------------------------------------------------------------------------------------------------------------
// MOV:
        ALU_in_0 = 64'h12_34_56_78_9a_bc_de_f0;
        ALU_in_1 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VMOV;
        WW = d_mode;
        #1 
        $fdisplay(fd, "MOV: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h\n", ALU_in_0, ALU_in_1, WW, ALU_out); 

//-----------------------------------------------------------------------------------------------------------------------
// MULEU:
        ALU_in_0 = 64'h01_02_03_04_05_06_07_08;
        ALU_in_1 = 64'h01_02_03_04_05_06_07_08;
        func_code = VMULEU;
        WW = b_mode;
        #1 
        $fdisplay(fd, "MULEU: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'h01_02_03_04_05_06_07_08;
        ALU_in_1 = 64'h01_02_03_04_05_06_07_08;
        func_code = VMULEU;
        WW = h_mode;
        #1 
        $fdisplay(fd, "MULEU: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'h01_02_03_04_05_06_07_08;
        ALU_in_1 = 64'h01_02_03_04_05_06_07_08;
        func_code = VMULEU;
        WW = w_mode;
        #1 
        $fdisplay(fd, "MULEU: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h\n", ALU_in_0, ALU_in_1, WW, ALU_out); 

//-----------------------------------------------------------------------------------------------------------------------
// MULOU:
        ALU_in_0 = 64'h01_02_03_04_05_06_07_08;
        ALU_in_1 = 64'h01_02_03_04_05_06_07_08;
        func_code = VMULOU;
        WW = b_mode;
        #1 
        $fdisplay(fd, "MULOU: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'h01_02_03_04_05_06_07_08;
        ALU_in_1 = 64'h01_02_03_04_05_06_07_08;
        func_code = VMULOU;
        WW = h_mode;
        #1 
        $fdisplay(fd, "MULOU: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'h01_02_03_04_05_06_07_08;
        ALU_in_1 = 64'h01_02_03_04_05_06_07_08;
        func_code = VMULOU;
        WW = w_mode;
        #1 
        $fdisplay(fd, "MULOU: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h\n", ALU_in_0, ALU_in_1, WW, ALU_out);

//-----------------------------------------------------------------------------------------------------------------------
// SQEU:
        ALU_in_0 = 64'h01_02_03_04_05_06_07_08;
        ALU_in_1 = 64'h01_02_03_04_05_06_07_08;
        func_code = VSQEU;
        WW = b_mode;
        #1 
        $fdisplay(fd, "SQEU: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'h01_02_03_04_05_06_07_08;
        ALU_in_1 = 64'h01_02_03_04_05_06_07_08;
        func_code = VSQEU;
        WW = h_mode;
        #1 
        $fdisplay(fd, "SQEU: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'h01_02_03_04_05_06_07_08;
        ALU_in_1 = 64'h01_02_03_04_05_06_07_08;
        func_code = VSQEU;
        WW = w_mode;
        #1 
        $fdisplay(fd, "SQEU: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h\n", ALU_in_0, ALU_in_1, WW, ALU_out);

//-----------------------------------------------------------------------------------------------------------------------
// SQOU:
        ALU_in_0 = 64'h01_02_03_04_05_06_07_08;
        ALU_in_1 = 64'h01_02_03_04_05_06_07_08;
        func_code = VSQOU;
        WW = b_mode;
        #1 
        $fdisplay(fd, "SQOU: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'h01_02_03_04_05_06_07_08;
        ALU_in_1 = 64'h01_02_03_04_05_06_07_08;
        func_code = VSQOU;
        WW = h_mode;
        #1 
        $fdisplay(fd, "SQOU: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'h01_02_03_04_05_06_07_08;
        ALU_in_1 = 64'h01_02_03_04_05_06_07_08;
        func_code = VSQOU;
        WW = w_mode;
        #1 
        $fdisplay(fd, "SQOU: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h\n", ALU_in_0, ALU_in_1, WW, ALU_out);

//-----------------------------------------------------------------------------------------------------------------------
// DIV:
        ALU_in_0 = 64'ha5_a5_a5_a5_a5_a5_a5_a5;
        ALU_in_1 = 64'h99_99_99_99_99_99_99_99;
        func_code = VDIV;
        WW = b_mode;
        #1 
        $fdisplay(fd, "DIV: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        ALU_in_1 = 64'h02_02_02_02_02_02_02_02;
        func_code = VDIV;
        WW = h_mode;
        #1 
        $fdisplay(fd, "DIV: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        ALU_in_1 = 64'h02_02_02_02_02_02_02_02;
        func_code = VDIV;
        WW = w_mode;
        #1 
        $fdisplay(fd, "DIV: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        ALU_in_1 = 64'h02_02_02_02_02_02_02_02;
        func_code = VDIV;
        WW = d_mode;
        #1 
        $fdisplay(fd, "DIV: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h\n", ALU_in_0, ALU_in_1, WW, ALU_out); 

//-----------------------------------------------------------------------------------------------------------------------
// MOD:
        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        ALU_in_1 = 64'h02_02_02_02_02_02_02_02;
        func_code = VMOD;
        WW = b_mode;
        #1 
        $fdisplay(fd, "MOD: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        ALU_in_1 = 64'h02_02_02_02_02_02_02_02;
        func_code = VMOD;
        WW = h_mode;
        #1 
        $fdisplay(fd, "MOD: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        ALU_in_1 = 64'h02_02_02_02_02_02_02_02;
        func_code = VMOD;
        WW = w_mode;
        #1 
        $fdisplay(fd, "MOD: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        ALU_in_1 = 64'h02_02_02_02_02_02_02_02;
        func_code = VMOD;
        WW = d_mode;
        #1 
        $fdisplay(fd, "MOD: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h\n", ALU_in_0, ALU_in_1, WW, ALU_out); 

//-----------------------------------------------------------------------------------------------------------------------
// SQRT:
        ALU_in_0 = 64'h40_40_40_40_40_40_40_40;
        ALU_in_1 = 64'hx;
        func_code = VSQRT;
        WW = b_mode;
        #1 
        $fdisplay(fd, "SQRT: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'h40_00_40_00_40_00_40_00;
        ALU_in_1 = 64'hx;
        func_code = VSQRT;
        WW = h_mode;
        #1 
        $fdisplay(fd, "SQRT: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out);  

        ALU_in_0 = 64'h40_00_00_00_40_00_00_00;
        ALU_in_1 = 64'hx;
        func_code = VSQRT;
        WW = w_mode;
        #1 
        $fdisplay(fd, "SQRT: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'h4000000000000000;
        ALU_in_1 = 64'hx;
        func_code = VSQRT;
        WW = d_mode;
        #1 
        $fdisplay(fd, "SQRT: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h\n", ALU_in_0, ALU_in_1, WW, ALU_out); 

//-----------------------------------------------------------------------------------------------------------------------
// SLL:
        ALU_in_1 = 64'hf4_f4_f4_f4_f4_f4_f4_f4; // shift 4 bits
        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSLL;
        WW = b_mode;
        #1 
        $fdisplay(fd, "SLL: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h, ", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_1 = 64'hf8_f8_f8_f8_f8_f8_f8_f8; // shift 8 bits
        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSLL;
        WW = h_mode;
        #1 
        $fdisplay(fd, "SLL: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h, ", ALU_in_0, ALU_in_1, WW, ALU_out);   

        ALU_in_1 = 64'hf0_f0_f0_f0_f0_f0_f0_f0; // shift 16 bits
        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSLL;
        WW = w_mode;
        #1 
        $fdisplay(fd, "SLL: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h, ", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_1 = 64'h00_00_00_00_00_00_00_20; // shift 32 bits
        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSLL;
        WW = d_mode;
        #1 
        $fdisplay(fd, "SLL: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h, \n", ALU_in_0, ALU_in_1, WW, ALU_out);  

//-----------------------------------------------------------------------------------------------------------------------
// SRL:
        ALU_in_1 = 64'hf4_f4_f4_f4_f4_f4_f4_f4; // shift 4 bits
        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSRL;
        WW = b_mode;
        #1 
        $fdisplay(fd, "SRL: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h, ", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_1 = 64'hf8_f8_f8_f8_f8_f8_f8_f8; // shift 8 bits
        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSRL;
        WW = h_mode;
        #1 
        $fdisplay(fd, "SRL: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h, ", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_1 = 64'hf0_f0_f0_f0_f0_f0_f0_f0; // shift 16 bits
        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSRL;
        WW = w_mode;
        #1 
        $fdisplay(fd, "SRL: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h, ", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_1 = 64'he0_e0_e0_e0_e0_e0_e0_e0; // shift 32 bits
        ALU_in_0 = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSRL;
        WW = d_mode;
        #1 
        $fdisplay(fd, "SRL: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h, \n", ALU_in_0, ALU_in_1, WW, ALU_out); 

//-----------------------------------------------------------------------------------------------------------------------
// SRA:
        ALU_in_1 = 64'hf4_f4_f4_f4_f4_f4_f4_f4; // shift 4 bits
        ALU_in_0 = 64'h80_80_80_80_80_80_80_80;
        func_code = VSRA;
        WW = b_mode;
        #1 
        $fdisplay(fd, "SRA: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h, ", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_1 = 64'hf8_f8_f8_f8_f8_f8_f8_f8; // shift 8 bits
        ALU_in_0 = 64'h80_80_80_80_80_80_80_80;
        func_code = VSRA;
        WW = h_mode;
        #1 
        $fdisplay(fd, "SRA: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h, ", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_1 = 64'hf0_f0_f0_f0_f0_f0_f0_f0; // shift 16 bits
        ALU_in_0 = 64'h80_80_80_80_80_80_80_80;
        func_code = VSRA;
        WW = w_mode;
        #1 
        $fdisplay(fd, "SRA: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h, ", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_1 = 64'he0_e0_e0_e0_e0_e0_e0_e0; // shift 32 bits
        ALU_in_0 = 64'h80_80_80_80_80_80_80_80;
        func_code = VSRA;
        WW = d_mode;
        #1 
        $fdisplay(fd, "SRA: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h, \n", ALU_in_0, ALU_in_1, WW, ALU_out);  

//-----------------------------------------------------------------------------------------------------------------------
// RTTH:
        ALU_in_0 = 64'h00_01_02_03_04_05_06_07;
        ALU_in_1 = 64'bx;
        func_code = VRTTH;
        WW = b_mode;
        #1 
        $fdisplay(fd, "RTTH: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'h00_01_02_03_04_05_06_07;
        ALU_in_1 = 64'bx;
        func_code = VRTTH;
        WW = h_mode;
        #1 
        $fdisplay(fd, "RTTH: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'h00_01_02_03_04_05_06_07;
        ALU_in_1 = 64'bx;
        func_code = VRTTH;
        WW = w_mode;
        #1 
        $fdisplay(fd, "RTTH: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h", ALU_in_0, ALU_in_1, WW, ALU_out); 

        ALU_in_0 = 64'h00_01_02_03_04_05_06_07;
        ALU_in_1 = 64'bx;
        func_code = VRTTH;
        WW = d_mode;
        #1 
        $fdisplay(fd, "RTTH: ALU_in_0 = %h, ALU_in_1 = %h, WW = %b, ALU_out = %h\n", ALU_in_0, ALU_in_1, WW, ALU_out);
//-----------------------------------------------------------------------------------------------------------------------

        #10
        $fclose(fd);
        $finish;

    end
endmodule