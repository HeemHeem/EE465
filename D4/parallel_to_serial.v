module parallel_to_serial(
    input wire clk, sam_clk_en, reset
    input wire [1:0] from_slicer_I, from_slicer_Q,

    output reg p_to_s
);

reg [1:0] counter;


always @ (posedge clk)
    if(reset)
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
        2'd2: p_to_s = from_slice_I[1];
        2'd3: p_to_s = from_slice_I[0];
    endcase
end