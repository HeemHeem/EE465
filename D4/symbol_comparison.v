module symbol_comparison(
    input wire sys_clk, sam_clk_ena, sym_clk_ena, clock_12_5_ena, reset,
    input wire [1:0] symb_in, slice_in,
    input wire [3:0] delay_chain,

    output wire sym_correct, sym_error

);


wire [1:0] symb_a;

delay dl(
	.sym_clk_en(sym_clk_ena),
	.sam_clk_en(sam_clk_ena),
	.sig_in(symb_in),
	.symb_a(symb_a),
	.sys_clk(sys_clk),
	.delay_change(delay_chain)
);

comparator comp(
	.sym_clk_ena(sym_clk_ena),
	.symb_a(symb_a),
	.symb_b(slice_in),
	.sym_correct(sym_correct),
	.sym_error(sym_error),
	.clk(sys_clk)
);





endmodule
