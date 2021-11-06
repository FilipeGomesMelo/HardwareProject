module PcWriteLogic (
    // control Signals
    input wire LTE_C, GT_C, EQ_C, NE_C,
    // ALU Signals
    input wire GT, EQ, PC,
    output wire PcWrite 
);
    assign PcWrite = PC || (!GT && LTE_C) || (GT && GT_C) || (EQ && EQ_C) || (!EQ && NE_C);

endmodule