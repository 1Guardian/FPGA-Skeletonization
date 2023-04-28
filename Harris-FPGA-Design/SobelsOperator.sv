module Sobels (
  input clk,
  input start,
  input [7:0] inCenter,
  input [7:0] inTarget,
  input [7:0] inputPixel,
  output reg Q,
  output wire signed [15:0] OIx,  
  output wire signed [15:0] OIy  

  );

  //ram blocks
  reg signed [15:0] Ix [8:0];  
  reg signed [15:0] Iy [8:0];  
  reg [7:0] inputPixels [24:0];
  
  //counter
  reg [6:0] counter;
  reg [6:0] counter_out;

  //flip
  reg flip;
  reg startc;

  initial begin
    flip = 1;
    startc = 1;
    counter = 0;
    counter_out = 0;
  end

  //latched FF that will do the corner calcs
  always @(posedge clk) begin
    if (flip) begin

        //begin if double latch is ready
        if (start) begin
            //find the x and y gradients

            if (counter == 25) begin

              //Ix
              Ix[0] = (inputPixels[0] * -1) + (inputPixels[1] * 0) + (inputPixels[2] * 1) + (inputPixels[5] * -2) + (inputPixels[6] * 0) + (inputPixels[7] * 2) + (inputPixels[10] * -1) + (inputPixels[11] * 0) + (inputPixels[12] * 1);
              Ix[1] = (inputPixels[1] * -1) + (inputPixels[2] * 0) + (inputPixels[3] * 1) + (inputPixels[6] * -2) + (inputPixels[7] * 0) + (inputPixels[8] * 2) + (inputPixels[11] * -1) + (inputPixels[12] * 0) + (inputPixels[13] * 1);
              Ix[2] = (inputPixels[2] * -1) + (inputPixels[3] * 0) + (inputPixels[4] * 1) + (inputPixels[7] * -2) + (inputPixels[8] * 0) + (inputPixels[9] * 2) + (inputPixels[12] * -1) + (inputPixels[13] * 0) + (inputPixels[14] * 1);
              
              Ix[3] = (inputPixels[5] * -1) + (inputPixels[6] * 0) + (inputPixels[7] * 1) + (inputPixels[10] * -2) + (inputPixels[11] * 0) + (inputPixels[12] * 2) + (inputPixels[15] * -1) + (inputPixels[16] * 0) + (inputPixels[17] * 1);
              Ix[4] = (inputPixels[6] * -1) + (inputPixels[7] * 0) + (inputPixels[8] * 1) + (inputPixels[11] * -2) + (inputPixels[12] * 0) + (inputPixels[13] * 2) + (inputPixels[16] * -1) + (inputPixels[17] * 0) + (inputPixels[18] * 1);
              Ix[5] = (inputPixels[7] * -1) + (inputPixels[8] * 0) + (inputPixels[9] * 1) + (inputPixels[12] * -2) + (inputPixels[13] * 0) + (inputPixels[14] * 2) + (inputPixels[17] * -1) + (inputPixels[18] * 0) + (inputPixels[19] * 1);

              Ix[6] = (inputPixels[10] * -1) + (inputPixels[11] * 0) + (inputPixels[12] * 1) + (inputPixels[15] * -2) + (inputPixels[16] * 0) + (inputPixels[17] * 2) + (inputPixels[20] * -1) + (inputPixels[21] * 0) + (inputPixels[22] * 1);
              Ix[7] = (inputPixels[11] * -1) + (inputPixels[12] * 0) + (inputPixels[13] * 1) + (inputPixels[16] * -2) + (inputPixels[17] * 0) + (inputPixels[18] * 2) + (inputPixels[21] * -1) + (inputPixels[22] * 0) + (inputPixels[23] * 1);
              Ix[8] = (inputPixels[12] * -1) + (inputPixels[13] * 0) + (inputPixels[14] * 1) + (inputPixels[17] * -2) + (inputPixels[18] * 0) + (inputPixels[19] * 2) + (inputPixels[22] * -1) + (inputPixels[23] * 0) + (inputPixels[24] * 1);

              //Iy
              Iy[0] = (inputPixels[0] * -1) + (inputPixels[1] * -2) + (inputPixels[2] * -1) + (inputPixels[5] * 0) + (inputPixels[6] * 0) + (inputPixels[7] * 0) + (inputPixels[10] * 1) + (inputPixels[11] * 2) + (inputPixels[12] * 1);
              Iy[1] = (inputPixels[1] * -1) + (inputPixels[2] * -2) + (inputPixels[3] * -1) + (inputPixels[6] * 0) + (inputPixels[7] * 0) + (inputPixels[8] * 0) + (inputPixels[11] * 1) + (inputPixels[12] * 2) + (inputPixels[13] * 1);
              Iy[2] = (inputPixels[2] * -1) + (inputPixels[3] * -2) + (inputPixels[4] * -1) + (inputPixels[7] * 0) + (inputPixels[8] * 0) + (inputPixels[9] * 0) + (inputPixels[12] * 1) + (inputPixels[13] * 2) + (inputPixels[14] * 1);
              
              Iy[3] = (inputPixels[5] * -1) + (inputPixels[6] * -2) + (inputPixels[7] * -1) + (inputPixels[10] * 0) + (inputPixels[11] * 0) + (inputPixels[12] * 0) + (inputPixels[15] * 1) + (inputPixels[16] * 2) + (inputPixels[17] * 1);
              Iy[4] = (inputPixels[6] * -1) + (inputPixels[7] * -2) + (inputPixels[8] * -1) + (inputPixels[11] * 0) + (inputPixels[12] * 0) + (inputPixels[13] * 0) + (inputPixels[16] * 1) + (inputPixels[17] * 2) + (inputPixels[18] * 1);
              Iy[5] = (inputPixels[7] * -1) + (inputPixels[8] * -2) + (inputPixels[9] * -1) + (inputPixels[12] * 0) + (inputPixels[13] * 0) + (inputPixels[14] * 0) + (inputPixels[17] * 1) + (inputPixels[18] * 2) + (inputPixels[19] * 1);

              Iy[6] = (inputPixels[10] * -1) + (inputPixels[11] * -2) + (inputPixels[12] * -1) + (inputPixels[15] * 0) + (inputPixels[16] * 0) + (inputPixels[17] * 0) + (inputPixels[20] * 1) + (inputPixels[21] * 2) + (inputPixels[22] * 1);
              Iy[7] = (inputPixels[11] * -1) + (inputPixels[12] * -2) + (inputPixels[13] * -1) + (inputPixels[16] * 0) + (inputPixels[17] * 0) + (inputPixels[18] * 0) + (inputPixels[21] * 1) + (inputPixels[22] * 2) + (inputPixels[23] * 1);
              Iy[8] = (inputPixels[12] * -1) + (inputPixels[13] * -2) + (inputPixels[14] * -1) + (inputPixels[17] * 0) + (inputPixels[18] * 0) + (inputPixels[19] * 0) + (inputPixels[22] * 1) + (inputPixels[23] * 2) + (inputPixels[24] * 1);
          
              counter = 0;
              startc = 1;
          end 

          else begin
            
            inputPixels[counter] = inputPixel;
            counter = counter + 1;

          end

          if (startc) begin
            counter_out = counter_out + 1;
          end

        end

        //reset if not
        else begin
            counter = 0;
            Q = 1'b0;
        end

    end

    flip = ~flip;
  end

  //assign the outputs 
  assign OIx = Ix[counter_out];
  assign OIy = Iy[counter_out];

endmodule 