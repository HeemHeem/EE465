module accumulated_dc_error #(
    parameter DATA_WIDTH = 18,
    parameter ACC_DATA_WIDTH = 36,
    parameter ACC_IN_PADDING = ACC_DATA_WIDTH-DATA_WIDTH
)(
    input clk, sym_clk_ena, clear_accumulator,
    input wire signed [DATA_WIDTH-1:0] error, // 1s17
    output reg signed [ACC_DATA_WIDTH-1:0] acc, // 19s17
    output reg signed [ACC_DATA_WIDTH-1:0] accumulated_error // -1s37 since you average by 2^20 this moves it from a 19s17 to an -1s37 number
                                                        

);


always @ (posedge clk)
    if(clear_accumulator)
        acc <= {{ACC_IN_PADDING{error[DATA_WIDTH-1]}},error}; // 19s17
    else if (sym_clk_ena)
        acc <= acc + {{ACC_IN_PADDING{error[DATA_WIDTH-1]}},error}; // 19s17 + 1s17 padded 
    else
        acc <= acc; 

always @ (posedge clk)
    if(clear_accumulator)
        //accumulated_error <= acc[35:18];
		 accumulated_error <= acc; 
    else
        accumulated_error <= accumulated_error;


endmodule
