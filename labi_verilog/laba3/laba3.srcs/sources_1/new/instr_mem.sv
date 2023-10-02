module instr_mem(

input logic [31:0] addr_i,
output logic [31:0] read_data_o,
logic [7:0] instr_mem [1024]
);



initial $readmemh("example.txt", instr_mem);
logic [31:0] Y;
always_comb begin 

if( addr_i[31:0] > 32'h000003fc) begin 
     Y <= 0;
    end else begin
    
    Y[31:0] <= {instr_mem[addr_i+3],instr_mem[addr_i+2],instr_mem[addr_i+1], instr_mem[addr_i]};

    
    
    end
    
    end
    
    assign read_data_o[31:0] = Y[31:0];
    
endmodule