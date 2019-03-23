/*This module slows down the main clock

receive as parameter the output frequency

and the output clock frequency

*/

module clk_counter #(parameter F_CLK_OUT = 48_000,F_CLK_IN = 50_000_000) (
    input clk,        // clock in
    input i_rst,      // reset
    input i_enable,
    output reg o_clk  // clk out, is slower that clk in  
  );
  
  // $clog2 es una funcion que calcula log2 y redondea al entero mas grande
  // sirve para ver cuantos bits necesito para almacenar un numero

 
  localparam MAX_COUNTER = F_CLK_IN / F_CLK_OUT;
  localparam NBITS  = $clog2(MAX_COUNTER); 
  
  reg [NBITS-1:0] counter;
    
  always @(posedge clk) begin
  
    if (i_rst) begin          
      o_clk <= 1'b0;
      counter <= 0;          
    end 
    else if(i_enable) begin
      
      if(counter == MAX_COUNTER - 1) begin          
        counter <= 0;
        o_clk <= ~o_clk;      
      end
      else begin        
        o_clk <= o_clk;
        counter <= counter + 1'b1; 
      end      
    end else begin
        counter <= 0;
        o_clk <= 0;
    end
  end
  
endmodule
