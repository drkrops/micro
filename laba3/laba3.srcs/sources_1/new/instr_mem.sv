module instr_mem(

input  logic [31:0] addr_i,
output logic [31:0] read_data_o
);

logic [31:0] instr_mem [1024];

initial $readmemh("example.txt", instr_mem);

logic [31:0] Y;

assign read_data_o = Y;
 
always_comb begin 

    if( addr_i[31:0] > 32'd4095) Y = 0;
    
    else  Y[31:0] = instr_mem[addr_i/4];
               
end
endmodule