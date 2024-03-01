module downsampler(
    input sym_clk_en, sam_clk_en, sys_clk,
    input wire signed [17:0] sig_in,
    output reg signed [17:0] sym_out

);

always @ (posedge sys_clk or posedge reset)
    if(reset)
        sym_out = 18'sd0;
    else if(sym_clk_en)
        sym_out = sig_in;
    else
        sym_out = sym_out;




endmodule