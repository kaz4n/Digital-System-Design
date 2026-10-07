        // Write your modules here!
        module circuit(input logic [7:0] tx_data_input, input logic reset, clk, baud, tx_valid, 
        output logic tx_data_output, tx_ready);
        
    //ready flag is for the frame generator module, to know when to send new data  
    // valid is for the uart frame tx module to know that it has a incoming data 

    // to have a saved copy of the input, assume during the operation an input glitchs, it will make big problem
    //therefore copy it such that they are independent. 

        logic [7:0] tx_data_copy; 
        logic [2:0] bit_count = 3'b000; 
        // State encoding using enum
        enum logic [1:0] {
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
                if(state == TX_IDLE && tx_ready && tx_valid) begin tx_data_copy<= tx_data_input; end  

                if(state == TX_DATA && baud)
                begin 
                if ( bit_count == 7 ) bit_count <= 3'b000;
                
                else begin 
        
                bit_count <= bit_count + 1; 
                
                end  end
        end 

        // Next state logic
        always_comb begin 
            case(state)  
            TX_IDLE: begin 
                if(tx_valid && tx_ready)
                begin 
                    next_state= TX_START;

                end 
                else 
                next_state =TX_IDLE;
            end 

            TX_START: begin if (baud) next_state= TX_DATA;
            end 

            TX_DATA: begin
                if(bit_count == 3'b111 && baud )
                begin 
                next_state= TX_STOP;
                end 
                
            end
            TX_STOP: if(baud)
            next_state = TX_IDLE;
            default:
            begin 
                next_state = TX_IDLE;
            end

            endcase
        end

        // Output logic
        always_comb begin
            tx_data_output = 1'b1; 
                    tx_ready       = 1'b0;
        case(state) 
        

            TX_IDLE: begin 
                tx_data_output = 1'b1; 
                tx_ready       = 1'b1;
            end
            TX_START: begin
                tx_data_output = 1'b0;
            tx_ready = 1'b0; end 



            TX_DATA: begin
                // each time going to this state i.e. each time transitioning back to this
                // state output the bit_count index of the input, which will happeb every baud 
            tx_data_output = tx_data_copy[bit_count];
            tx_ready = 1'b0;
            end 

            TX_STOP: begin
            tx_data_output = 1'b1;
            tx_ready = 1'b1;
            end 

            default: begin
            tx_data_output = 1'b1; 
            tx_ready       = 1'b0;


            end

        endcase
        end 
        endmodule
