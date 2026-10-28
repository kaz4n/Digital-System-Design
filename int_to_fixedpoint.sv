// Write your modules here!
module #(parameter int IN_W,
           parameter int OUT_W,
           parameter int IN_F,
           parameter int OUT_F,
           parameter int IN_SIGNED,
           parameter int OUT_SIGNED,
           parameter int ROUND,
           parameter int SAT
          ) circuit(
            input logic [IN_W - 1 : 0] x,
            output logic [OUT_W - 1 : 0] y,
            output ovf, inx
          );
  logic [OUT_W - 1 : 0 ] temp;
  logic [OUT_W - 1 : 0] MAX, MIN;
  localparam int S = IN_F - OUT_F;

  localparam int BASE_W = IN_W + (IN_SIGNED == 0 ? 1 : 0);

  // Wide enough for input, left shift, rounding,
  // and comparison with the output range.
  localparam int WORK_W = BASE_W + (S < 0 ? -S : 0)
             + OUT_W + 1;

  logic signed [WORK_W-1:0] x_ext;
  logic signed [WORK_W-1:0] q;
  logic signed [WORK_W-1:0] r;
  logic signed [WORK_W-1:0] H;
  logic signed [WORK_W-1:0] rounded;

  logic increment;

  always_comb
  begin
    if (S = 0 )
    begin
      temp = x;
      if
      y = x;

  end
  else if(S > 0)
    begin
      y = (x >>> S);
    end
    else
      y = (x << S);

  end


  //MIN and MAX init
  always_comb
  begin
    MAX = '0;
    MIN = '0;

    if (OUT_SIGNED == 1)
    begin
      MAX = {1'b0, {(OUT_W-1){1'b1}}};
      MIN = {1'b1, {(OUT_W-1){1'b0}}};
    end
    else
    begin
      MAX = {OUT_W{1'b1}};
      MIN = '0;
    end
  end

  //rounding modes
  always_comb
  begin
    case (ROUND)
      3'b000:
      begin

      end
      3'b001:
      begin

      end
      3'b010:
      begin

      end
      3'b011:
      begin

      end
      3'b100:
      begin

      end
      default:
      endcase
  end



endmodule
