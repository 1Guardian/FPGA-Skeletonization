//***********************************************************
// module: centerMask
//
// description: The centerMask (or convolutional unit as
// 				the paper would call it) is the unit that
//				creates the kernelRam and it's padded version
//				and manages them. It also returns the values
//				to the Ram once the units are loaded and 
//				convoluted, and it loads the rams again
//				when they are ready to be reset
//***********************************************************
module centerMask #(parameter N=8, bitSize=6) (clk, we, re, data_in, write_out_enable, primary_address, primary_output);
  input clk;
  input we;
  input re;
  input [7:0] data_in;
  output write_out_enable;
  output [bitSize:0] primary_address;
  output [7:0] primary_output;
  
  //registers for storing data that will be used by the kernels
  //under consideration, in addition to a register for storing
  //write completion events
  wire [7:0] we_blocks [((N*N)-1):0];
  reg re_blocks [((N*N)-1):0];
  wire [bitSize:0] block_address;
  wire [7:0] block_data_in;
  wire [7:0] block_data_out;
  reg element_we_reg;
  reg [7:0] stored_returned_value;
  
  //read counter to keep track of which position in the ram we are looking at
  reg [7:0] read_counter;
  reg [7:0] data_in_register;
  reg flip;
  
  //set counter
  initial begin
    read_counter = 0;
    flip <= 1;
    element_we_reg <= 0;
  end
  
  //generate the RAM segments that will check each pixel
  genvar i;
  
  generate
    for (i=0; i < ((N*N)); i = i + 1) begin : mask_block
      if ((i > N) && ((i - N) < (N*N)) && (((i + 1) % N) != 0) && (((i) % N) != 0))
      	kernelRam u0 (clk, we, re_blocks[i], block_address, block_data_in, i, we_blocks[i]);
      else
        kernelPaddedRam u0 (clk, we, re_blocks[i], block_address, block_data_in, i, we_blocks[i]);
    end
  endgenerate
  
  //run every clock cycle as soon as loading is done
  always @(posedge clk) begin
    if (flip) begin
      
      //reset last block
      re_blocks[read_counter -1] = 0;
      
      //writing to masks
      if (we) begin
        if (read_counter < ((N*N) - 1)) begin
          data_in_register = data_in;
          read_counter = read_counter + 1;
        end
        else begin
          read_counter = 0;
          element_we_reg = 1;
        end
      end
      
      //shite added here dumbass
      if (element_we_reg)begin
        if (read_counter < ((N*N) - 1)) begin

          //ignore the values that should be padding
          if (read_counter < N || read_counter > ((N*N) - N) || read_counter % N == 0 || (read_counter + 1) % N == 0) begin
            stored_returned_value = 0;
          end 

          //else ask for the value from the kernel ram
          else begin
            stored_returned_value = we_blocks[read_counter];
          end
          read_counter = read_counter + 1;
        end
        else begin
          read_counter = 0;
          element_we_reg = 0;
        end
      end
    end
    flip = ~flip;
  end
  
  //Assign the outputs on every clock cycle no matter what
  assign primary_address = read_counter;
  assign block_address = read_counter;
  assign block_data_in = data_in_register;
  assign write_out_enable = element_we_reg;
  assign primary_output = stored_returned_value;
endmodule