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
module kernelRam #(parameter N=8, bitSize=6, pixelWidth = 8, identifier=1) (clk, we, pixel_position_or_address, data_in, primary_output, harris_bit);
  input clk;
  input we;
  input [bitSize:0] pixel_position_or_address;
  input [pixelWidth-1:0] data_in;
  output [pixelWidth-1:0] primary_output;
  output harris_bit;
  
  //memory declaration
  //storing as registers seemed to reduce
  //le mapping a bit over array of registers
  reg [pixelWidth-1:0] ram [24:0];
  reg [6:0] currentWrite;

  reg [4:0] write_counter;
  reg [pixelWidth-1:0] read_out;
  reg [pixelWidth-1:0] stored_pixel;
  reg flip;
  reg [pixelWidth-1:0] largest;
  reg [pixelWidth-1:0] smallest;
  reg detectCorner;
  reg isCorner;
  reg harris_bit_read_out;

  //registers for Moravecs thresholds
  reg [13:0] E1;
  reg [13:0] E2;
  reg [13:0] E3;
  reg [13:0] E4;

  //wires for moravec FFs 
  wire Q11;
  wire Q21;
  wire Q31;
  wire Q41;
  wire Q12;
  wire Q22;
  wire Q32;
  wire Q42;
  wire Q13;
  wire Q23;
  wire Q33;
  wire Q43;
  wire Q14;
  wire Q24;
  wire Q34;
  wire Q44;

  //output wires for moravec FFs
  wire [13:0] Eout11;
  wire [13:0] Eout21;
  wire [13:0] Eout31;
  wire [13:0] Eout41;
  wire [13:0] Eout12;
  wire [13:0] Eout22;
  wire [13:0] Eout32;
  wire [13:0] Eout42;
  wire [13:0] Eout13;
  wire [13:0] Eout23;
  wire [13:0] Eout33;
  wire [13:0] Eout43;
  wire [13:0] Eout14;
  wire [13:0] Eout24;
  wire [13:0] Eout34;
  wire [13:0] Eout44;

  //reg(s) dedicated to keeping track of variable pixels
  reg [bitSize+1:0] current_identifier;
  reg [bitSize+1:0] variable_results [((N/3) + 1):0];
  reg corresponding_harris_bits [((N/3) + 1):0];
  reg [bitSize+1:0] meta_write_counter;
  
  //register to store the value of the result pixel in question
  reg [pixelWidth-1:0] result;

  //register to store count of full convolutions
  reg [bitSize:0] convolutionCounter;
  reg latch;

  //registers to deal with distressed pixels
  reg [bitSize+1:0] distressed_meta_write_counter;
  reg [bitSize+1:0] distressed_current_identifier;
  reg [pixelWidth-1:0] distressed_largest;
  reg [pixelWidth-1:0] distressed_smallest;

  //register for debugging
  reg [bitSize+1:0] debug;
  
  //set counter
  initial begin
    write_counter = 0;
    flip = 1;
    largest = 0;
    smallest = (2**pixelWidth) - 1;
    current_identifier = identifier;
    meta_write_counter = 0;
    detectCorner = 0;
    E1 = 10000;
    E2 = 10000;
    E3 = 10000;
    E4 = 10000;
    convolutionCounter = 0;
    latch = 1;
    distressed_current_identifier = 0;
    distressed_largest = 0;
    distressed_smallest = 0;
    distressed_meta_write_counter = 0;
    currentWrite = 0;
  end
  
  //on each cycle write if enabled
  always @(posedge clk) begin
    if (flip) begin
      if (we) begin

        //use latch to count (watch for metastability)
        if (latch) begin
          latch = 0;
          convolutionCounter = convolutionCounter + 1;
        end

        //check input pixels to see if they belong to the neighborhood set
        if ((pixel_position_or_address == (current_identifier - (N + N + 2))) || 
            (pixel_position_or_address == (current_identifier - (N + N + 1))) ||
            (pixel_position_or_address == (current_identifier - (N + N + 0))) || 
            (pixel_position_or_address == (current_identifier - (N + N - 1))) ||
            (pixel_position_or_address == (current_identifier - (N + N - 2))) ||
            (pixel_position_or_address == (current_identifier - (N + 2)))  || 
            (pixel_position_or_address == (current_identifier - (N + 1))) || 
            (pixel_position_or_address == (current_identifier - (N + 0))) ||
            (pixel_position_or_address == (current_identifier - (N - 1))) ||
            (pixel_position_or_address == (current_identifier - (N - 2))) ||
            (pixel_position_or_address == (current_identifier - (2))) || 
            (pixel_position_or_address == (current_identifier - (1))) ||
            (pixel_position_or_address == (current_identifier - (0))) ||
            (pixel_position_or_address == (current_identifier + 1))  ||
            (pixel_position_or_address == (current_identifier + 2)) || 
            (pixel_position_or_address == (current_identifier + (N - 2))) ||
            (pixel_position_or_address == (current_identifier + (N - 1))) ||
            (pixel_position_or_address == (current_identifier + (N - 0))) ||
            (pixel_position_or_address == (current_identifier + (N + 1))) ||
            (pixel_position_or_address == (current_identifier + (N + 2))) || 
            (pixel_position_or_address == (current_identifier + (N + N - 2))) || 
            (pixel_position_or_address == (current_identifier + (N + N - 1))) || 
            (pixel_position_or_address == (current_identifier + (N + N))) ||
            (pixel_position_or_address == (current_identifier + (N + N + 1))) ||
            (pixel_position_or_address == (current_identifier + (N + N + 2)))) begin
          ram[currentWrite] = data_in;
          write_counter = write_counter + 1;
          currentWrite = currentWrite + 1;
          largest = data_in >= largest ? data_in : largest;
          smallest = data_in <= smallest ? data_in : smallest;
        end

        //only let harris start when we have all pixels
        if (pixel_position_or_address > current_identifier + (N + N + 2)) begin
            //set the bit for the start of the ff chains
            detectCorner = 1'b1;
        end
        
        //check if we should compute out value yet
        //FIXME: REGISTER OF 54 CANNOT BE SET BECAUSE PIXEL VALUE 63 FORCES IT TO ASSUME 0
        if (pixel_position_or_address > current_identifier + (N + 1 + 4) || pixel_position_or_address == ((N*N)-1)) begin
          
          //check if the pixel is a border/corner
          if ((largest - smallest) >= 1 && ram[12] != 0) begin

            //if we determine it's a border, check to see if it's a corner
            if (Eout41 > 0 || Eout42 > 0 || Eout43 > 0 || Eout44 > 0) begin
              variable_results[meta_write_counter] = ram[12]; 
              corresponding_harris_bits[meta_write_counter] = 1;
              stored_pixel = ram[12];
              meta_write_counter = meta_write_counter + 1;
            end
            else begin
              
              //if thinning pass is at convergence, keep all borders
              if (ram[12] > 0 && convolutionCounter > 3) begin
                variable_results[meta_write_counter] = ram[12]; 
                corresponding_harris_bits[meta_write_counter] = 1;
              end
              else begin
                variable_results[meta_write_counter] = 0; 
                corresponding_harris_bits[meta_write_counter] = 0;
              end
              stored_pixel = 0;
              meta_write_counter = meta_write_counter + 1;
            end
          end

          //if not a corner or an edge
          else begin
            variable_results[meta_write_counter] = ram[12]; 
            corresponding_harris_bits[meta_write_counter] = 0;
            stored_pixel = ram[12];
            meta_write_counter = meta_write_counter + 1;
          end
          
          //get ready for next pixel
          write_counter = 0;
          current_identifier = current_identifier + (N*3);
          largest = 0;
          smallest = (2**pixelWidth) - 1;
          detectCorner = 1'b0;
        end
      end

      //begin reading out process
      else begin

        //reset latch
        latch = 1;

        //check if we have a pixel in distress
        if (current_identifier > 51 && current_identifier < 55) begin
          distressed_largest = largest;
          distressed_smallest = smallest;
          distressed_current_identifier = current_identifier;
          distressed_meta_write_counter = meta_write_counter;
          detectCorner = 1'b1;
        end

        //help the distressed pixels finish their convolutions
        if (distressed_current_identifier > 0) begin
          if (pixel_position_or_address > 5) begin
          
            //check if the pixel is a border/corner
            if ((distressed_largest - distressed_smallest) >= 1 && ram[12] != 0) begin

              debug = 12;
              distressed_current_identifier = 0;

              //if we determine it's a border, check to see if it's a corner
              if (Eout41 > 0 || Eout42 > 0 || Eout43 > 0 || Eout44 > 0) begin
                variable_results[distressed_meta_write_counter] = ram[12]; 
                corresponding_harris_bits[distressed_meta_write_counter] = 1;
                stored_pixel = ram[12];
                distressed_meta_write_counter = distressed_meta_write_counter + 1;
              end
              else begin
                
                //if thinning pass is at convergence, keep all borders
                if (ram[12] > 0 && convolutionCounter > 3) begin
                  variable_results[distressed_meta_write_counter] = ram[12]; 
                  corresponding_harris_bits[distressed_meta_write_counter] = 1;
                end
                else begin
                  variable_results[distressed_meta_write_counter] = 0; 
                  corresponding_harris_bits[distressed_meta_write_counter] = 0;
                end
                stored_pixel = 0;
                distressed_meta_write_counter = distressed_meta_write_counter + 1;
              end
            end

            //if not a corner or an edge
            else begin
              variable_results[distressed_meta_write_counter] = ram[12]; 
              corresponding_harris_bits[distressed_meta_write_counter] = 0;
              stored_pixel = ram[12];
              distressed_meta_write_counter = distressed_meta_write_counter + 1;
            end
          end
        end

        //reset current identifier if needed
        if (pixel_position_or_address <= 1) begin 
          current_identifier = identifier;
          meta_write_counter = 0;
          largest = 0;
          smallest = (2**pixelWidth) - 1;
        end
        
        //increase which value the outwire is getting set to
        if (pixel_position_or_address > current_identifier + (N+1)) begin
          current_identifier = current_identifier + (N*3);
          meta_write_counter = meta_write_counter + 1;
        end

        //reset for new read in cycle
        if (pixel_position_or_address == ((N*N)-1)) begin
          current_identifier = identifier;
          meta_write_counter = 0;
          largest = 0;
          smallest = (2**pixelWidth) - 1;
        end

        largest = 0;
        smallest = (2**pixelWidth) - 1;
      end
    
      //write out current pixel result constantly
      read_out = variable_results[meta_write_counter];
      harris_bit_read_out = corresponding_harris_bits[meta_write_counter];
    end
    
    flip = ~flip;
  end
  
  //Assign the outputs on every clock cycle no matter what
  assign primary_output = read_out;
  assign harris_bit = harris_bit_read_out;
endmodule