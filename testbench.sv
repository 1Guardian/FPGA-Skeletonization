//imported modules
`include "Rams.sv"
`include "mainController.sv"
`include "counter.sv"
`include "writeController.sv"
`include "centerMask.sv"
`include "paddedRam.sv"

`timescale 1 us / 10 ps

//test bench module
module tb;
  
  	//Parameter to control the size of the image that will be processed
  	parameter N = 8;
  	parameter bitSize = $clog2(N*N);
  	
    // Inputs
    reg clk;
    reg wr_en;
  	reg [7:0] data_in;
  	reg [15:0] i;
  	reg flip;

  	//image file storage
  	reg [7:0] image [63:0];

  
  	//file variable
  	integer fd;

    // Instantiate the Unit Under Test (UUT)
  mainController #(.N(N), .bitSize(bitSize)) controller (
        .clk(clk), 
        .we(wr_en), 
        .data_in(data_in)
    );
  
    always
        #0.04167 clk = ~clk;

    initial begin
      	
      	//enable write bit
      	wr_en = 1;
      
		//epwave stuff
      	$dumpfile("dump.vcd"); $dumpvars;
      
        //read in from image file
      	$readmemb("image.txt",image);
      

        // Initialize Inputs
        clk = 0;
      	i <= 0;
      	flip <= 1;
      	data_in = 0;
    end
  
    
  always @(posedge clk) begin
    
    if (flip) begin
      if (i < 64)
          data_in = image[i];

      i = i + 1;

      if (i == 64)
        wr_en = 0;

      if (i == 384) begin
        $finish;
      end
      
    end
    
    flip = ~flip;
    
  end
      
endmodule