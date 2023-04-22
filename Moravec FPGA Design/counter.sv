//***********************************************************
// module: counter
//
// description: The counter module is a simple counter. It
//				counts up to whatever N*N is and resets.
//***********************************************************
module counter #(parameter N=8, bitSize=6) (clk, inc, current_count);
  input clk;
  input inc;
  output [bitSize:0] current_count;
  reg flip;
  
  //register to store address
  reg [bitSize:0] address;
  
  //set reg to 0
  initial begin
    address <= 0;
    flip <= 1;
  end
  
  //on positive clock with write enabled, increase address
  always @(posedge clk) begin
    
    if (flip) begin
    
      if (inc) begin
          address = address + 1;
      end

      else begin
        address = 0;
      end

      if (address == (N*N))
        address = 0;
    end
    
    flip = ~flip;
    
  end
  
  //output cycles continuously
  assign current_count = address;
  
endmodule