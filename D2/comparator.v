module comparator(
    input [1:0] symb_a, symb_b,
    input sym_clk_ena,
    output reg sym_correct, sym_error
);

always @ (posedge sym_clk_ena)
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