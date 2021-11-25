// Só o começo, ainda não dá pra rodar nem nada
module cpu (
    input clk, reset
);

    // control wires (mux)
    wire [1:0] ExCause;
    wire [1:0] IorD;
    wire [1:0] WR_REG;
    wire [1:0] ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [1:0] PcSource;
    wire [2:0] WD_REG;
    
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

    // control wires (RegDesloc)
    wire [1:0] ShiftIn;
    wire [1:0] ShiftS;
    wire [2:0] ShiftCtrl;

    // control wires (mult_div)
    wire Mult_Div;
    wire MemA_A;
    wire MemB_B;
    wire Hi_load;
    wire Lo_load;
    wire resetlocal;

    // control wires (others)
    wire SingExCtrl;
    wire [1:0] LoadCtrl;
    wire [1:0] StoreCtrl;

    // Data wires
    // Acho uma boa tentar dividir isso melhor dps
    wire [5:0] OP;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [4:0] mux_wr_Out;
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
    wire [31:0] mux_wd_Out;
    wire [31:0] A_Out;
    wire [31:0] B_Out;
    wire [31:0] Ex_16or8to32_Out;
    wire [31:0] Shift_left2_Out;
    wire [31:0] mux_AluA_out;
    wire [31:0] mux_AluB_out;
    wire [27:0] shiftEx_26to28_out;
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;
    wire [31:0] EPC_Out;

    // Data Wires (DIV/Mult)
    wire [31:0] Hi;
    wire [31:0] Lo;
    wire [31:0] MemMultA_Out;
    wire [31:0] MemMultB_Out;
    wire [31:0] Hi_out;
    wire [31:0] Lo_out;
    wire [31:0] mux_DivmA_out;
    wire [31:0] mux_DivmB_out;
    wire [31:0] MultDivHi_out;
    wire [31:0] MultDivLo_out;
    wire [31:0] MultHi;
    wire [31:0] MultLo;
    wire [31:0] DivHi;
    wire [31:0] DivLo;

    // Data Wires (RegDesloc)
    wire [31:0] ShiftIn_Out;
    wire [4:0] ShiftS_Out;
    wire [31:0] ShiftReg_Out;

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
        Hi_out,
        Lo_out,
        32'd0,
        ShiftReg_Out,
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
        ReadData2
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

    Ex_16or8to32 singEx_16or8to32_(
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
        mux_PcSource_out
    );

    ShiftEx_26to28 shiftEx_26to28_(
        // Entradas
        {RS, RT, Immediate},
        // Saidas
        shiftEx_26to28_out
    );

    Mux_ShiftIn mux_shiftIn_(
        // Entradas
        ShiftIn,
        A_Out,
        Ex_16or8to32_Out,
        B_Out,
        // Saidas
        ShiftIn_Out
    );

    Mux_ShiftS mux_shiftS_(
        // Entradas
        ShiftS,
        B_Out[4:0],
        Immediate[10:6],
        Mem_Out[4:0],
        // Saidas
        ShiftS_Out
    );

    RegDesloc regDesloc_Out_(
        // Entradas
        clk,
        reset,
        ShiftCtrl,
        ShiftS_Out,
        ShiftIn_Out,
        // Saidas
        ShiftReg_Out
    );

    Registrador MemMultA_(
        // Entradas
        clk,
        reset,
        AuxMultA,
        Mem_Out,
        // Saidas
        MemMultA_Out
    );

    Registrador MemMultB_(
        // Entradas
        clk,
        reset,
        AuxMultB,
        Mem_Out,
        // Saidas
        MemMultB_Out
    );

    Registrador Hi_(
        // Entradas
        clk,
        reset,
        Hi_load,
        MultDivHi_out,
        // Saidas
        Hi_out
    );

    Registrador Lo_(
        // Entradas
        clk,
        reset,
        Lo_load,
        MultDivLo_out,
        // Saidas
        Lo_out
    );

    Mux_MultDiv mux_DivmA_(
        // Entradas
        MemA_A,
        MemMultA_Out,
        A_Out,
        // Saídas
        mux_DivmA_out
    );

    Mux_MultDiv mux_DivmB_(
        // Entradas
        MemB_B,
        MemMultB_Out,
        B_Out,
        // Saídas
        mux_DivmB_out
    );

    Mux_MultDiv mux_MultDivHi_(
        // Entradas
        Mult_Div,
        MultHi,
        DivHi,
        // Saídas
        MultDivHi_out
    );

    Mux_MultDiv mux_MultDivLo_(
        // Entradas
        Mult_Div,
        MultLo,
        DivLo,
        // Saídas
        MultDivLo_out
    );

    Mult mult_(
        //Entradas
        clk,
        reset,
        resetlocal,
        mux_DivmA_out,
        mux_DivmB_out,
        //Saidas
        MultHi,
        MultLo
    );

    Div div_(
        //Entradas
        clk,
        reset,
        resetlocal,
        mux_DivmA_out,
        mux_DivmB_out,
        //Saidas
        ZeroDivision,
        DivHi,
        DivLo
    );

    Control control_(
        // Entradas,
        clk,
        reset,
        ALU_overflow,
        1'b0,
        OP,
        Immediate[5:0],
        // Saidas
        ExCause,
        IorD,
        WR_REG,
        ALUSrcA,
        ALUSrcB,
        PcSource,
        WD_REG,
        ShiftIn,
        ShiftS,
        Mult_Div,
        MemA_A,
        MemB_B,
        PcWrite,
        Load_AB,
        ALUOut_Load,
        EPCwrite,
        AuxMultA,
        AuxMultB,
        Hi_load,
        Lo_load,
        resetlocal,
        MemWrite,
        MemRead,
        IRWrite,
        RegWrite,
        ALUOp,
        ShiftCtrl,
        SingExCtrl,
        LoadCtrl,
        StoreCtrl
    );
endmodule