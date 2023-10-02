module riscv_core(
    input clk_i,
    input rst_i,
    input [31:0] instr_i,
    input [31:0] RD_i,
    output [31:0] WD_o,
    output [31:0] instr_addr_o,
    output [31:0] data_addr_o,
    output [2:0] size_o,
    output WE_o
);
    wire illegalInstr;
    wire jalr;
    wire jal;
    wire b;
    wire wbSrcSel;
    wire memReq;
    wire [2:0] memSize;
    wire memWe;
    wire [4:0] aluOp;
    wire [2:0] srcB;
    wire [1:0] srcA;
    wire gprWe;
    wire [31:0] adderUpToPc;
    wire [31:0] adderDownToPc;
    wire [31:0] addersToPc;
    wire [31:0] rd1Out;
    wire [31:0] rd2Out;
    wire [31:0] immI = { {20{instr_i[31]}}, instr_i[31:20] };
    wire [31:0] immU = { instr_i[31:12], { 12{3'h000} } };
    wire [31:0] immS = { { 20{instr_i[31]} }, instr_i[31:25], instr_i[11:7] };
    wire [31:0] immB = { { 19{instr_i[31]} }, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], {1'b0} };
    wire [31:0] immJ = {  { 19{instr_i[31]} }, instr_i[31], instr_i[19:12], instr_i[20], instr_i[31:21], {1'b0} };
    wire [31:0] aluResult;
    wire comp;

    reg [31:0] PC;
    reg [31:0] srcAMultiplexerOut;
    reg [31:0] srcBMultiplexerOut;
    reg [31:0] WDOut;
    reg [31:0] adderDownRightMultiplexerOut;
    reg [31:0] adderDownLeftMultiplexerOut;
    
    decoder_riscv mainDecoder (.fetched_instr_i(instr_i),    
        .ex_op_a_sel_o(srcA),      
        .ex_op_b_sel_o(srcB),      
        .alu_op_o(aluOp),           
        .mem_req_o(memReq),          
        .mem_we_o(WE_o),           
        .mem_size_o(memSize),         
        .gpr_we_a_o(gprWe),         
        .wb_src_sel_o(wbSrcSel),       
        .illegal_instr_o(illegalInstr),    
        .branch_o(b),           
        .jal_o(jal),              
        .jalr_o (jalr) 
    );       
    fulladder32 adderUp (.A(rd1Out), .B(immI), .Pin(0), .S(adderUpToPc));
    fulladder32 adderDown (.A(adderDownLeftMultiplexerOut), .B(PC), .Pin(0), .S(adderDownToPc));
    rf_riscv registerFile (.clk(clk_i),
        .WE(gprWe),
        .A1(instr_i[19:15]),
        .A2(instr_i[24:20]),
        .A3(instr_i[11:7]),
        .WD3(WDOut),
        .RD1(rd1Out),
        .RD2(rd2Out)
    );
    alu_riscv ALU (.A(srcAMultiplexerOut), .B(srcBMultiplexerOut), .ALUOp(aluOp), .Flag(comp), .Result(aluResult));
    
    assign size_o = memReq & memSize;
    
    assign addersToPc = jalr ? adderUpToPc : adderDownToPc;
    always @(posedge clk_i) begin
        PC <= rst_i ? 0 : addersToPc;
    end
    assign instr_addr_o = PC;
    
    always @(*) begin
        case(srcA)
            2'd0: srcAMultiplexerOut <= rd1Out;
            2'd1: srcAMultiplexerOut <= PC;
            2'd2: srcAMultiplexerOut <= 0;
        endcase
    end
    assign WD_o = rd2Out;
    always @(*) begin
        case(srcB)
            3'd0: srcBMultiplexerOut <= rd2Out;
            3'd1: srcBMultiplexerOut <= immI;
            3'd2: srcBMultiplexerOut <= immU;
            3'd3: srcBMultiplexerOut <= immS;
            3'd4: srcBMultiplexerOut <= 4;
        endcase
    end
    
    assign data_addr_o = aluResult;
    always @(*) begin
        case(wbSrcSel)
            1'd0: WDOut <= aluResult;
            1'd1: WDOut <= RD_i;
        endcase
    end
    
    always @(*) begin
        case(b)
            1'd0: adderDownRightMultiplexerOut <= immJ;
            1'd1: adderDownRightMultiplexerOut <= immB;
        endcase
    end
    always @(*) begin
        case((b & comp) | jal)
            1'd0: adderDownLeftMultiplexerOut <= 4;
            1'd1: adderDownLeftMultiplexerOut <= adderDownRightMultiplexerOut;
        endcase
    end
    
endmodule
