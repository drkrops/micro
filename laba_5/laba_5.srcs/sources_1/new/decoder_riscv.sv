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
  output logic         mret
);
  import riscv_pkg::*; 
  
  import alu_opcodes_pkg::*;
  
  always_comb begin
  
  a_sel_o         = 0;
  b_sel_o         = 0;
  mem_req_o       = 0;
  mem_we_o        = 0;
  mem_size_o      = 0;
  gpr_we_o        = 0;
  wb_sel_o        = 0;
  illegal_instr_o = 0;
  branch_o        = 0;
  jal_o           = 0;
  jalr_o          = 0;
  mret            = 0;
  
  if(fetched_instr_i[1:0] == 2'b11) begin
  
  case(fetched_instr_i[6:2])
  
    OP_OPCODE: begin
    
       
         gpr_we_o = 1;
    
        case({fetched_instr_i[31:25], fetched_instr_i[14:12]})
        
        10'h00_0 : alu_op_o = ALU_ADD;
        10'h00_1 : alu_op_o = ALU_SLL;
        10'h00_2 : alu_op_o = ALU_SLTS;
        10'h00_3 : alu_op_o = ALU_SLTU;
        10'h00_4 : alu_op_o = ALU_XOR;
        10'h00_5 : alu_op_o = ALU_SRL;
        10'h00_6 : alu_op_o = ALU_OR;
        10'h00_7 : alu_op_o = ALU_AND;
        
        10'h20_0 : alu_op_o = ALU_SUB;
        10'h20_5 : alu_op_o = ALU_SRA;
        
        default : begin illegal_instr_o = 1; gpr_we_o = 0; end
                
        endcase
    end
    
    MISC_MEM_OPCODE:
    
     begin
     
     case(fetched_instr_i[14:12])
     
     3'h0 : begin alu_op_o = ALU_AND; b_sel_o = OP_B_IMM_I; end
     
     default : illegal_instr_o = 1;
     
     endcase
     
     end
    
    OP_IMM_OPCODE:
    
    begin
    
    gpr_we_o = 1;
    b_sel_o  = OP_B_IMM_I;
    
        case({fetched_instr_i[31:25], fetched_instr_i[14:12]}) 
        
        10'h00_1 : alu_op_o = ALU_SLL;     
        10'h00_5 : alu_op_o = ALU_SRL;
        10'h20_5 : alu_op_o = ALU_SRA;
        
        default : begin illegal_instr_o = 1; gpr_we_o = 0; end
        
        endcase 
    
      
         case({fetched_instr_i[14:12]}) 
           
        3'd0 : alu_op_o = ALU_ADD;     
        3'd1 : alu_op_o = ALU_ADD; 
        3'd2 : alu_op_o = ALU_SLTS; 
        3'd3 : alu_op_o = ALU_SLTU;
        3'd4 : alu_op_o = ALU_XOR;
        3'd6 : alu_op_o = ALU_OR;
        3'd7 : alu_op_o = ALU_AND; 
        
        default : begin illegal_instr_o = 1; gpr_we_o = 0; end
        
        endcase
        
    
   end
   
    AUIPC_OPCODE:
    
    begin
    
    a_sel_o  = OP_A_CURR_PC;
    b_sel_o  = OP_B_IMM_U;
    alu_op_o = ALU_ADD; 
    gpr_we_o = 1;
    
    end     
   
    STORE_OPCODE: 
    
    begin
    
    b_sel_o   = OP_B_IMM_S; gpr_we_o = 0;
    mem_req_o = 1; mem_we_o = 1;
    
        case(fetched_instr_i[14:12])
        
        3'h0 : mem_size_o = LDST_B;
        3'h1 : mem_size_o = LDST_H;
        3'h2 : mem_size_o = LDST_W;
        
        default : begin illegal_instr_o = 1;  mem_req_o = 0; mem_we_o = 0; end
        
        endcase
    
    end
    
    LOAD_OPCODE: 
    
    begin
    
    
    mem_req_o = 1;
    wb_sel_o  = 1;
    b_sel_o   = OP_B_IMM_I;
    alu_op_o  = ALU_ADD;
    gpr_we_o  = 1;
    
    case(fetched_instr_i[14:12])
    
    3'h0 : mem_size_o = LDST_B;
    3'h1 : mem_size_o = LDST_H;
    3'h2 : mem_size_o = LDST_W;
    3'h4 : mem_size_o = LDST_BU;
    3'h5 : mem_size_o = LDST_HU;
    
    default : begin illegal_instr_o = 1; mem_req_o = 0; gpr_we_o = 0; end
    
    endcase
    
    end
    
    LUI_OPCODE:
    
    begin
    
    a_sel_o  = OP_A_ZERO;
    b_sel_o  = OP_B_IMM_U;
    alu_op_o = ALU_ADD;
    gpr_we_o = 1;
    
    end  
    
    
    BRANCH_OPCODE: 
    
    begin
    
    branch_o = 1;
    gpr_we_o = 0;
    a_sel_o  = 0;
    b_sel_o  = 0;
    
    
    
    case(fetched_instr_i[14:12])
    
    3'h0 : alu_op_o = ALU_EQ;
    3'h1 : alu_op_o = ALU_NE;
    3'h4 : alu_op_o = ALU_LTS;
    3'h5 : alu_op_o = ALU_GES;
    3'h6 : alu_op_o = ALU_LTU;
    3'h7 : alu_op_o = ALU_GEU;
    
    default : begin illegal_instr_o = 1; branch_o = 0; end
    
    endcase
    
    end
    
    JALR_OPCODE:
      
    begin
    
    case(fetched_instr_i[14:12])
    
    3'h0 :
     begin
     jalr_o   = 1; 
     gpr_we_o = 1;
     a_sel_o  = OP_A_CURR_PC;
     b_sel_o  = OP_B_INCR; 
     alu_op_o = ALU_ADD; 
     
     end
    
    default : illegal_instr_o = 1;
    
    endcase
    
    end
    
    JAL_OPCODE: 
    
    begin

     jal_o    = 1;
     gpr_we_o = 1;
     a_sel_o  = OP_A_CURR_PC;
     b_sel_o  = OP_B_INCR; 
     alu_op_o = ALU_ADD;
    
    end
    
    SYSTEM_OPCODE:
    
    begin
    
    case({fetched_instr_i[14:12]})
    
        3'd0 : mret = 1;     
        3'd1 : alu_op_o = ALU_ADD; 
        3'd2 : alu_op_o = ALU_SLTS; 
        3'd3 : alu_op_o = ALU_SLTU;
        3'd4 : alu_op_o = ALU_XOR;
        3'd6 : alu_op_o = ALU_OR;
        3'd7 : alu_op_o = ALU_AND;
    
    default : illegal_instr_o = 1;
    
    endcase
    
    end
    
   default begin illegal_instr_o = 1; end 
   
  endcase
  
  end else illegal_instr_o = 1;
  
  end

endmodule