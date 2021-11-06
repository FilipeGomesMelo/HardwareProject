module mux_cause (  
    input wire [1:0] selector,
    output wire [31:0] data_out
);
    assign data_out = (selector == 2'b00) ? 32'd253 :
                      (selector == 2'b01) ? 32'd254 :
                      (selector == 2'b10) ? 32'd255 :
                      2'bxx;
endmodule
