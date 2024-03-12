module Deliverable_3(
	input load_data, // key3
	input CLOCK_50,
	output wire [21:0] q, LFSR_Counter,
	output wire [1:0] LFSR_2_BITS, slice_out, symb_a,
	output wire sys_clk, sam_clk_ena, sym_clk_ena, sym_correct, sym_error,
	output reg clear_accumulator,
	output wire [3:0] clk_phase,
	output wire signed [17:0] reference_level, decision_variable, mapper_out, error, b, symbol_into_filter, //errorless_decision_variable, error_by_system, // 1s17
	output wire [39:0] mapper_out_power, //4s36
	output wire [37:0] accumulator, absolute_value, acc_counter,

	// accumulated_square_error

	output wire [29:0] accumulated_squared_error, // -4u34

	// accumulated_dc_error
	output wire signed [35:0] acc_dc,
	output wire signed [35:0] accumulated_error, // -1s37
	
	
	// filters
	output wire signed [17:0] tx_out, symbol_into_upsam, y_into_down_sam, y_into_delay,
	output wire [1:0] time_share_counter
	);

wire [31:0] isi_in;
wire [49:0] acc_error;
wire [35:0] sqr_error;


MER isi_probes(
.probe(isi_in),
.source(isi_in)
);




clocks test_clocks(

	.clock_50(CLOCK_50),
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
	.LFSR_2_BITS(LFSR_2_BITS),
	.LFSR_Counter(LFSR_Counter)

);

/************************* CLEAR ACCUMULATOR SIGNAL *******************************/
always @ (posedge sys_clk)
	if(LFSR_Counter == 22'h3fffff)
	//if(q == 22'h0fffff)
		clear_accumulator = 1'b1;
	else
		clear_accumulator = 1'b0;

input_mapper in_map(

	.mapper_in(LFSR_2_BITS),
	.mapper_out(symbol_into_upsam) // decision variable output for now.
);

upsampler upsam(
	.sys_clk(sys_clk),
	.sym_clk_en(sym_clk_ena),
	.sam_clk_en(sam_clk_ena),
	.reset(~load_data),
	.symb_in(symbol_into_upsam),
	.sig_out(symbol_into_filter)

);

//tx_pract_filter2 pract(
//
//	.clk(sys_clk),
//	.reset(~load_data),
//	.sym_clk_en(sym_clk_ena),
//	.sam_clk_en(sam_clk_ena),
//	.x_in(symbol_into_filter),
//	.y(tx_out)
//
//);

tx_gs_filter2 gs(

	.clk(sys_clk),
	.reset(~load_data),
	.sym_clk_en(sym_clk_ena),
	.sam_clk_en(sam_clk_ena),
	.x_in(symbol_into_filter),
	.y(tx_out)

);

rx_gs_filter filt2(

	.clk(sys_clk),
	.reset(~load_data),
	.sym_clk_en(sym_clk_ena),
	.sam_clk_en(sam_clk_ena),
	.x_in(tx_out),
	.y(y_into_delay)
	//.y(decision_variable)
);


//test_timesharing5 filt2(
//
//	.clk(sys_clk),
//	.reset(~load_data),
//	.sym_clk_en(sym_clk_ena),
//	.sam_clk_en(sam_clk_ena),
//	.x_in(tx_out),
//	.y(y_into_delay),
//	.counter(time_share_counter)
//	//.y(decision_variable)
//);


filter_delay #(.DELAY(10)) filt_delay(
	.sys_clk(sys_clk),
	.reset(~load_data),
	.sam_clk_en(sam_clk_ena),
	.sig_in(y_into_delay),
	.sig_out(y_into_down_sam),
	.delay_change(isi_in[3:0])

);

downsampler downsam(

	.sys_clk(sys_clk),
	.sym_clk_en(sym_clk_ena),
	.sam_clk_en(sam_clk_ena),
	.reset(~load_data),
	.sig_in(y_into_down_sam),
	.sym_out(decision_variable)

);

//DUT_for_MER_measurement SUT(
//
//	.clk(sys_clk),
//	.clk_en(sym_clk_ena),
//	.reset(load_data),
//	 //.isi_power(18'sd9268), //20dB
//	// .isi_power(18'sd293), //50 dB
//	//.isi_power(18'sd165), //55dB
//	.isi_power(isi_in),
//	.in_data(symbol_into_filter),
//	.decision_variable(decision_variable),
//	.errorless_decision_variable(errorless_decision_variable),
//	.error(error_by_system)
//
//);




magnitude_estimate mag_est(

	.clk(sys_clk),
	.sym_clk_ena(sym_clk_ena),
	.clear_accumulator(clear_accumulator),
	.decision_variable(decision_variable),
	.reference_level(reference_level),
	.mapper_out_power(mapper_out_power),
	.accumulator(accumulator),
	//.b(b),
	.absolute_value(absolute_value),
	.acc_counter(acc_counter)

);

slicer slice(
	.reference_level(reference_level),
	.decision_variable(decision_variable),
	.slice_out(slice_out)

);

comparator comp(
	.sym_clk_ena(sym_clk_ena),
	.symb_a(symb_a),
	.symb_b(slice_out),
	.sym_correct(sym_correct),
	.sym_error(sym_error),
	.clk(sys_clk)
);


output_mapper out_map(
	.reference_level(reference_level),
	.slice_in(slice_out),
	.mapper_out(mapper_out),
	.b(b)
);

decision_error	dec_err(
	.clk(sys_clk),
	.sym_clk_ena(sym_clk_ena),
	.decision_variable(decision_variable),
	.mapper_out(mapper_out),
	.error(error)
);

average_accumulated_squared_error acc_sq_err(
	.clk(sys_clk),
	.clear_accumulator(clear_accumulator),
	.sym_clk_ena(sym_clk_ena),
	.error(error),
	.acc_error(acc_error),
	.sqr_error(sqr_error),
	.accumulated_squared_error(accumulated_squared_error)
);

accumulated_dc_error acc_dc_error(
	.clk(sys_clk),
	.sym_clk_ena(sym_clk_ena),
	.clear_accumulator(clear_accumulator),
	.error(error),
	.acc(acc_dc),
	.accumulated_error(accumulated_error)
);


delay dl(
	.sym_clk_en(sym_clk_ena),
	.sam_clk_en(sam_clk_ena),
	.sig_in(LFSR_2_BITS),
	.symb_a(symb_a),
	.sys_clk(sys_clk),
	.delay_change(isi_in[7:4])
);




endmodule
