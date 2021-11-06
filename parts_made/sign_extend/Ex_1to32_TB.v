`timescale 1ns/1ps

module Ex_1to32_TB();

	reg I1_TB;
    wire [31:0] F_TB;

	Ex_1to32 DUT(I1_TB, F_TB);

	initial
		begin
			$dumpfile("Ex_1to32_TB.vcd");
			$dumpvars(0,Ex_1to32_TB);

			// testes genericos
            I1_TB = 1'b0;
            #10 I1_TB = 1'b1;
            #10;
		end
endmodule