module comparator(
    input [1:0] symb_a, symb_b,
    input sym_clk_ena, clk,
    output reg sym_correct, sym_error,
    output reg [1:0] symb_a_delay 
);

always @ (posedge clk)
	if(sym_clk_ena)
    if(symb_a == symb_b)
        begin
            sym_correct = 1'b1;
            sym_error = 1'b0;
        end
    else begin
        sym_correct = 1'b0;
        sym_error = 1'b1;

    end





endmodule