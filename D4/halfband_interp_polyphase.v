module halfband_filter_interp2 (
    input clk, reset, sym_clk_en, sam_clk_en, clock_12_5_en,
							input [1:0] sw,
                    input signed [17:0] x_in, //1s17
                    output reg signed [17:0] y, y1, //1s17);
						  output reg signed [35:0] y2,
						  output reg counter
);

//reg signed [17:0] y1;
//reg signed [35:0] y2;
//reg counter;
// inputs
reg signed [17:0] x[3:0]; // 1s17
//reg signed [17:0] x_delay;
integer i;
// coefficients
wire signed [17:0] h3, h1; // 0s18
reg signed [17:0] h3_in, h1_in; // 2s16
reg signed [35:0] h3_out, h1_out; // 1s35
assign h3 = 18'sd 74920; // 0s18
assign h1 = -18'sd 9220; // 0s18

//always @ (posedge clk)
//	if(sam_clk_en)
//		x_delay <= x_in;

always @ (posedge clk or posedge reset)
    if(reset)
        x[0] <= 18'sd0;
    
    else if(sam_clk_en)
        x[0] <= x_in;
    else
        x[0] <= x[0];


always @ (posedge clk or posedge reset)
    if(reset)
        for(i=1; i < 4; i = i+1)
            x[i] <= 18'sd0;
    else if (sam_clk_en)
        for(i=1; i < 4; i = i+1)
            x[i] <= x[i-1];
    else
        for(i = 1; i < 4; i = i+1)
            x[i] <= x[i];   

// filter 1
always @ *//(posedge clk)
    y1 = x[2] >>> 1;

// filter 2
always @ *
    h3_in = {x[1][17], x[1][17:1]} + {x[2][17], x[2][17:1]}; //2s16

always @ *
    h1_in = {x[0][17], x[0][17:1]} + {x[3][17], x[3][17:1]}; //2s16

always @ *
    h3_out = h3 * h3_in; // 2s34

always @ *
    h1_out = h1 * h1_in; //2s34


always @ *// (posedge clk)
    y2 = h1_out + h3_out; // 2s34

// output and counter
always @ (posedge clk or posedge reset)
    if(reset)
        counter <= 1'b0;
	else if(sam_clk_en)
		counter <= 1'b0;
    else //if(clock_12_5_en)
        counter <= counter + 1'b1;
    // else
    //     counter <= counter;


always @ *
begin
    case(counter)
        1'b0: y = y1;
        1'b1: y = y2[34:17];
        default: y = y1;
    endcase
end




endmodule