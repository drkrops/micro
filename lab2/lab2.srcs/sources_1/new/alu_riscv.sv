module alu_riscv (

input logic [31:0] a_i,
input logic [31:0] b_i,
input logic [4:0] alu_op_i,

output logic flag_o,
output logic [31:0] result_o

);


    logic [31:0] result0;
    logic [31:0] result_sub_w;

import alu_opcodes_pkg::*;

    
    always_comb begin
        case(alu_op_i)
        
         ALU_LTS: flag_o = $signed(a_i[31:0]) < $signed(b_i[31:0]);
         ALU_LTU: flag_o =  a_i[31:0] < b_i[31:0];
         ALU_GES: flag_o = $signed(a_i[31:0]) >= $signed(b_i[31:0]);
         ALU_GEU: flag_o = a_i[31:0] >= b_i[31:0];
         ALU_EQ: flag_o = a_i[31:0] == b_i[31:0];
         ALU_NE: flag_o = a_i[31:0] != b_i[31:0];
         default: flag_o = 0;
        
        endcase
        
        case(alu_op_i)
        
        ALU_ADD: result_o = result0;
        ALU_SUB: result_o = result_sub_w;
        ALU_XOR: result_o = a_i ^ b_i;
        ALU_OR:  result_o = a_i | b_i;
        ALU_AND: result_o = a_i & b_i;
        ALU_SRA: result_o = $signed(a_i[31:0]) >>> b_i[4:0];
        ALU_SRL: result_o = a_i[31:0] >> b_i[4:0];
        ALU_SLL:  result_o = a_i[31:0] << b_i[4:0];
        ALU_SLTS: result_o = $signed(a_i[31:0]) < $signed(b_i[31:0]);
        ALU_SLTU: result_o = a_i[31:0] < b_i[31:0];
        default: result_o[31:0] = 0;
        
        endcase
    end
        fulladder32 sum(
        
            .a_i(a_i),
            .b_i(b_i),
            .carry_i(0),
            .sum_o(result0)
        
        );
        
        fulladder32 subtr(
        
        .a_i(a_i),
        .b_i(~(b_i)+1'b1),
        .carry_i('0),
        
        .sum_o(result_sub_w)
        
        );      
        
endmodule