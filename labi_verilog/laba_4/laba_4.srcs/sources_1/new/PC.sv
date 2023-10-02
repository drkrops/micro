module PC(

input logic clk_i,
input logic rst_i,
input logic [31:0] instr_i,

output logic [31:0] instr_o

);


always @(posedge clk_i) begin 

if(rst_i) instr_o <= 32'd0;

instr_o <= instr_i;


end

endmodule