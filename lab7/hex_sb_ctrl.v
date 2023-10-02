module hex_sb_ctrl(
/*
    Часть интерфейса модуля, отвечающая за подключение к системной шине
*/
    input clk_i,
    input [31:0] addr_i,
    input req_i,
    input [31:0] WD_i,
    input WE_i,
    output [31:0] RD_o,
/*
    Часть интерфейса модуля, отвечающая за подключение к модулю,
    осуществляющему вывод цифр на семисегментные индикаторы
*/
    output [6:0] hex_led,
    output [7:0] hex_sel
);
    reg [3:0] hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7;
    reg [7:0] bitmask_on_off;
    reg rd;
    reg rst;
    
    assign RD_o = rd;
    
    hex_digits hexDigits (
        .clk_i(clk_i),
        .rst_i(rst),
        .hex0({ bitmask_on_off[0], hex0 }), // Входной сигнал со значением цифры, выводимой на нулевой (самый правый) индикатор
        .hex1({ bitmask_on_off[1], hex1 }), // Входной сигнал со значением цифры, выводимой на первый индикатор
        .hex2({ bitmask_on_off[2], hex2 }), // Входной сигнал со значением цифры, выводимой на второй индикатор
        .hex3({ bitmask_on_off[3], hex3 }), // Входной сигнал со значением цифры, выводимой на третий индикатор
        .hex4({ bitmask_on_off[4], hex4 }), // Входной сигнал со значением цифры, выводимой на четвертый индикатор
        .hex5({ bitmask_on_off[5], hex5 }), // Входной сигнал со значением цифры, выводимой на пятый индикатор
        .hex6({ bitmask_on_off[6], hex6 }), // Входной сигнал со значением цифры, выводимой на шестой индикатор
        .hex7({ bitmask_on_off[7], hex7 }), // Входной сигнал со значением цифры, выводимой на седьмой индикатор
        .hex_led(hex_led), // Выходной сигнал, контролирующий каждый отдельный светодиод индикатора
        .hex_sel(hex_sel) // Выходной сигнал, указывающий на какой индикатор выставляется hex_led
    );
    
    always @(*) begin
        rst <= 1'b0;
        
        case (addr_i)
            32'h00: begin
                if (~WE_i && req_i) begin
                    rd <= { {28{1'b0}}, hex0 };
                end
            end
            32'h04: begin
                if (~WE_i && req_i) begin
                    rd <= { {28{1'b0}}, hex1 };
                end
            end
            32'h08: begin
                if (~WE_i && req_i) begin
                    rd <= { {28{1'b0}}, hex2 };
                end
            end
            32'h0C: begin
                if (~WE_i && req_i) begin
                    rd <= { {28{1'b0}}, hex3 };
                end
            end
            32'h10: begin
                if (~WE_i && req_i) begin
                    rd <= { {28{1'b0}}, hex4 };
                end
            end
            32'h14: begin
                if (~WE_i && req_i) begin
                    rd <= { {28{1'b0}}, hex5 };
                end
            end
            32'h18: begin
                if (~WE_i && req_i) begin
                    rd <= { {28{1'b0}}, hex6 };
                end
            end
            32'h1C: begin
                if (~WE_i && req_i) begin
                    rd <= { {28{1'b0}}, hex7 };
                end
            end
            32'h20: begin
                if (~WE_i && req_i) begin
                    rd <= { {24{1'b0}}, bitmask_on_off };
                end
            end
        endcase
    end
    
    always @(posedge clk_i) begin
        case (addr_i)
            32'h00: begin
                if (WE_i && req_i && WD_i < 32'd16) begin
                    hex0 <= WD_i[3:0];
                end
            end
            32'h04: begin
                if (WE_i && req_i && WD_i < 32'd16) begin
                    hex1 <= WD_i[3:0];
                end
            end
            32'h08: begin
                if (WE_i && req_i && WD_i < 32'd16) begin
                    hex2 <= WD_i[3:0];
                end
            end
            32'h0C: begin
                if (WE_i && req_i && WD_i < 32'd16) begin
                    hex3 <= WD_i[3:0];
                end
            end
            32'h10: begin
                if (WE_i && req_i && WD_i < 32'd16) begin
                    hex4 <= WD_i[3:0];
                end
            end
            32'h14: begin
                if (WE_i && req_i && WD_i < 32'd16) begin
                    hex5 <= WD_i[3:0];
                end
            end
            32'h18: begin
                if (WE_i && req_i && WD_i < 32'd16) begin
                    hex6 <= WD_i[3:0];
                end
            end
            32'h1C: begin
                if (WE_i && req_i && WD_i < 32'd16) begin
                    hex7 <= WD_i[3:0];
                end
            end
            32'h20: begin
                if (WE_i && req_i && WD_i < 32'd256) begin
                    bitmask_on_off <= WD_i[7:0];
                end
            end
            32'h24: begin
                if (WE_i && req_i && WD_i == 32'd1) begin
                    hex0 <= 0;
                    hex1 <= 0;
                    hex2 <= 0;
                    hex3 <= 0;
                    hex4 <= 0;
                    hex5 <= 0;
                    hex6 <= 0;
                    hex7 <= 0;
                    bitmask_on_off <= 8'hFF;
                    rst <= 1'b1;
                end 
            end
        endcase
    end

endmodule
