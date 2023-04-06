//***********************************************************
// module: kernelPaddedRam
//
// description: The centerMask (or convolutional unit as
// 				the paper would call it) generates a 
//				kernel ram module for each 3x3 neighborhood
//				for each pixel in question. These memory
//				blocks do their convolutions themselves
//				and then the centerMask collects them and
//				sends them to the Ram block. However, since
//				all images are padded and require padding,
//				there is no reason to check anything in these
//				blocks, and thus it is worth lowering all of
//				the logic that they need to the bare minimum
//				(just returning the padded value)
//***********************************************************

module kernelPaddedRam #(parameter N=8, bitSize=6) (clk, we, pixel_position_or_address, data_in, identifier, primary_output);
  input clk;
  input we;
  input [bitSize:0] pixel_position_or_address;
  input [7:0] data_in;
  input [7:0] identifier;
  output [7:0] primary_output;
  
  //memory declaration
  reg [7:0] read_out;
  reg flip;
  
  //register to store the value of the result pixel in question
  reg [7:0] result;
  
  //set counter
  initial begin
    flip = 1;
  end
  
  //on each cycle write if enabled
  always @(posedge clk) begin
    if (flip) begin
      if (we) begin
      	read_out = 0;
      end
    end
    
    flip = ~flip;
  end
  
  //Assign the outputs on every clock cycle no matter what
  assign primary_output = read_out;
endmodule