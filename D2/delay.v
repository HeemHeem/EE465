module delay#(
    parameter   DELAY_COUNT = 3
)(
    input sym_clk_ena, sam_clk_ena,
    input symb_in,
    output reg [1:0] symb_a
    //output reg [1:0] delay_reg [DELAY_COUNT-1:0]

);

integer i;
reg [1:0] delay_reg [DELAY_COUNT-1:0];

always @ (posedge sam_clk_ena) begin
    delay_reg[0] <= symb_in;
    
    for (i=1; i <= DELAY_COUNT; i = i+1)
        delay_reg[i] <= delay_reg[i-1];
end

always @ *
    symb_a = delay_reg[DELAY_COUNT-1];


    







endmodule