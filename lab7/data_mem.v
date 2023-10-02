module data_mem(
    input clk,
    input WE,
    input [31:0] addr,
    input [31:0] write_data,
    output [31:0] read_data
    );
    
    reg [7:0] RAM [1023:0];
    
    assign read_data = {RAM[addr + 3], RAM[addr + 2], RAM[addr + 1] , RAM[addr]};
    
    always @(posedge clk)
        if(WE) begin
            {RAM[addr + 3], RAM[addr + 2], RAM[addr + 1], RAM[addr]} = write_data;
        end

endmodule
