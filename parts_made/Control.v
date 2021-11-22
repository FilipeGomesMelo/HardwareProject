// This is where the fun begins
module Control (
        // Entradas externas
        input wire clk, reset,

        // Sinais de exceção
        input wire overflow, zero_div,
        // Sinais de instrução
        input wire [5:0] OP, funct,

        // Sinais de controle
        // control wires (mux)
        output reg [1:0] ExCause,
        output reg [1:0] IorD,
        output reg [1:0] WR_REG,
        output reg [1:0] ALUSrcA,
        output reg [1:0] ALUSrcB,
        output reg [1:0] PcSource,
        output reg [2:0] WD_REG,
        output reg [1:0] ShiftIn,
        output reg [1:0] ShiftS,

        // control regs (REGs)
        output reg PcWrite,
        output reg Load_AB,
        output reg ALUOut_Load,
        output reg EPCwrite,

        // control regs (big boys)
        output reg MemWrite,
        output reg MemRead,
        output reg IRWrite,
        output reg RegWrite,
        output reg [2:0] ALUOp,

        // control regs (RegDesloc)
        output reg [2:0] ShiftCtrl,

        // control regs (others)
        output reg SingExCtrl,
        output reg [1:0] LoadCtrl,
        output reg [1:0] StoreCtrl
    );

    // Variáveis internas
    reg [5:0] state;
    reg [4:0] COUNTER;

    // Constantes internas (estados)
    // Universal
    parameter ST_Reset = 6'b000_000;
    parameter ST_Fetch = 6'b000_001;
    parameter ST_Decode = 6'b000_010;
    
    // Exceções
    parameter ST_OPError = 6'b000_011;
    parameter ST_Overflow = 6'b000_100;
    parameter ST_ZeroDiv = 6'b000_101;

    // Estados Tipo R
    parameter ST_ADD = 6'b000_110;
    parameter ST_AND = 6'b000_111;
    parameter ST_DIV = 6'b001_000;
    parameter ST_MULT = 6'b001_001;
    parameter ST_JR = 6'b001_010;
    parameter ST_MFHI = 6'b001_011;
    parameter ST_MFLO = 6'b001_100;
    parameter ST_SLL = 6'b001_101;
    parameter ST_SLLV = 6'b001_110;
    parameter ST_SLT = 6'b001_111;
    parameter ST_SRA = 6'b010_000;
    parameter ST_SRAV = 6'b010_001;
    parameter ST_SRL = 6'b010_010;
    parameter ST_SUB = 6'b010_011;
    parameter ST_BREAK = 6'b010_100;
    parameter ST_RTE = 6'b010_101;
    parameter ST_DIVM = 6'b010_110;
    
    // Estados Tipo I
    parameter ST_ADDI = 6'b010_111;
    parameter ST_ADDIU = 6'b011_000;
    parameter ST_BEQ = 6'b011_001;
    parameter ST_BNE = 6'b011_010;
    parameter ST_BLE = 6'b011_011;
    parameter ST_BGT = 6'b011_100;
    parameter ST_SRAM = 6'b011_101;
    parameter ST_LB = 6'b011_110;
    parameter ST_LH = 6'b011_111;
    parameter ST_LUI = 6'b100_000;
    parameter ST_LW = 6'b100_001;
    parameter ST_SB = 6'b100_010;
    parameter ST_SH = 6'b100_011;
    parameter ST_SLTI = 6'b100_100;
    parameter ST_RT = 6'b100_101;

    // Estados Tipo J
    parameter ST_J = 6'b100_110;
    parameter ST_JAL = 6'b100_111;

    // OPs Tipo R
    parameter OP_TypeR = 6'b000_000;

    // OPs Tipe I
    // Estados Tipo I
    parameter OP_ADDI = 6'b001_000;
    parameter OP_ADDIU = 6'b001_001;
    parameter OP_BEQ = 6'b000_100;
    parameter OP_BNE = 6'b000_101;
    parameter OP_BLE = 6'b000_110;
    parameter OP_BGT = 6'b000_111;
    parameter OP_SRAM = 6'b000_001;
    parameter OP_LB = 6'b100_000;
    parameter OP_LH = 6'b100_001;
    parameter OP_LUI = 6'b001_111;
    parameter OP_LW = 6'b100_011;
    parameter OP_SB = 6'b101_000;
    parameter OP_SH = 6'b101_001;
    parameter OP_SLTI = 6'b001_010;
    parameter OP_RT = 6'b101_011;

    // Estados Tipo J
    parameter OP_J = 6'b000_010;
    parameter OP_JAL = 6'b000_011;

    // Funct tipo R
    parameter FUNCT_ADD = 6'b100_000;
    parameter FUNCT_AND = 6'b100_100;
    parameter FUNCT_DIV = 6'b011_010;
    parameter FUNCT_MULT = 6'b011_000;
    parameter FUNCT_JR = 6'b001_000;
    parameter FUNCT_MFHI = 6'b010_000;
    parameter FUNCT_MFLO = 6'b010_010;
    parameter FUNCT_SLL = 6'b000_000;
    parameter FUNCT_SLLV = 6'b000_100;
    parameter FUNCT_SLT = 6'b101_010;
    parameter FUNCT_SRA = 6'b000_011;
    parameter FUNCT_SRAV = 6'b000_111;
    parameter FUNCT_SRL = 6'b000_010;
    parameter FUNCT_SUB = 6'b100_010;
    parameter FUNCT_BREAK = 6'b001_101;
    parameter FUNCT_RTE = 6'b010_011;
    parameter FUNCT_DIVM = 6'b000_101;

    // teste

    always @(posedge clk) begin
        if (reset == 1'b1 || state == ST_Reset) begin
            // Coloca todos sinais de controle para 0
            PcWrite = 1'b0;
            Load_AB = 1'b0;
            ALUOut_Load = 1'b0;
            EPCwrite = 1'b0;
            MemWrite = 1'b0;
            MemRead = 1'b0;
            IRWrite = 1'b0;
            SingExCtrl = 1'b0;
            ExCause = 2'b00;
            IorD = 2'b00;
            ALUSrcA = 2'b00;
            ALUSrcB = 2'b00;
            PcSource = 2'b00;
            ALUOp = 3'b000;
            LoadCtrl = 2'b00;
            StoreCtrl = 2'b00;
            ShiftIn = 2'b00;
            ShiftS = 2'b00;
            ShiftCtrl = 3'b000;

            // reseta o valor do registratodor da pilha no banco de registradores
            WR_REG = 2'b11;
            WD_REG = 3'b110;
            RegWrite = 1'b1;

            // Next state
            COUNTER = 5'b00000;
            state = ST_Fetch;
        end else begin
            case (state)
                ST_Fetch: begin
                    // Fetch
                    if (COUNTER != 5'b00011) begin
                        // Zera todos sinais de estados anteriores
                        RegWrite = 1'b0;
                        PcWrite = 1'b0;
                        Load_AB = 1'b0;
                        ALUOut_Load = 1'b0;
                        EPCwrite = 1'b0;
                        MemWrite = 1'b0;
                        IRWrite = 1'b0;

                        // Primeiros 3 ciclos pro load
                        IorD = 1'b00;
                        MemRead = 1'b1;
                        ALUSrcA = 2'b00;
                        ALUSrcB = 2'b01;
                        ALUOp = 3'b001;

                        // Update do counter
                        COUNTER = COUNTER + 5'b00001; 
                    end else begin
                        // Zera sinais do anterior
                        MemRead = 1'b0;
                        
                        // Ultimo ciclo do Fetch
                        PcSource = 2'b00;
                        PcWrite = 1'b1;
                        IRWrite = 1'b1;

                        // Zera counter e próximo estado
                        COUNTER = 5'b00000;
                        state = ST_Decode;
                    end
                end    
                ST_Decode: begin
                    if (COUNTER == 5'b00000) begin
                        // Zera sinais do anterior
                        PcWrite = 1'b0;
                        IRWrite = 1'b0;

                        // Primeiro ciclo do Decode
                        ALUSrcA = 2'b00;
                        SingExCtrl = 1'b0;
                        ALUSrcB = 2'b11;
                        ALUOp = 3'b001;
                        ALUOut_Load = 1'b1;

                        // Passa o counter
                        COUNTER = COUNTER + 5'b00001;
                    end else if (COUNTER == 5'b00001) begin
                        // Zera sinais do anterior
                        ALUOut_Load = 1'b0;
                        
                        // Segundo ciclo do Decode
                        Load_AB = 1'b1;

                        // Reinicia o counter
                        COUNTER = 5'b00000;
                        // Seleciona o próximo estado
                        case (OP)
                            OP_TypeR: begin
                                case (funct)
                                    // Colocar todas funções aqui
                                    FUNCT_ADD: begin
                                        state = ST_ADD;
                                    end
                                    FUNCT_AND: begin
                                        state = ST_AND;
                                    end
                                    FUNCT_DIV: begin
                                        state = ST_DIV;
                                    end
                                    FUNCT_MULT: begin
                                        state = ST_MULT;
                                    end
                                    FUNCT_JR: begin
                                        state = ST_JR;
                                    end
                                    FUNCT_MFHI: begin
                                        state = ST_MFHI;
                                    end
                                    FUNCT_MFLO: begin
                                        state = ST_MFLO;
                                    end
                                    FUNCT_SLL: begin
                                        state = ST_SLL;
                                    end
                                    FUNCT_SLLV: begin
                                        state = ST_SLLV;
                                    end
                                    FUNCT_SLT: begin
                                        state = ST_SLT;
                                    end
                                    FUNCT_SRA: begin
                                        state = ST_SRA;
                                    end
                                    FUNCT_SRAV: begin
                                        state = ST_SRAV;
                                    end
                                    FUNCT_SRL: begin
                                        state = ST_SRL;
                                    end
                                    FUNCT_SUB: begin
                                        state = ST_SUB;
                                    end
                                    FUNCT_BREAK: begin
                                        state = ST_BREAK;
                                    end
                                    FUNCT_RTE: begin
                                        state = ST_RTE;
                                    end
                                    FUNCT_DIVM: begin
                                        state = ST_DIVM;
                                    end
                                endcase
                            end
                            OP_ADDI: begin
                                state = ST_ADDI;
                            end
                            OP_ADDIU: begin
                                state = ST_ADDIU;
                            end
                            OP_BEQ: begin
                                state = ST_BEQ;
                            end
                            OP_BNE: begin
                                state = ST_BNE;
                            end
                            OP_BLE: begin
                                state = ST_BLE;
                            end
                            OP_BGT: begin
                                state = ST_BGT;
                            end
                            OP_SRAM: begin
                                state = ST_SRAM;
                            end
                            OP_LB: begin
                                state = ST_LB;
                            end
                            OP_LH: begin
                                state = ST_LH;
                            end
                            OP_LUI: begin
                                state = ST_LUI;
                            end
                            OP_LW: begin
                                state = ST_LW;
                            end
                            OP_SB: begin
                                state = ST_SB;
                            end
                            OP_SH: begin
                                state = ST_SH;
                            end
                            OP_SLTI: begin
                                state = ST_SLTI;
                            end
                            OP_RT: begin
                                state = ST_RT;
                            end
                            OP_J: begin
                                state = ST_J;
                            end
                            OP_JAL: begin
                                state = ST_JAL;
                            end
                            default: // OP inexistente
                                state = ST_OPError;
                        endcase
                    end
                end
                ST_OPError: begin
                    // OPcode inexistente
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_Overflow: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_ZeroDiv: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_ADD: begin
                    // CRCP
                    if(COUNTER == 5'b00000) begin
                        // Coloca todos sinais de controle para 0
                        PcWrite = 1'b0;
                        Load_AB = 1'b0;
                        ALUOut_Load = 1'b1;
                        EPCwrite = 1'b0;
                        MemWrite = 1'b0;
                        MemRead = 1'b0;
                        IRWrite = 1'b0;
                        SingExCtrl = 1'b0;
                        ExCause = 2'b00;
                        IorD = 2'b00;
                        ALUSrcA = 2'b10;
                        ALUSrcB = 2'b00;
                        PcSource = 2'b00;
                        ALUOp = 3'b001;
                        LoadCtrl = 2'b00;
                        StoreCtrl = 2'b00;

                        // reseta o valor do registratodor da pilha no banco de registradores
                        WR_REG = 2'b00;
                        WD_REG = 3'b000;
                        RegWrite = 1'b0;

                        
                        COUNTER = COUNTER + 5'b00001;

                    end else if(COUNTER == 5'b00001) begin
                        ALUOut_Load = 1'b0;
                        if(overflow == 1'b1) begin
                            COUNTER = 5'b00000;
                            state = ST_Overflow;                            
                        end
                        else begin
                            WR_REG = 2'b01;
                            WD_REG = 3'b000;
                            RegWrite = 1'b1;

                            COUNTER = 5'b00000;
                            state = ST_Fetch;
                        end
                    end
                end
                ST_AND: begin
                    // CRCP
                    if(COUNTER == 5'b00000) begin
                        PcWrite = 1'b0;
                        Load_AB = 1'b0;
                        ALUOut_Load = 1'b1;
                        EPCwrite = 1'b0;
                        MemWrite = 1'b0;
                        MemRead = 1'b0;
                        IRWrite = 1'b0;
                        SingExCtrl = 1'b0;
                        ExCause = 2'b00;
                        IorD = 2'b00;
                        ALUSrcA = 2'b10;
                        ALUSrcB = 2'b00;
                        PcSource = 2'b00;
                        ALUOp = 3'b011;
                        LoadCtrl = 2'b00;
                        StoreCtrl = 2'b00;
                        WR_REG = 2'b00;
                        WD_REG = 3'b000;
                        RegWrite = 1'b0;

                        
                        COUNTER = COUNTER + 5'b00001;

                    end else if(COUNTER == 5'b00001) begin
                        ALUOut_Load = 1'b0;

                        WR_REG = 2'b01;
                        WD_REG = 3'b000;
                        RegWrite = 1'b1;

                        COUNTER = 5'b00000;
                        state = ST_Fetch;                    
                    end
                end
                ST_DIV: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_MULT: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_JR: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_MFHI: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_MFLO: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_SLL: begin
                    // Shifts
                    if (COUNTER == 5'b000000) begin
                        // Coloca todos sinais de controle para 0
                        PcWrite = 1'b0;
                        Load_AB = 1'b0;
                        ALUOut_Load = 1'b0;
                        EPCwrite = 1'b0;
                        MemWrite = 1'b0;
                        MemRead = 1'b0;
                        IRWrite = 1'b0;
                        SingExCtrl = 1'b0;
                        ExCause = 2'b00;
                        IorD = 2'b00;
                        ALUSrcA = 2'b10;
                        ALUSrcB = 2'b00;
                        PcSource = 2'b00;
                        ALUOp = 3'b001;
                        LoadCtrl = 2'b00;
                        StoreCtrl = 2'b00;

                        // Sinais do ciclo
                        ShiftIn = 2'b10;
                        ShiftS = 2'b01;
                        ShiftCtrl = 3'b001;

                        COUNTER = COUNTER + 5'b00001;
                    end else if (COUNTER == 5'b000001) begin
                        // Sinais do ciclo
                        ShiftCtrl = 3'b010;

                        COUNTER = COUNTER + 5'b00001;
                    end else if (COUNTER == 5'b000010) begin
                        // Zera os sinais
                        ShiftCtrl = 3'b000; 

                        // Sinais do ciclo
                        WR_REG = 2'b01;
                        WD_REG = 3'b101;
                        RegWrite = 1'b1;

                        COUNTER = 5'b00000;
                        state = ST_Fetch;
                    end
                end
                ST_SLLV: begin
                    // Shifts
                    if (COUNTER == 5'b000000) begin
                        // Coloca todos sinais de controle para 0
                        PcWrite = 1'b0;
                        Load_AB = 1'b0;
                        ALUOut_Load = 1'b0;
                        EPCwrite = 1'b0;
                        MemWrite = 1'b0;
                        MemRead = 1'b0;
                        IRWrite = 1'b0;
                        SingExCtrl = 1'b0;
                        ExCause = 2'b00;
                        IorD = 2'b00;
                        ALUSrcA = 2'b10;
                        ALUSrcB = 2'b00;
                        PcSource = 2'b00;
                        ALUOp = 3'b001;
                        LoadCtrl = 2'b00;
                        StoreCtrl = 2'b00;

                        // Sinais do ciclo
                        ShiftIn = 2'b00;
                        ShiftS = 2'b00;
                        ShiftCtrl = 3'b001;

                        COUNTER = COUNTER + 5'b00001;
                    end else if (COUNTER == 5'b000001) begin
                        // Sinais do ciclo
                        ShiftCtrl = 3'b010;

                        COUNTER = COUNTER + 5'b00001;
                    end else if (COUNTER == 5'b000010) begin
                        // Zera os sinais
                        ShiftCtrl = 3'b000; 

                        // Sinais do ciclo
                        WR_REG = 2'b01;
                        WD_REG = 3'b101;
                        RegWrite = 1'b1;

                        COUNTER = 5'b00000;
                        state = ST_Fetch;
                    end
                end
                ST_SLT: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_SRA: begin
                    // Shifts
                    if (COUNTER == 5'b000000) begin
                        // Coloca todos sinais de controle para 0
                        PcWrite = 1'b0;
                        Load_AB = 1'b0;
                        ALUOut_Load = 1'b0;
                        EPCwrite = 1'b0;
                        MemWrite = 1'b0;
                        MemRead = 1'b0;
                        IRWrite = 1'b0;
                        SingExCtrl = 1'b0;
                        ExCause = 2'b00;
                        IorD = 2'b00;
                        ALUSrcA = 2'b10;
                        ALUSrcB = 2'b00;
                        PcSource = 2'b00;
                        ALUOp = 3'b001;
                        LoadCtrl = 2'b00;
                        StoreCtrl = 2'b00;

                        // Sinais do ciclo
                        ShiftIn = 2'b10;
                        ShiftS = 2'b01;
                        ShiftCtrl = 3'b001;

                        COUNTER = COUNTER + 5'b00001;
                    end else if (COUNTER == 5'b000001) begin
                        // Sinais do ciclo
                        ShiftCtrl = 3'b100;

                        COUNTER = COUNTER + 5'b00001;
                    end else if (COUNTER == 5'b000010) begin
                        // Zera os sinais
                        ShiftCtrl = 3'b000; 

                        // Sinais do ciclo
                        WR_REG = 2'b01;
                        WD_REG = 3'b101;
                        RegWrite = 1'b1;

                        COUNTER = 5'b00000;
                        state = ST_Fetch;
                    end
                end
                ST_SRAV: begin
                    // Shifts
                    if (COUNTER == 5'b000000) begin
                        // Coloca todos sinais de controle para 0
                        PcWrite = 1'b0;
                        Load_AB = 1'b0;
                        ALUOut_Load = 1'b0;
                        EPCwrite = 1'b0;
                        MemWrite = 1'b0;
                        MemRead = 1'b0;
                        IRWrite = 1'b0;
                        SingExCtrl = 1'b0;
                        ExCause = 2'b00;
                        IorD = 2'b00;
                        ALUSrcA = 2'b10;
                        ALUSrcB = 2'b00;
                        PcSource = 2'b00;
                        ALUOp = 3'b001;
                        LoadCtrl = 2'b00;
                        StoreCtrl = 2'b00;

                        // Sinais do ciclo
                        ShiftIn = 2'b00;
                        ShiftS = 2'b00;
                        ShiftCtrl = 3'b001;

                        COUNTER = COUNTER + 5'b00001;
                    end else if (COUNTER == 5'b000001) begin
                        // Sinais do ciclo
                        ShiftCtrl = 3'b100;

                        COUNTER = COUNTER + 5'b00001;
                    end else if (COUNTER == 5'b000010) begin
                        // Zera os sinais
                        ShiftCtrl = 3'b000; 

                        // Sinais do ciclo
                        WR_REG = 2'b01;
                        WD_REG = 3'b101;
                        RegWrite = 1'b1;

                        COUNTER = 5'b00000;
                        state = ST_Fetch;
                    end
                end
                ST_SRL: begin
                    // Shifts
                    if (COUNTER == 5'b000000) begin
                        // Coloca todos sinais de controle para 0
                        PcWrite = 1'b0;
                        Load_AB = 1'b0;
                        ALUOut_Load = 1'b0;
                        EPCwrite = 1'b0;
                        MemWrite = 1'b0;
                        MemRead = 1'b0;
                        IRWrite = 1'b0;
                        SingExCtrl = 1'b0;
                        ExCause = 2'b00;
                        IorD = 2'b00;
                        ALUSrcA = 2'b10;
                        ALUSrcB = 2'b00;
                        PcSource = 2'b00;
                        ALUOp = 3'b001;
                        LoadCtrl = 2'b00;
                        StoreCtrl = 2'b00;

                        // Sinais do ciclo
                        ShiftIn = 2'b10;
                        ShiftS = 2'b01;
                        ShiftCtrl = 3'b001;

                        COUNTER = COUNTER + 5'b00001;
                    end else if (COUNTER == 5'b000001) begin
                        // Sinais do ciclo
                        ShiftCtrl = 3'b011;

                        COUNTER = COUNTER + 5'b00001;
                    end else if (COUNTER == 5'b000010) begin
                        // Zera os sinais
                        ShiftCtrl = 3'b000; 

                        // Sinais do ciclo
                        WR_REG = 2'b01;
                        WD_REG = 3'b101;
                        RegWrite = 1'b1;

                        COUNTER = 5'b00000;
                        state = ST_Fetch;
                    end
                end
                ST_SUB: begin
                    // CRCP
                    if(COUNTER == 5'b00000) begin
                        PcWrite = 1'b0;
                        Load_AB = 1'b0;
                        ALUOut_Load = 1'b1;
                        EPCwrite = 1'b0;
                        MemWrite = 1'b0;
                        MemRead = 1'b0;
                        IRWrite = 1'b0;
                        SingExCtrl = 1'b0;
                        ExCause = 2'b00;
                        IorD = 2'b00;
                        ALUSrcA = 2'b10;
                        ALUSrcB = 2'b00;
                        PcSource = 2'b00;
                        ALUOp = 3'b010;
                        LoadCtrl = 2'b00;
                        StoreCtrl = 2'b00;

                        WR_REG = 2'b00;
                        WD_REG = 3'b000;
                        RegWrite = 1'b0;

                        
                        COUNTER = COUNTER + 5'b00001;

                    end else if(COUNTER == 5'b00001) begin
                        ALUOut_Load = 1'b0;
                        if(overflow == 1'b1) begin
                            COUNTER = 5'b00000;
                            state = ST_Overflow;                            
                        end else begin
                            WR_REG = 2'b01;
                            WD_REG = 3'b000;
                            RegWrite = 1'b1;

                            COUNTER = 5'b00000;
                            state = ST_Fetch;                           
                        end
                    end
                end
                ST_BREAK: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_RTE: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_ADDI: begin    
                    // CRCP
                    if(COUNTER == 5'b00000) begin
                        PcWrite = 1'b0;
                        Load_AB = 1'b0;
                        ALUOut_Load = 1'b1;
                        EPCwrite = 1'b0;
                        MemWrite = 1'b0;
                        MemRead = 1'b0;
                        IRWrite = 1'b0;
                        SingExCtrl = 1'b0;
                        ExCause = 2'b00;
                        IorD = 2'b00;
                        ALUSrcA = 2'b10;
                        ALUSrcB = 2'b10;
                        PcSource = 2'b00;
                        ALUOp = 3'b001;
                        LoadCtrl = 2'b00;
                        StoreCtrl = 2'b00;
                        WR_REG = 2'b00;
                        WD_REG = 3'b000;
                        RegWrite = 1'b0;

                        
                        COUNTER = COUNTER + 5'b00001;

                    end else if(COUNTER == 5'b00001) begin
                        ALUOut_Load = 1'b0;
                        if(overflow == 1'b1) begin
                            COUNTER = 5'b00000;
                            state = ST_Overflow;                            
                        end else begin
                            WR_REG = 2'b00;
                            WD_REG = 3'b000;
                            RegWrite = 1'b1;

                            COUNTER = 5'b00000;
                            state = ST_Fetch;
                        end                        
                    end      
                end
                ST_ADDIU: begin
                    // CRCP
                    if(COUNTER == 5'b00000) begin
                        PcWrite = 1'b0;
                        Load_AB = 1'b0;
                        ALUOut_Load = 1'b1;
                        EPCwrite = 1'b0;
                        MemWrite = 1'b0;
                        MemRead = 1'b0;
                        IRWrite = 1'b0;
                        SingExCtrl = 1'b0;
                        ExCause = 2'b00;
                        IorD = 2'b00;
                        ALUSrcA = 2'b10;
                        ALUSrcB = 2'b10;
                        PcSource = 2'b00;
                        ALUOp = 3'b001;
                        LoadCtrl = 2'b00;
                        StoreCtrl = 2'b00;
                        WR_REG = 2'b00;
                        WD_REG = 3'b000;
                        RegWrite = 1'b0;

                        
                        COUNTER = COUNTER + 5'b00001;

                    end else if(COUNTER == 5'b00001) begin
                        ALUOut_Load = 1'b0;
                        
                        WR_REG = 2'b00;
                        WD_REG = 3'b000;
                        RegWrite = 1'b1;

                        COUNTER = 5'b00000;
                        state = ST_Fetch;                    
                    end
                end
                ST_BEQ: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_BNE: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_BLE: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_BGT: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_SRAM: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_LB: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_LH: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_LUI: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_LW: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_SB: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_SH: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_SLTI: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_RT: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_J: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
                ST_JAL: begin
                    // TODO
                    COUNTER = 5'b00000;
                    state = ST_Fetch;
                end
            endcase
        end
    end
endmodule