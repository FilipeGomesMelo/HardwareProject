module Shift_left2 (
    input wire [31:0] data_in;
    output wire [31:0] data_out;
);
    assign data_out = data_in << 2;
endmodule