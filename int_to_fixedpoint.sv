// Write your modules here!
module fixed_point_converter #(
    parameter int IN_W       = 8,
    parameter int OUT_W      = 6,
    parameter int IN_F       = 4,
    parameter int OUT_F      = 2,
    parameter bit IN_SIGNED  = 1,
    parameter bit OUT_SIGNED = 1,
    parameter logic [2:0] ROUND = 3'b100,
    parameter bit SAT        = 1
) (
    input  logic [IN_W-1:0] x,
    output logic [OUT_W-1:0] y,
    output logic ovf, inx
);
  logic [OUT_W - 1 : 0 ] temp;
  logic [OUT_W - 1 : 0] MAX, MIN;
  localparam int S = IN_F - OUT_F;

  // want all internal calculations to use signed, therefore add a bit 
  //at the end for unsigned and leave the input as is otherwise 
  localparam int BASE_W = IN_W + (IN_SIGNED == 0 ? 1 : 0);

  // Wide enough for input, left shift, rounding,
  // and comparison with the output range.
  //if the shift is to the right, meaning we are gaining more fractions
  // we need to shift by the negative difference (i.e. S) becuase S will be negative -- S = S 
  localparam int WORK_W = BASE_W + (S < 0 ? -S : 0)
             + OUT_W + 1;  //could have less bits, but increase them for safety 

  logic signed [WORK_W-1:0] x_ext;
  logic signed [WORK_W-1:0] q;
  logic signed [WORK_W-1:0] r;
  logic signed [WORK_W-1:0] H;
  logic signed [WORK_W-1:0] rounded;
logic increment;

 

always_comb begin
    //they are already declared with a known width, therefore we coud use 'x for their sizes
    x_ext = '0;
    q = '0;
    r = '0;
    H = '0; // Halfway threshold used to decide rounding
    //make sure last bit is for sign
    if (IN_SIGNED == 1)
        x_ext = $signed(x);
    else
      //put last bit 0 
        x_ext = $signed({1'b0, x}); // put last bit 

        //input fraction bits are more than the output 
    if (S > 0) begin // X = q * 2**S + r , X - q * 2**S =   r 
        //arithmetic right shifting rounds toward negative infinity
        q = x_ext >>> S; // get qoutient 
        r = x_ext - (q <<< S); //reminder, between 0 to 2**S - 1 
        H = {{(WORK_W-1){1'b0}}, 1'b1} << (S-1); //go to the [S - 1] bit and add one on it 
        // before xxxx_xxxxx after xxxx_xxx . S = 3,
        // therefore add just before the decimal point on the last fraction bit
        // meaning it's the half point of the fraction section
    end
    //no difference in fracion bits width  
    //HALF_AWAY
    else if (S == 0) begin
        q = x_ext;
    end
    //output fraction bits are more than the input  
    //HALF_even
    else begin
        q = x_ext <<< (-S);
    end
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

  //wrong stuff

  // always_comb begin 
  //   //
  //   if((x < 0) && r != 0) ROUND = 1'b001; 
  //   //
  //   else if (r >= H) ROUND = 2'b010;
  //   //
  //   else if ( ( r>H ) || ((r == H)&&(x>=0))) ROUND = 2'b010;
  //   //
  //   else if (( r>H ) || ((r == H)&&(q[0]))) ROUND = 2'b010;
  //   //floor mode 
  //   else ROUND = 3'b000;

  // end



  //rounding modes
always_comb begin
    increment = 1'b0;

    if (S > 0) begin
        case (ROUND)
            3'b000: increment = 1'b0; // FLOOR
            // Zero 
            3'b001: increment = (x_ext < 0) && (r != 0);
            // Round UP, i.e. bigger number 
            3'b010: increment = (r >= H);
            // Round Half
            3'b011: increment = (r > H) ||
                               ((r == H) && (x_ext >= 0));
            // Round Even
            3'b100: increment = (r > H) ||
                                 ((r == H) && q[0]);
            // Floor
            default: increment = 1'b0;
        endcase
    end
end


logic signed [WORK_W-1:0] max_ext;
logic signed [WORK_W-1:0] min_ext;


always_comb begin
    max_ext = '0;
    min_ext = '0;

    if (OUT_SIGNED == 1) begin
        max_ext = {{(WORK_W-OUT_W){MAX[OUT_W-1]}}, MAX};
        min_ext = {{(WORK_W-OUT_W){MIN[OUT_W-1]}}, MIN};
    end
    else begin
        max_ext = {{(WORK_W-OUT_W){1'b0}}, MAX};
        min_ext = '0;
    end
end

always_comb begin
    if (SAT == 1 && ovf == 1) begin
        if (rounded > max_ext)
            y = MAX;
        else
            y = MIN;
    end
    else begin
        y = rounded[OUT_W-1:0];
    end
end

assign ovf = (rounded > max_ext) ||
             (rounded < min_ext);

assign rounded = q + increment;
assign inx = (S > 0) && (r != 0);


endmodule
