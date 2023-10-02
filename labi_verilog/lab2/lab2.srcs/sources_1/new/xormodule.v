module xormodule(

input logic [31:0] a_i,b_i,
output logic [31:0] O


);

assign O[31:0]  = a_i[31:0] ^ b_i[31:0];

endmodule