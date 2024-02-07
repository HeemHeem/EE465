module LFSR(
	input wire clk,
	input wire load_data,
	output reg [21:0] q

);
reg [21:0] data;
reg d0;
(* noprune *) reg [21:0] counter;

	
assign data = 22'h3ffff;

// shift register
always @ (posedge clk)
	if(~load_data)
		q <= data;
	
	else
		q <= {q[20:0], d0};

// feedback network
always @ *
	d0 <= q[21]^((q[18]^(q[17]^q[16]))); // maximum value when qx = q4
	
// counter
always @ (posedge clk)
	if (q == 22'h3fffff)
		counter <= 22'h0001;
	
	else
		counter <= counter + 22'd1;


	






endmodule
