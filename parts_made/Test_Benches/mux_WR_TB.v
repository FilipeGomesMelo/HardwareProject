`timescale 1ns/1ps

module mux_WR_TB();

	wire [4:0] I1_TB;
    wire [15:0] I2_TB;
	reg [1:0] seletor_TB;
	wire [4:0] F_TB;

	Mux_WR DUT(seletor_TB, I1_TB, I2_TB[15:11], F_TB);

	assign I1_TB = 5'd9;
	assign I2_TB = 16'b1010101010101010;

	initial
		begin
			$dumpfile("mux_WR.vcd");
			$dumpvars(0,mux_WR_TB);

			// testes genericos
			seletor_TB = 2'b00;
            #10 seletor_TB = 2'b01;
            #10 seletor_TB = 2'b10;
            #10 seletor_TB = 2'b11;
            #10;
		end
endmodule