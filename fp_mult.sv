module fp_mult #(
    parameter int A_IN_W = 8,
    parameter int B_IN_W = 8,

    parameter int A_IN_F = 4,
    parameter int B_IN_F = 4,

    parameter bit A_IN_SIGN = 0,
    parameter bit B_IN_SIGN = 0,

    parameter int Y_OUT_W = 16,
    parameter int Y_OUT_F = 16,
    parameter bit Y_OUT_SIGN = 1,

    parameter logic [2:0] ROUND = 3'b100,
    parameter bit SAT = 1

  ) (input logic [A_IN_W - 1 : 0 ] a_in, input logic [B_IN_W - 1 : 0]b_in,

     output logic [Y_OUT_W - 1 : 0]y,

     output logic ovf,
     output logic inx);
  fixed_point_converter #(.IN_W(WORK_W), .OUT_W(Y_OUT_W), .IN_F(WORK_F), .OUT_F(Y_OUT_F),
                          .IN_SIGNED(1'b1), .OUT_SIGNED(Y_OUT_SIGN), .ROUND(ROUND), .SAT(SAT)) converter (.x(raw), .y(y), .inx(inx), .ovf(ovf) );

  // add an extra bit when it's unsigned

// TODO:: 
                          /// this needs review, i am making it bigger by 1 bit twice, once is fine 
  localparam internal_A_IN_W = A_IN_W + ((~A_IN_SIGN) ? 1  : 0) ;
  localparam internal_B_IN_W = B_IN_W + ((~B_IN_SIGN) ? 1  : 0) ;

  localparam WORK_W = internal_A_IN_W + internal_B_IN_W ;

  localparam WORK_F = A_IN_F + B_IN_F ;
  localparam S =  WORK_F - Y_OUT_F;

  // localparam signed_flag = A_IN_SIGN || B_IN_SIGN ;

  logic signed [internal_A_IN_W - 1 :0] internal_a ;
  logic   signed [internal_B_IN_W - 1:0] internal_b;



  logic signed [WORK_W - 1:0] raw ;

  always_comb
  begin
    // wrong, should make them signed before multiplication
    // internal_a = a_in;
    // internal_b = b_in;

    //wrong too, need to sign extend this bothersome
    // internal_a = $signed(a_in);
    // internal_b = $signed(b_in);

    if (A_IN_SIGN)
      internal_a = $signed(a_in);
    else
      internal_a = $signed({1'b0, a_in});

    if (B_IN_SIGN)
      internal_b = $signed(b_in);
    else
      internal_b = $signed({1'b0, b_in});


    raw = internal_a * internal_b;
  end


endmodule
