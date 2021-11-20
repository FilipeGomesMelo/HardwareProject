module Mux_ShiftIn (  
    input wire [1:0] selector,
    input wire [31:0] data_0, data_1, data_2,
    output wire [31:0] data_out
);
    
    assign data_out = (selector == 2'b00) ? data_0 :
                      (selector == 2'b01) ? data_1 :
                      (selector == 2'b10) ? data_2 :
                      2'bxx;
                      
endmodule
