module adjacent_channel(
    input wire sys_clk, sam_clk_ena, sym_clk_ena, clock_12_5_ena, reset, adj_on_off, gauss_noise_on_off,
    input wire [1:0] gains,
    input [3:0] in_delay_chain, out_delay_chain, NCO_in_delay_chain, NCO_out_delay_chain,
    input wire signed [17:0] sig_in, 
    output wire signed [17:0] sig_out //1s17


);

wire signed[17:0] sig_in_delay;
// another PS filter?

 //halfband interpolator
// halfband_filter_interp interp1(
// 	.clk(sys_clk),
// 	.reset(reset),
// 	.sym_clk_en(sym_clk_ena),
// 	.sam_clk_en(sam_clk_ena),
// 	.bit_rate_en(clock_12_5_ena),
// 	//.x_in(periodic_impulse),
// 	.x_in(tx_out),
// 	.y(hb_interp1_out)


// );

// halfband_filter_interp2 interp2(
// 	.clk(sys_clk),
// 	.reset(reset),
// 	.sym_clk_en(sym_clk_ena),
// 	.sam_clk_en(sam_clk_ena),
// 	.bit_rate_en(clock_12_5_ena),
// 	.x_in(hb_interp1_out),
// 	//.x_in(p_delay),
// 	.y(hb_interp2_out)
// 	//.y2(y2),
// 	//.y1(y1),
// 	//.counter(count)


// );


// NCO in delays
// filter_delay #(.DELAY(10)) NCO_in_delay(
// 	.sys_clk(sys_clk),
// 	.reset(reset),
// 	.sam_clk_en(1'b1),
// 	.sig_in(hb_interp2_out),
// 	.sig_out(hb_interp2_out_delay),
// 	.delay_change(NCO_in_delay_chain)

// );

//NCO_2

// NCO_2 delays


// filter_delay #(.DELAY(10)) NCO_out_delay(
// 	.sys_clk(sys_clk),
// 	.reset(PHYS_SW[0]),
// 	.sam_clk_en(1'b1),
// 	.sig_in(hb_interp2_out),
// 	.sig_out(hb_interp2_out_delay),
// 	.delay_change(NCO_out_delay_chain)

// );


// gains

// gaussian white noise





// summations

// input delay
filter_delay #(.DELAY(10)) in_delay(
	.sys_clk(sys_clk),
	.reset(reset),
	.sam_clk_en(1'b1),
	.sig_in(sig_in),
	.sig_out(sig_in_delay),
	.delay_change(in_delay_chain)

);







// output delay
filter_delay #(.DELAY(10)) out_delay(
	.sys_clk(sys_clk),
	.reset(reset),
	.sam_clk_en(1'b1),
	.sig_in(sig_in_delay),
	.sig_out(sig_out),
	.delay_change(out_delay_chain)

);





endmodule