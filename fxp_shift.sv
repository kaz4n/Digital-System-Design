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

    output logic [IN_W - 1 : 0 ] y,
    output logic ovf, inx
  );




//   localparam WORK_W = IN_W*2 + (IN_SIGNED? 1 : 0) ;
localparam int WORK_W = 2*IN_W + 1; // account for maximum possible shift and for signed bit also always 


  logic [IN_W - 1 : 0] MAX, MIN;

logic signed [WORK_W-1:0] q;

    logic signed [WORK_W-1:0] r;
  logic signed [WORK_W-1:0] H;
logic signed [WORK_W - 1 : 0 ] x_ext ;
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

    if (!direction && shamt > 0)
    begin       
    q = x_ext >>> shamt; 
      r = x_ext - (q <<< shamt); 
      H = {{(WORK_W-1){1'b0}}, 1'b1} << (shamt - 1); 
    end
    else 
    begin
      q = x_ext;
    end

  end

  //MIN and MAX init
  always_comb
  begin
    MAX = '0;
    MIN = '0;

    if (IN_SIGNED == 1)
    begin
      MAX = (2<<(IN_W - IN_F)) - (2<<(-IN_F));
      MIN = '0;
    end
    else
    begin
      MAX = (2<<(IN_W - 1 - IN_F)) - (2<<(-IN_F));
      MIN = '0;
    end
  end


  always_comb
  begin
    if (IN_SIGNED)
    begin
      y = (~direction) ? (x >>> shamt): (x << shamt);
    end
    else
    begin
      y = (~direction) ? (x >> shamt): (x << shamt);
    end
  end


endmodule
