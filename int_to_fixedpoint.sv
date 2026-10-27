// Write your modules here!
module #(parameter int IN_W, 
         parameter int OUT_W,
        parameter int IN_F, 
         parameter int OUT_F,
         parameter int IN_SIGNED, 
         parameter int OUT_SIGNED, 
         parameter int ROUND
         parameter int SAT
        ) circuit(
            input logic [IN_W - 1 : 0] x, 
            output logic [OUT_W - 1 : 0] y,
            output ovf, inx
        );
        logic [OUT_W - 1 : 0 ] temp; 

        logic signed frac_diff = IN_F - OUT_F; 
        always_comb begin 
            if (frac_diff = 0 ) begin  
                temp = x; 
                if
                y = x;
            
            end  
            else if(frac_diff > 0) begin 
                y = (x >>> frac_diff);
            end 
            else y = (x << frac_diff); 
            
        end 


  
endmodule
