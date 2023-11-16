module buffer #(
    parameter PAC_WIDTH = 64
) (
    input clk,
    input reset,//sync active high reset
    input wen,//write enable input
    input ren,//read enable input
    input [PAC_WIDTH-1:0] d_in,
    output full,
    output empty,
    output [PAC_WIDTH-1:0] d_out
);
    reg flag;//flag = 0 means empty, 1 means full
    assign empty = ~flag;
    assign full = flag;

    wire wenq, renq;//write enable and read enable qulified signal
    assign wenq = wen & (~flag);//only if the buffer is empty and there is a write request, enable write
    assign renq = ren & (flag);//only if the buffer is full and there is a read request, enable read

    reg [PAC_WIDTH-1:0] mem;// memory to store input data

    always @(posedge clk) begin
        if (reset) begin
            mem <= 'b0;
            flag <= 1'b0;
        end
        else begin
            if (wenq) begin
                mem <= d_in;
                flag <= 1'b1;
            end
            else if (renq) begin
                flag <= 1'b0;
            end
        end
    end

    assign d_out = mem;
endmodule