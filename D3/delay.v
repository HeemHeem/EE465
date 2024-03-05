module delay(
    input sym_clk_en, sam_clk_en, sys_clk, reset,
    input [1:0] sig_in,
	 input [3:0] delay_change,
    output reg [1:0] symb_a
    //output reg [1:0] delay_reg [DELAY_COUNT-1:0]

);

reg signed [1:0] delay_0, delay_1, delay_2, delay_3, delay_4, delay_5, delay_6, delay_7, delay_8, delay_9, delay_10;


// delay_1
always @ (posedge sys_clk)
    if(reset)
        delay_1 <= 2'd0;
    else if (sym_clk_en)
        delay_1 <= sig_in;
    else 
        delay_1 <= delay_1;

always @ (posedge sys_clk)
    if(reset)
        delay_2 <= 2'd0;
    else if (sym_clk_en)
        delay_2 <= delay_1;
    else 
        delay_2 <= delay_2;

always @ (posedge sys_clk)
    if(reset)
        delay_3 <= 2'd0;
    else if (sym_clk_en)
        delay_3 <= delay_2;
    else 
        delay_3 <= delay_3;

		  
		  
		  
always @ (posedge sys_clk)
    if(reset)
        delay_4 <= 2'd0;
    else if (sym_clk_en)
        delay_4 <= delay_3;
    else 
        delay_4 <= delay_4;

		  
		  
always @ (posedge sys_clk)
    if(reset)
        delay_5 <= 2'd0;
    else if (sym_clk_en)
        delay_5 <= delay_4;
    else 
        delay_5 <= delay_5;
		  
		  
		  
always @ (posedge sys_clk)
    if(reset)
        delay_6 <= 2'd0;
    else if (sym_clk_en)
        delay_6 <= delay_5;
    else 
        delay_6 <= delay_6;



		  
always @ (posedge sys_clk)
    if(reset)
        delay_7 <= 2'd0;
    else if (sym_clk_en)
        delay_7 <= delay_6;
    else 
        delay_7 <= delay_7;


		  
always @ (posedge sys_clk)
    if(reset)
        delay_8 <= 2'd0;
    else if (sym_clk_en)
        delay_8 <= delay_7;
    else 
        delay_8 <= delay_8;

		  
always @ (posedge sys_clk)
    if(reset)
        delay_9 <= 2'd0;
    else if (sym_clk_en)
        delay_9 <= delay_8;
    else 
        delay_9 <= delay_8;

		  
always @ (posedge sys_clk)
    if(reset)
        delay_10 <= 2'd0;
    else if (sym_clk_en)
        delay_10 <= delay_9;
    else 
        delay_10 <= delay_10;


		  
	
always @ *
    case(delay_change)
    4'd0: symb_a = sig_in;
    4'd1: symb_a = delay_1;
    4'd2: symb_a = delay_2;
    4'd3: symb_a = delay_3;
	 4'd4: symb_a = delay_4;
	 4'd5: symb_a = delay_5;
	 4'd6: symb_a = delay_6;
	 4'd7: symb_a = delay_7;
	 4'd8: symb_a = delay_8;
	 4'd9: symb_a = delay_9;
	 4'd10: symb_a = delay_10;
    default: symb_a = delay_0;
    endcase









endmodule