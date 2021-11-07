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
    wire Load_A;
    wire Load_B;
    wire ALUout_Load;
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
    wire [31:0] Pc_In;
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

    Registrador PC_(
        // Entradas
        clk,
        reset,
        PcWrite, // vamos ter que trocar isso quando for pra implementar os Branches
        Pc_In,
        // Saidas
        Pc_Out
    );

    mux_ExCause ExCause_(
        // Entradas
        IorD,
        // Saidas
        ExCause_Out
    );

    mux_IorD mux_Address_(
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

    mux_WR mux_wr_(
        // Entradas
        WR_REG,
        RT,
        Immediate,
        // Saidas
        mux_wr_Out
    );

    mux_WD mux_wd_(
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
        Load_A,
        ReadData1,
        // Saidas
        Pc_Out
    );
endmodule