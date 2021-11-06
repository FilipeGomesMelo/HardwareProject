`timescale 1ns/1ps

module StoreAux_TB();

    reg [1:0] selector;
    reg [31:0] data_0, data_1;
    wire [31:0] data_out;

	StoreAux DUT(selector, data_0, data_1, data_out);

	initial
		begin
			$dumpfile("StoreAux.vcd");
			$dumpvars(0,StoreAux_TB);
            
            data_0 = 32'b11111_11111_11111_11111_11111_11111_11;
            data_1 = 32'd0;

            selector = 2'b00;
            #10 selector = 2'b01;
            #10 selector = 2'b10;
            #10;
		end
endmodule