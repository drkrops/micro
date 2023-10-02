/*module sign_extension(

input logic word_i,
output logic [31:0] word_o

);

always_comb begin

if(word_i[$bits(word_i)-1] == 1) word_o <= {(32 - $bits(word_i)) * 1'b1, word_i};

else word_o <= {(32 - $bits(word_i)) * 1'b0, word_i};

end

endmodule*/