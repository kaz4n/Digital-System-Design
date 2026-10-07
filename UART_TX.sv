// Write your modules here!
module circuit(input logic [7:0] tx_data_input, input logic reset, clk, baud, tx_valid, 
output logic tx_data_output, tx_ready);
   
   // State encoding using enum
   enum logic [2:0] {
    TX_IDLE,
    TX_START,
    TX_DATA,
    TX_STOP
   } state, next_state;
  


// State transition logic
  always_ff @(posedge clk or posedge reset)
  begin 
    if(reset) begin 
      state <= TX_IDLE; 
    end 
        else 
        state <= next_state; 
  end 

  // Next state logic
always_comb begin : next_State_logic 
    case(state)  
    TX_IDLE: begin 
        if(tx_ready && tx_valid)
          begin 
            next_state= TX_START;
          end 
        else 
          next_state =TX_IDLE;
      end 

      TX_START: begin
       next_state= TX_DATA;
       end 

  	default:
      begin 
        next_state = TX_IDLE;
    end

    endcase
end

// Output logic
always_comb begin
case(state) 
    TX_START: tx_data_output = 1'b0;
        TX_STOP: tx_data_output = 1'b1;

endcase
end 
endmodule
