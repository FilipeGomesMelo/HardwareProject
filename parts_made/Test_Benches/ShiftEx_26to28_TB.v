`timescale 1ns/1ps

module ShiftEx_26to28_TB();

	reg [25:0] I1_TB;
    wire [27:0] F_TB;

	ShiftEx_26to28 DUT(I1_TB, F_TB);

	initial
		begin
			$dumpfile("ShiftEx_26to28_TB.vcd");
			$dumpvars(0,ShiftEx_26to28_TB);

			// testes genericos
            I1_TB = 26'b11111111111111111111111111;
            #10 I1_TB = 1'd25;
            #10;
		end
endmodule