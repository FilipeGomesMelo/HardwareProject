`timescale 1ns/1ps

module PcWriteLogic_TB();

    // control Signals
    reg LTE_C_TB, GT_C_TB, EQ_C_TB, NE_C_TB;
    // ALU Signals
    reg GT_TB, EQ_TB, PC_TB;
    wire PcWrite_TB;

	PcWriteLogic DUT(LTE_C_TB, GT_C_TB, EQ_C_TB, NE_C_TB, GT_TB, EQ_TB, PC_TB, PcWrite_TB);

	initial
		begin
			$dumpfile("PcWriteLogic.vcd");
			$dumpvars(0,PcWriteLogic_TB);
            LTE_C_TB = 1'b0; GT_C_TB = 1'b0; EQ_C_TB = 1'b0; NE_C_TB = 1'b0; GT_TB = 1'b0; EQ_TB = 1'b0; PC_TB = 1'b0;
			// PcWrite test
            PC_TB = 1'b0;
            #10 PC_TB = 1'b1;
            #10 PC_TB = 1'b0;
            // LTE test
            #10 LTE_C_TB = 1'b1; GT_TB = 1'b0;
            #10 GT_TB = 1'b1;
            #10 LTE_C_TB = 1'b0;
            // GT test
            #10 GT_C_TB = 1'b1; GT_TB = 1'b0;
            #10 GT_TB = 1'b1;
            #10 GT_C_TB = 1'b0;
            // EQ test
            #10 EQ_C_TB = 1'b1; EQ_TB = 1'b0;
            #10 EQ_TB = 1'b1;
            #10 EQ_C_TB = 1'b0;
            // NE test
            #10 NE_C_TB = 1'b1; EQ_TB = 1'b0;
            #10 EQ_TB = 1'b1;
            #10 NE_C_TB = 1'b0;
            #10;

		end
endmodule