module riscv_unit(
    input clk_i,
    input resetn,
    
    input        kclk,    // Тактирующий сигнал клавиатуры
    input        kdata,   // Сигнал данных клавиатуры
    output [6:0] hex_led, // Вывод семисегментных индикаторов
    output [7:0] hex_sel // Селектор семисегментных индикаторов
);
    wire rst_i = ~resetn;
    wire [31:0] instr;
    wire [31:0] instr_addr;
    wire [31:0] dataMemoryRdToCore;
    wire [31:0] coreWeToDataMemory;
    wire [31:0] coreDataAddrToDataMemoryA;
    wire [31:0] coreWdToDataMemory;
    reg [255:0] oneHotEncoderOut;
    reg [31:0] periphDevicesToRd;
    wire [31:0] ps2ControllerRd;
    wire req;
    
    wire sysclk, clk10;
    clk_div#(4) divider(.clk_i(clk_i),.aresetn_i(resetn),.div_i(10),.clk_o(clk10));
    BUFG clk (.O(sysclk),.I(clk10));
    
    instr_mem instructionMemory (
          .addr(instr_addr),
          .read_data(instr)
    );
    riscv_core core (
        .clk_i(sysclk),
        .rst_i(rst_i),
        .instr_i(instr),
        .RD_i(periphDevicesToRd),
        .WD_o(coreWdToDataMemory),
        .instr_addr_o(instr_addr),
        .data_addr_o(coreDataAddrToDataMemoryA),
        .size_o(),
        .WE_o(coreWeToDataMemory),
        .mem_req_o(req)
    );
    data_mem dataMemory (
        .clk(sysclk),
        .WE(coreWeToDataMemory),
        .addr({ {8{1'b0}}, coreDataAddrToDataMemoryA[23:0] }),
        .write_data(coreWdToDataMemory),
        .read_data(dataMemoryRdToCore)
    );
    
    ps2_sb_ctrl ps2Controller(
        .clk_i(sysclk),
        .addr_i({ {8{1'b0}}, coreDataAddrToDataMemoryA[23:0] }),
        .req_i(req && oneHotEncoderOut[3]),
        .WD_i(coreWdToDataMemory),
        .WE_i(coreWeToDataMemory),
        .RD_o(ps2ControllerRd),
        .kclk(kclk),
        .kdata(kdata)
    );
    hex_sb_ctrl hexSbController(
        .clk_i(sysclk),
        .addr_i({ {8{1'b0}}, coreDataAddrToDataMemoryA[23:0] }),
        .req_i(req && oneHotEncoderOut[4]),
        .WD_i(coreWdToDataMemory),
        .WE_i(coreWeToDataMemory),
        .RD_o(hexSbControllerRd),
        .hex_led(hex_led),
        .hex_sel(hex_sel)
    );
    
    always @(*) begin
        case (coreDataAddrToDataMemoryA[31:24])
            8'h03: oneHotEncoderOut[3] <= 1;
            8'h04: oneHotEncoderOut[4] <= 1;
            default: oneHotEncoderOut <= 0;
        endcase
    end
    
    always @(*) begin
        case (coreDataAddrToDataMemoryA[31:24])
            8'h00: periphDevicesToRd <= dataMemoryRdToCore;
            8'h03: periphDevicesToRd <= ps2ControllerRd;
            8'h04: periphDevicesToRd <= hexSbControllerRd;
        endcase
    end

endmodule
