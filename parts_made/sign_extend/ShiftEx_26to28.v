module ShiftEx_26to28 (
    input wire [25:0] data_in,
    output wire [27:0] data_out
);
    // Extende 26-bits e move dois para a esquerda (Jumps)
    assign data_out = {data_in, 2'b00};
endmodule