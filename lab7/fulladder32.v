module fulladder32(
    input [31:0] A,
    input [31:0] B,
    input Pin,
    
    output [31:0] S,
    output Pout
);

wire a0a1;
wire a1a2;
wire a2a3;
wire a3a4;
wire a4a5;
wire a5a6;
wire a6a7;

fulladder4 a0 (A[3:0], B[3:0], Pin, S[3:0], a0a1);
fulladder4 a1 (A[7:4], B[7:4], a0a1, S[7:4], a1a2);
fulladder4 a2 (A[11:8], B[11:8], a1a2, S[11:8], a2a3);
fulladder4 a3 (A[15:12], B[15:12], a2a3, S[15:12], a3a4);
fulladder4 a4 (A[19:16], B[19:16], a3a4, S[19:16], a4a5);
fulladder4 a5 (A[23:20], B[23:20], a4a5, S[23:20], a5a6);
fulladder4 a6 (A[27:24], B[27:24], a5a6, S[27:24], a6a7);
fulladder4 a7 (A[31:28], B[31:28], a6a7, S[31:28], Pout);

endmodule
