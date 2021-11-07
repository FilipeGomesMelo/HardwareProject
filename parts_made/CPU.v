// Só o começo, ainda não dá pra rodar nem nada
module cpu (
    input clk, reset
);

    // control wires (mux)
    wire [2:0] ExCauxe;
    wire [2:0] IorD;
    wire [2:0] WR_REG;
    wire [2:0] ALUSrcA;
    wire [2:0] ALUSrcB;
    wire [2:0] PcSource;
    wire [3:0] WD_REG;

    // control wires (REGs)
    wire PcWrite;
    wire Load_AB;
    wire ALUOut_Load;
    wire EPCwrite;

    // control wires (big boys)
    wire MemWrite;
    wire MemRead;
    wire IRWrite;
    wire RegWrite;
    wire [2:0] ALUOp;


    // control wires (others)
    wire SingExCtrl;
    wire [1:0] LoadCtrl;
    wire [1:0] StoreCtrl;

    // Data wires
    // Acho uma boa tentar dividir isso melhor dps
    wire [5:0] OP;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] Immediate;
    wire [31:0] mux_PcSource_out;
    wire [31:0] Pc_Out;
    wire [31:0] ExCause_Out;
    wire [31:0] ALUOut_Out;
    wire [31:0] ALU_result;
    wire [31:0] Mux_IorD_Out;
    wire [31:0] StoreAux_Out;
    wire [31:0] Mem_Out;
    wire [31:0] LoadAux_Out;
    wire [31:0] mux_wr_Out;
    wire [31:0] mux_wd_Out;
    wire [31:0] A_Out;
    wire [31:0] B_Out;
    wire [31:0] Ex_16or8to32_Out;
    wire [31:0] Shift_left2_Out;
    wire [31:0] mux_AluA_out;
    wire [31:0] mux_AluB_out;
    wire [31:0] shiftEx_26to28_out;

    // Flags da ALU
    wire ALU_overflow;
    wire ALU_negative;
    wire ALU_zero;
    wire ALU_eq; 
    wire ALU_gt;
    wire ALU_lt;

    Registrador PC_(
        // Entradas
        clk,
        reset,
        PcWrite, // vamos ter que trocar isso quando for pra implementar os Branches
        mux_PcSource_out,
        // Saidas
        Pc_Out
    );

    Mux_ExCause ExCause_(
        // Entradas
        IorD,
        // Saidas
        ExCause_Out
    );

    Mux_IorD mux_Address_(
        // Entradas
        IorD,
        Pc_Out,
        ExCause_Out,
        ALUOut_Out,
        ALU_result,
        // Saida
        Mux_IorD_Out
    );

    Memoria Mem_(
        // Entradas
        Mux_IorD_Out,
        clk,
        MemWrite,
        StoreAux_Out,
        // Saida
        Mem_Out
    );

    Instr_Reg instr_reg_(
        // Entradas
        clk,
        reset,
        IRWrite,
        Mem_Out,
        // Saidas
        OP,
        RS,
        RT,
        Immediate
    );

    LoadAux load_aux_(
        // Entradas
        LoadCtrl,
        Mem_Out,
        // Saidas
        LoadAux_Out
    );

    Mux_WR mux_wr_(
        // Entradas
        WR_REG,
        RT,
        Immediate[15:11],
        // Saidas
        mux_wr_Out
    );

    Mux_WD mux_wd_(
        // Entradas
        WD_REG,
        ALUOut_Out,
        LoadAux_Out,
        // change later
        32'd0,
        32'd0,
        32'd0,
        32'd0,
        // Saidas
        mux_wd_Out
    );

    Banco_reg Registers_(
        // Entradas
        clk,
        reset,
        RegWrite,
        RS,
        RT,
        mux_wr_Out,
        mux_wd_Out,
        // Saidas
        ReadData1,
        ReadData2,
    );

    Registrador A_(
        // Entradas
        clk,
        reset,
        Load_AB,
        ReadData1,
        // Saidas
        A_Out
    );

    Registrador B_(
        // Entradas
        clk,
        reset,
        Load_AB,
        ReadData2,
        // Saidas
        B_Out
    );

    Ex_16or8to32 singEx_16or8to32(
        // Entradas
        SingExCtrl,
        Immediate,
        Mem_Out[7:0],
        // Saidas
        Ex_16or8to32_Out
    );

    Shift_left2 SL2_(
        // Etradas
        Ex_16or8to32_Out,
        // Saidas
        Shift_left2_Out
    );

    Mux_AluA mux_AluA_(
        // Entradas
        ALUSrcA,
        Pc_Out,
        // 0
        A_Out,
        // Saidas
        mux_AluA_out
    );

    Mux_AluB mux_AluB_(
        // Entradas
        ALUSrcB,
        B_Out,
        // 4
        Ex_16or8to32_Out,
        Shift_left2_Out,
        // Saidas
        mux_AluB_out
    );

    ula32 ula32_(
        // Entradas
        mux_AluA_out,
        mux_AluB_out,
        ALUOp,
        // Saidas
        ALU_result,
        ALU_overflow,
        ALU_negative,
        ALU_zero,
        ALU_eq, 
        ALU_gt,
        ALU_lt
    );

    Registrador ALUOut_(
        // Entradas
        clk,
        reset,
        ALUOut_Load,
        ALU_result,
        // Saidas
        ALUOut_Out
    );

    Registrador EPC_(
        // Entradas
        clk,
        reset,
        EPCwrite,
        ALU_result,
        // Saidas
        EPC_Out
    );

    Mux_PcSource mux_PcSource_(
        // Entradas
        PcSource,
        ALU_result,
        ALUOut_Out,
        {Pc_Out[31:28], shiftEx_26to28_out},
        EPC_Out, 
        // Saidas
        mux_PcSource_out,
    );

    ShiftEx_26to28 shiftEx_26to28_(
        // Entradas
        {RS, RT, Immediate},
        // Saidas
        shiftEx_26to28_out
    );

    
endmodule