//***********************************************************
// module: kernelRam
//
// description: The centerMask (or convolutional unit as
// 				the paper would call it) generates a 
//				kernel ram module for each 3x3 neighborhood
//				for each pixel in question. These memory
//				blocks do their convolutions themselves
//				and then the centerMask collects them and
//				sends them to the Ram block.
//***********************************************************
module kernelRam #(parameter N=8, bitSize=6) (clk, we, re, pixel_position_or_address, data_in, identifier, primary_output);
  input clk;
  input we;
  input re;
  input [bitSize:0] pixel_position_or_address;
  input [7:0] data_in;
  input [7:0] identifier;
  output [7:0] primary_output;
  
  //memory declaration
  reg [7:0] ram [8:0];
  reg [4:0] write_counter;
  reg [7:0] read_out;
  reg [7:0] stored_pixel;
  reg flip;
  reg [7:0] largest;
  reg [7:0] smallest;
  
  //reg(s) dedicated to keeping track of variable pixels
  reg [7:0] current_identifier;
  reg [7:0] variable_results [((N/3) + 1):0];
  reg [7:0] meta_write_counter;
  
  //register to store the value of the result pixel in question
  reg [7:0] result;
  
  //set counter
  initial begin
    write_counter = 0;
    flip = 1;
    largest = 0;
    smallest = 255;
    current_identifier = identifier;
    meta_write_counter = 0;
  end
  
  //on each cycle write if enabled
  always @(posedge clk) begin
    if (flip) begin
      if (we) begin

        if (pixel_position_or_address == current_identifier) begin
          ram[write_counter] = data_in; //write counter and ram acts as queue to keep order
          write_counter = write_counter + 1;
          stored_pixel = ram[4]; 
          largest = data_in >= largest ? data_in : largest;
          smallest = data_in <= smallest ? data_in : smallest;
        end
        else if (pixel_position_or_address == (current_identifier - 1)) begin
          ram[write_counter] = data_in; //write counter and ram acts as queue to keep order
          write_counter = write_counter + 1;
          stored_pixel = ram[4]; 
          largest = data_in >= largest ? data_in : largest;
          smallest = data_in <= smallest ? data_in : smallest;
        end
        else if (pixel_position_or_address == (current_identifier + 1)) begin
          ram[write_counter] = data_in; //write counter and ram acts as queue to keep order
          write_counter = write_counter + 1;
          stored_pixel = ram[4]; 
          largest = data_in >= largest ? data_in : largest;
          smallest = data_in <= smallest ? data_in : smallest;
        end
        else if (pixel_position_or_address == (current_identifier + (N-1))) begin
          ram[write_counter] = data_in; //write counter and ram acts as queue to keep order
          write_counter = write_counter + 1;
          stored_pixel = ram[4]; 
        end
        else if (pixel_position_or_address == (current_identifier - (N-1))) begin
          ram[write_counter] = data_in; //write counter and ram acts as queue to keep order
          write_counter = write_counter + 1;
          stored_pixel = ram[4]; 
        end
        else if (pixel_position_or_address == (current_identifier + (N))) begin
          ram[write_counter] = data_in; //write counter and ram acts as queue to keep order
          write_counter = write_counter + 1;
          stored_pixel = ram[4]; 
          largest = data_in >= largest ? data_in : largest;
          smallest = data_in <= smallest ? data_in : smallest;
        end
        else if (pixel_position_or_address == (current_identifier - (N))) begin
          ram[write_counter] = data_in; //write counter and ram acts as queue to keep order
          write_counter = write_counter + 1;
          stored_pixel = ram[4]; 
          largest = data_in >= largest ? data_in : largest;
          smallest = data_in <= smallest ? data_in : smallest;
        end
        else if (pixel_position_or_address == (current_identifier + (N+1))) begin
          ram[write_counter] = data_in; //write counter and ram acts as queue to keep order
          write_counter = write_counter + 1;
          stored_pixel = ram[4]; 
        end
        else if (pixel_position_or_address == (current_identifier - (N+1))) begin
          ram[write_counter] = data_in; //write counter and ram acts as queue to keep order
          write_counter = write_counter + 1;
          stored_pixel = ram[4]; 
        end
        
        //check if we should compute out value yet
        if (pixel_position_or_address > current_identifier + (N+1) || pixel_position_or_address == ((N*N)-1)) begin
          
          //check if the pixel is a border
          if ((largest - smallest) >= 1) begin
            variable_results[meta_write_counter] = 0; 
            meta_write_counter = meta_write_counter + 1;
          end
          else begin
            variable_results[meta_write_counter] = ram[4]; 
            meta_write_counter = meta_write_counter + 1;
          end
          
          //get ready for next pixel
          write_counter = 0;
          current_identifier = current_identifier + (N*3);
        end
      end
      else begin
        largest = 0;
        smallest = 255;
        current_identifier = identifier;
        meta_write_counter = 0;
      end
    
      //write out current pixel result constantly
      read_out = variable_results[meta_write_counter];
    end
    
    flip = ~flip;
  end
  
  //Assign the outputs on every clock cycle no matter what
  assign primary_output = read_out;
endmodule