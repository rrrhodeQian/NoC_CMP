module fa (a, b, ci, sum, carry);
input a, b, ci;
output sum, carry;
wire w1, w2;

xor X1(w1, a, b); // XOR gate for w1
xor X2(sum, w1, ci); // XOR gate for SUM
and A1(w2, a, b); // AND gate for OR input1
and A2(w3, w1, ci); // AND gate for OR input2
or O1(carry, w2, w3); // OR gate for COUT   

endmodule