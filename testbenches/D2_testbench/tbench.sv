module tbench();

// Example testbench provided to EE 465 class for the following purposes:
// - to provide a basic template to help the students get started writing testbenches
// - to illustrate the correct and incorrect way to generate input stimulus signals
// - to provide an example of file IO in verilog

reg clk;
reg reset;
int count;

reg signed [17:0] x_in, y, y_inter;

reg sys_clk, sam_clk_ena, sym_clk_ena, load_data;
reg [21:0] q;
reg [2:1] lfsr_2_bits;
reg [3:0] clk_phase;
reg [1:0] counter;
int i;
// wire c;

localparam PERIOD = 21;
localparam RESET_DELAY = 2;
localparam RESET_LENGTH = 500;


// Clock generation (OK to use hardcoded delays #)
initial
begin
  i = 0;
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
  // reset = 0;
  // #(RESET_DELAY);
  reset = 1;
  #(RESET_LENGTH);
  reset = 0;
end

// initial begin

// load_data = 0;
// #20  load_data = 1; 

// end

integer file_in;

// initial
// begin
//   file_in = $fopen("impulse_input.txt", "r");
//   // file_in = $fopen("impulse_input.txt", "r");
//   // file_in = $fopen("impulse_3_zero.txt", "r");
// // #5000 x_in = 18'sd131071; 
// // #1  x_in = 18'sd0;
// end

// always @ (posedge clk)
//   if (reset)
//     x_in <= 18'sd0;
//   else if (sym_clk_ena)
//     if(count + 1 == 7)
//     begin
//         $fseek(file_in, 0,0); // restart file reading position
//         $fscanf(file_in, "%d\n", x_in);
//     end
//     else
//         $fscanf(file_in, "%d\n", x_in);

// always @ (posedge sym_clk_ena or posedge reset)
//   if(reset)
//         x_in <= 18'sd0;
//   else if (sym_clk_ena)
//     if(count + 1 == 7)
//     begin
//         $fseek(file_in, 0,0); // restart file reading position
//         $fscanf(file_in, "%d\n", x_in);
//     end
//     else
//         $fscanf(file_in, "%d\n", x_in);


always @ (posedge sam_clk_ena or posedge reset)
  if(reset)
    i = 0;
  else if(i == 1000)
    i = 0;
  else
    i++;

always @ (posedge sam_clk_ena)
  // if(i > 100 && i < 150)
  if(i == 200)
    // x_in <= 18'sd131071;
    x_in <= 18'sd98304;
    // x_in <= 18'sd1;
  else
    x_in <= 18'sd0;

always @ (posedge sym_clk_ena or posedge reset)
  if(reset)
    count <= 0;
  else if (count == 6 && sym_clk_ena)
    count <= 0;
  else if (sym_clk_ena)
    count++;
  else
    count <= count;





clocks test_clocks(

    .clock_50(clk),
    .sys_clk(sys_clk),
    .sam_clk_ena(sam_clk_ena),
    .sym_clk_ena(sym_clk_ena),
    .clk_phase(clk_phase)
);



tx_pract_filter2 tx(
  .clk(sys_clk),
  .sam_clk_en(sam_clk_ena),
  .sym_clk_en(sym_clk_ena),
  .x_in(x_in),
  .y(y_inter),
  // .counter(counter),
  .reset(reset)
);


// test_timesharing3 SUT(
//   .clk(sys_clk),
//   .sam_clk_en(sam_clk_ena),
//   .sym_clk_en(sym_clk_ena),
//   .x_in(x_in),
//   .y(y),
//   .counter(counter),
//   .reset(reset)
// );


test_timesharing6 SUT(
  .clk(sys_clk),
  .sam_clk_en(sam_clk_ena),
  .sym_clk_en(sym_clk_ena),
  .x_in(y_inter),
  .y(y),
  // .counter(counter),
  .reset(reset)
);


// upsampler up_samp(
//   .sys_clk(sys_clk),
//   .sym_clk_en(sym_clk_ena),
//   .sam_clk_en(sam_clk_ena),
//   .symb_in(x_in),
//   .sig_out(y_inter),
//   .reset(reset)
// );

// downsampler downsamp(
//   .sys_clk(sys_clk),
//   .sym_clk_en(sym_clk_ena),
//   .sig_in(y_inter),
//   .sym_out(y),
//   .reset(reset)
// );

// LFSR lfsr(
//     .clk(sys_clk),
//     .sam_clk_ena(sam_clk_ena),
//     .load_data(load_data),
//     .q(q),
//     .LFSR_2_BITS(lfsr_2_bits)
// );


endmodule