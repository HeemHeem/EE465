module clocks(
    input wire clock_50,
    output reg sys_clk, sam_clk_ena, sym_clk_ena,
    output reg [3:0] clk_phase
);

parameter EN = 1'b1;
parameter DISEN = 1'b0;

always @ (posedge clock_50)
    sys_clk <= ~sys_clk;

always @ (posedge sys_clk)
    if(clk_phase == 4'd15)
        clk_phase <= 4'd0;
    
    else
        clk_phase <= clk_phase + 4'd1;


always @ *
    if(clk_phase[1:0] == 2'b11)
        sam_clk_ena = EN;
    else
        sam_clk_ena = DISEN;

always @ *
    if(clk_phase == 4'hf)
        sym_clk_ena = EN;
    else
        sym_clk_ena = DISEN;
    

endmodule