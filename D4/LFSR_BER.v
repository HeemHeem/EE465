module LFSR_BER (
	input wire clk,
	input wire sam_clk_ena,
	input wire d0,
	input wire load_data,
	output reg [21:0] q,
	output reg [1:0] I_sym, Q_sym,
	output reg [21:0] LFSR_Counter,
	output reg feedback

);
wire [21:0] data;
// reg d0;
//(* noprune *) reg [21:0] counter;

	
assign data = 22'h3fffff;

// shift register
always @ (posedge clk)
	if(load_data)
		q <= data;
	
	else if (sam_clk_ena)
		q <= {q[20:0], d0};
	else
		q <= q;

// feedback network
always @ *
	feedback = q[21]^q[20];//q[21]^((q[18]^(q[17]^q[16]))); // maximum value when qx = q4
	
// counter
always @ (posedge clk)

	if (load_data || q == data)
		LFSR_Counter <= 22'd1;
	
	else if(sam_clk_ena)
		LFSR_Counter <= LFSR_Counter + 22'd1;
	else
		LFSR_Counter <= LFSR_Counter;

always @ (posedge clk)
	if(sam_clk_ena)
		I_sym <= q[1:0];
	else
		I_sym <= I_sym;

always @ (posedge clk)
	if(sam_clk_ena)
		Q_sym <= q[3:2];
	else
		Q_sym <= Q_sym;




	






endmodule
