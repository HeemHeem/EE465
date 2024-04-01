module MER_circuit(
    input wire sys_clk, sam_clk_ena, sym_clk_ena, clock_12_5_ena, reset, clear_accumulator,

    input wire signed [17:0] decision_variable, error, //1s17

    output wire [39:0] mapper_out_power, //4u36
    output wire [29:0] accumulated_squared_error, //-4u34
    output wire [35:0] accumulated_error, // -1s37   
    output wire signed [17:0] reference_level //1s17

);

wire [37:0] accumulator, absolute_value, acc_counter;
wire signed [35:0] acc_dc;
wire [35:0] sqr_error;
wire [49:0] acc_error;

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


endmodule