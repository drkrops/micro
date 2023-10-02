`timescale 1ns / 1ps

module hex_digits(
  input       clk_i, rst_i,
  input [4:0] hex0,     // ������� ������ �� ��������� �����, ��������� �� ������� (����� ������) ���������
  input [4:0] hex1,     // ������� ������ �� ��������� �����, ��������� �� ������ ���������
  input [4:0] hex2,     // ������� ������ �� ��������� �����, ��������� �� ������ ���������
  input [4:0] hex3,     // ������� ������ �� ��������� �����, ��������� �� ������ ���������
  input [4:0] hex4,     // ������� ������ �� ��������� �����, ��������� �� ��������� ���������
  input [4:0] hex5,     // ������� ������ �� ��������� �����, ��������� �� ����� ���������
  input [4:0] hex6,     // ������� ������ �� ��������� �����, ��������� �� ������ ���������
  input [4:0] hex7,     // ������� ������ �� ��������� �����, ��������� �� ������� ���������

  output [6:0] hex_led, // �������� ������, �������������� ������ ��������� ��������� ����������
  output [7:0] hex_sel  // �������� ������, ����������� �� ����� ��������� ������������ hex_led
    );
  `define pwm       1000    //��� ���������
  
  reg [9:0] counter;
  reg [4:0] semseg;
  reg [7:0] ANreg;
  reg [6:0] hex_ledr;
  
  assign hex_sel = ANreg;
  assign hex_led = hex_ledr;
  
  always @(posedge clk_i) begin
    if (rst_i) begin
      counter <= 'b0;
      ANreg[7:0] <= 8'b11111111;
      hex_ledr <= 7'b1111111;
    end
    else begin
      if (counter < `pwm) counter <= counter + 'b1;
      else begin
        counter <= 'b0;
        ANreg[1] <= ANreg[0];
        ANreg[2] <= ANreg[1];
        ANreg[3] <= ANreg[2];
        ANreg[4] <= ANreg[3];
        ANreg[5] <= ANreg[4];
        ANreg[6] <= ANreg[5];
        ANreg[7] <= ANreg[6];
        ANreg[0] <= !(ANreg[6:0] == 7'b1111111);
      end
      case (1'b0)
        ANreg[0]: semseg <= hex0;
        ANreg[1]: semseg <= hex1;
        ANreg[2]: semseg <= hex2;
        ANreg[3]: semseg <= hex3;
        ANreg[4]: semseg <= hex4;
        ANreg[5]: semseg <= hex5;
        ANreg[6]: semseg <= hex6;
        ANreg[7]: semseg <= hex7;
      endcase
      case (semseg)
          5'h10: hex_ledr <= 7'b0000001;
          5'h11: hex_ledr <= 7'b1001111;
          5'h12: hex_ledr <= 7'b0010010;
          5'h13: hex_ledr <= 7'b0000110;
          5'h14: hex_ledr <= 7'b1001100;
          5'h15: hex_ledr <= 7'b0100100;
          5'h16: hex_ledr <= 7'b0100000;
          5'h17: hex_ledr <= 7'b0001111;
          5'h18: hex_ledr <= 7'b0000000;
          5'h19: hex_ledr <= 7'b0000100;
          5'h1A: hex_ledr <= 7'b0001000;
          5'h1B: hex_ledr <= 7'b1100000;
          5'h1C: hex_ledr <= 7'b0110001;
          5'h1D: hex_ledr <= 7'b1000010;
          5'h1E: hex_ledr <= 7'b0110000;
          5'h1F: hex_ledr <= 7'b0111000;
          default: hex_ledr <= 7'b1111111;
      endcase
    end
  end
  
endmodule
