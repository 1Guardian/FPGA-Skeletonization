//***********************************************************
// module: writeController
//
// description: The writeController is an example of a piece
//				of logic that has made it to the current 
//				version like a piece of vestigial DNA. It
//				does do a function: it controls the output
//				of data from two sources (tb or internal)
//				so that the Ram only gets one info piece
//				however, it is definitely not elegant and
//				really does not need to be its own module
//***********************************************************
module writeController #(parameter N=8, bitSize=6) (clk, we, we_two, data_0, data_1, res);
  input clk;
  input we;
  input we_two;
  input [7:0] data_0;
  input [7:0] data_1;
  output [7:0] res;
  
  //register to store address
  reg [7:0] stored;
  reg flip;
  
  //set reg to 0
  initial begin
    stored <= 0;
    flip <= 1;
  end
  
  //depending on which write is happening, write
  always @(posedge clk) begin
    if (flip)
      if (we)
        stored = data_0;

      if (we_two)
        stored = data_1;
    
    flip = ~flip;
  end
  
  //output cycles continuously
  assign res = stored;
  
endmodule