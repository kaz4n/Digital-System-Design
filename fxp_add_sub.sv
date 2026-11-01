module #(
    parameter int A_IN_W = 8,
    parameter int B_IN_W = 8,

    parameter int A_IN_F = 4,
    parameter int B_IN_F = 4,

    parameter bit A_IN_SIGN = 0,
    parameter bit B_IN_SIGN = 0,

    parameter int Y_OUT_W = 16,
    parameter int Y_OUT_F = 16,
    parameter bit Y_OUT_SIGN = 1,

    parameter bit add_or_sub = 1'b1)

  fxp_add_sub (
      input logic [A_IN_W - 1 : 0] a,
      input logic [B_IN_W - 1 : 0] b,
      output logic [Y_OUT_W - 1 : 0] y

    );

  localparam int S = A_IN_F - B_IN_F ;

localparam WORK_W = ((A_IN_W >= B_IN_W) ? (A_IN_W + 1) : (B_IN_W + 1)) + $abs(S); 

  localparam internal_A_IN_W = A_IN_W + ((~A_IN_SIGN) ? 1  : 0) ;
  localparam internal_B_IN_W = B_IN_W + ((~B_IN_SIGN) ? 1  : 0) ;

  logic signed [internal_A_IN_W - 1 :0] internal_a ;
  logic signed [internal_B_IN_W - 1:0] internal_b;

  logic [WORK_W - 1 : 0] internal_out ; 
  always_comb
  begin

    if (A_IN_SIGN)
      internal_a = $signed(a);
    else
      internal_a = $signed({1'b0, a});
    if (B_IN_SIGN)
      internal_b = $signed(b);
    else
      internal_b = $signed({1'b0, b});

  end


  always_comb
  begin
    internal_a = a;
    internal_b = b;
    if (S == 0)
    begin
      internal_out = (add_or_sub) ? (internal_a + internal_b) : (internal_a - internal_b);
    end
    else if (S > 0)
    begin
      internal_b = b << S;
      internal_out = (add_or_sub) ? (internal_a + internal_b) : (internal_a - internal_b);
    end
    else
    begin
      internal_b = a << S;
      internal_out = (add_or_sub) ? (internal_a + internal_b) : (internal_a - internal_b);
    end
  end

endmodule
