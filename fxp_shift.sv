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

    output logic [IN_W-1:0] y,
    output logic ovf, inx
  );




  //   localparam WORK_W = IN_W*2 + (IN_SIGNED? 1 : 0) ;
  localparam int WORK_W = 2*IN_W + 1; // account for maximum possible shift and for signed bit also always


  logic [IN_W - 1 : 0] MAX, MIN;

  logic signed [WORK_W-1:0] q;

  logic signed [WORK_W-1:0] r;
  logic signed [WORK_W-1:0] H;
  logic signed [WORK_W - 1 : 0 ] x_ext ;
  logic signed [WORK_W-1:0] rounded;

  logic increment;
  always_comb
  begin
    x_ext = '0;
    q = '0;
    r = '0;
    H = '0;
    if (IN_SIGNED == 1)
      x_ext = $signed(x);
    else
      x_ext = $signed({1'b0, x});


      if (shamt > IN_W) begin
    q = '0;
    r = '0;
    H = '0;
end
    else if (!direction && shamt > 0)
    begin
      q = x_ext >>> shamt;
      r = x_ext - (q <<< shamt);
      H = {{(WORK_W-1){1'b0}}, 1'b1} << (shamt - 1);
    end
    else if (direction) //forgor to put left shift
    begin
      // Left shift
      q = x_ext <<< shamt;
    end
    else
    begin
      // No shift
      q = x_ext;
    end

  end

  //MIN and MAX logic init
  always_comb
  begin
    if (IN_SIGNED)
    begin
      //dont use old method with << and whatever, not smart and hidious and incorrect
      MAX = {1'b0, {(IN_W-1){1'b1}}};
      MIN = {1'b1, {(IN_W-1){1'b0}}};
    end
    else
    begin
      MAX = {IN_W{1'b1}};
      MIN = '0;
    end
  end

  // for the comparison which will happen for overflow
  logic signed [WORK_W-1:0] max_ext;
  logic signed [WORK_W-1:0] min_ext;

  always_comb
  begin
    if (IN_SIGNED)
    begin
      max_ext = {{(WORK_W-IN_W){MAX[IN_W-1]}}, MAX};
      min_ext = {{(WORK_W-IN_W){MIN[IN_W-1]}}, MIN};
    end
    else
    begin
      max_ext = {{(WORK_W-IN_W){1'b0}}, MAX};
      min_ext = '0;
    end
  end


  always_comb
  begin
    increment = 1'b0;

if (!direction && shamt > 0 && shamt <= IN_W)
    begin
      case (ROUND)
        // FLOOR, always round towards negative infinity
        3'b000:
          increment = 1'b0;

        // Zero , always round towards zero
        3'b001:
          increment = (x_ext < 0) && (r != 0);

        // Round UP, i.e. bigger number, round to nearest exactly halfway rounds toward positive infinity
        3'b010:
          increment = (r >= H);

        // Round Half, Round to nearest exactly halfway rounds away from zero.
        3'b011:
          increment = (r > H) ||
          ((r == H) && (x_ext >= 0));

        // Round Even, to nearest exactly halfway goes to the even integer.
        3'b100:
          increment = (r > H) ||
          ((r == H) && q[0]); // q[0] If it is odd, adding one produces an even integer

        default:
          increment = 1'b0; // FLOOR
      endcase
    end
  end



  always_comb
  begin
    rounded = q + increment;
    inx = (shamt > IN_W) ? 1'b0 : (!direction && (r != 0));
   // ovf = 0;
    if (shamt > IN_W )
    begin
      y = 0;
    end
    else
     if (rounded<min_ext && SAT)
    begin
      //ovf = 1;
      y = MIN;
    end
    else if ((max_ext<rounded) && SAT) begin
      y = MAX;
    end
    else
    begin
      y = rounded[IN_W - 1 : 0];
    end
  end

  assign ovf = (shamt > IN_W) ? 1'b0 :
             ((rounded > max_ext) || (rounded < min_ext));


endmodule
