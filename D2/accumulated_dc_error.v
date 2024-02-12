module accumulated_dc_error #(
    parameter DATA_WIDTH = 18,
    parameter ACC_DATA_WIDTH = 36,
    parameter ACC_IN_PADDING = ACC_DATA_WIDTH-DATA_WIDTH
)(
    input clk, sym_clk_ena, clear_accumulator,
    input wire signed [DATA_WIDTH-1:0] error,
    output reg signed [ACC_DATA_WIDTH-1:0] acc,
    output reg signed [ACC_DATA_WIDTH-1:0] acc_error_out
);


always @ (posedge clk)
    if(clear_accumulator)
        acc <= {{ACC_IN_PADDING{error[DATA_WIDTH-1]}},error};
    else if (sym_clk_ena)
        acc <= acc + {{ACC_IN_PADDING{error[DATA_WIDTH-1]}},error};
    else
        acc <= acc;

always @ (posedge clk)
    if(clear_accumulator)
        acc_error_out <= acc;
    else
        acc_error_out <= acc_error_out;


endmodule
