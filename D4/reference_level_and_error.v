module reference_level_and_error(
    input wire sys_clk, sam_clk_ena, sym_clk_ena, clock_12_5_ena, reset,
    input wire signed [17:0] reference_level, decision_variable, //1s17

    output wire [1:0] slice_out,
    output wire signed [17:0] b, mapper_out, error//1s17    
    
);


slicer slice(
	.reference_level(reference_level),
	.decision_variable(decision_variable),
	.slice_out(slice_out)

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




endmodule