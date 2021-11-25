module Ex_16or8to32 (
    input wire selector,
    input wire [15:0] data_0,
    input wire [7:0] data_1,
    output wire [31:0] data_out
);
    wire [31:0] aux_0, aux_1;

    // Extenção do fio de 16-bits, mantendo o sinal (imediatos e offsets)
    assign aux_0 = (data_0[15]) ? {{16{1'b1}}, data_0} : {{16{1'b0}}, data_0};

    // Extenção do fio de 8-bits da memória, extende sempre com zero (exceções)
    assign aux_1 = {{24{1'b0}}, data_1};

    // Escolhe o fio da mesma forma que um multiplexador de 2 entradas
    assign data_out = (selector == 1'b0) ? aux_0 : aux_1;

endmodule