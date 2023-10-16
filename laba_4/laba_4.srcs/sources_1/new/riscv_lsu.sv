module riscv_lsu(
  input logic clk_i,
  input logic rst_i,

  // Интерфейс с ядром
  input  logic        core_req_i,
  input  logic        core_we_i,
  input  logic [ 2:0] core_size_i,
  input  logic [31:0] core_addr_i,
  input  logic [31:0] core_wd_i,
  output logic [31:0] core_rd_o,
  output logic        core_stall_o,

  // Интерфейс с памятью
  output logic        mem_req_o,
  output logic        mem_we_o,
  output logic [ 3:0] mem_be_o,
  output logic [31:0] mem_addr_o,
  output logic [31:0] mem_wd_o,
  input  logic [31:0] mem_rd_i,
  input  logic        mem_ready_i
);

assign mem_req_o = core_req_i;
assign mem_we_o = core_we_i;
assign mem_addr_o = core_addr_i;

logic half_offset;
logic byte_offset;

logic [31:0] ldst_b_w;
logic [31:0] ldst_bu_w;
logic [31:0] ldst_h_w;
logic [31:0] ldst_hu_w;

logic stallreg_i;
logic stallreg_o;

assign byte_offset = core_addr_i[1:0];
assign half_offset = core_addr_i[1];



always_comb begin
    if(core_req_i && core_we_i) begin
        case(core_size_i)
        
            3'b000  :  mem_be_o = (4'b0001 << byte_offset);
            
            3'b001  :  mem_be_o = half_offset == 1 ? 4'b0011 : 4'b1100;
            
            default :  mem_be_o = 4'b1111;  
        
        endcase
    end
end

always_comb begin

    case(core_size_i)

        3'b000  :  mem_wd_o = {4{core_wd_i[7:0]}};
        
        3'b001  :  mem_wd_o = {2{core_wd_i[15:0]}};
        
        default :  mem_wd_o = core_wd_i;

    endcase

end

always_comb begin

    case(core_size_i) 
    
        3'b000 : begin 
                    case(byte_offset)
                 
                        2'b00 : ldst_b_w = {{24{mem_rd_i[7]}} , mem_rd_i[7:0]};
                        
                        2'b01 : ldst_b_w = {{24{mem_rd_i[15]}} , mem_rd_i[15:8]};
                        
                        2'b10 : ldst_b_w = {{24{mem_rd_i[23]}} , mem_rd_i[23:16]};
                        
                        2'b11 : ldst_b_w = {{24{mem_rd_i[31]}} , mem_rd_i[31:24]};
                    
                    endcase
                 
                 core_rd_o = ldst_b_w;
                 
                 end
        3'b100 : begin 
                    case(byte_offset) 
                     
                        2'b00 : ldst_bu_w = {24'd0 , mem_rd_i[7:0]};
                        
                        2'b01 : ldst_bu_w = {24'd0 , mem_rd_i[15:8]};
                        
                        2'b10 : ldst_bu_w = {24'd0 , mem_rd_i[23:16]};
                        
                        2'b11 : ldst_bu_w = {24'd0 , mem_rd_i[31:24]};
                 
                    endcase
                 
                 core_rd_o = ldst_bu_w;
                 
                 end
                 
        3'b001 : begin 
                    case(half_offset) 
                     
                        1'b0 : ldst_h_w = {{16{mem_rd_i[15]}} , mem_rd_i[15:0]};
                        
                        2'b01 : ldst_h_w = {{16{mem_rd_i[31]}} , mem_rd_i[31:16]};
                 
                    endcase
                 
                 core_rd_o = ldst_h_w;
                 
                 end
                 
        3'b101 : begin 
                    case(half_offset) 
                     
                        1'b0 : ldst_hu_w = {16'd0 , mem_rd_i[15:0]};
                        
                        2'b01 : ldst_hu_w = {16'd0 , mem_rd_i[31:16]};
                 
                    endcase
                 
                 core_rd_o = ldst_hu_w;
                 
                 end
                 
        default : core_rd_o = mem_rd_i;
                                    
    endcase

end

assign stallreg_i = (core_req_i && !(stallreg_o && mem_ready_i));

always_ff @(posedge clk_i) begin

    if(rst_i) stallreg_o <= 1'd0;

    else

    stallreg_o <= stallreg_i; 

end

endmodule