module BER(
    input sys_clk, sam_clk_en, sym_clk_en, KEY,
    input [1:0] slicer_in,

    output [21:0] error_count // 22 bits instead of 21 because we are using both I and Q


);

reg feedback, p_to_s, initialize, d0;
reg [21:0] q;


LFSR_BER lfsr_ber(
    .clk(sys_clk)
    .sam_clk_ena(sam_clk_en),
    .d0(d0),
    .load_data(initialize),
    .q(q),
    // .I_sym(),
    // .Q_sym(),
    // .LFSR_Counter(),
    .feedback(feedback)
);

always @ *
    begin
    case(initialize)
        1'b0: d0 = feedback;
        1'b1: d0 = p_to_s;
    endcase
end


//Parrallel to serial circuit






endmodule