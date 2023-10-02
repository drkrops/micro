module CYBERcobra(
    input clk_i,
    input rst_i,
    input [15:0] sw_i,
    output [31:0] out_o
);
    wire [31:0] adderToPc;
    wire [31:0] instrMemoryOut;
    wire [31:0] rd1ToAluA;
    wire [31:0] rd2ToAluB;
    wire [31:0] aluResultOut;
    wire aluFlag;

    reg[31:0] PC;
    reg [31:0] caseToWd3;
    reg [31:0] caseToAdder;
    
    assign toWe = ~(instrMemoryOut[30] | instrMemoryOut[31]);
    assign out_o = rd1ToAluA;
    assign caseToAdderCondition = (instrMemoryOut[30] & aluFlag) | instrMemoryOut[31];
    
    instr_mem instrMemory (.addr(PC), .read_data(instrMemoryOut));
    fulladder32 adder32 (.A(PC), .B(caseToAdder), .Pin(0), .S(adderToPc));
    rf_riscv registerFile (.clk(clk_i),
        .WE(toWe),
        .A1(instrMemoryOut[22:18]),
        .A2(instrMemoryOut[17:13]),
        .A3(instrMemoryOut[4:0]),
        .WD3(caseToWd3),
        .RD1(rd1ToAluA),
        .RD2(rd2ToAluB)
    );
    alu_riscv ALU (.A(rd1ToAluA), .B(rd2ToAluB), .ALUOp(instrMemoryOut[27:23]), .Flag(aluFlag), .Result(aluResultOut));
    
    always @(posedge clk_i) begin
        PC <= rst_i ? 0 : adderToPc;
    end
    
    always @ (*) begin
        case (instrMemoryOut[29:28])
            2'b00: caseToWd3 <= { {9{instrMemoryOut[27]}}, instrMemoryOut[27:5] };
            2'b01: caseToWd3 <= aluResultOut;
            2'b10: caseToWd3 <= { {16{sw_i}}, sw_i };
            2'b11: caseToWd3 <= 0;
        endcase
    end

    always @ (*) begin
        case (caseToAdderCondition)
            1'b0: caseToAdder <= 4;
            1'b1: caseToAdder <= { {22{instrMemoryOut[12]}}, instrMemoryOut[12:5], {2{1'b0}} };
        endcase
    end
    
endmodule
