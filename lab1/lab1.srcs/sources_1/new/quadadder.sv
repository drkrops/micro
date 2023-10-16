module quadadder(

input logic [3:0] a_i,
input logic [3:0] b_i,
input logic carry_i,

output logic [3:0] sum_o,
output logic carry_o

);

logic carry_o1;
logic carry_o2;
logic carry_o3;
logic carry_o4;


fulladder fulladder_0 (

.a_i(a_i[0]),

.b_i(b_i[0]),

.carry_i(carry_i),

.sum_o(sum_o[0]),

.carry_o(carry_o1)

);

fulladder fulladder_1 (

.a_i(a_i[1]),

.b_i(b_i[1]),

.carry_i(carry_o1),

.sum_o(sum_o[1]),

.carry_o(carry_o2)

);

fulladder fulladder_2 (

.a_i(a_i[2]),

.b_i(b_i[2]),

.carry_i(carry_o2),

.sum_o(sum_o[2]),

.carry_o(carry_o3)

);

fulladder fulladder_3 (

.a_i(a_i[3]),

.b_i(b_i[3]),

.carry_i(carry_o3),

.sum_o(sum_o[3]),

.carry_o(carry_o)

);


endmodule