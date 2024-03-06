module delay #(
	parameter DELAY = 20
)(
    input sym_clk_en, sam_clk_en, sys_clk, reset,
    input [1:0] sig_in,
	 input [3:0] delay_change,
    output reg [1:0] symb_a
    //output reg [1:0] delay_reg [DELAY_COUNT-1:0]

);
// delay change should be DELAY = 30 and delay_change of 4
// delay change should be DELAY = 20 and delay_change of 9




reg [1:0]  delay[DELAY:0];
integer i;

always @ (posedge sys_clk)
	if(sym_clk_en)
		delay[0] <= sig_in;
	else
		delay[0] <= delay[0];

always @ (posedge sys_clk)
	if(sym_clk_en)
		for (i = 1; i <=DELAY; i=i+1)
			delay[i] <= delay[i-1];
	else
		for (i = 1; i <= DELAY; i = i+1)
			delay[i] <= delay[i];
			

always @ *
    case(delay_change)
    4'd0: symb_a = delay[DELAY-10];
    4'd1: symb_a = delay[DELAY-9];
    4'd2: symb_a = delay[DELAY-8];
    4'd3: symb_a = delay[DELAY-7];
	 4'd4: symb_a = delay[DELAY-6];
	 4'd5: symb_a = delay[DELAY-5];
	 4'd6: symb_a = delay[DELAY-4];
	 4'd7: symb_a = delay[DELAY-3];
	 4'd8: symb_a = delay[DELAY-2];
	 4'd9: symb_a = delay[DELAY-1];
	 4'd10: symb_a = delay[DELAY];
    default: symb_a = delay[DELAY-10];
    endcase


endmodule