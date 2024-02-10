module slicer#(
    parameter   DATA_WIDTH = 18 // DATA WIDTH
)(
    input wire signed [DATA_WIDTH-1:0] reference_level, decision_variable,
    output reg [1:0] slice_out
);

reg signed [17:0] absolute_decision_variable;
// absolute value
always @ *
    if(decision_variable[DATA_WIDTH-1] == 1'b1)
        absolute_decision_variable = ~ decision_variable;
    else
        absolute_decision_variable = decision_variable;




always @ *
    if(absolute_decision_variable <= reference_level)
        if(decision_variable[DATA_WIDTH-1]) // NEGATIVE
            slice_out = 2'b01; //-b
        else
            slice_out = 2'b11; // b
    
    else
        if(decision_variable[DATA_WIDTH-1]) //NEGATIVE
            slice_out = 2'b00; // -3b
        else
            slice_out = 2'b10; // 3b


endmodule