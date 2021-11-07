module Mux_WR (  
    input wire [1:0] selector,
    input wire [4:0] data_0, data_1,
    output wire [4:0] data_out
);
    assign data_out = (selector == 2'b00) ? data_0 :
                      (selector == 2'b01) ? data_1 :
                      (selector == 2'b10) ? 5'd31 :
                      (selector == 2'b11) ? 5'd29 :
                      2'bxx;
endmodule
