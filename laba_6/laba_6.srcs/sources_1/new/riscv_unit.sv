module riscv_unit(

input logic clk_i, rst_i,

logic [31:0] instr_i_w, mem_rd_i_w, instr_addr_o_w, mem_wd_o_w, data_addr_o_w, 
logic mem_we_o_w, mem_req_o_w,
reg stall_i_w

);

riscv_core core(

.clk_i(clk_i),
.rst_i(rst_i),
.stall_i(stall_i_w),
.instr_i(instr_i_w),
.mem_rd_i(mem_rd_i_w),
.instr_addr_o(instr_addr_o_w),
.mem_wd_o(mem_wd_o_w),
.data_addr_o(data_addr_o_w),
.mem_we_o(mem_we_o_w),
.mem_req_o(mem_req_o_w)

);

instr_mem instr_mem(

.addr_i(instr_addr_o_w),
.read_data_o(instr_i_w)

);

data_mem data_mem(

.clk_i(clk_i),
.mem_req_i(mem_req_o_w),
.write_enable_i(mem_we_o_w),
.addr_i(data_addr_o_w),
.write_data_i(mem_wd_o_w)

);


//какую роль играет rst_i?

always @(posedge clk_i) begin
    
    stall_i_w <= 0;
    
    if(mem_req_o_w && !(stall_i_w) && rst_i) stall_i_w <= 1;
     
end

endmodule