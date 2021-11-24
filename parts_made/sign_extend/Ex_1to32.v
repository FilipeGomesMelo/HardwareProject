module Ex_1to32 (
    input wire data_in,
    output wire [31:0] data_out
);
    // Extende 1 bit para 32-bits com 0s a esquerda(slt, slti)
    assign data_out = {31'b0, data_in};
endmodule