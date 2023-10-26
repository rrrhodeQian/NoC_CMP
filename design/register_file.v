module register_file (
    clk, reset, wrEn, data_in, PPP_sel, wr_addr, data_out_0, data_out_1, rd_addr_0, rd_addr_1
);
    parameter DATA_WIDTH = 64;
    parameter ADDR_WIDTH = 32;
    parameter DEPTH = 32;//register depth
    input clk, reset;
    input wrEn;//register write enable
    //big-endian, bit 0 is the MSB
    input [0:2] PPP_sel;//participate select
    input [0:ADDR_WIDTH-1] wr_addr;//write address
    input [0:DATA_WIDTH-1] data_in;//data input port
    input [0:ADDR_WIDTH-1] rd_addr_0, rd_addr_1;//read address
    output reg [0:DATA_WIDTH-1] data_out_0, data_out_1;//data output port
    
    reg [0:DATA_WIDTH-1] mem_array [DEPTH-1:0];//32 64-bit register array

    localparam  mode_a = 3'b000,//all subfield participate
                mode_u = 3'b001,//upper 32-bit participate
                mode_d = 3'b010,//lower 32-bit participate
                mode_e = 3'b011,//subfields with even index participate
                mode_o = 3'b100;//subfields with odd index participate

    // assign mem_array[0] = 'b0;//register 0 hard-wired to 0;

    always @(*) begin
        //if read address equals to write address, internally forwarding
        if (wrEn && (wr_addr == rd_addr_0)) begin
            case (PPP_sel)
                mode_a: data_out_0 = data_in;
                mode_u: data_out_0[0:31] = data_in[0:31];
                mode_d: data_out_0[32:63] = data_in[32:63];
                mode_e: begin
                    data_out_0[0:7] = data_in[0:7];
                    data_out_0[16:23] = data_in[16:23];
                    data_out_0[32:39] = data_in[32:39];
                    data_out_0[48:55] = data_in[48:55];
                end
                mode_o: begin
                    data_out_0[8:15] = data_in[8:15];
                    data_out_0[24:31] = data_in[24:31];
                    data_out_0[40:47] = data_in[40:47];
                    data_out_0[56:63] = data_in[56:63];
                end
                default: data_out_0 = 'bx;
            endcase
        end
        else if (wrEn && (wr_addr == rd_addr_1)) begin
            case (PPP_sel)
                mode_a: data_out_1 = data_in;
                mode_u: data_out_1[0:31] = data_in[0:31];
                mode_d: data_out_1[32:63] = data_in[32:63];
                mode_e: begin
                    data_out_1[0:7] = data_in[0:7];
                    data_out_1[16:23] = data_in[16:23];
                    data_out_1[32:39] = data_in[32:39];
                    data_out_1[48:55] = data_in[48:55];
                end
                mode_o: begin
                    data_out_1[8:15] = data_in[8:15];
                    data_out_1[24:31] = data_in[24:31];
                    data_out_1[40:47] = data_in[40:47];
                    data_out_1[56:63] = data_in[56:63];
                end
                default: data_out_1 = 'bx;
            endcase
        end
        //if write address does not match read address, put data in the register file to data output port
        else begin
            data_out_0 = mem_array[rd_addr_0];
            data_out_1 = mem_array[rd_addr_1];
        end
    end

    generate
        for (genvar i = 0; i < DEPTH; i = i + 1) begin : INIT_LOOP
        always @(posedge clk) begin
            if (reset) begin
            // Initialize array elements to your desired values
            mem_array[i] <= 'b0;
            end
        end
        end
    endgenerate

    //data write logic
    always @(posedge clk) begin
        mem_array[0] <= 'b0;//register 0 hard-wired to 0;
        if (wrEn && (wr_addr != 32'b0)) begin
            case (PPP_sel)
                mode_a: mem_array[wr_addr] <= data_in;
                mode_u: mem_array[wr_addr][0:31] <= data_in[0:31];
                mode_d: mem_array[wr_addr][32:63] <= data_in[32:63];
                mode_e: begin
                    mem_array[wr_addr][0:7] <= data_in[0:7];
                    mem_array[wr_addr][16:23] <= data_in[16:23];
                    mem_array[wr_addr][32:39] <= data_in[32:39];
                    mem_array[wr_addr][48:55] <= data_in[48:55];
                end
                mode_o: begin
                    mem_array[wr_addr][8:15] <= data_in[8:15];
                    mem_array[wr_addr][24:31] <= data_in[24:31];
                    mem_array[wr_addr][40:47] <= data_in[40:47];
                    mem_array[wr_addr][56:63] <= data_in[56:63];
                end
                default: mem_array[wr_addr] <= 'bx;
            endcase
        end
    end
endmodule