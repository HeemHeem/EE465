module LFSR(
	input wire clk,
	input wire sam_clk_ena,
	input wire load_data,
	output reg [21:0] q,
	output reg [1:0] LFSR_2_BITS,
	output reg [21:0] LFSR_Counter

);
wire [21:0] data;
reg d0;
//(* noprune *) reg [21:0] counter;

	
assign data = 22'h0fffff;

// shift register
always @ (posedge clk)
	if(~load_data)
		q <= data;
	
	else
		q <= {q[20:0], d0};

// feedback network
always @ *
	d0 = q[21]^((q[18]^(q[17]^q[16]))); // maximum value when qx = q4
	
// counter
always @ (posedge clk)

	if (~load_data || q == data)
		LFSR_Counter <= 22'd1;
	
	else
		LFSR_Counter <= LFSR_Counter + 22'd1;

always @ (posedge clk)
	if(sam_clk_ena)
		LFSR_2_BITS <= q[1:0];
	else
		LFSR_2_BITS <= LFSR_2_BITS;






	






endmodule
