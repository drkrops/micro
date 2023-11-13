module decoder_riscv (
  input  logic [31:0]  fetched_instr_i,
  output logic [1:0]   a_sel_o,
  output logic [2:0]   b_sel_o,
  output logic [4:0]   alu_op_o,
  output logic [2:0]   csr_op_o,
  output logic         csr_we_o,
  output logic         mem_req_o,
  output logic         mem_we_o,
  output logic [2:0]   mem_size_o,
  output logic         gpr_we_o,
  output logic [1:0]   wb_sel_o,        //write back selector
  output logic         illegal_instr_o,
  output logic         branch_o,
  output logic         jal_o,
  output logic         jalr_o,
  output logic         mret_o
);
    
    import riscv_pkg::*;
    //import alu_opcodes_pkg::*;
    
    logic [2:0] func3;
    logic [6:0] func7;
    logic [4:0] op_code;
    
    assign op_code = fetched_instr_i[6:2];
    assign func3 = fetched_instr_i[14:12];
    assign func7 = fetched_instr_i[31:25];
    
    always_comb begin
        a_sel_o <= 0;
        b_sel_o <= 0;
        alu_op_o <= 0;
        csr_we_o <= 0;
        csr_op_o <= 0;
        mem_req_o <= 0;
        mem_we_o <= 0;
        mem_size_o <= 0;
        gpr_we_o <= 0;
        wb_sel_o <= 0;
        illegal_instr_o <= 0;
        branch_o <= 0;
        jal_o <= 0;
        jalr_o <= 0;
        mret_o <= 0;
        case(fetched_instr_i[1:0])
            2'b11: 
            begin
                
                   case(op_code)
                                     
                        OP_OPCODE:  
                        begin
                            a_sel_o <= OP_A_RS1;
                            b_sel_o <= OP_B_RS2;
                            csr_we_o <= 0;
                            csr_op_o <= 0;
                            mem_req_o <= 0;
                            mem_we_o <= 0;
                            mem_size_o <= 0;
                            gpr_we_o <= 1'd1;
                            wb_sel_o <= WB_EX_RESULT;
                            jal_o <= 0;
                            jalr_o <= 0;
                            case(func7)   
                                // case(func3)
                                    //если сделать через конкатенацию, то не потеряем ли мы нелегальные инструкции, ведь как проследить?                       
                                7'b000_0000: 
                              
                                    case(func3)
                                        //alu_op_o <= {func7[5:4], func3};
                                        3'b000: alu_op_o <= ALU_ADD;                                        
                                        3'b100: alu_op_o <= ALU_XOR;
                                        3'b110: alu_op_o <= ALU_OR;
                                        3'b111: alu_op_o <= ALU_AND;
                                        3'b001: alu_op_o <= ALU_SLL;                                        
                                        3'b101: alu_op_o <= ALU_SRL;
                                        3'b010: alu_op_o <= ALU_SLTS;
                                        3'b011: alu_op_o <= ALU_SLTU;
                                        default: 
                                        begin
                                            illegal_instr_o <= 1'd1;
                                            gpr_we_o <= 1'd0; 
                                        end
                                    
                                    endcase    
                                                               
                                7'b010_0000:

                                    case(func3)
                                        3'b000: alu_op_o <= ALU_SUB;
                                        3'b101: alu_op_o <= ALU_SRA;
                                        default:
                                        begin
                                            illegal_instr_o <= 1'd1;
                                            gpr_we_o <= 1'd0; 
                                        end
                                    endcase
                                
                                default:
                                begin
                                    illegal_instr_o <= 1'd1;
                                    gpr_we_o <= 1'd0; 
                                end
                            endcase
                        end
                        
                        OP_IMM_OPCODE:
                        begin
                            gpr_we_o <= 1'd1; 
                            b_sel_o <= OP_B_IMM_I;
                            case(func3)
                                3'b000: alu_op_o <= ALU_ADD;
                                3'b100: alu_op_o <= ALU_XOR;
                                3'b110: alu_op_o <= ALU_OR;
                                3'b111: alu_op_o <= ALU_AND;
                                3'b010: alu_op_o <= ALU_SLTS;
                                3'b011: alu_op_o <= ALU_SLTU;
                                3'b001:
                                    case(func7)
                                        7'b000_0000: alu_op_o <= ALU_SLL;
                                        default: 
                                        begin
                                            illegal_instr_o <= 1'd1;
                                            gpr_we_o <= 1'd0; 
                                        end
                                    endcase
                                3'b101:
                                    case(func7)
                                        7'b000_0000: alu_op_o <= ALU_SRL;
                                        7'b010_0000: alu_op_o <= ALU_SRA;
                                        default: 
                                        begin
                                            illegal_instr_o <= 1'd1;
                                            gpr_we_o <= 1'd0; 
                                        end
                                    endcase
                                default:
                                begin
                                    illegal_instr_o <= 1'd1;
                                    gpr_we_o <= 1'd0; 
                                end
                            endcase
                        end
                        
                        LOAD_OPCODE:
                        begin         
                            gpr_we_o <= 1'd1;                 
                            b_sel_o <= OP_B_IMM_I;                            
                            alu_op_o <= ALU_ADD;
                            wb_sel_o <= WB_LSU_DATA;
                            case(func3)
                                LDST_B,
                                LDST_H,
                                LDST_W,
                                LDST_BU,
                                LDST_HU:
                                begin
                                    mem_req_o <= 1'd1;
                                    mem_size_o <= func3;
                                end
                                default:
                                begin
                                    illegal_instr_o <= 1'd1;
                                    gpr_we_o <= 1'd0;
                                end
                            endcase                            
                        end
                        
                        STORE_OPCODE:
                        begin
                            b_sel_o <= OP_B_IMM_S;
                            mem_we_o <= 1'd1;
                            gpr_we_o <= 1'd0;
                            case(func3)
                                LDST_B,
                                LDST_H,
                                LDST_W:
                                begin
                                    mem_req_o <= 1'd1;
                                    mem_size_o <= func3;
                                end
                                default:
                                begin
                                    illegal_instr_o <= 1'd1;
                                    mem_we_o <= 1'd0;
                                end
                            endcase
                        end
                        
                        BRANCH_OPCODE:
                        begin
                            b_sel_o <= OP_B_RS2;
                            branch_o <= 1'd1;
                            gpr_we_o <= 1'd0;
                            case(func3)
                                3'b000: alu_op_o <= ALU_EQ;
                                3'b001: alu_op_o <= ALU_NE;
                                3'b100: alu_op_o <= ALU_LTS;
                                3'b101: alu_op_o <= ALU_GES;
                                3'b110: alu_op_o <= ALU_LTU;
                                3'b111: alu_op_o <= ALU_GEU;
                                default:
                                begin
                                    illegal_instr_o <= 1'd1;
                                    gpr_we_o <= 1'd0; 
                                    branch_o <= 1'd0;
                                end
                            endcase
                        end
                        
                        JAL_OPCODE:
                        begin
                            gpr_we_o <= 1'd1; 
                            a_sel_o <= OP_A_CURR_PC;
                            b_sel_o <= OP_B_INCR;
                            jal_o <= 1'd1;
                            alu_op_o <= ALU_ADD;
                        end
                        
                        JALR_OPCODE:
                        begin
                            case(func3)
                                3'b000:
                                begin
                                    gpr_we_o <= 1'd1; 
                                    a_sel_o <= OP_A_CURR_PC;
                                    b_sel_o <= OP_B_INCR;
                                    jalr_o <= 1'd1;
                                    alu_op_o <= ALU_ADD;
                                end
                                default:
                                begin
                                    illegal_instr_o <= 1'd1;
                                    gpr_we_o <= 1'd0; 
                                end
                            endcase
                        end
                        
                        LUI_OPCODE:
                        begin
                            gpr_we_o <= 1'd1; 
                            a_sel_o <= OP_A_ZERO;
                            b_sel_o <= OP_B_IMM_U;
                            alu_op_o <= ALU_ADD;
                        end
                        
                        AUIPC_OPCODE:
                        begin
                            gpr_we_o <= 1'd1; 
                            a_sel_o <= OP_A_CURR_PC;
                            b_sel_o <= OP_B_IMM_U;
                            alu_op_o <= ALU_ADD;
                        end
                        
                        MISC_MEM_OPCODE:
                        begin
                            if(func3 != 3'b000)
                            begin
                                gpr_we_o <= 1'd0; 
                                illegal_instr_o <= 1'd1;
                            end else
                            begin
                                illegal_instr_o <= 1'd0;
                            end
                        end
                        
                        SYSTEM_OPCODE:
                        begin
                            
                            case(func3)
                                3'b000:
                                begin
                                    case(func7)
                                        7'b000_0000: 
                                        begin
                                            illegal_instr_o <= 1'd1;
                                            gpr_we_o <= 1'd0; //узнать
                                        end
                                        7'b000_0001: 
                                        begin
                                            illegal_instr_o <= 1'd1;
                                            gpr_we_o <= 1'd0; //узнать 
                                        end
                                        default:
                                            case(fetched_instr_i[31:0])
                                                32'b00110000001000000000000001110011: mret_o <= 1'd1;
                                                default: illegal_instr_o <= 1'd1;
                                            endcase
                                    endcase
                                end
                                CSR_RW,
                                CSR_RS,
                                CSR_RC,
                                CSR_RWI,
                                CSR_RSI,
                                CSR_RCI:
                                begin
                                    gpr_we_o <= 1'd1; 
                                    wb_sel_o <= WB_CSR_DATA;
                                    csr_we_o <= 1'd1;
                                    csr_op_o <= func3;
                                end
                                default:
                                begin
                                    illegal_instr_o <= 1'd1;
                                    gpr_we_o <= 1'd0; 
                                end
                            endcase
                        end
                        
                        
                        default:
                        begin
                            illegal_instr_o <= 1'd1;
                            gpr_we_o <= 1'd0; 
                        end
                   endcase
            end
            default: 
            begin
                illegal_instr_o <= 1'd1;
                gpr_we_o <= 1'd0; 
            end
        endcase
    end
    
endmodule