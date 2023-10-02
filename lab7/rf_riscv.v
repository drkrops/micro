module rf_riscv(
    input clk,
    input WE,
    
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    
    input [31:0] WD3,
    output [31:0] RD1,
    output [31:0] RD2
    );
    
    reg [31:0] RAM [31:0];
    
    initial RAM[0] = 0;
    
    // assign RD1 = A1 ? RAM[A1] : 0
    assign RD1 = RAM[A1];
    assign RD2 = RAM[A2];
    
     always @(posedge clk)
        if(WE && A3 != 0) begin
            RAM[A3] <= WD3;
        end
    
endmodule
    