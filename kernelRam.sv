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
  reg [pixelWidth-1:0] ram0;
  reg [pixelWidth-1:0] ram1;
  reg [pixelWidth-1:0] ram2;
  reg [pixelWidth-1:0] ram3;
  reg [pixelWidth-1:0] ram4;
  reg [pixelWidth-1:0] ram5;
  reg [pixelWidth-1:0] ram6;
  reg [pixelWidth-1:0] ram7;
  reg [pixelWidth-1:0] ram8;

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
  end

  //use this ff chain to run Moravec's algorithm

  //1
  MoravecFF F11(.clk(clk),
            .start(detectCorner),
            .inCenter(ram4),
            .inTarget(ram3),
            .inE(E1),
            .Q(Q11),
            .Eout(Eout11)
            );

  MoravecFF F21(.clk(clk),
            .start(Q11),
            .inCenter(ram4),
            .inTarget(ram0),
            .inE(Eout11),
            .Q(Q21),
            .Eout(Eout21)
            );

  MoravecFF F31(.clk(clk),
            .start(Q21),
            .inCenter(ram4),
            .inTarget(ram1),
            .inE(Eout21),
            .Q(Q31),
            .Eout(Eout31)
            );

  MoravecFF F41(.clk(clk),
            .start(Q31),
            .inCenter(ram4),
            .inTarget(ram2),
            .inE(Eout31),
            .Q(Q41),
            .Eout(Eout41)
            );

  //2
  MoravecFF F12(.clk(clk),
            .start(detectCorner),
            .inCenter(ram4),
            .inTarget(ram1),
            .inE(E2),
            .Q(Q12),
            .Eout(Eout12)
            );

  MoravecFF F22(.clk(clk),
            .start(Q12),
            .inCenter(ram4),
            .inTarget(ram2),
            .inE(Eout12),
            .Q(Q22),
            .Eout(Eout22)
            );

  MoravecFF F32(.clk(clk),
            .start(Q22),
            .inCenter(ram4),
            .inTarget(ram5),
            .inE(Eout22),
            .Q(Q32),
            .Eout(Eout32)
            );

  MoravecFF F42(.clk(clk),
            .start(Q32),
            .inCenter(ram4),
            .inTarget(ram8),
            .inE(Eout32),
            .Q(Q42),
            .Eout(Eout42)
            );

  //3
  MoravecFF F13(.clk(clk),
            .start(detectCorner),
            .inCenter(ram4),
            .inTarget(ram5),
            .inE(E3),
            .Q(Q13),
            .Eout(Eout13)
            );

  MoravecFF F23(.clk(clk),
            .start(Q13),
            .inCenter(ram4),
            .inTarget(ram8),
            .inE(Eout13),
            .Q(Q23),
            .Eout(Eout23)
            );

  MoravecFF F33(.clk(clk),
            .start(Q23),
            .inCenter(ram4),
            .inTarget(ram7),
            .inE(Eout23),
            .Q(Q33),
            .Eout(Eout33)
            );

  MoravecFF F43(.clk(clk),
            .start(Q33),
            .inCenter(ram4),
            .inTarget(ram6),
            .inE(Eout33),
            .Q(Q43),
            .Eout(Eout43)
            );

  //4
  MoravecFF F14(.clk(clk),
            .start(detectCorner),
            .inCenter(ram4),
            .inTarget(ram7),
            .inE(E4),
            .Q(Q14),
            .Eout(Eout14)
            );

  MoravecFF F24(.clk(clk),
            .start(Q14),
            .inCenter(ram4),
            .inTarget(ram6),
            .inE(Eout14),
            .Q(Q24),
            .Eout(Eout24)
            );

  MoravecFF F34(.clk(clk),
            .start(Q24),
            .inCenter(ram4),
            .inTarget(ram3),
            .inE(Eout24),
            .Q(Q34),
            .Eout(Eout34)
            );

  MoravecFF F44(.clk(clk),
            .start(Q34),
            .inCenter(ram4),
            .inTarget(ram0),
            .inE(Eout34),
            .Q(Q44),
            .Eout(Eout44)
            );
  
  //on each cycle write if enabled
  always @(posedge clk) begin
    if (flip) begin
      if (we) begin

        if (pixel_position_or_address == current_identifier) begin
          ram4 = data_in;
          write_counter = write_counter + 1;
          largest = data_in >= largest ? data_in : largest;
          smallest = data_in <= smallest ? data_in : smallest;
        end
        else if (pixel_position_or_address == (current_identifier - 1)) begin
          ram3 = data_in;
          write_counter = write_counter + 1;
          largest = data_in >= largest ? data_in : largest;
          smallest = data_in <= smallest ? data_in : smallest;
        end
        else if (pixel_position_or_address == (current_identifier + 1)) begin
          ram5 = data_in; 
          write_counter = write_counter + 1;
          largest = data_in >= largest ? data_in : largest;
          smallest = data_in <= smallest ? data_in : smallest;
        end
        else if (pixel_position_or_address == (current_identifier + (N-1))) begin
          ram6 = data_in;
          write_counter = write_counter + 1;
        end
        else if (pixel_position_or_address == (current_identifier - (N-1))) begin
          ram2 = data_in;
          write_counter = write_counter + 1;
        end
        else if (pixel_position_or_address == (current_identifier + (N))) begin
          ram7 = data_in;
          write_counter = write_counter + 1;
          largest = data_in >= largest ? data_in : largest;
          smallest = data_in <= smallest ? data_in : smallest;
        end
        else if (pixel_position_or_address == (current_identifier - (N))) begin
          ram1 = data_in;
          write_counter = write_counter + 1;
          largest = data_in >= largest ? data_in : largest;
          smallest = data_in <= smallest ? data_in : smallest;
        end
        else if (pixel_position_or_address == (current_identifier + (N+1))) begin
          ram8 = data_in;
          write_counter = write_counter + 1;
        end
        else if (pixel_position_or_address == (current_identifier - (N+1))) begin
          ram0 = data_in;
          write_counter = write_counter + 1;
        end

        //let the moravec operator start before we have the last pixel
        if (pixel_position_or_address > current_identifier + (N)) begin
            //set the bit for the start of the ff chains
            detectCorner = 1'b1;
        end
        
        //check if we should compute out value yet
        //FIXME: REGISTER OF 54 CANNOT BE SET BECAUSE PIXEL VALUE 63 FORCES IT TO ASSUME 0
        if (pixel_position_or_address > current_identifier + (N + 1 + 4) || pixel_position_or_address == ((N*N)-1)) begin
          
          //check if the pixel is a border
          if ((largest - smallest) >= 1 && ram4 != 0) begin

            //if we determine it's a border, check to see if it's a corner
            if (Eout41 > 0 || Eout42 > 0 || Eout43 > 0 || Eout44 > 0) begin
              variable_results[meta_write_counter] = ram4; 
              corresponding_harris_bits[meta_write_counter] = 1;
              stored_pixel = ram4;
              meta_write_counter = meta_write_counter + 1;
            end
            else begin
              variable_results[meta_write_counter] = 0; 
              corresponding_harris_bits[meta_write_counter] = 0;
              stored_pixel = 0;
              meta_write_counter = meta_write_counter + 1;
            end
          end
          else begin
            variable_results[meta_write_counter] = ram4; 
            corresponding_harris_bits[meta_write_counter] = 0;
            stored_pixel = ram4;
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