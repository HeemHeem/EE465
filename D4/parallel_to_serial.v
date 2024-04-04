module parallel_to_serial(
    input wire clk, sam_clk_en, reset, sym_clk_en,
    input wire [1:0] from_slicer_I, from_slicer_Q,

    output reg p_to_s
);

reg [1:0] slice_I_delay, slice_Q_delay, slice_I_delay2, slice_Q_delay2;

always @ (posedge clk)
    if(sym_clk_en)
        slice_I_delay <= from_slicer_I;
    else
        slice_I_delay <= slice_I_delay;

always @ (posedge clk)
    if(sym_clk_en)
        slice_Q_delay <= from_slicer_Q;
    else
        slice_Q_delay <= slice_Q_delay;

always @ (posedge clk)
    if(sym_clk_en)
        slice_I_delay2 <= slice_I_delay;
    else
        slice_I_delay2 <= slice_I_delay2;

always @ (posedge clk)
    if(sym_clk_en)
        slice_Q_delay2 <= slice_Q_delay;
    else
        slice_Q_delay2 <= slice_Q_delay2;




reg [1:0] counter;


always @ (posedge clk)
    if(reset||sym_clk_en)
        counter <= 2'd0;
    else if(sam_clk_en)
        counter <= counter + 2'd1;
    else    
        counter <= counter;
        




always @ *
begin
    case(counter) // flip order
        2'd0: p_to_s = from_slicer_Q[1];
        2'd1: p_to_s = from_slicer_Q[0];
        2'd2: p_to_s = from_slicer_I[1];
        2'd3: p_to_s = from_slicer_I[0];
    endcase
end
endmodule