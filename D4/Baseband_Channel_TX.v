module Baseband_Channel_TX(

    input wire sys_clk, sam_clk_ena, sym_clk_ena, clock_12_5_ena, reset, impulse_on_off,
    input wire [3:0] delay_chain,
    input [1:0] mapper_in,

	input wire signed [17:0] impulse_in,
    output wire signed [17:0] sig_out 

);


wire signed [17:0] symbol_into_upsam, symbol_into_filter, tx_out, hb_interp1_out, hb_interp2_out;
reg signed [17:0] sym2filter;

input_mapper in_map(

	.mapper_in(mapper_in),
	.mapper_out(symbol_into_upsam) // decision variable output for now.
);

upsampler upsam(
	.sys_clk(sys_clk),
	.sym_clk_en(sym_clk_ena),
	.sam_clk_en(sam_clk_ena),
	.reset(reset),
	.symb_in(symbol_into_upsam),
	.sig_out(symbol_into_filter)

);


always @ *
	if(impulse_on_off)
		sym2filter = impulse_in;
	else
		sym2filter = symbol_into_filter;

tx_pract_filter2 pract(

	.clk(sys_clk),
	.reset(reset),
	.sym_clk_en(sym_clk_ena),
	.sam_clk_en(sam_clk_ena),
	.x_in(sym2filter),
	.y(tx_out)

);

 //halfband interpolator
halfband_filter_interp interp1(
	.clk(sys_clk),
	.reset(reset),
	.sym_clk_en(sym_clk_ena),
	.sam_clk_en(sam_clk_ena),
	.bit_rate_en(clock_12_5_ena),
	//.x_in(periodic_impulse),
	.x_in(tx_out),
	.y(hb_interp1_out)


);

halfband_filter_interp2 interp2(
	.clk(sys_clk),
	.reset(reset),
	.sym_clk_en(sym_clk_ena),
	.sam_clk_en(sam_clk_ena),
	.bit_rate_en(clock_12_5_ena),
	.x_in(hb_interp1_out),
	.y(hb_interp2_out)


);

filter_delay #(.DELAY(10)) hb1_interp_delay(
	.sys_clk(sys_clk),
	.reset(reset),
	.sam_clk_en(1'b1),
	.sig_in(hb_interp2_out),
	.sig_out(sig_out),
	.delay_change(delay_chain)

);


endmodule