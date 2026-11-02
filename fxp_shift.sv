module fxp_shift #(
    parameter int IN_W       = 8,
    parameter int IN_F       = 4,
    parameter bit IN_SIGNED  = 1,

    parameter logic [2:0] ROUND = 3'b100,
    parameter bit SAT        = 1  
) (
    input  logic [IN_W-1:0] x,
    input  logic [$clog2(IN_W+1)-1:0] shamt,
    input  logic direction, // 0 = right, 1 = left
    output logic [IN_W] y,
    output logic ovf, inx
);


    
endmodule