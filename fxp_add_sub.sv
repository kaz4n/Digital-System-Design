module fxp_add_sub #(
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
    parameter bit SAT = 1)

   (
      input logic [A_IN_W - 1 : 0] a,
      input logic [B_IN_W - 1 : 0] b, 
      input logic add_or_sub,
      output logic [Y_OUT_W - 1 : 0] y,
    output logic ovf, inx 
    );

  localparam int S = A_IN_F - B_IN_F ;

  localparam int ABS_S = (S < 0) ? -S : S;
  localparam WORK_W = ((internal_A_IN_W >= internal_B_IN_W) ? (internal_A_IN_W + 1) : (internal_B_IN_W + 1)) + ABS_S;

  localparam internal_A_IN_W = A_IN_W + ((~A_IN_SIGN) ? 1  : 0) ;
  localparam internal_B_IN_W = B_IN_W + ((~B_IN_SIGN) ? 1  : 0) ;

localparam WORK_F = (S>0) ? (A_IN_F) : ( B_IN_F);

  logic signed [internal_A_IN_W - 1 :0] internal_a ;
  logic signed [internal_B_IN_W - 1:0] internal_b;

  logic signed [WORK_W - 1 : 0] internal_out ;


  fixed_point_converter #(.IN_W(WORK_W), .OUT_W(Y_OUT_W), .IN_F(WORK_F), .OUT_F(Y_OUT_F),
                          .IN_SIGNED(1'b1), .OUT_SIGNED(Y_OUT_SIGN), .ROUND(ROUND), .SAT(SAT)) 
                          converter (.x(internal_out), .y(y), .inx(inx), .ovf(ovf) );


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

logic signed [WORK_W-1:0] a_aligned;
logic signed [WORK_W-1:0] b_aligned;

assign a_aligned =
    $signed(internal_a) <<< ((S < 0) ? -S : 0);

assign b_aligned =
    $signed(internal_b) <<< ((S > 0) ? S : 0);

     assign internal_out = (add_or_sub) ? (a_aligned + b_aligned) : (a_aligned - b_aligned);

endmodule
