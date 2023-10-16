module data_mem(

input logic clk_i,
input logic mem_req_i,
input logic write_enable_i,
input logic [31:0] addr_i,
input logic [31:0] write_data_i,
output logic [31:0] read_data_o

);

logic [31:0]  mem1 [4096]; 

logic [31:0] rd_o_reg;

//assign read_data_o = rd_o_reg;

always_ff @(posedge clk_i) begin

    case({mem_req_i, write_enable_i})
        
        2'b00 : read_data_o <= 32'hfa11_1eaf;
        
        2'b01 : read_data_o <= 32'hfa11_1eaf;
        
        2'b10 :     if(( addr_i >= 0) && (addr_i <= 'd16383)) begin
     
                    read_data_o <= mem1[addr_i/4];
                    
                    end
                    
                    else read_data_o <= 32'hdead_beef;
                    
        2'b11 : begin
        
                mem1 [addr_i/4] <= write_data_i;
                
                read_data_o <= 32'hfa11_1eaf;
                
                end 
            
    endcase
    
end           

endmodule