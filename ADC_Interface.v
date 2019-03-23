
//Modulo que recibe datos del ADC lt2389-24

/*
Para el regmen de operacion normal RDL/SDI <= GND, CHAIN <= GND.


*/
module ADC_Interface #(parameter SMPL_FREQ = 48_000, SPI_CLK_FREQ = 4_000_000)(

	input i_read_enable,
	input clk,
	input i_reset,			 //   Pines del ADC
	input i_busy,	 	 	 //--->BUSY  Goes high at the start of a new conversion and returns low when the conversion has finished.
	input i_data_in, 	 	 //--->SDO 
	output o_start_conv, 	 //--->CNV es el sample clock
	output  o_sck,     	 	 //--->SCK When SDO is enabled the conversion result is shifted out on the rising edges of this clock MSB first
	output  o_RDL_SDI,    //--->RDL/SDI   is low in normal mode, data is read out of the SDO pin. When RDL/SDI is high  SDO becomes Hi-Z and SCK is disabled
	output  o_chain,		 //--->CHAIN When low, operates in normal mode in high operates in chain mode
	output reg [23:0] o_data_frame, //data from 24 bits ADC.
	output reg data_ready       // gets high when data_frame is ready to deliver

	);

wire o_sck_wire;
reg spi_clock_enable, sampling_clock_enable;
reg [5:0] data_counter;

assign o_sck = o_sck_wire;
assign o_RDL_SDI = 1'b0 ;
assign o_chain = 1'b0;

// Contador para generar el clock SPI

clk_counter #(.F_CLK_OUT(SPI_CLK_FREQ)) spi_clock(

	.clk(clk),
	.i_rst(i_reset),
	.o_clk(sck_wire),
	.i_enable(spi_clock_enable)

	);

// Contador con enable para generar start_conv clock. En idle io_clk tiene que estar en 0

clk_counter #(.F_CLK_OUT(SMPL_FREQ)) sampling_clock(

	.clk(clk),
	.i_rst(i_reset),
	.o_clk(o_start_conv),
	.i_enable(sampling_clock_enable)

	);

/* %%%%%%%%%%%%%%%% FSM CODE %%%%%%%%%%%%%%%%%*/

   localparam IDLE = 2'b00;
   localparam READ_DATA = 2'b01;
   

   (* FSM_ENCODING="SEQUENTIAL", SAFE_IMPLEMENTATION="NO" *) reg [1:0] state = IDLE;

   	always@(posedge clk) begin
      if (i_reset) begin
         state <= IDLE;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (state)
            IDLE : begin

           	   sampling_clock_enable <= 1'b0;
           	   spi_clock_enable 	 <= 1'b0;
               data_counter 		 <= 5'b0;
               data_ready		     <= 1'b0;

               if (i_read_enable) begin
                  state <= READ_DATA;
               end
               else begin
                  state <= state;
               end
               
            end
            READ_DATA : begin

			   sampling_clock_enable <= 1'b1;
           	   spi_clock_enable 	 <= 1'b1;

               if (!i_read_enable) begin
                  state <= IDLE;
               end
               else begin
               	  state <= state;
               end
            end
         endcase
    end

    always @(posedge o_sck_wire) begin
    	if (!i_busy) begin
    		
    		if (data_counter < 24) begin
    			o_data_frame[data_counter] <= i_data_in;
    			data_counter 			   <= data_counter + 1'b1;
    		end
	    	else begin
	    		data_ready 			 <= 1'b1;
	    		data_counter 		 <= 5'b0;
	    	end

    	end
    	else begin	
    		o_data_frame <= o_data_frame;
    		data_counter <= data_counter;
    	end
    end

endmodule