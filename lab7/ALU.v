`include "defines_riscv.v"

module alu_riscv (
    input [31:0] A,
    input [31:0] B,
    input [4:0] ALUOp,
    output reg Flag,
    output reg [31:0] Result
);

wire [31:0] adderToResult;
wire [31:0] nB;

assign nB = ~B;

fulladder32 add32 (.A(A), .B(ALUOp[3] ? nB : B), .Pin(ALUOp[3]), .S(adderToResult));

always @ * begin

    case (ALUOp)
        `ALU_ADD: Result <= adderToResult;
        `ALU_SUB: Result <= adderToResult;
        `ALU_SLL: Result <= A << B[4:0];
        `ALU_SLTS: Result <= $signed(A) < $signed(B);
        `ALU_SLTU: Result <= A < B;
        `ALU_XOR: Result <= A ^ B;
        `ALU_SRL: Result <= A >> B[4:0];
        `ALU_SRA: Result <= $signed(A) >>> $signed(B[4:0]);
        `ALU_OR: Result <= A | B;
        `ALU_AND: Result <= A & B;
        default: Result <= 0; 
    endcase
    
        case (ALUOp)
        `ALU_EQ: Flag <= (A == B);
        `ALU_NE: Flag <= (A != B);
        `ALU_LTS: Flag <= $signed(A) < $signed(B);
        `ALU_GES: Flag <= $signed(A) >= $signed(B);
        `ALU_LTU: Flag <= A < B;
        `ALU_GEU: Flag <= A >= B;
        default: Flag <= 0;
    endcase
end

endmodule
