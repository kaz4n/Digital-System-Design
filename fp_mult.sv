module fp_mult #(
    parameter int A_IN_W = 8,
    parameter int B_IN_W = 8,

    parameter int A_IN_F = 4,
    parameter int B_IN_F = 4,

    parameter bit A_IN_SIGN = 0,
    parameter bit B_IN_SIGN = 0,

    parameter int Y_OUT_W = 16,
    parameter int Y_OUT_F = 16

    parameter logic [2:0] ROUND = 3'b100,
    parameter bit SAT = 1

) (input logic [A_IN_W]a,input logic [B_IN_W]b,

    input logic [Y_OUT_W]y,     
    
    output logic ovf,
    output logic inx);
    
localparam internal_A_IN_W = A_IN_W + ((A_IN_SIGN) ? 1  : 0) ;
localparam internal_B_IN_W = B_IN_W + ((B_IN_SIGN) ? 1  : 0) ;

localparam WORK_W = internal_A_IN_W + internal_B_IN_W ;

localparam WORK_F = A_IN_F + B_IN_F ;
localparam S =  WORK_F - Y_OUT_F;


always_comb begin 
    
end


endmodule