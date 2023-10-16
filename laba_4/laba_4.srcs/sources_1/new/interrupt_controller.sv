module interrupt_controller(
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        stall_i,
  input  logic [31:0] irq_req_i,
  input  logic [31:0] mie_i,
  input  logic        mret_i,

  output logic [31:0] irq_ret_o,
  output logic [31:0] mcause_o,
  output logic        irq_o
);

logic [31:0] masked_irq;
logic [31:0] mcause_o_w;
logic [31:0] irqreg_o;
logic busyreg_o;
logic enable [31:0];


assign masked_irq = irq_req_i & mie_i;

assign enable[0] = !mcause_o[0] & busyreg_o;
assign mcause_o[0] = masked_irq[0] & busyreg_o;


genvar i;

generate
    for (i = 1; i < 32; i = i  + 1) begin : newgen

            assign enable[i] = !mcause_o[i] & enable[i-1];
            assign mcause_o[i] = masked_irq[i] & enable[i-1];  

    end
    
endgenerate
    
assign irq_o = | mcause_o;

always_ff @(posedge clk_i) begin

if(rst_i) busyreg_o <= '0;

else busyreg_o <= (!mret_i && (busyreg_o || (!stall_i && irq_o)));

end

always_ff @(posedge clk_i) 

if(rst_i) irqreg_o <= '0;

else if(irq_o) irqreg_o <= mcause_o;

always_comb begin

irq_ret_o = mret_i ? irqreg_o : 32'd0;

end
        
endmodule