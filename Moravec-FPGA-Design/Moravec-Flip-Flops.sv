module MoravecFF (clk, start, inCenter, inTarget, inE, Q, Eout);
  input clk;
  input start;
  input [7:0] inCenter;
  input [7:0] inTarget;
  input [13:0] inE;
  output reg Q;
  output reg [13:0] Eout;

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
            //do our one bit of math
            Eout = ((((inTarget - inCenter)**2) < inE) ? ((inTarget - inCenter)**2): inE);
            Q = 1'b1;
        end 

        //reset if not
        else begin
            Q = 1'b0;
        end
    end

    flip = ~flip;
  end

endmodule 