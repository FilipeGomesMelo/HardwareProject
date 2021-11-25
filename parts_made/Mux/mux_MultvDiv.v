module Mux_MultDiv (  
    input wire selector,
    input wire [31:0] data_0, data_1,
    output wire [31:0] data_out
);
    assign data_out = (selector == 2'b0) ? data_0 :
                      (selector == 2'b1) ? data_1 :
                      2'bxx;
endmodule