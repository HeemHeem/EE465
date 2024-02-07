module magnitude_estimate(

    parameter           DATA_WIDTH = 18, // data width
    parameter           ACC_DATA_WIDTH = 22, // only have 22 for now since the period could be very long
    parameter           ACC_IN_PADDING = ACC_DATA_WIDTH-DATA_WIDTH, // padding to the input of the accumulator as it may be large?
    

    input               sym_clk_ena, //symbol clk enable
    input               clear_accumulator, 
    input wire signed [DATA_WIDTH-1:0]   decision_variable, // dont know what format yet.
    output reg signed [DATA_WIDTH-1:0]   reference_level, // 1s17
    output reg signed [3*DATA_WIDTH-1:0]   mapper_out_power // estimated average power - probably need more bits  (3 multiplications - could however use less bits as we know
                                                            // reference is 1.25) 
);



reg signed [DATA_WIDTH-1:0] absolute_value, 

reg signed [ACC_DATA_WIDTH-1:0] acculumlator;

reg signed [2*DATA_WIDTH-1:0] reference_level_squared;

reg signed [DATA_WIDTH-1:0]

// TODO: make 1.25 value. ask about how many bits to use

// absolute value
always @ *
    if(decision_variable[DATA_WIDTH-1] == 1'b1)
        absolute_value = -{ACC_IN_PADDING*{decision_variable[DATA_WIDTH]}, decision_variable};

    else
        absolute_value = {ACC_IN_PADDING*{1'b0}, decision_variable};


// acculumlator
always @ (posedge sym_clk_en or posedge clear_accumulator) // maybe change to always @ * instead?

    if (clear_accumulator)
        acculumlator <= DATA_WIDTH'0;
    
    else
        acculumlator <= acculumlator + absolute_value;
    
// reference_level
always @ (posedge clear_accumulator)
    reference_level <= acculumlator[ACC_DATA_WIDTH:ACC_DATA_WIDTH-DATA_WIDTH];

// reference squared
always @ *
    reference_level_squared = reference_level * reference_level;

// code for mapper_out_power
/*
always @ *
    mapper_out_power = 1.25 * reference_level_squared



endmodule
