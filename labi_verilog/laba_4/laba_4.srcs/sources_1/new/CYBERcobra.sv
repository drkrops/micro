module CYBERcobra (
input logic clk_i,
input logic rst_i,
input logic [15:0] sw_i,

output logic [31:0] out_o ,

logic [31:0] pc_instr_in_w,
logic [31:0] pc_instr_out_w, 
logic [31:0]reg_instr_out_w,
logic [31:0] sum_b_w , 
logic [31:0] wd_w,
logic [31:0] rd1_w, 
logic [31:0] rd2_w,
logic [31:0] alu_res_w,
logic [31:0] counter_w,
logic [4:0] ra1_w, 
logic [4:0]ra2_w,
logic [4:0] wa_w,
logic alu_flag_w

);

    PC PC(
    
    .clk_i(clk_i),
    .rst_i(rst_i),
    .instr_i(pc_instr_in_w),
    .instr_o(pc_instr_out_w)
    
    );

    instr_mem instr_mem(
    
    .addr_i(pc_instr_out_w),
    .read_data_o(reg_instr_out_w)
    
    );
    
    fulladder32 pc_adder(
    
    .a_i(pc_instr_out_w),
    .b_i(sum_b_w),
    .sum_o(pc_instr_in_w),
    .carry_i('0)
    
    );
    
    rf_riscv regfile(
    
    .clk_i(clk_i),
    .write_enable_i(!(reg_instr_out_w[31] || reg_instr_out_w[30])),
    .read_addr1_i(ra1_w),
    .read_addr2_i(ra2_w),
    .write_addr_i(wa_w),
    .write_data_i(wd_w),
    .read_data1_o(rd1_w),
    .read_data2_o(rd2_w)
    
    ); 
               
    alu_riscv alu(
    
    .a_i(rd1_w),
    .b_i(rd2_w),
    .alu_op_i(reg_instr_out_w[27:23]),
    .flag_o(alu_flag_w),
    .result_o(alu_res_w)
    
    );   
    
    
    assign out_o = rd1_w;
    
      //мультиплексор записи данных
        always @(posedge clk_i) begin 
        
            case(reg_instr_out_w[29:28])
            
                2'b00 :
                if(reg_instr_out_w[27] == 1) wd_w <= {9'b1,reg_instr_out_w [27:5] }; 
                else wd_w <= {9'b0, reg_instr_out_w [27:5]} ;
                
                2'b01 : wd_w <= alu_res_w;
                
                2'b10 : 
                
                if(sw_i[15] == 1) wd_w <= {16'b1, sw_i}; 
                else wd_w <= {16'b0, sw_i} ;
                
                default : wd_w <= 32'd0;
            
            endcase 
            
        //мультиплексор jump команд 
            
        end
    
        always @(posedge clk_i) begin
        
         case(reg_instr_out_w[31] || (reg_instr_out_w[30] && alu_flag_w))
            
                1'b0: sum_b_w <= 32'd4;
            
                1'b1: if(reg_instr_out_w[12] == 1) sum_b_w <= {22'b1,reg_instr_out_w [12:5], 2'b0 }; 
            else sum_b_w <= {22'b0, reg_instr_out_w [12:5], 2'b0};
            
            endcase
            
            counter_w <=  counter_w + 32'd4;
            
        end
         
endmodule