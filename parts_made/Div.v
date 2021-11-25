module Div (input wire clk, reset, resetlocal,
            input wire [31:0] Dividendo, Divisor,
            output reg ZeroDivision,
            output reg [31:0] Hi, Lo
);
    reg [31:0] divs, divd;
    reg [31:0] quociente, resto;
    reg [5:0] digito_atual;

    always @ (posedge clk) begin
        if (reset == 1'b1 | resetlocal == 1'b1) begin
            Hi = 32'b0;
			Lo  = 32'b0;
            ZeroDivision = 1'b0;
            digito_atual = 6'd32;
            quociente = 32'b0;
            resto = 32'b0;
            if (Divisor == 32'b0) begin
                ZeroDivision = 1'b1;
            end else begin
                if (Divisor[31] == 1'b1) begin
                    divs = ~Divisor + 1'b1;
                end else begin
                    divs = Divisor;
                end

                if (Dividendo[31] == 1'b1) begin
                    divd = ~Dividendo + 1'b1;
                end else begin
                    divd = Dividendo;
                end
            end
        end else if (digito_atual != 6'd000000 && !ZeroDivision) begin
            resto = resto << 1;
            resto[0] = divd[digito_atual-1];

            if (resto >= divs) begin
                resto = resto - divs;
                quociente[digito_atual-1] = 1'b1;
            end

            digito_atual = digito_atual - 1'b1;
            if (digito_atual == 6'd000000) begin
                if (Dividendo[31] != Divisor[31]) begin
                    Lo = -(quociente+1'b1);
                end else begin
                    Lo = quociente;
                end

                if (Dividendo[31] != Divisor[31]) begin
                    if (Divisor[31] == 1'b1) begin
                        Hi = -(divs-resto);
                    end else begin
                        Hi = divs-resto;
                    end
                end else begin
                    if (Divisor[31] == 1'b1) begin
                        Hi = -resto;
                    end else begin
                        Hi = resto;
                    end
                end
            end
        end
    end
endmodule
