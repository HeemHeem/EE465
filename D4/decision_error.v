module decision_error(
    input clk, sym_clk_ena,
    input [17:0] decision_variable, mapper_out,
    output reg signed [17:0] error // 1s17

);


always @ (posedge clk)
    if(sym_clk_ena)
        error <= decision_variable - mapper_out;
    else
        error <= error;




endmodule