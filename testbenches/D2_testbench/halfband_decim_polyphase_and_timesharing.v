module halfband_filter_decim(
    input clk, reset, sym_clk_en, sam_clk_en, clock_12_5_en,
							input [1:0] sw,
                    input signed [17:0] x_in, //1s17
                    output reg signed [17:0] y //1s17);
);

reg signed [17:0] y1, y1_delay, y2_acc_delay, y2_acc_delay2;
reg signed [35:0] y2, y2_acc;// 2s34
reg counter, counter_lpf;
// inputs
reg signed [17:0] x1[2:0]; // 1s17 filter 1 input
reg signed [17:0] x2[3:0]; // 1s17 filter 2 input
reg signed [17:0] x1_delay, x2_delay;

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

always @ (posedge clk or posedge reset)
    if(counter == 1'b0)
        x1_delay <= x_in;
    else 
        x1_delay <= x1_delay;

always @ (posedge clk or posedge reset)
    if(counter == 1'b1)
        x2_delay <= x_in;
    else 
        x2_delay <= x2_delay;


always @ (posedge clk or posedge reset)
    if(sam_clk_en)
        x1[0] <= x1_delay;
    else 
        x1[0] <= x1[0];

always @ (posedge clk or posedge reset)
    if(sam_clk_en)
        x2[0] <= x2_delay;
    else 
        x2[0] <= x2[0];


// x1 delays
always @ (posedge clk or posedge reset)
    if(reset)
        for(i=1; i < 3; i = i+1)
            x1[i] <= 18'sd0;
    else if (sam_clk_en)
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
    else if (sam_clk_en)
        for(i=1; i < 4; i = i+1)
            x2[i] <= x2[i-1];
    else
        for(i = 1; i < 4; i = i+1)
            x2[i] <= x2[i];   




// filter 1
always @ (posedge clk)
    if( sam_clk_en)
        y1 <= x1[2] >>> 1;
    else
        y1 <= y1;
// always @ (posedge clk)
//     if(sam_clk_en)
//         y1_delay <= y1; 
//     else
//         y1_delay <= y1;

// filter 2
always @ *
    h3_in = {x2[1][17], x2[1][17:1]} + {x2[2][17], x2[2][17:1]}; //2s16

always @ *
    h1_in = {x2[0][17], x2[0][17:1]} + {x2[3][17], x2[3][17:1]}; //2s16


always @ *
    y2 = h_mult*x_mult;
// always @ *
//     h3_out = h3 * h3_in; // 2s34

// always @ *
//     h1_out = h1 * h1_in; //2s34

// always @ *
//     y2 = h1_out + h3_out; // 2s34 + 2s34

always @ (posedge clk or posedge reset)
    if (reset)
        y <= 18'sd0;
    else if (sam_clk_en)
        y <= y2_acc_delay + y1;
    else
        y <= y;


// accumulator
always @ (posedge clk)
    if(reset)
        y2_acc <= y2;
    else if (counter == 1'b0) // clear
        y2_acc <= y2;
    else
        y2_acc <= y2_acc + y2;


always @ (posedge clk)
    y2_acc_delay <= y2_acc[34:17];

// always @ (posedge clk)
//     y2_acc_delay2  <= y2_acc_delay;
// always @ *// (posedge clk)
//     y2 = h1_out + h3_out; // 2s34

// output and counter
always @ (posedge clk or posedge reset)
    if(reset)
        counter <= 1'b1;
    else //if(clock_12_5_en)
        counter <= counter + 1'b1;
    // else
        // counter <= counter;

// always @ (posedge clk or posedge reset)
//     if(reset)
//         counter_lpf <= 1'd1;
//     // else if (sam_clk_en)
//     //     counter_lpf <= 1'd0;
//     else
//         counter_lpf <= counter_lpf + 1'd1;


always @ *
    begin
        case(counter)
        1'b0: h_mult = h1;
        1'b1: h_mult = h3;
        default: h_mult = h1;
    endcase
    end


always @ *
    begin
        case(counter)
        1'b0: x_mult = h1_in;
        1'b1: x_mult = h3_in;
        default: x_mult = h1_in;
    endcase
    end

endmodule