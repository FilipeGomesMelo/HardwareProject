module Mult (input wire clk, reset, resetlocal,
            input wire [31:0] A, B,
            output reg [31:0] Hi, Lo
);
	reg [31:0] M, a, Q;
	reg Q0;
	reg [5:0] N;
	reg [31:0] ComplementoM;

	always @ (posedge clk) begin
		if (reset == 1'b1 | resetlocal == 1'b1) begin
			M = A;
			Q = B;
			a = 32'b0;
			Q0 = 0;
			N = 6'd32;
			ComplementoM = ~M + 1'b1;
			Hi = 32'b0;
			Lo  = 32'b0;
		end else if (N != 6'd0) begin
			if (Q0 == 1'b1 && Q[0] == 1'b0) begin
				a = a + M;
			end else if (Q0 == 1'b0 && Q[0] == 1'b1) begin
				a = ComplementoM + a;
			end
			
			{a,Q,Q0} = {a,Q,Q0} >>> 1'b1;
			if (a[30] == 1'b1) begin
				a[31] = 1'b1;
			end
			
			N = N - 1'b1;
			if (N == 6'd0) begin
				Hi = a;
				Lo = Q;
			end
		end
	end
endmodule
