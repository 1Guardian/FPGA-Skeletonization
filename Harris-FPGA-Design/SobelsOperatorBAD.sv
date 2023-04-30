module Sobels (
  input clk,
  input start,
  input [7:0] inputPixels0,
  input [7:0] inputPixels1,
  input [7:0] inputPixels2,
  input [7:0] inputPixels3,
  input [7:0] inputPixels4,
  input [7:0] inputPixels5,
  input [7:0] inputPixels6,
  input [7:0] inputPixels7,
  input [7:0] inputPixels8,
  input [7:0] inputPixels9,
  input [7:0] inputPixels10,
  input [7:0] inputPixels11,
  input [7:0] inputPixels12,
  input [7:0] inputPixels13,
  input [7:0] inputPixels14,
  input [7:0] inputPixels15,
  input [7:0] inputPixels16,
  input [7:0] inputPixels17,
  input [7:0] inputPixels18,
  input [7:0] inputPixels19,
  input [7:0] inputPixels20,
  input [7:0] inputPixels21,
  input [7:0] inputPixels22,
  input [7:0] inputPixels23,
  input [7:0] inputPixels24,
  output reg Q,
  output wire signed [21:0] OIx0,
  output wire signed [21:0] OIx1,
  output wire signed [21:0] OIx2,
  output wire signed [21:0] OIx3,  
  output wire signed [21:0] OIx4,
  output wire signed [21:0] OIx5,
  output wire signed [21:0] OIx6,
  output wire signed [21:0] OIx7,
  output wire signed [21:0] OIx8,
  output wire signed [21:0] OIy0, 
  output wire signed [21:0] OIy1, 
  output wire signed [21:0] OIy2, 
  output wire signed [21:0] OIy3, 
  output wire signed [21:0] OIy4, 
  output wire signed [21:0] OIy5, 
  output wire signed [21:0] OIy6, 
  output wire signed [21:0] OIy7, 
  output wire signed [21:0] OIy8,
  output wire signed [21:0] OIxy0, 
  output wire signed [21:0] OIxy1, 
  output wire signed [21:0] OIxy2, 
  output wire signed [21:0] OIxy3, 
  output wire signed [21:0] OIxy4, 
  output wire signed [21:0] OIxy5, 
  output wire signed [21:0] OIxy6, 
  output wire signed [21:0] OIxy7, 
  output wire signed [21:0] OIxy8  
  );

  //ram blocks
  reg signed [10:0] Ix [8:0];  
  reg signed [10:0] Iy [8:0];  

  //flip
  reg flip;

  initial begin
    flip = 1;
  end

  //latched FF that will do the corner calcs
  always @(posedge clk) begin
    if (flip) begin

        //begin if double latch is ready
        if (start) begin
            //find the x and y gradients

            //Ix
            Ix[0] = (inputPixels0 * -1) + (inputPixels1 * 0) + (inputPixels2 * 1) + (inputPixels5 * -2) + (inputPixels6 * 0) + (inputPixels7 * 2) + (inputPixels10 * -1) + (inputPixels11 * 0) + (inputPixels12 * 1);
            Ix[1] = (inputPixels1 * -1) + (inputPixels2 * 0) + (inputPixels3 * 1) + (inputPixels6 * -2) + (inputPixels7 * 0) + (inputPixels8 * 2) + (inputPixels11 * -1) + (inputPixels12 * 0) + (inputPixels13 * 1);
            Ix[2] = (inputPixels2 * -1) + (inputPixels3 * 0) + (inputPixels4 * 1) + (inputPixels7 * -2) + (inputPixels8 * 0) + (inputPixels9 * 2) + (inputPixels12 * -1) + (inputPixels13 * 0) + (inputPixels14 * 1);
            
            Ix[3] = (inputPixels5 * -1) + (inputPixels6 * 0) + (inputPixels7 * 1) + (inputPixels10 * -2) + (inputPixels11 * 0) + (inputPixels12 * 2) + (inputPixels15 * -1) + (inputPixels16 * 0) + (inputPixels17 * 1);
            Ix[4] = (inputPixels6 * -1) + (inputPixels7 * 0) + (inputPixels8 * 1) + (inputPixels11 * -2) + (inputPixels12 * 0) + (inputPixels13 * 2) + (inputPixels16 * -1) + (inputPixels17 * 0) + (inputPixels18 * 1);
            Ix[5] = (inputPixels7 * -1) + (inputPixels8 * 0) + (inputPixels9 * 1) + (inputPixels12 * -2) + (inputPixels13 * 0) + (inputPixels14 * 2) + (inputPixels17 * -1) + (inputPixels18 * 0) + (inputPixels19 * 1);

            Ix[6] = (inputPixels10 * -1) + (inputPixels11 * 0) + (inputPixels12 * 1) + (inputPixels15 * -2) + (inputPixels16 * 0) + (inputPixels17 * 2) + (inputPixels20 * -1) + (inputPixels21 * 0) + (inputPixels22 * 1);
            Ix[7] = (inputPixels11 * -1) + (inputPixels12 * 0) + (inputPixels13 * 1) + (inputPixels16 * -2) + (inputPixels17 * 0) + (inputPixels18 * 2) + (inputPixels21 * -1) + (inputPixels22 * 0) + (inputPixels23 * 1);
            Ix[8] = (inputPixels12 * -1) + (inputPixels13 * 0) + (inputPixels14 * 1) + (inputPixels17 * -2) + (inputPixels18 * 0) + (inputPixels19 * 2) + (inputPixels22 * -1) + (inputPixels23 * 0) + (inputPixels24 * 1);

            //Iy
            Iy[0] = (inputPixels0 * -1) + (inputPixels1 * -2) + (inputPixels2 * -1) + (inputPixels5 * 0) + (inputPixels6 * 0) + (inputPixels7 * 0) + (inputPixels10 * 1) + (inputPixels11 * 2) + (inputPixels12 * 1);
            Iy[1] = (inputPixels1 * -1) + (inputPixels2 * -2) + (inputPixels3 * -1) + (inputPixels6 * 0) + (inputPixels7 * 0) + (inputPixels8 * 0) + (inputPixels11 * 1) + (inputPixels12 * 2) + (inputPixels13 * 1);
            Iy[2] = (inputPixels2 * -1) + (inputPixels3 * -2) + (inputPixels4 * -1) + (inputPixels7 * 0) + (inputPixels8 * 0) + (inputPixels9 * 0) + (inputPixels12 * 1) + (inputPixels13 * 2) + (inputPixels14 * 1);
            
            Iy[3] = (inputPixels5 * -1) + (inputPixels6 * -2) + (inputPixels7 * -1) + (inputPixels10 * 0) + (inputPixels11 * 0) + (inputPixels12 * 0) + (inputPixels15 * 1) + (inputPixels16 * 2) + (inputPixels17 * 1);
            Iy[4] = (inputPixels6 * -1) + (inputPixels7 * -2) + (inputPixels8 * -1) + (inputPixels11 * 0) + (inputPixels12 * 0) + (inputPixels13 * 0) + (inputPixels16 * 1) + (inputPixels17 * 2) + (inputPixels18 * 1);
            Iy[5] = (inputPixels7 * -1) + (inputPixels8 * -2) + (inputPixels9 * -1) + (inputPixels12 * 0) + (inputPixels13 * 0) + (inputPixels14 * 0) + (inputPixels17 * 1) + (inputPixels18 * 2) + (inputPixels19 * 1);

            Iy[6] = (inputPixels10 * -1) + (inputPixels11 * -2) + (inputPixels12 * -1) + (inputPixels15 * 0) + (inputPixels16 * 0) + (inputPixels17 * 0) + (inputPixels20 * 1) + (inputPixels21 * 2) + (inputPixels22 * 1);
            Iy[7] = (inputPixels11 * -1) + (inputPixels12 * -2) + (inputPixels13 * -1) + (inputPixels16 * 0) + (inputPixels17 * 0) + (inputPixels18 * 0) + (inputPixels21 * 1) + (inputPixels22 * 2) + (inputPixels23 * 1);
            Iy[8] = (inputPixels12 * -1) + (inputPixels13 * -2) + (inputPixels14 * -1) + (inputPixels17 * 0) + (inputPixels18 * 0) + (inputPixels19 * 0) + (inputPixels22 * 1) + (inputPixels23 * 2) + (inputPixels24 * 1);
            Q = 1'b1;
        end 

        //reset if not
        else begin
            Q = 1'b0;
        end
    end

    flip = ~flip;
  end

  //assign the outputs 
   assign OIx0 = Ix[0] * Ix[0];
   assign OIx1 = Ix[1] * Ix[1];
   assign OIx2 = Ix[2] * Ix[2];
   assign OIx3 = Ix[3] * Ix[3];
   assign OIx4 = Ix[4] * Ix[4];
   assign OIx5 = Ix[5] * Ix[5];
   assign OIx6 = Ix[6] * Ix[6];
   assign OIx7 = Ix[7] * Ix[7];
   assign OIx8 = Ix[8] * Ix[8];
   assign OIy0 = Iy[0] * Iy[0];
   assign OIy1 = Iy[1] * Iy[1];
   assign OIy2 = Iy[2] * Iy[2];
   assign OIy3 = Iy[3] * Iy[3];
   assign OIy4 = Iy[4] * Iy[4];
   assign OIy5 = Iy[5] * Iy[5];
   assign OIy6 = Iy[6] * Iy[6];
   assign OIy7 = Iy[7] * Iy[7];
   assign OIy8 = Iy[8] * Iy[8];
   assign OIxy0 = Ix[0] * Iy[0];
   assign OIxy1 = Ix[1] * Iy[1];
   assign OIxy2 = Ix[2] * Iy[2];
   assign OIxy3 = Ix[3] * Iy[3];
   assign OIxy4 = Ix[4] * Iy[4];
   assign OIxy5 = Ix[5] * Iy[5];
   assign OIxy6 = Ix[6] * Iy[6];
   assign OIxy7 = Ix[7] * Iy[7];
   assign OIxy8 = Ix[8] * Iy[8];

endmodule 