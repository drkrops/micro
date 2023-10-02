module data_mem(

input logic clk_i,
input logic mem_req_i,
input logic write_enable_i,
input logic [31:0] addr_i,
input logic [31:0] write_data_i,
output logic [31:0] read_data_o,
logic [7:0]  mem1 [4096] 
);


always_ff @(posedge clk_i) begin

case({mem_req_i, write_enable_i}) 
  2'b00 : read_data_o <= 32'hfa11_1eaf;
  
  2'b01 : read_data_o <= 32'hfa11_1eaf;
  
  2'b10 :if (0 <= addr_i <=4096) begin
  
   read_data_o [31:0] <= {mem1[addr_i+3],mem1[addr_i+2],mem1[addr_i+1],mem1[addr_i]};
   
  end else begin
  
  read_data_o <= 32'hdead_beef;
  
  end
  2'b11 : begin
  read_data_o <= 32'hfa11_1eaf;
  {mem1[addr_i+3], mem1[addr_i+2], mem1[addr_i+1], mem1[addr_i]} <= write_data_i;
  
  end
  
  endcase

    end

endmodule