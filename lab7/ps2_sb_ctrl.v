module ps2_sb_ctrl(
/*
    ����� ���������� ������, ���������� �� ����������� � ��������� ����
*/
    input clk_i,
    input [31:0] addr_i,
    input req_i,
    input [31:0] WD_i,
    input WE_i,
    output [31:0] RD_o,
/*
    ����� ���������� ������, ���������� �� ����������� � ������,
    ��������������� ����� ������ � ����������
*/
    input kclk,
    input kdata
);
    reg [7:0] scan_code;
    reg scan_code_is_unread;
    wire isKeycodeValid;
    wire keycodeoutValue;
    reg [31:0] rd;

    PS2Receiver ps2(
        .clk(clk_i), // ������ ������������ ���������� � ������ ������-�����������
        .kclk(kclk), // �������� ������, ���������� � ����������
        .kdata(kdata), // ������ ������, ���������� � ����������
        .keycodeout(keycodeoutValue), // ������ ����������� � ���������� ����-���� �������
        .keycode_valid(isKeycodeValid) // ������ ���������� ������ �� ������ keycodeout 
    );

    assign RD_o = rd;

    always @(posedge clk_i) begin
        if (isKeycodeValid && req_i) begin
            scan_code <= keycodeoutValue;
            scan_code_is_unread  <= 1;
        end
    end

    always @(*) begin
        case (addr_i)
            32'h00: begin
                if (!WE_i && req_i) begin
                    rd <= { 24'd0, scan_code };
                    scan_code_is_unread <= 0;
                end
            end
            32'h04: begin
                if (!WE_i && req_i) begin
                    rd <= scan_code_is_unread;
                end 
            end
        endcase
    end
    
    always @(posedge clk_i) begin
        case (addr_i)
            32'h24: begin
                if (WE_i && WD_i == 1 && req_i) begin
                    scan_code <= 0;
                    scan_code_is_unread <= 0;
                end
            end
        endcase
    end

endmodule
