module riscv_unit(
    input clk_i,
    input rst_i
);

    wire [31:0] instr;
    wire [31:0] instr_addr;
    wire [31:0] dataMemoryRdToCore;
    wire [31:0] coreWeToDataMemory;
    wire [31:0] coreDataAddrToDataMemoryA;
    wire [31:0] coreWdToDataMemory;
    
    instr_mem instructionMemory (
          .addr(instr_addr),
          .read_data(instr)
    );
    riscv_core core (.clk_i(clk_i),
        .rst_i(rst_i),
        .instr_i(instr),
        .RD_i(dataMemoryRdToCore),
        .WD_o(coreWdToDataMemory),
        .instr_addr_o(instr_addr),
        .data_addr_o(coreDataAddrToDataMemoryA),
        .size_o(),
        .WE_o(coreWeToDataMemory)
    );
    data_mem dataMemory (.clk(clk_i),
        .WE(coreWeToDataMemory),
        .addr(coreDataAddrToDataMemoryA),
        .write_data(coreWdToDataMemory),
        .read_data(dataMemoryRdToCore)
    ); 

endmodule
