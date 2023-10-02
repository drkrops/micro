module fulladder4(
    input [3:0] A,
    input [3:0] B,
    input Pin,
    
    output [3:0] S,
    output Pout
);

wire a0a1;
wire a1a2;
wire a2a3;

fulladder a0 (.a(A[0]), .b(B[0]), .Pin(Pin), .S(S[0]), .Pout(a0a1));
fulladder a1 (A[1], B[1], a0a1, S[1], a1a2);
fulladder a2 (A[2], B[2], a1a2, S[2], a2a3);
fulladder a3 (A[3], B[3], a2a3, S[3], Pout);

endmodule
