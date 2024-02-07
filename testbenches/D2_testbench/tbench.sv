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
  // reset = 0;
  // #(RESET_DELAY);
  reset = 1;
  #(RESET_LENGTH);
  reset = 0;
end

initial begin

load_data = 0;
#20  load_data = 1; 

end

clocks test_clocks(

    .clock_50(clk),
    .sys_clk(sys_clk),
    .sam_clk_ena(sam_clk_ena),
    .sym_clk_ena(sym_clk_ena),
    .clk_phase(clk_phase)
);


LFSR lfsr(
    .clk(sys_clk),
    .sam_clk_ena(sam_clk_ena),
    .load_data(load_data),
    .q(q),
    .LFSR_2_BITS(lfsr_2_bits)
);


endmodule