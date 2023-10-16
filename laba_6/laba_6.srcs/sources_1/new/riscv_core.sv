module riscv_core(

input logic [31:0] instr_i,
input logic [31:0] mem_rd_i,
input logic clk_i,
input logic rst_i,
input logic stall_i,

output logic [31:0] instr_addr_o,
output logic [31:0] data_addr_o,
output logic [2:0] mem_size_o,
output logic [31:0] mem_wd_o,
output logic mem_we_o,
output logic mem_req_o,

logic [31:0] wb_data_w,
logic [31:0] rd1_w,
logic [31:0] rd2_w,

logic [1:0] a_sel_o_w,
logic [2:0] b_sel_o_w,
logic [4:0] alu_op_o_w,
logic mem_req_o_w, mem_we_o_w, gpr_we_a_o_w, wb_src_sel_o_w, branch_o_w, 
logic gpr_we_w, jalr_o_w, jal_o_w,

logic [31:0] pc_i_w, pc_o_w,

logic [31:0] alu_a_i_w, alu_b_i_w, alu_result_o_w, 
logic flag_o_w,

logic [2:0] mem_size_o_w,

logic [31:0] pc_sum_a_i_w, pc_sum_b_i_w, pc_sum_res_o_w,

logic [31:0] imm_I_w

);


assign mem_wd_o = rd1_w;
assign data_addr_o = alu_result_o_w;
assign instr_addr_o = pc_o_w;
assign pc_sum_b_i_w = pc_o_w;

assign imm_I_w = {20*instr_i[31] , instr_i[31:20]};

rf_riscv registerfile (

.clk_i(clk_i),
.write_enable_i(gpr_we_w),
.write_addr_i(instr_i[11:7]),
.read_addr1_i(instr_i[19:15]),
.read_addr2_i(instr_i[24:20]),
.write_data_i(wb_data_w),
.read_data1_o(rd1_w),
.read_data2_o(rd2_w)

);

decoder_riscv decoder(

.fetched_instr_i(instr_i),
.a_sel_o(a_sel_o_w),
.b_sel_o(b_sel_o_w),
.alu_op_o(alu_op_o_w),
.mem_req_o(mem_req_o_w),      
.mem_we_o(mem_we_o_w),       
.mem_size_o(mem_size_o_w),
.gpr_we_a_o(gpr_we_a_o_w),     
.wb_src_sel_o(wb_src_sel_o_w),   
.branch_o(branch_o_w),       
.jal_o(jal_o_w),          
.jalr_o(jalr_o_w)          

);

pc_riscv pc(

.clk_i(clk_i),
.rst_i(rst_i),
.stall_i(stall_i),
.pc_i(pc_i_w),
.pc_o(pc_o_w)


);


alu_riscv alu(

.a_i(alu_a_i_w),
.b_i(alu_b_i_w),
.alu_op_i(alu_op_o_w),
.flag_o(flag_o_w),
.result_o(alu_result_o_w)

);

always @(posedge clk_i) begin
// ¿À” 
case(b_sel_o_w)

    3'd0 : alu_b_i_w <= rd2_w;
    3'd1 : alu_b_i_w <= imm_I_w;
    3'd2 : alu_b_i_w <= {instr_i[31:12], 12'd0};
    3'd3 : alu_b_i_w <= {20*instr_i[31],instr_i[31:25], instr_i[11:7]};
    
    default : alu_b_i_w <= 32'd4;
    
    
endcase

case(a_sel_o_w)
    
    2'd0 : alu_a_i_w <= rd1_w;
    2'd1 : alu_a_i_w <= pc_o_w;
    
    default : alu_a_i_w <= 32'd0;

endcase

case(wb_src_sel_o_w)
    
    1'd0 : wb_data_w <= alu_result_o_w;
    1'd1 : wb_data_w <= mem_rd_i;
    
endcase

case(jal_o_w || (flag_o_w && branch_o_w))
    
    1'd0 : pc_sum_a_i_w <= 32'd4;
    1'd1 :      case(branch_o_w) 
                
                1'd0 : pc_sum_a_i_w <= {19*instr_i[31], instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'd0};
                1'd1 : pc_sum_a_i_w <= {9*instr_i[31], instr_i[31], instr_i[19:12], instr_i[20], instr_i[31:21], 1'd0}; 
                
                endcase
endcase

case(jalr_o_w)

    1'd0 : pc_i_w <= pc_sum_a_i_w + pc_sum_b_i_w;
    1'd1 : pc_i_w <= rd1_w + imm_I_w;  

endcase

end

endmodule