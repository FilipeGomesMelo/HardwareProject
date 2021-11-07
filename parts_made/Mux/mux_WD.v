module Mux_WD (
    input wire [2:0] selector,
    input wire [31:0] data_0, data_1, data_2, data_3, data_4, data_5,
    output wire [31:0] data_out
);

    assign data_out = (selector == 3'b000) ? data_0 :
                      (selector == 3'b001) ? data_1 :
                      (selector == 3'b010) ? data_2 :
                      (selector == 3'b011) ? data_3 :
                      (selector == 3'b100) ? data_4 :
                      (selector == 3'b101) ? data_5 :
                      (selector == 3'b110) ? 32'd227 :
                      32'bx;

endmodule