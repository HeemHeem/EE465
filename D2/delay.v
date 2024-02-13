module delay#(
    parameter   DELAY_COUNT = 3
)(
    input sym_clk_ena, sam_clk_ena, clk,
    input [1:0] symb_in,
    output reg [1:0] symb_a
    //output reg [1:0] delay_reg [DELAY_COUNT-1:0]

);

integer i;
reg [1:0] delay_reg [DELAY_COUNT-1:0];

always @ (posedge clk)
	if(sym_clk_ena) begin
		delay_reg[0] <= symb_in;
		delay_reg[1] <= delay_reg[0];
		delay_reg[2] <= delay_reg[1];
	end
	
	else begin
		delay_reg[0] <= delay_reg[0];
		delay_reg[1] <= delay_reg[1];
		delay_reg[2] <= delay_reg[2];
	end
	

always @ *
    symb_a = delay_reg[DELAY_COUNT-1];


    







endmodule