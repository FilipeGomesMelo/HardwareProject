module Ex_16or8to32 (
    input wire selector,
    input wire [15:0] data_0,
    input wire [7:0] data_1,
    output wire [31:0] data_out
);
    wire [31:0] aux_0, aux_1;

    assign aux_0 = (data_0[15]) ? {{16{1'b1}}, data_0} : {{16{1'b0}}, data_0};

    assign aux_1 = (data_1[7]) ? {{24{1'b1}}, data_1} : {{24{1'b0}}, data_1};

    assign data_out = (selector == 1'b0) ? aux_0 : aux_1;

endmodule