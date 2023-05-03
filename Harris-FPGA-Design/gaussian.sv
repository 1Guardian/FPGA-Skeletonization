module Gaussian 
(
  input clk,
  input start,
  input signed [39:0] Ix0,
  input signed [39:0] Ix1,
  input signed [39:0] Ix2,
  input signed [39:0] Ix3,
  input signed [39:0] Ix4,
  input signed [39:0] Ix5,
  input signed [39:0] Ix6,
  input signed [39:0] Ix7,
  input signed [39:0] Ix8,
  output signed [39:0] finalValue
);
    
  reg signed [39:0] sixteenth;
  reg signed [39:0] eighth;
  reg signed [39:0] fourth;
  reg signed [39:0] half;

  reg flip;

  reg signed [80:0] large_results [8:0];
  reg signed [39:0] results [8:0];

  reg signed [39:0] finalVal;
  
  initial begin
  // Initialize Inputs
  sixteenth = 27'b00000000000000000000000_0001;
  eighth = 27'b00000000000000000000000_0010;
  fourth = 27'b00000000000000000000000_0100;
  half = 27'b00000000000000000000000_1000;
  flip = 1;
  end
      
  //latched FF that will do the corner calcs
  always @(posedge clk) begin
    if (flip) begin

        //begin if double latch is ready
        if (start) begin

            //do our one cycle of math
            large_results[0] = (Ix0 << 4) * sixteenth;
            results[0] = large_results[0][44:4];

            large_results[1] = (Ix1 << 4) * eighth;
            results[1] = large_results[1][44:4];

            large_results[2] = (Ix2 << 4) * sixteenth;
            results[2] = large_results[2][44:4];

            large_results[3] = (Ix3 << 4) * eighth;
            results[3] = large_results[3][44:4];

            large_results[4] = (Ix4 << 4) * fourth;
            results[4] = large_results[4][44:4];

            large_results[5] = (Ix5 << 4) * eighth;
            results[5] = large_results[5][44:4];

            large_results[6] = (Ix6 << 4) * sixteenth;
            results[6] = large_results[6][44:4];

            large_results[7] = (Ix7 << 4) * eighth;
            results[7] = large_results[7][44:4];

            large_results[8] = (Ix8 << 4) * sixteenth;
            results[8] = large_results[8][44:4];

            //get final value
            finalVal = results[0] + results[1] + results[2] + results[3] + results[4] + results[5] + results[6] + results[7] + results[8];
        end 
    end

    flip = ~flip;
  end

  assign finalValue = finalVal;

endmodule 