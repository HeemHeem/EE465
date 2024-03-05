module filter_delay(
    input wire sys_clk, sam_clk_en, reset,
    input wire signed [17:0] sig_in,
    input wire [1:0] delay_change,
    output reg signed [17:0] sig_out
);

reg signed [17:0] delay_0, delay_1, delay_2, delay_3;


// delay_1
always @ (posedge sys_clk)
    if(reset)
        delay_1 <= 18'sd0;
    else if (sam_clk_en)
        delay_1 <= sig_in;
    else 
        delay_1 <= delay_1;

always @ (posedge sys_clk)
    if(reset)
        delay_2 <= 18'sd0;
    else if (sam_clk_en)
        delay_2 <= delay_1;
    else 
        delay_2 <= delay_2;

always @ (posedge sys_clk)
    if(reset)
        delay_3 <= 18'sd0;
    else if (sam_clk_en)
        delay_3 <= delay_2;
    else 
        delay_3 <= delay_3;


always @ *
    case(delay_change)
    2'd0: sig_out = sig_in;
    2'd1: sig_out = delay_1;
    2'd2: sig_out = delay_2;
    2'd3: sig_out = delay_3;
    default: sig_out = delay_0;
    endcase









endmodule