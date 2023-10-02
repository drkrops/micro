module fulladder32(

input logic [31:0] a_i,
input logic [31:0] b_i,
input logic carry_i = 0,

output logic [31:0] sum_o,
output logic carry_o 

);

logic carry0;
logic carry1;
logic carry2;
logic carry3;
logic carry4;
logic carry5;
logic carry6;
logic carry7;


quadadder quadadder0(

.a_i(a_i[3:0]),
.b_i(b_i[3:0]),
.carry_i(carry_i),

.sum_o(sum_o[3:0]),
.carry_o(carry0)

);

quadadder quadadder1(

.a_i(a_i[7:4]),
.b_i(b_i[7:4]),
.carry_i(carry0),

.sum_o(sum_o[7:4]),
.carry_o(carry1)

);

quadadder quadadder2(

.a_i(a_i[11:8]),
.b_i(b_i[11:8]),
.carry_i(carry1),

.sum_o(sum_o[11:8]),
.carry_o(carry2)

);

quadadder quadadder3(

.a_i(a_i[15:12]),
.b_i(b_i[15:12]),
.carry_i(carry2),

.sum_o(sum_o[15:12]),
.carry_o(carry3)

);

quadadder quadadder4(

.a_i(a_i[19:16]),
.b_i(b_i[19:16]),
.carry_i(carry3),

.sum_o(sum_o[19:16]),
.carry_o(carry4)

);

quadadder quadadder5(

.a_i(a_i[23:20]),
.b_i(b_i[23:20]),
.carry_i(carry4),

.sum_o(sum_o[23:20]),
.carry_o(carry5)

);

quadadder quadadder6(

.a_i(a_i[27:24]),
.b_i(b_i[27:24]),
.carry_i(carry5),

.sum_o(sum_o[27:24]),
.carry_o(carry6)

);

quadadder quadadder7(

.a_i(a_i[31:28]),
.b_i(b_i[31:28]),
.carry_i(carry6),

.sum_o(sum_o[31:28]),
.carry_o(carry_o)

);


endmodule