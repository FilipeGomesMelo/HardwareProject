`timescale 1ns/1ps

module mux_WD_TB();

	reg [2:0] selector_TB;
    wire [31:0] data_0_TB, data_1_TB, data_2_TB, data_3_TB, data_4_TB, data_5_TB, data_6_TB;
    wire [31:0] data_out_TB;

	mux_WD DUT(selector_TB, data_0_TB, data_1_TB, data_2_TB, data_3_TB, data_4_TB, data_5_TB, data_6_TB, data_out_TB);

    assign data_0_TB = 32'd0;
    assign data_1_TB = 32'd1;
    assign data_2_TB = 32'd2;
    assign data_3_TB = 32'd3;
    assign data_4_TB = 32'd4;
    assign data_5_TB = 32'd5;
    assign data_6_TB = 32'd6;

	initial
		begin
			$dumpfile("mux_WD.vcd");
			$dumpvars(0,mux_WD_TB);

			// testes genericos
			#10 selector_TB = 3'b000;
            #10 selector_TB = 3'b001;
            #10 selector_TB = 3'b010;
            #10 selector_TB = 3'b011;
            #10 selector_TB = 3'b100;
            #10 selector_TB = 3'b101;
            #10 selector_TB = 3'b110;
            #10 selector_TB = 3'b111;
            #10;
		end
endmodule