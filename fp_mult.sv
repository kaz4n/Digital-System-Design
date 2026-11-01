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

) (input logic [A_IN_W] a_in, input logic [B_IN_W]b_in,

    input logic [Y_OUT_W]y,     
    
    output logic ovf,
    output logic inx);
fixed_point_converter #(.IN_W() .OUT_W() .IN_F() .OUT_F() .IN_SIGNED() .OUT_SIGNED .ROUND() .SAT()) converter (); 

localparam internal_A_IN_W = A_IN_W + ((A_IN_SIGN) ? 1  : 0) ;
localparam internal_B_IN_W = B_IN_W + ((B_IN_SIGN) ? 1  : 0) ;

localparam WORK_W = internal_A_IN_W + internal_B_IN_W ;

localparam WORK_F = A_IN_F + B_IN_F ;
localparam S =  WORK_F - Y_OUT_F;

logic internal_a [internal_A_IN_W -1 :0];
logic internal_b [internal_B_IN_W - 1:0];
logic raw [WORK_W - 1:0]
always_comb begin 
    if (A_IN_SIGN || B_IN_SIGN) begin
       assign internal_a = a_in;
       assign internal_b = b_in; 
       assign internal_a * internal_b;

    end
end


endmodule