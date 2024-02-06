module LFSR(
	input wire clk,
	input wire load_data,
	output reg [15:0] q

);
reg [15:0] data;
reg d0;
(* noprune *) reg [15:0] counter;

	
assign data = 16'hffff;

// shift register
always @ (posedge clk)
	if(~load_data)
		q <= data;
	
	else
		q <= {q[14:0], d0};

// feedback network
always @ *
	d0 <= q[1]^((q[2]^(q[15]^q[4]))); // maximum value when qx = q4
	
// counter
always @ (posedge clk)
	if (q == 16'hffff)
		counter <= 16'h0001;
	
	else
		counter <= counter + 16'd1;


	






endmodule
