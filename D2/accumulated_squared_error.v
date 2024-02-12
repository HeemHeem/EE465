module accumulated_squared_error #(
    parameter DATA_WIDTH = 18, // DATA WIDTH
    parameter ACC_DATA_WIDTH = 50, // accumulator data width
    parameter SQUR_ERROR_DATA_WIDTH = 36,
    parameter ACC_SQR_ERROR_DATA_WIDTH = 30,
    parameter ACC_IN_PADDING = ACC_DATA_WIDTH- SQUR_ERROR_DATA_WIDTH
)(
    input clk, clear_accumulator, sym_clk_ena,
    input wire signed [DATA_WIDTH-1:0] error, // 1s17
    output reg  [ACC_DATA_WIDTH-1:0] acc_error, // 16u34
    output reg  [SQUR_ERROR_DATA_WIDTH-1:0] sqr_error, //2u34
    output reg  [ACC_SQR_ERROR_DATA_WIDTH-1:0] acc_sqr_error // -4u34

);


always @ *
    sqr_error = error * error;

// accumulator
always @(posedge clk)
    if(clear_accumulator)
        acc_error <= {{ACC_IN_PADDING{sqr_error[SQUR_ERROR_DATA_WIDTH-1]}}, sqr_error};
    else if (sym_clk_ena)
        acc_error <= acc_error + {{ACC_IN_PADDING{1'b0}}, sqr_error};
    else
        acc_error <= acc_error; 

// averaging
always @ (posedge clk)
    if(clear_accumulator)
        acc_sqr_error <= acc_error[49:20]; // -4u30
    else
        acc_sqr_error <= acc_sqr_error;



endmodule