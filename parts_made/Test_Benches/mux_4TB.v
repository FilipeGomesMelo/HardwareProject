`timescale 1ns/1ps

module mux_4TB();

	wire [31:0] I1_TB, I2_TB, I3_TB, I4_TB;
	reg [1:0] seletor_TB;
	wire [31:0] F_TB;

	Mux_AluB DUT(seletor_TB, I1_TB, I2_TB, I3_TB, F_TB);

	assign I1_TB = 32'd9;
	assign I2_TB = 32'd7;
	assign I3_TB = 32'd6;
	assign I4_TB = 32'd5;

	initial
		begin
			$dumpfile("mux_4TB.vcd");
			$dumpvars(0,mux_4TB);

			// testes genericos
			seletor_TB = 2'b00;
            #10 seletor_TB = 2'b01;
            #10 seletor_TB = 2'b10;
            #10 seletor_TB = 2'b11;
            #10;
		end
endmodule