//***********************************************************
// module: v_rams_09
//
// description: This is the central Ram block that is used.
//				the design is based off a Xilinx v_ram_09
//				design, and as such I left it named after
//				it to show it's relationship to Xilinx's
//				design
//***********************************************************
module v_rams_09 #(parameter N=8, bitSize=6, pixelWidth = 8) (clk, we, primary_address, dual_read_address, data_in, primary_output, dual_output);
  input clk;
  input we;
  input [bitSize:0] primary_address;
  input [bitSize:0] dual_read_address;
  input [pixelWidth-1:0] data_in;
  output [pixelWidth-1:0] primary_output;
  output [pixelWidth-1:0] dual_output;
  
  //memory declaration
  //(Use 64bits for image + 1 bit for completion mark)
  reg [pixelWidth-1:0] ram [(N*N)-1:0];
  reg [pixelWidth-1:0] stored;
  reg flip;
  
  //initialize flip
  initial begin
    flip = 1;
  end
  
  //on each cycle write if enabled
  always @(posedge clk) begin
    if (flip) begin
      if (we) begin
        stored = data_in;
        ram[primary_address] = stored;
      end
    end
    flip = ~flip;
  end
  
  //Assign the outputs on every clock cycle no matter what
  assign primary_output = ram[primary_address];
  assign dual_output = ram[dual_read_address];
endmodule