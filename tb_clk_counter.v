module tb_clk_counter();

	reg clk, rst, enable; 
	wire clk_out;	

	initial begin

		clk = 1'b0;
		rst = 1'b1;
		enable = 1'b0;
		#160 rst = 1'b0;
		#80 enable = 1'b1;
		#200 enable = 1'b0;
		#200 enable = 1'b1;
	end

	always #20 clk = ~clk;

clk_counter #(.F_CLK_OUT(48_000),.F_CLK_IN(50_000_000)) DUT(

	.clk(clk),        // clock in
    .i_rst(rst ),      // reset
    .enable(enable),
    .o_clk(clk_out) 
	);		



endmodule


