module LoadAux (
    input wire [1:0] selector,
    input wire [31:0] data_in,
    output wire [31:0] data_out
);

    assign data_out = (selector == 2'b00) ? data_in :
                      (selector == 2'b01) ? {16'b0, data_in[15:0]} :
                      (selector == 2'b10) ? {24'b0, data_in[7:0]} :
                      32'dx;

endmodule