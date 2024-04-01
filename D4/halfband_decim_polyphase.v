module halfband_filter_decim_poly(
    input clk, reset, sym_clk_en, sam_clk_en, bit_rate_en,
							input [1:0] sw,
                    input signed [17:0] x_in, //1s17
                    output reg signed [17:0] y, //1s17);
						  output reg signed [35:0] y2
);


reg signed [17:0] y1, y2_acc_delay, y2_acc_delay2;
reg signed [35:0]  y2_acc;// 2s34y2,
reg counter, counter_lpf;
// inputs
reg signed [17:0] x1[2:0]; // 1s17 filter 1 input
reg signed [17:0] x2[3:0]; // 1s17 filter 2 input
reg signed [17:0] x1_delay, x2_delay, x1_delay2, x2_delay2;

integer i;
// coefficients
reg signed [17:0] h_mult, x_mult; // 0s18 and 1s17
wire signed [17:0] h3, h1; // 0s18
reg signed [17:0] h3_in, h1_in; // 2s16
reg signed [35:0] h3_out, h1_out; // 2s34

assign h3 = 18'sd 74920; // 0s18
assign h1 = -18'sd 9220; // 0s18


// always @ (posedge clk or posedge reset)
//     if(reset)
//         x1[0] <= 18'sd0;
    
//     // else if(sam_clk_en)
//     else
//         x1[0] <= x_in;
//     // else
//     //     x[0] <= x[0];

always @ (posedge clk)
    if(counter == 1'b0)
        x1_delay <= x_in;
    else 
        x1_delay <= x1_delay;

always @ (posedge clk)
	x1_delay2 <= x1_delay;


always @ (posedge clk)
    if(counter == 1'b1)
        x2_delay <= x_in;
    else 
        x2_delay <= x2_delay;

always @ (posedge clk)
	x2_delay2 <= x2_delay;
		  
always @ (posedge clk)
    if(bit_rate_en)
        x1[0] <= x1_delay2;
    else 
        x1[0] <= x1[0];

always @ (posedge clk)
    if(bit_rate_en)
        x2[0] <= x2_delay2;
    else 
        x2[0] <= x2[0];


// x1 delays
always @ (posedge clk or posedge reset)
    if(reset)
        for(i=1; i < 3; i = i+1)
            x1[i] <= 18'sd0;
    else if (bit_rate_en)
        for(i=1; i < 3; i = i+1)
            x1[i] <= x1[i-1];
    else
        for(i = 1; i < 3; i = i+1)
            x1[i] <= x1[i];   

// x2 delays
always @ (posedge clk or posedge reset)
    if(reset)
        for(i=1; i < 4; i = i+1)
            x2[i] <= 18'sd0;
    else if (bit_rate_en)
        for(i=1; i < 4; i = i+1)
            x2[i] <= x2[i-1];
    else
        for(i = 1; i < 4; i = i+1)
            x2[i] <= x2[i];   




// filter 1
always @ (posedge clk)
    y1 = x1[2] >>> 1;

// filter 2
always @ *
    h3_in = {x2[1][17], x2[1][17:1]} + {x2[2][17], x2[2][17:1]}; //2s16

always @ *
    h1_in = {x2[0][17], x2[0][17:1]} + {x2[3][17], x2[3][17:1]}; //2s16


// always @ *
//     y2 = h_mult*x_mult;
always @ *
    h3_out = h3 * h3_in; // 2s34

always @ *
    h1_out = h1 * h1_in; //2s34

always @ *
    y2 = h1_out + h3_out; // 2s34 + 2s34

always @ (posedge clk or posedge reset)
    if (reset)
        y <= 18'sd0;
    else if (bit_rate_en)
        y <= y2[34:17] + y1;
    else
        y <= y;

// output and counter
always @ (posedge clk or posedge reset)
    if(reset)
        counter <= 1'b1;
	else if (bit_rate_en)
		counter <= 1'b1;
    else //if(clock_12_5_en)
        counter <= counter + 1'b1;




endmodule