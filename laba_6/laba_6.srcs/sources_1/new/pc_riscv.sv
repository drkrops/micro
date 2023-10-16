module pc_riscv(

input logic clk_i,
input logic rst_i,
input logic stall_i,

input logic pc_i,
output logic pc_o

);

assign pc_i = 0;

always @(posedge clk_i) begin

if(!stall_i) begin

if(rst_i) pc_o <= 32'd0;

else pc_o <= pc_i;

end

end

endmodule