`timescale 1ns/1ps

module Ex16or8to32_TB();

	reg I1_TB;
	reg [7:0] I2_TB;
	reg seletor_TB;
	wire [31:0] F_TB;

	Ex_16or8to32 DUT(seletor_TB, I1_TB, I2_TB, F_TB);

	initial
		begin
			$dumpfile("Ex16or8to32.vcd");
			$dumpvars(0,Ex16or8to32_TB);

			// testes genericos
			seletor_TB = 1'b0; I1_TB = 16'd4;
            #10  I1_TB = -16'd4;
            #10 seletor_TB = 1'b1; I2_TB = 8'd5;
            #10 I2_TB = -8'd5;
            #10;
            
		end
endmodule