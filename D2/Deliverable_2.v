module Deliverable_2(
	input load_data,
	input CLOCK_50,
	output wire [21:0] q, LFSR_Counter,
	output wire [1:0] LFSR_2_BITS, slice_out,
	output wire sys_clk, sam_clk_ena, sym_clk_ena, sym_correct, sym_error,
	output reg clear_accumulator,
	output wire [3:0] clk_phase,
	output wire [17:0] reference_level, decision_variable, mapper_out, error, b,
	output wire [39:0] mapper_out_power,
	output wire [37:0] accumulator, absolute_value, acc_counter,

	// accumulated_square_error
	output wire [49:0] acc_error,
	output wire [35:0] sqr_error,
	output wire [29:0] acc_sqr_error,

	// accumulated_dc_error
	output wire [35:0] acc_dc, acc_error_out_dc

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
	.mapper_out(decision_variable) // decision variable output for now.
);

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
	.symb_a(LFSR_2_BITS),
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

accumulated_squared_error acc_sq_err(
	.clk(sys_clk),
	.clear_accumulator(clear_accumulator),
	.sym_clk_ena(sym_clk_ena),
	.error(error),
	.acc_error(acc_error),
	.sqr_error(sqr_error),
	.acc_sqr_error(acc_sqr_error)
);

accumulated_dc_error acc_dc_error(
	.clk(sys_clk),
	.sym_clk_ena(sym_clk_ena),
	.clear_accumulator(clear_accumulator),
	.error(error),
	.acc(acc_dc),
	.acc_error_out(acc_error_out_dc)
);







endmodule
