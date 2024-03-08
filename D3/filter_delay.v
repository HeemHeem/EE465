module filter_delay#(
	parameter DELAY = 10
)(
    input wire sys_clk, sam_clk_en, reset,
    input wire signed [17:0] sig_in,
    input wire [3:0] delay_change,
    output reg signed [17:0] sig_out
);

reg signed [17:0] delay[DELAY:0];

integer i;

always @ (posedge sys_clk)
	if(sam_clk_en)
		delay[0] <= sig_in;
	else
		delay[0] <= delay[0];
		
always @ (posedge sys_clk)
	if(sam_clk_en)
		for (i = 1; i <= DELAY; i = i+1)
			delay[i] <= delay[i-1];
	else
		for(i = 1; i <= DELAY; i = i+1)
			delay[i] <= delay[i];

			
always @ *
    case(delay_change)
    4'd0: sig_out = delay[DELAY-10];
    4'd1: sig_out = delay[DELAY-9];
    4'd2: sig_out = delay[DELAY-8];
    4'd3: sig_out = delay[DELAY-7];
	 4'd4: sig_out = delay[DELAY-6];
	 4'd5: sig_out = delay[DELAY-5];
	 4'd6: sig_out = delay[DELAY-4];
	 4'd7: sig_out = delay[DELAY-3];
	 4'd8: sig_out = delay[DELAY-2];
	 4'd9: sig_out = delay[DELAY-1];
	 4'd10: sig_out = delay[DELAY];
    default: sig_out = delay[DELAY-10];
    endcase








endmodule