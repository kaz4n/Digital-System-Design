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


assign q = x >>> S ;
assign r = x - (q<<S) ;
 assign H = (1'b1 << (S -1));
  assign rounded = ;

always_comb begin
    x_ext = '0;
    q = '0;
    r = '0;
    H = '0;
    //make sure last bit is for sign
    if (IN_SIGNED == 1)
        x_ext = $signed(x);
    else
      //put last bit 0 
        x_ext = $signed({1'b0, x});

        //input fraction bits are more than the output 
    if (S > 0) begin
        q = x_ext >>> S; // get qoutient 
        r = x_ext - (q <<< S); //reminder 
        H = {{(WORK_W-1){1'b0}}, 1'b1} << (S-1); 
    end
    //no difference in fracion bits width 
    else if (S == 0) begin
        q = x_ext;
    end
    //output fraction bits are more than the input  
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
            //
            3'b001: increment = (x_ext < 0) && (r != 0);
            //
            3'b010: increment = (r >= H);
            //
            3'b011: increment = (r > H) ||
                               ((r == H) && (x_ext >= 0));
//
            3'b100: increment = (r > H) ||
                                 ((r == H) && q[0]);
            //
            default: increment = 1'b0;
        endcase
    end
end


endmodule
