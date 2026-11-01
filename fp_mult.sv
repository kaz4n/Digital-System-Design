module fp_mult #(
    parameter int A_IN_W = 8,
    parameter int B_IN_W = 8,

    parameter int A_IN_F = 4,
    parameter int B_IN_F = 4,

    parameter bit A_IN_SIGN = 0,
    parameter bit B_IN_SIGN = 0,

    parameter int Y_OUT_W = 16,
    parameter int Y_OUT_F = 16,

    parameter logic [2:0] ROUND = 3'b100,
    parameter bit SAT = 1

  ) (input logic [A_IN_W - 1 : 0 ] a_in, input logic [B_IN_W - 1 : 0]b_in,

     output logic [Y_OUT_W - 1 : 0]y,

     output logic ovf,
     output logic inx);
  fixed_point_converter #(.IN_W(WORK_W), .OUT_W(Y_OUT_W), .IN_F(WORK_F), .OUT_F(Y_OUT_F),
                          .IN_SIGNED(signed_flag), .OUT_SIGNED(signed_flag), .ROUND(ROUND), .SAT(1'b1)) converter (.x(raw), .y(y), .inx(inx), .ovf(ovf) );

  localparam internal_A_IN_W = A_IN_W + ((A_IN_SIGN) ? 1  : 0) ;
  localparam internal_B_IN_W = B_IN_W + ((B_IN_SIGN) ? 1  : 0) ;

  localparam WORK_W = internal_A_IN_W + internal_B_IN_W ;

  localparam WORK_F = A_IN_F + B_IN_F ;
  localparam S =  WORK_F - Y_OUT_F;

  localparam signed_flag = A_IN_SIGN || B_IN_SIGN ;

  logic[internal_A_IN_W - 1 :0] internal_a ;
  logic  [internal_B_IN_W - 1:0] internal_b;
  logic ovf, inx;



  logic [WORK_W - 1:0] raw ; 

        always_comb
        begin
          internal_a = a_in;
           internal_b = b_in;
          if (signed_flag)
          begin
            raw = $signed(internal_a * internal_b);
          end
          else
             raw = internal_a * internal_b;
        end


      endmodule
