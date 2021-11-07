module Mux_AluA (  
    input wire [1:0] selector,
    input wire [31:0] data_0, data_1,
    output wire [31:0] data_out
);
    assign data_out = (selector == 2'b00) ? data_0 :
                      (selector == 2'b01) ? 32'd0 :
                      (selector == 2'b10) ? data_1 :
                      2'bxx;

endmodule
