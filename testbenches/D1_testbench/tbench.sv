module tbench();

// Example testbench provided to EE 465 class for the following purposes:
// - to provide a basic template to help the students get started writing testbenches
// - to illustrate the correct and incorrect way to generate input stimulus signals
// - to provide an example of file IO in verilog

reg clk;
reg reset;
int count;

reg signed [17:0] x_in, y;
// wire c;

localparam PERIOD = 21;
localparam RESET_DELAY = 2;
localparam RESET_LENGTH = 42;


// Clock generation (OK to use hardcoded delays #)
initial
begin
  clk = 0;
  x_in = 18'sd0;
  count = 0;
  forever
    begin 
      #(PERIOD/2);
      clk = ~clk;
    end
end

// Reset generation (OK to use hardcoded delays #)
initial 
begin
  reset = 0;
  #(RESET_DELAY);
  reset = 1;
  #(RESET_LENGTH);
  reset = 0;
end 

// Generate input stimulus signals - correct method
// - stimulus signals should be generated inside always blocks
//   which are triggered off of the clock

// always @(posedge clk)
//   if(reset)
//     begin
// 	  a <= 1'b0;
// 	  //b <= 1'b0;
// 	end
//   else
//     begin
// 	  a <= ~a;
// 	  //b <= ~b;
// 	end
	
	
// Generate input stimulus signals - incorrect method
// - stimulus signals should not be generated inside initial blocks
//   with hardcoded delays (#)
// DON'T DO THIS!

// initial 
// begin
//   b = 0;
//   #(PERIOD/2);
//   forever
//     begin 
// 	  #(PERIOD);	
// 	  b = ~b;
//     end
// end

//  Example of reading data into the simulation from a text file
//  - could connect into DUT to test various scenarios

integer file_in;

initial
begin
  // file_in = $fopen("impulse_lut.txt", "r");
  file_in = $fopen("impulse_input.txt", "r");
  // file_in = $fopen("impulse_3_zero.txt", "r");

end

always @ (posedge clk)
  if (reset)
    x_in <= 18'sd0;
  else
    begin

    if(count + 1 == 21)
    begin
        $fseek(file_in, 0,0); // restart file reading position
        $fscanf(file_in, "%d\n", x_in);
    end
    else
        $fscanf(file_in, "%d\n", x_in);
    end
   
always @ (posedge clk)
  if(reset)
    count <= 0;
  else if (count == 20)
    count <= 0;
  else
    count++;

// Instantiate device under test (DUT)
// tx_filter_with_mult test_inst (
//   // clocks and resets
//   .clk(clk),
//   .reset(reset),
  
//   // inputs
//   .x_in(x_in),
  
//   //outputs
//   .y(y)

// );

// tx_filter_with_luts test_inst (
//   // clocks and resets
//   .clk(clk),
//   .reset(reset),
  
//   // inputs
//   .x_in(x_in),
  
//   //outputs
//   .y(y)

// );


rx_filter_with_mult test_inst (
  // clocks and resets
  .clk(clk),
  .reset(reset),
  
  // inputs
  .x_in(x_in),
  
  //outputs
  .y(y)

);



endmodule: tbench