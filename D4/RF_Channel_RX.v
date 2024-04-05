module RF_Channel_RX(

    input wire sys_clk, sam_clk_ena, sym_clk_ena, clock_12_5_ena, reset,
    input wire [3:0] delay_chain1, delay_chain2, delay_chain3,
    input wire signed [17:0] sig_in, //1s17
    
    //output wire [1:0] mapper_out,
    output wire signed [17:0] decision_variable,  //1s17
	 output reg signed [17:0] test_point3a, test_point3b

);

wire signed [17:0] hb_decim1_out,hb_decim1_down, hb_decim2_out, hb_decim2_down, y_into_delay, y_into_down_sam;


halfband_filter_decim_poly decim1(
	.clk(sys_clk),
	.reset(reset),
	.sym_clk_en(sym_clk_ena),
	.sam_clk_en(sam_clk_ena),
	.bit_rate_en(clock_12_5_ena),
	.x_in(sig_in),
	.y(hb_decim1_out)
	//.y2(y2)


);

filter_delay #(.DELAY(10)) hb1_decim_delay(
	.sys_clk(sys_clk),
	.reset(reset),
	.sam_clk_en(clock_12_5_ena),
	.sig_in(hb_decim1_out),
	.sig_out(hb_decim1_down),
	.delay_change(delay_chain1)

);
always @ *
	test_point3a = hb_decim1_down;

halfband_filter_decim decim2(
	.clk(sys_clk),
	.reset(reset),
	.sym_clk_en(sym_clk_ena),
	.sam_clk_en(sam_clk_ena),
	.bit_rate_en(clock_12_5_ena),
	.x_in(hb_decim1_down),
	.y(hb_decim2_out)


);


filter_delay #(.DELAY(10)) hb2_decim_delay(
	.sys_clk(sys_clk),
	.reset(reset),
	.sam_clk_en(sam_clk_ena),
	.sig_in(hb_decim2_out),
	.sig_out(hb_decim2_down),
	.delay_change(delay_chain2)

);

always @ *
	test_point3b = hb_decim2_down;

rx_gs_filter filt2(

	.clk(sys_clk),
	.reset(reset),
	.sym_clk_en(sym_clk_ena),
	.sam_clk_en(sam_clk_ena),
	.x_in(hb_decim2_down),
	.y(y_into_delay)
	//.y(decision_variable)
);


filter_delay #(.DELAY(10)) filt_delay(
	.sys_clk(sys_clk),
	.reset(reset),
	.sam_clk_en(sam_clk_ena),
	.sig_in(y_into_delay),
	.sig_out(y_into_down_sam),
	.delay_change(delay_chain3)

);



downsampler downsam(

	.sys_clk(sys_clk),
	.sym_clk_en(sym_clk_ena),
	.sam_clk_en(sam_clk_ena),
	.reset(reset),
	.sig_in(y_into_down_sam),
	.sym_out(decision_variable)

);


endmodule