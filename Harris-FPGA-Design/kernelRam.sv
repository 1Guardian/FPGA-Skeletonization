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
module kernelRam #(parameter N=8, bitSize=6, pixelWidth = 8, identifier=1, thresh=5000) (clk, we, pixel_position_or_address, data_in, primary_output, harris_bit);
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
  reg [7:0] stored;
  reg signed [32:0] R;
  reg signed [79:0] check;
  reg signed [79:0] check_two;
  reg signed [79:0] storage;
  reg signed [79:0] storage_two;
  reg signed [39:0] storage_three;
  reg signed [39:0] storage_two_final;
  reg signed [39:0] storage_final;

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

  //output of sobels module
  wire signed [39:0] sobelIx0;
  wire signed [39:0] sobelIx1;
  wire signed [39:0] sobelIx2;
  wire signed [39:0] sobelIx3;
  wire signed [39:0] sobelIx4;
  wire signed [39:0] sobelIx5;
  wire signed [39:0] sobelIx6;
  wire signed [39:0] sobelIx7;
  wire signed [39:0] sobelIx8;
  wire signed [39:0] sobelIy0;
  wire signed [39:0] sobelIy1;
  wire signed [39:0] sobelIy2;
  wire signed [39:0] sobelIy3;
  wire signed [39:0] sobelIy4;
  wire signed [39:0] sobelIy5;
  wire signed [39:0] sobelIy6;
  wire signed [39:0] sobelIy7;
  wire signed [39:0] sobelIy8;
  wire signed [39:0] sobelIxy0;
  wire signed [39:0] sobelIxy1;
  wire signed [39:0] sobelIxy2;
  wire signed [39:0] sobelIxy3;
  wire signed [39:0] sobelIxy4;
  wire signed [39:0] sobelIxy5;
  wire signed [39:0] sobelIxy6;
  wire signed [39:0] sobelIxy7;
  wire signed [39:0] sobelIxy8;

  //registers to store Ixx, Iyy, and Ixy
  wire signed [39:0] Ixx;
  wire signed [39:0] Iyy;
  wire signed [39:0] Ixy;
  reg signed [39:0] point_zero_seven;

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
    convolutionCounter = 0;
    latch = 1;
    distressed_current_identifier = 0;
    distressed_largest = 0;
    distressed_smallest = 0;
    distressed_meta_write_counter = 0;
    currentWrite = 0;
    ram[24] = 0;
    point_zero_seven = 40'b0000000000000000000000_00010001111010111;
  end

  //define harris modules needed
  Sobels sobelOperator (
  .clk(clk),
  .start(detectCorner),
  .inputPixels0(ram[0]),
  .inputPixels1(ram[1]),
  .inputPixels2(ram[2]),
  .inputPixels3(ram[3]),
  .inputPixels4(ram[4]),
  .inputPixels5(ram[5]),
  .inputPixels6(ram[6]),
  .inputPixels7(ram[7]),
  .inputPixels8(ram[8]),
  .inputPixels9(ram[9]),
  .inputPixels10(ram[10]),
  .inputPixels11(ram[11]),
  .inputPixels12(ram[12]),
  .inputPixels13(ram[13]),
  .inputPixels14(ram[14]),
  .inputPixels15(ram[15]),
  .inputPixels16(ram[16]),
  .inputPixels17(ram[17]),
  .inputPixels18(ram[18]),
  .inputPixels19(ram[19]),
  .inputPixels20(ram[20]),
  .inputPixels21(ram[21]),
  .inputPixels22(ram[22]),
  .inputPixels23(ram[23]),
  .inputPixels24(ram[24]),
  .Q(Q11),
  .OIx0(sobelIx0),
  .OIx1(sobelIx1),
  .OIx2(sobelIx2),
  .OIx3(sobelIx3),  
  .OIx4(sobelIx4),
  .OIx5(sobelIx5),
  .OIx6(sobelIx6),
  .OIx7(sobelIx7),
  .OIx8(sobelIx8),
  .OIy0(sobelIy0), 
  .OIy1(sobelIy1), 
  .OIy2(sobelIy2), 
  .OIy3(sobelIy3), 
  .OIy4(sobelIy4), 
  .OIy5(sobelIy5), 
  .OIy6(sobelIy6), 
  .OIy7(sobelIy7), 
  .OIy8(sobelIy8),
  .OIxy0(sobelIxy0), 
  .OIxy1(sobelIxy1), 
  .OIxy2(sobelIxy2), 
  .OIxy3(sobelIxy3), 
  .OIxy4(sobelIxy4), 
  .OIxy5(sobelIxy5), 
  .OIxy6(sobelIxy6), 
  .OIxy7(sobelIxy7), 
  .OIxy8(sobelIxy8)  
  );
  
  //Ixx Gaussian applier
  Gaussian xguassianOperator(
  .clk(clk),
  .start(Q11),
  .Ix0(sobelIx0),
  .Ix1(sobelIx1),
  .Ix2(sobelIx2),
  .Ix3(sobelIx3),
  .Ix4(sobelIx4),
  .Ix5(sobelIx5),
  .Ix6(sobelIx6),
  .Ix7(sobelIx7),
  .Ix8(sobelIx8),
  .finalValue(Ixx)
  );

  //Iyy Gaussian applier
  Gaussian yguassianOperator(
  .clk(clk),
  .start(Q11),
  .Ix0(sobelIy0),
  .Ix1(sobelIy1),
  .Ix2(sobelIy2),
  .Ix3(sobelIy3),
  .Ix4(sobelIy4),
  .Ix5(sobelIy5),
  .Ix6(sobelIy6),
  .Ix7(sobelIy7),
  .Ix8(sobelIy8),
  .finalValue(Iyy)
  );

  //Ixy Gaussian applier
  Gaussian xyguassianOperator(
  .clk(clk),
  .start(Q11),
  .Ix0(sobelIxy0),
  .Ix1(sobelIxy1),
  .Ix2(sobelIxy2),
  .Ix3(sobelIxy3),
  .Ix4(sobelIxy4),
  .Ix5(sobelIxy5),
  .Ix6(sobelIxy6),
  .Ix7(sobelIxy7),
  .Ix8(sobelIxy8),
  .finalValue(Ixy)
  );
  
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
        if ((pixel_position_or_address == (current_identifier - (N + N + 2)))) begin 
          ram[0] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier - (N + N + 1))) begin 
          ram[1] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier - (N + N + 0))) begin 
          ram[2] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end 
        if (pixel_position_or_address == (current_identifier - (N + N - 1))) begin 
          ram[3] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier - (N + N - 2))) begin 
          ram[4] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier - (N + 2)))  begin 
          ram[5] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end 
        if (pixel_position_or_address == (current_identifier - (N + 1))) begin 
          ram[6] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end 
        if (pixel_position_or_address == (current_identifier - (N + 0))) begin 
          ram[7] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier - (N - 1))) begin 
          ram[8] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier - (N - 2))) begin 
          ram[9] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier - (2))) begin 
          ram[10] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end 
        if (pixel_position_or_address == (current_identifier - (1))) begin 
          ram[11] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier - (0))) begin 
          ram[12] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier + 1))  begin 
          ram[13] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier + 2)) begin 
          ram[14] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end 
        if (pixel_position_or_address == (current_identifier + (N - 2))) begin 
          ram[15] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier + (N - 1))) begin 
          ram[16] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier + (N - 0))) begin 
          ram[17] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier + (N + 1))) begin 
          ram[18] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier + (N + 2))) begin 
          ram[19] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end 
        if (pixel_position_or_address == (current_identifier + (N + N - 2))) begin 
          ram[20] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end 
        if (pixel_position_or_address == (current_identifier + (N + N - 1))) begin 
          ram[21] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end 
        if (pixel_position_or_address == (current_identifier + (N + N))) begin 
          ram[22] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier + (N + N + 1))) begin 
          ram[23] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
        end
        if (pixel_position_or_address == (current_identifier + (N + N + 2))) begin
          ram[24] = data_in;
          stored = data_in;
          write_counter = write_counter + 1;
          currentWrite = currentWrite + 1;
        end

        if ((pixel_position_or_address == (current_identifier - (1))) ||
        (pixel_position_or_address == (current_identifier - (0))) ||
        (pixel_position_or_address == (current_identifier + 1))  ||
        (pixel_position_or_address == (current_identifier - (N + 0))) ||
        (pixel_position_or_address == (current_identifier + (N + 0)))) begin
          largest = data_in >= largest ? data_in : largest;
          smallest = data_in <= smallest ? data_in : smallest;
        end

        //only let harris start when we have all pixels
        if (pixel_position_or_address > current_identifier + (N + N + 2)) begin
            //set the bit for the start of the ff chains
            detectCorner = 1'b1;
            currentWrite = 0;
        end
        
        //check if we should compute out value yet
        //FIXME: REGISTER OF 54 CANNOT BE SET BECAUSE PIXEL VALUE 63 FORCES IT TO ASSUME 0
        if (pixel_position_or_address > current_identifier + (N + N + 2 + 2) || pixel_position_or_address == ((N*N)-1)) begin
          
          //check if the pixel is a border/corner
          if ((largest - smallest) >= 1 && ram[12] != 0) begin

            //if we determine it's a border, check to see if it's a corner
            storage = (((Ixx << 14) * (Iyy << 14)) - ((Ixy << 14) * (Ixy << 14))); //80 bits
            storage_two = (((Ixx << 14) + (Iyy << 14))  * ((Ixx << 14) + (Iyy << 14))); //80 bits
            storage_three = storage_two[56:16]; // back to 40 bits
            storage_three = (storage_three << 1);
            storage_two = point_zero_seven * storage_three; //80 bits
            storage = (storage << 2);
            storage_final = storage[69:30]; // back to 40 bits
            storage_two_final = storage_two[69:30]; // back to 40 bits
            storage_three = storage_final - storage_two_final;

            //R = ((Ixx * Iyy) - (Ixy * Ixy)) - (0.07*((Ixx + Iyy)  * (Ixx + Iyy)));
            R = storage_final - storage_two_final;
            if (R > thresh) begin
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
          current_identifier = current_identifier + (N*5);
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
        if (current_identifier > 42 && current_identifier < 46) begin
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
              storage = (((Ixx << 14) * (Iyy << 14)) - ((Ixy << 14) * (Ixy << 14))); //80 bits
              storage_two = (((Ixx << 14) + (Iyy << 14))  * ((Ixx << 14) + (Iyy << 14))); //80 bits
              storage_three = storage_two[56:16]; // back to 40 bits
              storage_three = (storage_three << 1);
              storage_two = point_zero_seven * storage_three; //80 bits
              storage = (storage << 2);
              storage_final = storage[69:30]; // back to 40 bits
              storage_two_final = storage_two[69:30]; // back to 40 bits
              storage_three = storage_final - storage_two_final;

              //R = ((Ixx * Iyy) - (Ixy * Ixy)) - (0.07*((Ixx + Iyy)  * (Ixx + Iyy)));
              R = storage_final - storage_two_final;
              if (R > thresh) begin
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
        if (pixel_position_or_address > current_identifier + (N+N+2)) begin
          current_identifier = current_identifier + (N*5);
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