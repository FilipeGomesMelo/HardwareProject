module Ex_1to32 (
    input wire data_in,
    output wire [31:0] data_out
);
    assign data_out = {31'b0, data_in};
endmodule