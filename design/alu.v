`include "./include/sim_ver/DW01_addsub.v"
`include "./include/sim_ver/DW02_mult.v"
`include "./include/sim_ver/DW_div.v"
`include "./include/sim_ver/DW_sqrt.v"
`include "./include/sim_ver/DW_shifter.v"
module alu (
    ALU_in_0, ALU_in_1, WW, func_code, ALU_out
);
    parameter DATA_WIDTH = 64;
    input [0:DATA_WIDTH-1] ALU_in_0, ALU_in_1;
    input [0:1] WW;
    input [0:5] func_code;
    output reg [0:DATA_WIDTH-1] ALU_out;

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

    localparam  b_mode = 2'b00,//byte mode
                h_mode = 2'b01,//half word mode
                w_mode = 2'b10,//word mode
                d_mode = 2'b11;//double word mode
    
    //add sub operation
    wire [0:7] ci, co;//carry in and carry out signal for each addsub
    wire add_sub;
    wire [0:DATA_WIDTH-1] sum;//64-bit result

    assign add_sub = (func_code == VADD) ? 1'b0 : 1'b1;// 0 means addition, 1 means subtraction

    DW01_addsub #(.width(8)) addsub0 (.A(ALU_in_0[0:7]), .B(ALU_in_1[0:7]), .CI(ci[0]), .ADD_SUB(add_sub), .SUM(sum[0:7]), .CO(co[0]));
    DW01_addsub #(.width(8)) addsub1 (.A(ALU_in_0[8:15]), .B(ALU_in_1[8:15]), .CI(ci[1]), .ADD_SUB(add_sub), .SUM(sum[8:15]), .CO(co[1]));
    DW01_addsub #(.width(8)) addsub2 (.A(ALU_in_0[16:23]), .B(ALU_in_1[16:23]), .CI(ci[2]), .ADD_SUB(add_sub), .SUM(sum[16:23]), .CO(co[2]));
    DW01_addsub #(.width(8)) addsub3 (.A(ALU_in_0[24:31]), .B(ALU_in_1[24:31]), .CI(ci[3]), .ADD_SUB(add_sub), .SUM(sum[24:31]), .CO(co[3]));
    DW01_addsub #(.width(8)) addsub4 (.A(ALU_in_0[32:39]), .B(ALU_in_1[32:39]), .CI(ci[4]), .ADD_SUB(add_sub), .SUM(sum[32:39]), .CO(co[4]));
    DW01_addsub #(.width(8)) addsub5 (.A(ALU_in_0[40:47]), .B(ALU_in_1[40:47]), .CI(ci[5]), .ADD_SUB(add_sub), .SUM(sum[40:47]), .CO(co[5]));
    DW01_addsub #(.width(8)) addsub6 (.A(ALU_in_0[48:55]), .B(ALU_in_1[48:55]), .CI(ci[6]), .ADD_SUB(add_sub), .SUM(sum[48:55]), .CO(co[6]));
    DW01_addsub #(.width(8)) addsub7 (.A(ALU_in_0[56:63]), .B(ALU_in_1[56:63]), .CI(ci[7]), .ADD_SUB(add_sub), .SUM(sum[56:63]), .CO(co[7]));

    assign ci[0] = (WW == b_mode) ? 1'b0 : co[1];
    assign ci[1] = ((WW == b_mode) || (WW == h_mode)) ? 1'b0 : co[2];
    assign ci[2] = (WW == b_mode) ? 1'b0 : co[3];
    assign ci[3] = ((WW == b_mode) || (WW == h_mode) || (WW == w_mode)) ? 1'b0 : co[4];
    assign ci[4] = (WW == b_mode) ? 1'b0 : co[5];
    assign ci[5] = ((WW == b_mode) || (WW == h_mode)) ? 1'b0 : co[6];
    assign ci[6] = (WW == b_mode) ? 1'b0 : co[7];
    assign ci[7] = 1'b0;

    //multiply and square
    reg [0:DATA_WIDTH/2-1] mul_A, mul_B;//data input for multiply and square
    wire [0:DATA_WIDTH-1] product_b, product_h, product_w;//product of byte, half-word and word mode

    always @(*) begin
        case (func_code)
            VMULEU: begin
                case (WW)
                    b_mode: begin
                        mul_A = {ALU_in_0[0:7], ALU_in_0[16:23], ALU_in_0[32:39], ALU_in_0[48:55]};
                        mul_B = {ALU_in_1[0:7], ALU_in_1[16:23], ALU_in_1[32:39], ALU_in_1[48:55]};
                    end
                    h_mode: begin
                        mul_A = {ALU_in_0[0:15], ALU_in_0[32:47]};
                        mul_B = {ALU_in_1[0:15], ALU_in_1[32:47]};
                    end
                    w_mode: begin
                        mul_A = ALU_in_0[0:31];
                        mul_B = ALU_in_1[0:31];
                    end
                    default: begin
                        mul_A = 'b0;
                        mul_B = 'b0;
                    end
                endcase
            end
            VMULOU: begin
                case (WW)
                    b_mode: begin
                        mul_A = {ALU_in_0[8:15], ALU_in_0[24:31], ALU_in_0[40:47], ALU_in_0[56:63]};
                        mul_B = {ALU_in_1[8:15], ALU_in_1[24:31], ALU_in_1[40:47], ALU_in_1[56:63]};
                    end
                    h_mode: begin
                        mul_A = {ALU_in_0[16:31], ALU_in_0[48:63]};
                        mul_B = {ALU_in_1[16:31], ALU_in_1[48:63]};
                    end
                    w_mode: begin
                        mul_A = ALU_in_0[32:63];
                        mul_B = ALU_in_1[32:63];
                    end
                    default: begin
                        mul_A = 'b0;
                        mul_B = 'b0;
                    end
                endcase
            end
            VSQEU: begin
                case (WW)
                    b_mode: begin
                        mul_A = {ALU_in_0[0:7], ALU_in_0[16:23], ALU_in_0[32:39], ALU_in_0[48:55]};
                        mul_B = {ALU_in_0[0:7], ALU_in_0[16:23], ALU_in_0[32:39], ALU_in_0[48:55]};
                    end
                    h_mode: begin
                        mul_A = {ALU_in_0[0:15], ALU_in_0[32:47]};
                        mul_B = {ALU_in_0[0:15], ALU_in_0[32:47]};
                    end
                    w_mode: begin
                        mul_A = ALU_in_0[0:31];
                        mul_B = ALU_in_0[0:31];
                    end
                    default: begin
                        mul_A = 'b0;
                        mul_B = 'b0;
                    end
                endcase
            end
            VSQOU: begin
                case (WW)
                    b_mode: begin
                        mul_A = {ALU_in_0[8:15], ALU_in_0[24:31], ALU_in_0[40:47], ALU_in_0[56:63]};
                        mul_B = {ALU_in_0[8:15], ALU_in_0[24:31], ALU_in_0[40:47], ALU_in_0[56:63]};
                    end
                    h_mode: begin
                        mul_A = {ALU_in_0[16:31], ALU_in_0[48:63]};
                        mul_B = {ALU_in_0[16:31], ALU_in_0[48:63]};
                    end
                    w_mode: begin
                        mul_A = ALU_in_0[32:63];
                        mul_B = ALU_in_0[32:63];
                    end
                    default: begin
                        mul_A = 'b0;
                        mul_B = 'b0;
                    end
                endcase
            end
            default: begin
                mul_A = 'b0;
                mul_B = 'b0;
            end
        endcase
    end
    
    DW02_mult #(.A_width(8), .B_width(8)) mul_b0 (.A(mul_A[0:7]), .B(mul_B[0:7]), .TC(1'b0), .PRODUCT(product_b[0:15]));
    DW02_mult #(.A_width(8), .B_width(8)) mul_b1 (.A(mul_A[8:15]), .B(mul_B[8:15]), .TC(1'b0), .PRODUCT(product_b[16:31]));
    DW02_mult #(.A_width(8), .B_width(8)) mul_b2 (.A(mul_A[16:23]), .B(mul_B[16:23]), .TC(1'b0), .PRODUCT(product_b[32:47]));
    DW02_mult #(.A_width(8), .B_width(8)) mul_b3 (.A(mul_A[24:31]), .B(mul_B[24:31]), .TC(1'b0), .PRODUCT(product_b[48:63]));
    
    DW02_mult #(.A_width(16), .B_width(16)) mul_h0 (.A(mul_A[0:15]), .B(mul_B[0:15]), .TC(1'b0), .PRODUCT(product_h[0:31]));
    DW02_mult #(.A_width(16), .B_width(16)) mul_h1 (.A(mul_A[16:31]), .B(mul_B[16:31]), .TC(1'b0), .PRODUCT(product_h[32:63]));

    DW02_mult #(.A_width(32), .B_width(32)) mul_w (.A(mul_A), .B(mul_B), .TC(1'b0), .PRODUCT(product_w));

    //division and modulo operation
    wire [0:63] quotient_b, quotient_h, quotient_w, quotient_d, remainder_b, remainder_h, remainder_w, remainder_d;

    DW_div #(.a_width(8), .b_width(8), .tc_mode(0), .rem_mode(0)) div_b0 (.a(ALU_in_0[0:7]), .b(ALU_in_1[0:7]), .quotient(quotient_b[0:7]), .remainder(remainder_b[0:7]), .divide_by_0());
    DW_div #(.a_width(8), .b_width(8), .tc_mode(0), .rem_mode(0)) div_b1 (.a(ALU_in_0[8:15]), .b(ALU_in_1[8:15]), .quotient(quotient_b[8:15]), .remainder(remainder_b[8:15]), .divide_by_0());
    DW_div #(.a_width(8), .b_width(8), .tc_mode(0), .rem_mode(0)) div_b2 (.a(ALU_in_0[16:23]), .b(ALU_in_1[16:23]), .quotient(quotient_b[16:23]), .remainder(remainder_b[16:23]), .divide_by_0());
    DW_div #(.a_width(8), .b_width(8), .tc_mode(0), .rem_mode(0)) div_b3 (.a(ALU_in_0[24:31]), .b(ALU_in_1[24:31]), .quotient(quotient_b[24:31]), .remainder(remainder_b[24:31]), .divide_by_0());
    DW_div #(.a_width(8), .b_width(8), .tc_mode(0), .rem_mode(0)) div_b4 (.a(ALU_in_0[32:39]), .b(ALU_in_1[32:39]), .quotient(quotient_b[32:39]), .remainder(remainder_b[32:39]), .divide_by_0());
    DW_div #(.a_width(8), .b_width(8), .tc_mode(0), .rem_mode(0)) div_b5 (.a(ALU_in_0[40:47]), .b(ALU_in_1[40:47]), .quotient(quotient_b[40:47]), .remainder(remainder_b[40:47]), .divide_by_0());
    DW_div #(.a_width(8), .b_width(8), .tc_mode(0), .rem_mode(0)) div_b6 (.a(ALU_in_0[48:55]), .b(ALU_in_1[48:55]), .quotient(quotient_b[48:55]), .remainder(remainder_b[48:55]), .divide_by_0());
    DW_div #(.a_width(8), .b_width(8), .tc_mode(0), .rem_mode(0)) div_b7 (.a(ALU_in_0[56:63]), .b(ALU_in_1[56:63]), .quotient(quotient_b[56:63]), .remainder(remainder_b[56:63]), .divide_by_0());

    DW_div #(.a_width(16), .b_width(16), .tc_mode(0), .rem_mode(0)) div_h0 (.a(ALU_in_0[0:15]), .b(ALU_in_1[0:15]), .quotient(quotient_h[0:15]), .remainder(remainder_h[0:15]), .divide_by_0());
    DW_div #(.a_width(16), .b_width(16), .tc_mode(0), .rem_mode(0)) div_h1 (.a(ALU_in_0[16:31]), .b(ALU_in_1[16:31]), .quotient(quotient_h[16:31]), .remainder(remainder_h[16:31]), .divide_by_0());
    DW_div #(.a_width(16), .b_width(16), .tc_mode(0), .rem_mode(0)) div_h2 (.a(ALU_in_0[32:47]), .b(ALU_in_1[32:47]), .quotient(quotient_h[32:47]), .remainder(remainder_h[32:47]), .divide_by_0());
    DW_div #(.a_width(16), .b_width(16), .tc_mode(0), .rem_mode(0)) div_h3 (.a(ALU_in_0[48:63]), .b(ALU_in_1[48:63]), .quotient(quotient_h[48:63]), .remainder(remainder_h[48:63]), .divide_by_0());

    DW_div #(.a_width(32), .b_width(32), .tc_mode(0), .rem_mode(0)) div_w0 (.a(ALU_in_0[0:31]), .b(ALU_in_1[0:31]), .quotient(quotient_w[0:31]), .remainder(remainder_w[0:31]), .divide_by_0());
    DW_div #(.a_width(32), .b_width(32), .tc_mode(0), .rem_mode(0)) div_w1 (.a(ALU_in_0[32:63]), .b(ALU_in_1[32:63]), .quotient(quotient_w[32:63]), .remainder(remainder_w[32:63]), .divide_by_0());

    DW_div #(.a_width(64), .b_width(64), .tc_mode(0), .rem_mode(0)) div_d0 (.a(ALU_in_0[0:63]), .b(ALU_in_1[0:63]), .quotient(quotient_d[0:63]), .remainder(remainder_d[0:63]), .divide_by_0());

    //square root operation
    wire [0:63] root_b, root_h, root_w, root_d;
    DW_sqrt #(.width(8), .tc_mode(0)) sqrt_b0 (.a(ALU_in_0[0:7]), .root(root_b[4:7]));
    DW_sqrt #(.width(8), .tc_mode(0)) sqrt_b1 (.a(ALU_in_0[8:15]), .root(root_b[12:15]));
    DW_sqrt #(.width(8), .tc_mode(0)) sqrt_b2 (.a(ALU_in_0[16:23]), .root(root_b[20:23]));
    DW_sqrt #(.width(8), .tc_mode(0)) sqrt_b3 (.a(ALU_in_0[24:31]), .root(root_b[27:31]));
    DW_sqrt #(.width(8), .tc_mode(0)) sqrt_b4 (.a(ALU_in_0[32:39]), .root(root_b[36:39]));
    DW_sqrt #(.width(8), .tc_mode(0)) sqrt_b5 (.a(ALU_in_0[40:47]), .root(root_b[44:47]));
    DW_sqrt #(.width(8), .tc_mode(0)) sqrt_b6 (.a(ALU_in_0[48:55]), .root(root_b[52:55]));
    DW_sqrt #(.width(8), .tc_mode(0)) sqrt_b7 (.a(ALU_in_0[56:63]), .root(root_b[60:63]));

    DW_sqrt #(.width(16), .tc_mode(0)) sqrt_h0 (.a(ALU_in_0[0:15]), .root(root_h[8:15]));
    DW_sqrt #(.width(16), .tc_mode(0)) sqrt_h1 (.a(ALU_in_0[16:31]), .root(root_h[24:31]));
    DW_sqrt #(.width(16), .tc_mode(0)) sqrt_h2 (.a(ALU_in_0[32:47]), .root(root_h[40:47]));
    DW_sqrt #(.width(16), .tc_mode(0)) sqrt_h3 (.a(ALU_in_0[48:63]), .root(root_h[56:63]));

    DW_sqrt #(.width(32), .tc_mode(0)) sqrt_w0 (.a(ALU_in_0[0:31]), .root(root_w[16:31]));
    DW_sqrt #(.width(32), .tc_mode(0)) sqrt_w1 (.a(ALU_in_0[32:63]), .root(root_w[48:63]));

    DW_sqrt #(.width(64), .tc_mode(0)) sqrt_d0 (.a(ALU_in_0[0:63]), .root(root_d[32:63]));

    assign root_b[0:3] = 'b0;
    assign root_b[8:11] = 'b0;
    assign root_b[16:19] = 'b0;
    assign root_b[24:27] = 'b0;
    assign root_b[32:35] = 'b0;
    assign root_b[40:43] = 'b0;
    assign root_b[48:51] = 'b0;
    assign root_b[56:59] = 'b0;

    assign root_h[0:7] = 'b0;
    assign root_h[16:23] = 'b0;
    assign root_h[32:39] = 'b0;
    assign root_h[48:55] = 'b0;

    assign root_w[0:15] = 'b0;
    assign root_w[32:47] = 'b0;

    assign root_d[0:31] = 'b0;

    // assign root_b = {4{0}, root_b[4:7], 4{0}, root_b[12:15], 4{0}, root_b[20:23], 4{0}, root_b[27:31], 4{0}, root_b[36:39], 4{0}, root_b[44:47], 4{0}, root_b[52:55], 4{0}, root_b[60:63]};
    // assign root_h = {8{0}, root_h[8:15], 8{0}, root_h[24:31], 8{0}, root_h[40:47], 8{0}, root_h[56:63]};
    // assign root_w = {16{0}, root_w[16:31], 16{0}, root_w[48:63]};
    // assign root_d = {32{0}, root_d[32:63]};

    //shift operation
    reg sh_tc, data_tc;
    reg [0:3] sh_b [0:7];//shift control for byte mode
    reg [0:4] sh_h [0:3];
    reg [0:5] sh_w [0:1];
    reg [0:6] sh_d;
    wire [0:DATA_WIDTH-1] shift_out_b, shift_out_h, shift_out_w, shift_out_d;

    always @(*) begin

        case (func_code)
            VSLL: begin
                sh_tc = 0;
                data_tc = 0;

                sh_b[0] = {1'b0, ALU_in_1[5:7]};
                sh_b[1] = {1'b0, ALU_in_1[13:15]};
                sh_b[2] = {1'b0, ALU_in_1[21:23]};
                sh_b[3] = {1'b0, ALU_in_1[29:31]};
                sh_b[4] = {1'b0, ALU_in_1[37:39]};
                sh_b[5] = {1'b0, ALU_in_1[45:47]};
                sh_b[6] = {1'b0, ALU_in_1[53:55]};
                sh_b[7] = {1'b0, ALU_in_1[61:63]};

                sh_h[0] = {1'b0, ALU_in_1[12:15]};
                sh_h[1] = {1'b0, ALU_in_1[28:31]};
                sh_h[2] = {1'b0, ALU_in_1[44:47]};
                sh_h[3] = {1'b0, ALU_in_1[60:63]};

                sh_w[0] = {1'b0, ALU_in_1[27:31]};
                sh_w[1] = {1'b0, ALU_in_1[59:63]};

                sh_d = {1'b0, ALU_in_1[58:63]};
            end
            VSRL: begin
                sh_tc = 1;
                data_tc = 0;

                sh_b[0] = {1'b1, ALU_in_1[5:7]^3'b111} + 1'b1;
                sh_b[1] = {1'b1, ALU_in_1[13:15]^3'b111} + 1'b1;
                sh_b[2] = {1'b1, ALU_in_1[21:23]^3'b111} + 1'b1;
                sh_b[3] = {1'b1, ALU_in_1[29:31]^3'b111} + 1'b1;
                sh_b[4] = {1'b1, ALU_in_1[37:39]^3'b111} + 1'b1;
                sh_b[5] = {1'b1, ALU_in_1[45:47]^3'b111} + 1'b1;
                sh_b[6] = {1'b1, ALU_in_1[53:55]^3'b111} + 1'b1;
                sh_b[7] = {1'b1, ALU_in_1[61:63]^3'b111} + 1'b1;

                sh_h[0] = {1'b1, ALU_in_1[12:15]^4'b1111} + 1'b1;
                sh_h[1] = {1'b1, ALU_in_1[28:31]^4'b1111} + 1'b1;
                sh_h[2] = {1'b1, ALU_in_1[44:47]^4'b1111} + 1'b1;
                sh_h[3] = {1'b1, ALU_in_1[60:63]^4'b1111} + 1'b1;

                sh_w[0] = {1'b1, ALU_in_1[27:31]^5'b11111} + 1'b1;
                sh_w[1] = {1'b1, ALU_in_1[59:63]^5'b11111} + 1'b1;

                sh_d = {1'b1, ALU_in_1[58:63]^6'b111111} + 1'b1;
            end
            VSRA: begin
                sh_tc = 1;
                data_tc = 1;

                sh_b[0] = {1'b1, ALU_in_1[5:7]^3'b111} + 1'b1;
                sh_b[1] = {1'b1, ALU_in_1[13:15]^3'b111} + 1'b1;
                sh_b[2] = {1'b1, ALU_in_1[21:23]^3'b111} + 1'b1;
                sh_b[3] = {1'b1, ALU_in_1[29:31]^3'b111} + 1'b1;
                sh_b[4] = {1'b1, ALU_in_1[37:39]^3'b111} + 1'b1;
                sh_b[5] = {1'b1, ALU_in_1[45:47]^3'b111} + 1'b1;
                sh_b[6] = {1'b1, ALU_in_1[53:55]^3'b111} + 1'b1;
                sh_b[7] = {1'b1, ALU_in_1[61:63]^3'b111} + 1'b1;

                sh_h[0] = {1'b1, ALU_in_1[12:15]^4'b1111} + 1'b1;
                sh_h[1] = {1'b1, ALU_in_1[28:31]^4'b1111} + 1'b1;
                sh_h[2] = {1'b1, ALU_in_1[44:47]^4'b1111} + 1'b1;
                sh_h[3] = {1'b1, ALU_in_1[60:63]^4'b1111} + 1'b1;

                sh_w[0] = {1'b1, ALU_in_1[27:31]^5'b11111} + 1'b1;
                sh_w[1] = {1'b1, ALU_in_1[59:63]^5'b11111} + 1'b1;

                sh_d = {1'b1, ALU_in_1[58:63]^6'b111111} + 1'b1;
            end
            default: begin
                sh_tc = 0;
                data_tc = 0;

                sh_b[0] = {1'b1, ALU_in_1[5:7]};
                sh_b[1] = {1'b1, ALU_in_1[13:15]};
                sh_b[2] = {1'b1, ALU_in_1[21:23]};
                sh_b[3] = {1'b1, ALU_in_1[29:31]};
                sh_b[4] = {1'b1, ALU_in_1[37:39]};
                sh_b[5] = {1'b1, ALU_in_1[45:47]};
                sh_b[6] = {1'b1, ALU_in_1[53:55]};
                sh_b[7] = {1'b1, ALU_in_1[61:63]};

                sh_h[0] = {1'b1, ALU_in_1[12:15]};
                sh_h[1] = {1'b1, ALU_in_1[28:31]};
                sh_h[2] = {1'b1, ALU_in_1[44:47]};
                sh_h[3] = {1'b1, ALU_in_1[60:63]};

                sh_w[0] = {1'b1, ALU_in_1[27:31]};
                sh_w[1] = {1'b1, ALU_in_1[59:63]};

                sh_d = {1'b1, ALU_in_1[58:63]};
            end
        endcase
    end

    DW_shifter #(.data_width(8), .sh_width(4), .inv_mode(0)) DW_shifter_b0 (.data_in(ALU_in_0[0:7]), .data_tc(data_tc), .sh(sh_b[0]), .sh_tc(sh_tc), .sh_mode(1'b1), .data_out(shift_out_b[0:7]));
    DW_shifter #(.data_width(8), .sh_width(4), .inv_mode(0)) DW_shifter_b1 (.data_in(ALU_in_0[8:15]), .data_tc(data_tc), .sh(sh_b[1]), .sh_tc(sh_tc), .sh_mode(1'b1), .data_out(shift_out_b[8:15]));
    DW_shifter #(.data_width(8), .sh_width(4), .inv_mode(0)) DW_shifter_b2 (.data_in(ALU_in_0[16:23]), .data_tc(data_tc), .sh(sh_b[2]), .sh_tc(sh_tc), .sh_mode(1'b1), .data_out(shift_out_b[16:23]));
    DW_shifter #(.data_width(8), .sh_width(4), .inv_mode(0)) DW_shifter_b3 (.data_in(ALU_in_0[24:31]), .data_tc(data_tc), .sh(sh_b[3]), .sh_tc(sh_tc), .sh_mode(1'b1), .data_out(shift_out_b[24:31]));
    DW_shifter #(.data_width(8), .sh_width(4), .inv_mode(0)) DW_shifter_b4 (.data_in(ALU_in_0[32:39]), .data_tc(data_tc), .sh(sh_b[4]), .sh_tc(sh_tc), .sh_mode(1'b1), .data_out(shift_out_b[32:39]));
    DW_shifter #(.data_width(8), .sh_width(4), .inv_mode(0)) DW_shifter_b5 (.data_in(ALU_in_0[40:47]), .data_tc(data_tc), .sh(sh_b[5]), .sh_tc(sh_tc), .sh_mode(1'b1), .data_out(shift_out_b[40:47]));
    DW_shifter #(.data_width(8), .sh_width(4), .inv_mode(0)) DW_shifter_b6 (.data_in(ALU_in_0[48:55]), .data_tc(data_tc), .sh(sh_b[6]), .sh_tc(sh_tc), .sh_mode(1'b1), .data_out(shift_out_b[48:55]));
    DW_shifter #(.data_width(8), .sh_width(4), .inv_mode(0)) DW_shifter_b7 (.data_in(ALU_in_0[56:63]), .data_tc(data_tc), .sh(sh_b[7]), .sh_tc(sh_tc), .sh_mode(1'b1), .data_out(shift_out_b[56:63]));

    DW_shifter #(.data_width(16), .sh_width(5), .inv_mode(0)) DW_shifter_h0 (.data_in(ALU_in_0[0:15]), .data_tc(data_tc), .sh(sh_h[0]), .sh_tc(sh_tc), .sh_mode(1'b1), .data_out(shift_out_h[0:15]));
    DW_shifter #(.data_width(16), .sh_width(5), .inv_mode(0)) DW_shifter_h1 (.data_in(ALU_in_0[16:31]), .data_tc(data_tc), .sh(sh_h[1]), .sh_tc(sh_tc), .sh_mode(1'b1), .data_out(shift_out_h[16:31]));
    DW_shifter #(.data_width(16), .sh_width(5), .inv_mode(0)) DW_shifter_h2 (.data_in(ALU_in_0[32:47]), .data_tc(data_tc), .sh(sh_h[2]), .sh_tc(sh_tc), .sh_mode(1'b1), .data_out(shift_out_h[32:47]));
    DW_shifter #(.data_width(16), .sh_width(5), .inv_mode(0)) DW_shifter_h3 (.data_in(ALU_in_0[48:63]), .data_tc(data_tc), .sh(sh_h[3]), .sh_tc(sh_tc), .sh_mode(1'b1), .data_out(shift_out_h[48:63]));

    DW_shifter #(.data_width(32), .sh_width(6), .inv_mode(0)) DW_shifter_w0 (.data_in(ALU_in_0[0:31]), .data_tc(data_tc), .sh(sh_w[0]), .sh_tc(sh_tc), .sh_mode(1'b1), .data_out(shift_out_w[0:31]));
    DW_shifter #(.data_width(32), .sh_width(6), .inv_mode(0)) DW_shifter_w1 (.data_in(ALU_in_0[32:63]), .data_tc(data_tc), .sh(sh_w[1]), .sh_tc(sh_tc), .sh_mode(1'b1), .data_out(shift_out_w[32:63]));

    DW_shifter #(.data_width(64), .sh_width(7), .inv_mode(0)) DW_shifter_d0 (.data_in(ALU_in_0), .data_tc(data_tc), .sh(sh_d), .sh_tc(sh_tc), .sh_mode(1'b1), .data_out(shift_out_d));

    always @(*) begin
        case (func_code)
            VAND: ALU_out = ALU_in_0 & ALU_in_1;
            VOR: ALU_out = ALU_in_0 | ALU_in_1;
            VXOR: ALU_out = ALU_in_0 ^ ALU_in_1;
            VNOT: ALU_out = ~ALU_in_0;
            VMOV: ALU_out = ALU_in_0;
            VADD: ALU_out = sum;
            VSUB: ALU_out = sum;
            VMULEU: begin
                case (WW)
                    b_mode: ALU_out = product_b;
                    h_mode: ALU_out = product_h;
                    w_mode: ALU_out = product_w;
                    default: ALU_out = 'b0;
                endcase
            end
            VMULOU: begin
                case (WW)
                    b_mode: ALU_out = product_b;
                    h_mode: ALU_out = product_h;
                    w_mode: ALU_out = product_w;
                    default: ALU_out = 'b0;
                endcase
            end
            VSQEU: begin
                case (WW)
                    b_mode: ALU_out = product_b;
                    h_mode: ALU_out = product_h;
                    w_mode: ALU_out = product_w;
                    default: ALU_out = 'b0;
                endcase
            end
            VSQOU: begin
                case (WW)
                    b_mode: ALU_out = product_b;
                    h_mode: ALU_out = product_h;
                    w_mode: ALU_out = product_w;
                    default: ALU_out = 'b0;
                endcase
            end
            VDIV: begin
                case(WW)
                    b_mode: ALU_out = quotient_b;
                    h_mode: ALU_out = quotient_h;
                    w_mode: ALU_out = quotient_w;
                    d_mode: ALU_out = quotient_d;
                endcase
            end
            VMOD: begin
                case(WW)
                    b_mode: ALU_out = remainder_b;
                    h_mode: ALU_out = remainder_h;
                    w_mode: ALU_out = remainder_w;
                    d_mode: ALU_out = remainder_d;
                endcase
            end
            VSQRT: begin
                case(WW)
                    b_mode: ALU_out = root_b;
                    h_mode: ALU_out = root_h;
                    w_mode: ALU_out = root_w;
                    d_mode: ALU_out = root_d;
                endcase
            end
            VSLL: begin
                case(WW)
                    b_mode: ALU_out = shift_out_b;
                    h_mode: ALU_out = shift_out_h;
                    w_mode: ALU_out = shift_out_w;
                    d_mode: ALU_out = shift_out_d;
                endcase
            end
            VSRL: begin
                case(WW)
                    b_mode: ALU_out = shift_out_b;
                    h_mode: ALU_out = shift_out_h;
                    w_mode: ALU_out = shift_out_w;
                    d_mode: ALU_out = shift_out_d;
                endcase
            end
            VSRA: begin
                case(WW)
                    b_mode: ALU_out = shift_out_b;
                    h_mode: ALU_out = shift_out_h;
                    w_mode: ALU_out = shift_out_w;
                    d_mode: ALU_out = shift_out_d;
                endcase
            end
            VRTTH: begin
                case(WW)
                    b_mode :
                    begin
                        ALU_out[0:7] = {ALU_in_0[4:7], ALU_in_0[0:3]};
                        ALU_out[8:15] = {ALU_in_0[12:15], ALU_in_0[8:11]};
                        ALU_out[16:23] = {ALU_in_0[20:23], ALU_in_0[16:19]};
                        ALU_out[24:31] = {ALU_in_0[28:31], ALU_in_0[24:27]};
                        ALU_out[32:39] = {ALU_in_0[36:39], ALU_in_0[32:35]};
                        ALU_out[40:47] = {ALU_in_0[44:47], ALU_in_0[40:43]};
                        ALU_out[48:55] = {ALU_in_0[52:55], ALU_in_0[48:51]};
                        ALU_out[56:63] = {ALU_in_0[60:63], ALU_in_0[56:59]};
                    end
                    h_mode :
                    begin
                        ALU_out[0:15] = {ALU_in_0[8:15], ALU_in_0[0:7]};
                        ALU_out[16:31] = {ALU_in_0[24:31], ALU_in_0[16:23]};
                        ALU_out[32:47] = {ALU_in_0[40:47], ALU_in_0[32:39]};
                        ALU_out[48:63] = {ALU_in_0[56:63], ALU_in_0[48:55]};
                    end
                    w_mode :
                    begin
                        ALU_out[0:31] = {ALU_in_0[16:31], ALU_in_0[0:15]};
                        ALU_out[32:63] = {ALU_in_0[48:63], ALU_in_0[32:47]};
                    end
                    d_mode :
                        ALU_out[0:63] = {ALU_in_0[32:63], ALU_in_0[0:31]};
                endcase
            end
            default: ALU_out = 'b0;
        endcase
    end
endmodule