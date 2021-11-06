module StoreAux (
    input wire [1:0] selector,
    input wire [31:0] data_0, data_1,
    output wire [31:0] data_out
);

    assign data_out = (selector == 2'b00) ? data_0 :
                      (selector == 2'b01) ? {data_1[31:16], data_0[15:0]} :
                      (selector == 2'b10) ? {data_1[31:8], data_0[7:0]} :
                      32'dx;

endmodule