module csr_controller(

  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        trap_i,

  input  logic [ 2:0] opcode_i,

  input  logic [11:0] addr_i,
  input  logic [31:0] pc_i,
  input  logic [31:0] mcause_i,
  input  logic [31:0] rs1_data_i,
  input  logic [31:0] imm_data_i,
  input  logic        write_enable_i,

  output logic [31:0] read_data_o,
  output logic [31:0] mie_o,
  output logic [31:0] mepc_o,
  output logic [31:0] mtvec_o
);

// import csr_pkg::*;

logic [31:0] miereg_i_w; //выход мультиплексора инструкций
logic [31:0] readdata_o_w;

logic mie_en;
logic mtvec_en;
logic mscratch_en;
logic mepc_en;
logic mcause_en;

logic [31:0] miereg_o_w;
logic [31:0] mtvecreg_o_w;
logic [31:0] mscratchreg_o_w;
logic [31:0] mepcreg_o_w;
logic [31:0] mcausereg_o_w;


always_comb begin

    case(opcode_i)
    
        3'b000  : miereg_i_w = rs1_data_i;
        
        3'b010  : miereg_i_w = (readdata_o_w || rs1_data_i);
        
        3'b011  : miereg_i_w = (readdata_o_w || !rs1_data_i);
        
        3'b101  : miereg_i_w = imm_data_i;
        
        3'b110  : miereg_i_w = (imm_data_i || readdata_o_w);
        
        default : miereg_i_w = (!imm_data_i || readdata_o_w);
    
    endcase

end
//дешифратор
always_comb begin

    case(addr_i)

        12'h304 : mie_en = write_enable_i;
        
        12'h305 : mtvec_en = write_enable_i;
        
        12'h340 : mscratch_en = write_enable_i;
        
        12'h341 : mepc_en = write_enable_i;
        
        default : mcause_en = write_enable_i;      

    endcase

end

always_comb begin

    case(addr_i)
    
        12'h304 : readdata_o_w = miereg_o_w; 
        
        12'h305 : readdata_o_w = mtvecreg_o_w;
        
        12'h340 : readdata_o_w = mscratchreg_o_w;
        
        12'h341 : readdata_o_w = mepcreg_o_w;
        
        default : readdata_o_w = mcausereg_o_w;
    
    endcase

end

assign miereg_o_w = mie_o;

always_ff @(posedge clk_i) begin

    if(rst_i) miereg_o_w <= '0;
    
    else if(mie_en) 
    
    miereg_o_w <= miereg_i_w;

end

assign mtvecreg_o_w = mtvec_o;

always_ff @(posedge clk_i) begin

    if(rst_i) mtvecreg_o_w <= '0;
    
    else if(mtvec_en) 
    
    mtvecreg_o_w <= miereg_i_w;

end

always_ff @(posedge clk_i) begin

    if(rst_i) mscratchreg_o_w <= '0;
    
    else if(mscratch_en) 
    
    mscratchreg_o_w <= miereg_i_w;

end

assign mepc_o = mepcreg_o_w;

always_ff @(posedge clk_i) begin

    if(rst_i) mepcreg_o_w <= '0;
    
    else if(mepc_en || trap_i) 
        
    mepcreg_o_w <= trap_i == 1 ? pc_i : miereg_i_w;
    
end

always_ff @(posedge clk_i) begin

    if(rst_i) mcausereg_o_w <= '0;
    
    else if(mcause_en || trap_i) 
        
    mcausereg_o_w <= trap_i == 1 ? mcause_i : miereg_i_w;
    
end


endmodule