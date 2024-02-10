module magnitude_estimate #(

    parameter           DATA_WIDTH = 18, // data width
    parameter           ACC_DATA_WIDTH = 39, // only have 22 for now since the period could be very long - Should be 18s17 but make it 22s17 just in case
    parameter           ACC_IN_PADDING = ACC_DATA_WIDTH-DATA_WIDTH, // padding to the input of the accumulator as it may be large?
    parameter           REF_DIV = 20, // reference level division. Divide by 20 since 8*M = 8*2^18 = 2^21
    parameter           P_AVE_MULTIPLIER = 4'd5 //1.25 as a 2s2 number
)( 

    input              sym_clk_ena, //symbol clk enable
    input              clear_accumulator, 
    input              clk,
    input wire signed [DATA_WIDTH-1:0]   decision_variable, // dont know what format yet.
    output reg signed [DATA_WIDTH-1:0]   reference_level, b, // 1s17
	output	reg signed [ACC_DATA_WIDTH-1:0] accumulator, absolute_value, acc_counter,
    output reg signed [2*DATA_WIDTH+4-1:0]   mapper_out_power // estimated average power - probably need more bits  (3 multiplications - could however use less bits as we know
                                                            // reference is 1.25) Data is now 1s17*1s17 = 2s34*2s2 = 4s36
);



//reg signed [ACC_DATA_WIDTH-1:0] absolute_value; 



reg signed [2*DATA_WIDTH-1:0] reference_level_squared;

//reg signed [DATA_WIDTH-1:0]

// TODO: make 1.25 value. ask about how many bits to use

// absolute value
always @ *
    if(decision_variable[DATA_WIDTH-1] == 1'b1)
        absolute_value = -{{ACC_IN_PADDING{decision_variable[DATA_WIDTH-1]}}, decision_variable};
		  //absolute_value <= -decision_variable; //21s17 <= 1s17
    else
        absolute_value = {{ACC_IN_PADDING{1'b0}}, decision_variable};
		  //absolute_value <= decision_variable; //21s17 <= 1s17

// acculumlator 21s17 
always @ (posedge clk) // or posedge clear_accumulator) // maybe change to always @ * instead?

    if (clear_accumulator)
		//accumulator <= absolute_value;
			accumulator <= {{ACC_IN_PADDING{1'b0}}, decision_variable};
				
    else if(sym_clk_ena)
        accumulator <= accumulator + absolute_value; // 21s17 + 21s17
		 
	else
		accumulator <= accumulator; // 21s17
		
		
always @ (posedge clk)
	if(clear_accumulator)
		acc_counter <= 39'd0;
	else if (sym_clk_ena)
		acc_counter <= acc_counter + 39'd1;
		
	else
		acc_counter <= acc_counter;

// reference_level	
always @ (posedge clk)
    if (clear_accumulator)
         //reference_level <= accum_shift[36:19];
		//reference_level <= accumulator[35:18]; // 1s17
		reference_level <= accumulator[37:20]; // 1s17
	else
		reference_level <= reference_level; // 1s17
		  
always @ (posedge clk)
	if (clear_accumulator)
		b <= accumulator[38:21];
        //b <= accumulator[36:19];
	else
		b <= b;

// reference squared
always @ *
    reference_level_squared = reference_level * reference_level; //1s17 * 1s17 = 2s34

// code for mapper_out_power

always @ *
    mapper_out_power = P_AVE_MULTIPLIER * reference_level_squared; //  2s34 * 2s2



endmodule
