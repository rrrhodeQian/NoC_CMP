module arbiter(
    input rq0, rq1,//two request from different channel
    input clk, reset,
    output gt0, gt1//two grant output
);
    wire r0, r1;//outputs of the input barrel shifter as well as inputs of the fixed priority resolver
    wire g0, g1;//outputs of the fixed priority resolver as well as inputs of the output barrel shifter
    reg lgt;//last grant
    //input barrel shifter
    assign r0 = (!lgt) ? rq1 : rq0;//if last grant is 0, demote priority of rq0
    assign r1 = (!lgt) ? rq0 : rq1;//if last grant is 0, elevate priority of rq1
    //fixed priority resolver
    assign g0 = r0;//r0 always has the highest priority
    assign g1 = r1 & (~r0);//only r0 does not request, r1 gets granted
    //output barrel shifter
    assign gt0 = (!lgt) ? g1 : g0;//rotate back to the original port
    assign gt1 = (!lgt) ? g0 : g1;

    always @(posedge clk) begin
        if (reset) begin
            lgt <= 1'b1;//on reset rq0 has the highest priority
        end
        else begin
            if (gt0) lgt <= 1'b0;//last grant is rq0
            else if (gt1) lgt <= 1'b1;//last grant is rq1
            else lgt <= lgt;//no one is requesting
        end
    end
endmodule