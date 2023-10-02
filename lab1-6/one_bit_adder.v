module fulladder(
    input a,
    input b,
    input Pin,
    
    output S,
    output Pout
);

wire aAndPin;
wire aAndB;
wire aAndBOrAAndPin;
wire bAndPin;
wire aXorB;

assign aXorB = a ^ b;
assign S = aXorB ^ Pin;
assign aAndPin = a & Pin;
assign aAndB = a & b;
assign aAndBOrAAndPin = aAndB | aAndPin;
assign bAndPin = b & Pin;
assign Pout = bAndPin | aAndBOrAAndPin;

endmodule
