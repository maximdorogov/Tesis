module tb_ADC_Interface();

	reg clk, rst, read_enable,busy; 
	wire sck_clk_out,cnv,rdl,chain,data_rdy;	

	initial begin

		clk = 1'b0;
		rst = 1'b1;
		busy = 0;
		read_enable = 1'b0;
		#40 rst = 1'b0;
		#80 read_enable = 1'b1;
		busy =1'b1;
		#200 busy  = 1'b0;
		#200 read_enable = 1'b1;
	end

	always #20 clk = ~clk;

ADC_Interface #(.SMPL_FREQ(48_000), .SPI_CLK_FREQ(4_000_000)) DUT(

	.i_read_enable(1'b0),
	.clk(clk),
	.i_reset(rst),			//   Pines del ADC
	.i_busy(busy),	 	 	//--->BUSY  Goes high at the start of a new conversion and returns low when the conversion has finished.
	//.i_data_in(), 	 	//--->SDO 	 	
	.o_start_conv(cnv), 	 	//--->CNV es el sample clock
	.o_sck(sck_clk_out),     	 	//--->SCK When SDO is enabled the conversion result is shifted out on the rising edges of this clock MSB first
	.o_RDL_SDI(rdl),    		//--->RDL/SDI   is low in normal mode, data is read out of the SDO pin. When RDL/SDI is high  SDO becomes Hi-Z and SCK is disabled
	.o_chain(chain),		 	//--->CHAIN When low, operates in normal mode in high operates in chain mode
	//.o_data_frame(), 		//data from 24 bits ADC.
	.data_ready(data_rdy)       	// gets high when data_frame is ready to deliver

	);	



endmodule