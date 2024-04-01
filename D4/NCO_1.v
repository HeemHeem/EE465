module NCO_1(
    input clk, reset,
    input wire signed [17:0] I_sig_in, Q_sig_in,
    output reg signed [17:0] NCO_cos, NCO_sin
);

reg [1:0] counter;

always @ (posedge clk or posedge reset)
    if(reset)
        counter <= 2'd0;
    else
        counter <= counter + 2'd1;

always @ *
    begin
    case(counter)
    2'd0: NCO_cos = I_sig_in;
    2'd1: NCO_cos =  18'sd0; //-Q_sig_in;
    2'd2: NCO_cos = - I_sig_in;
    2'd3: NCO_cos =  18'sd0; //Q_sig_in;

    default: NCO_cos = I_sig_in;

    endcase
end


always @ *
    begin
    case(counter)
    2'd0: NCO_sin = 18'sd0;//I_sig_in;
    2'd1: NCO_sin =  -Q_sig_in;
    2'd2: NCO_sin = 18'sd0;//- I_sig_in;
    2'd3: NCO_sin =  Q_sig_in;

    default: NCO_sin = -Q_sig_in;

    endcase
end







endmodule
    