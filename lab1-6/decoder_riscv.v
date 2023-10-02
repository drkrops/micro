`include "./defines_riscv.v"

module decoder_riscv (
  input       [31:0]  fetched_instr_i,    
  output  reg [1:0]   ex_op_a_sel_o,      
  output  reg [2:0]   ex_op_b_sel_o,      
  output  reg [4:0]   alu_op_o,           
  output  reg         mem_req_o,          
  output  reg         mem_we_o,           
  output  reg [2:0]   mem_size_o,         
  output  reg         gpr_we_a_o,         
  output  reg         wb_src_sel_o,       
  output  reg         illegal_instr_o,    
  output  reg         branch_o,           
  output  reg         jal_o,              
  output  reg         jalr_o              
);

wire [4:0] opcode;
wire [2:0] funct3;
wire [6:0] funct7;

assign opcode = fetched_instr_i[6:2];
assign funct3 = fetched_instr_i[14:12];
assign funct7 = fetched_instr_i[31:25];

always @* begin
    ex_op_a_sel_o <= 0;
    ex_op_b_sel_o <= 0;
    alu_op_o <= 0;
    mem_req_o <= 0;
    mem_we_o <= 0;
    mem_size_o <= 0;
    gpr_we_a_o <= 0;
    wb_src_sel_o <= 0;
    illegal_instr_o <= 0;
    branch_o <= 0;
    jal_o <= 0;
    jalr_o <= 0;
    
    case (fetched_instr_i[1:0])
        2'b11: 
        begin
            case (opcode)
                `OP_OPCODE:
                begin
                    if (funct3 < 8 && (funct7 == 0 || funct7 == 32))
                    begin
                        if (funct3 != 0 && funct3 != 5 && funct7 != 0)
                            illegal_instr_o <= 1;
                        else begin
                            alu_op_o <= {funct7[6:5], funct3};
                            gpr_we_a_o <= 1;
                            ex_op_a_sel_o <= 0;
                            ex_op_b_sel_o <= 0;
                            wb_src_sel_o <= 0;
                        end 
                    end else illegal_instr_o <= 1;
                end
                
                `OP_IMM_OPCODE:
                begin
                    gpr_we_a_o <= 1;
                    ex_op_a_sel_o <= 0;
                    ex_op_b_sel_o <= 1;
                    wb_src_sel_o <= 0;
                    
                    if (funct3 == 1 || funct3 == 5)
                    begin
                        if (funct7 == 0 || funct7 == 32)
                        begin
                            alu_op_o <= {funct7[6:5], funct3};
                        end else begin
                            gpr_we_a_o <= 0;
                            ex_op_a_sel_o <= 0;
                            ex_op_b_sel_o <= 0;
                            wb_src_sel_o <= 0;
                            illegal_instr_o <= 1;
                        end
                    end else begin 
                        alu_op_o <= {1'b0, 1'b0, funct3};
                    end
                end
                
                `LOAD_OPCODE:
                begin
                
                    if (funct3 < 6 && funct3 != 3)
                    begin
                        mem_req_o <= 1;
                        alu_op_o <= `ALU_ADD;
                        mem_we_o <= 0;
                        wb_src_sel_o <= 1;
                        
                        ex_op_a_sel_o <= 0;
                        ex_op_b_sel_o <= 1;
                        
                        gpr_we_a_o <= 1;
                        mem_size_o <= funct3;
                    end else illegal_instr_o <= 1;
                end
                
                `STORE_OPCODE:
                begin
                    if (funct3 < 3)
                    begin
                        mem_req_o <= 1;
                        mem_we_o <= 1;
                        mem_size_o <= funct3;
                        alu_op_o <= `ALU_ADD;
                        
                        ex_op_a_sel_o <= 0;
                        ex_op_b_sel_o <= 3;
                    end else illegal_instr_o <= 1;
                end
                
                `BRANCH_OPCODE:
                begin
                    if (funct3 < 8 && funct3 != 2 && funct3 != 3)
                    begin
                        alu_op_o <= {2'b11, funct3};
                        branch_o <= 1;
                        
                        ex_op_a_sel_o <= 0;
                        ex_op_b_sel_o <= 0;
                    end else illegal_instr_o <= 1;
                end
                
                `JAL_OPCODE: 
                begin
                    gpr_we_a_o <= 1;
                    wb_src_sel_o <= 0;
                    ex_op_a_sel_o <= 1;
                    ex_op_b_sel_o <= 4;
                    
                    jal_o <= 1;
                end
                
                `JALR_OPCODE: 
                begin
                    case (funct3)
                        0:
                        begin
                            gpr_we_a_o <= 1;
                            ex_op_a_sel_o <= 1;
                            ex_op_b_sel_o <= 4;
                            jalr_o <= 1; 
                        end
                        default:
                            illegal_instr_o <= 1;
                    endcase
                    
                end
                
                `LUI_OPCODE:
                begin
                    gpr_we_a_o <= 1;
                    wb_src_sel_o <= 0;
                    
                    ex_op_a_sel_o <= 2;
                    ex_op_b_sel_o <= 2;
                end
                
                `AUIPC_OPCODE:
                begin
                    gpr_we_a_o <= 1;
                    wb_src_sel_o <= 0;
                    
                    ex_op_a_sel_o <= 1;
                    ex_op_b_sel_o <= 2;
                end
                
                `SYSTEM_OPCODE:
                begin
                    if (fetched_instr_i[31:7] != 0 && fetched_instr_i[31:7] != 8192) 
                        illegal_instr_o <= 1;
                end
                
                `MISC_MEM_OPCODE:
                begin
                    if (funct3 != 0)
                        illegal_instr_o <= 1;
                end
                
                default:
                    illegal_instr_o <= 1;
            endcase
        end
        default:
            illegal_instr_o <= 1;
    endcase
end

endmodule