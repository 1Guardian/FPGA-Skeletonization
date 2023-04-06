//***********************************************************
// module: mainController
//
// description: The mainController is a wrapper simply for me
//				and not really for the modules themselves. It
//				controls all creation of the modules as they
//				are children of it, and routes all inputs
// 				and outputs
//***********************************************************
module mainController #(parameter N=8, bitSize=6) (clk, we, data_in);
  input clk;
  input we;
  input [7:0] data_in;
  
  //make wires to connect inputs to ram block
  wire memoryBlock__clk;
  wire memoryBlock_we;
  wire [7:0] memoryBlock_in;
  wire [bitSize:0] memoryBlock_addr_in_0;
  wire [bitSize:0] memoryBlock_addr_in_1;
  wire [7:0] memoryBlock_out_0; //output
  wire [7:0] memoryBlock_out_1; //output
  
  //wires for communication between ram and the masks
  //controller/representative
  wire [bitSize:0] requesting_address;
  wire [7:0] received_data;
  
  //global write element
  wire global_we;
  wire element_we;
  //assign element_we = we;
  assign global_we = we | element_we;
  wire [7:0] element_writeout_data;
  
  //wire output for the write controller and counter
  wire [bitSize:0] counter_output;
  wire [7:0] write_controller_output;
  
  //make wires to connect to processingElement
  wire processingElement_clk;
  wire processingElement_we;
  wire processingElement_re;
  wire [7:0] processingElement_in;
  wire [bitSize:0] processingElement_in_0;
  wire [7:0] processingElement_out_0;
  
  //assign the wires to the inputs
  assign memoryBlock__clk = clk;
  assign memoryBlock_we = we;
  assign memoryBlock_in = data_in;
  
  //declare a segment of Memory for storing the image
  v_rams_09 #(.N(N), .bitSize(bitSize)) memoryBlock (
    .clk(clk), 
    .we(global_we), 
    .data_in(write_controller_output), 
    .primary_address(counter_output), 
    .dual_read_address(requesting_address), 
    .primary_output(memoryBlock_out_0), 
    .dual_output(received_data)
  );
  
  //declare a counter to use for addressing
  counter #(.N(N), .bitSize(bitSize)) address_counter (
    .clk(clk), 
    .inc(global_we), 
    .current_count(counter_output)
  );
  
  //declare a write controller to use
  writeController #(.N(N), .bitSize(bitSize)) write_controller (
    .clk(clk), 
    .we(we), 
    .we_two(element_we),
    .data_0(data_in),
    .data_1(element_writeout_data),
    .res(write_controller_output)
  );
  
  //declare the center mask to act on behalf
  //of the mask set
  centerMask #(.N(N), .bitSize(bitSize)) central_Mask (
    .clk(clk), 
    .we(~global_we), 
    .re(~global_we),
    .data_in(received_data),
    .write_out_enable(element_we),
    .primary_address(requesting_address),
    .primary_output(element_writeout_data)
  );

endmodule