module upsampler(
    input sys_clk, sym_clk_en, sam_clk_en, reset,
    input wire signed [17:0] symb_in,
    // input [1:0] counter,
    output reg signed [17:0] sig_out
);

always @ *//@ (posedge sys_clk or posedge reset)
    if(reset)
        sig_out <= 18'sd0;
    else if (sam_clk_en && sym_clk_en)
        sig_out <= symb_in;
    else
        sig_out <= 18'sd0;


endmodule