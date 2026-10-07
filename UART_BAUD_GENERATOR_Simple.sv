// Write your modules here!
module circuit #(parameter int clock_rate = 50000000 , parameter int baud_rate = 115200)(input logic clk, reset, output logic baud);
     localparam int clk_divisor = clock_rate / baud_rate;
  logic [15:0]counter; 
  
  always_ff@(posedge clk)
  begin
    if (reset) begin 
    counter<= '0; 
    baud<='0; 
    end 
    //should be else if, otherwise the reset will fire and still the counter could fire at the 
    //same time and the outputs do not care about the reset, therefore we should make them dependent
    //with else if
    else if(counter == clk_divisor -1 ) begin
      baud <= '1; 
      counter <= '0; end 
    else 
      begin
      counter <= counter + 1; 
         baud <= '0; 
      end 
  end 

endmodule
