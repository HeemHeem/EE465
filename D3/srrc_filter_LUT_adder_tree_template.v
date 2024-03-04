module tx_pract_filter #(
    parameter COEFF_LEN = 105,
    parameter HALF_COEFF_LEN = (COEFF_LEN-1)/2
)
( input clk, reset, sym_clk_en, sam_clk_en,
							input [1:0] sw,
                    input signed [17:0] x_in, //1s17
                    output reg signed [17:0] y); //1s17);



// create array of vectors
integer  i;
reg signed [17:0] x[COEFF_LEN-1:0]; // for 21 coefficients 0s18
reg signed [18:0] sum_level_1[HALF_COEFF_LEN:0]; // last value of this is alone since it is the center. can add to others
reg signed [17:0] sum_level_2[25:0];
reg signed [17:0] sum_level_3[12:0]; // sum_level_3[12] is alone
reg signed [17:0] sum_level_4[5:0];
reg signed [17:0] sum_level_5[3:0]; // add sum_level_3[12] into here and LUT_out[52] into here
reg signed [17:0] sum_level_6[1:0]; 
reg signed [17:0] sum_level_7; // add sum_level_1 last coefficient here
//reg signed [17:0] sum_out[HALF_COEFF_LEN-1:0];
reg signed [17:0] LUT_out[HALF_COEFF_LEN:0]; // 1s17 out
// reg signed [17:0] b[10:0]; // coefficients

always @ (posedge clk or posedge reset)
    if(reset)
        x[0] <= 0;
    else if (sam_clk_en)
        x[0] <= x_in;
	else
		x[0] <= x[0];

always @ (posedge clk or posedge reset)
    if(reset) 
    begin
        for(i=1; i<COEFF_LEN; i=i+1)
            x[i] <= 0;
    end
    else if (sam_clk_en)
    begin
        for(i=1; i<COEFF_LEN; i=i+1)
            x[i] <= x[i-1];
    end
	else
    begin
        for(i=1; i<COEFF_LEN; i=i+1)
            x[i] <= x[i];
    end
// add values the require the same coefficients
always @ *
begin
    for(i=0; i<=HALF_COEFF_LEN-1; i= i+1)
    sum_level_1[i] <= {x[i][17], x[i]} + {x[COEFF_LEN-1-i][17], x[COEFF_LEN-1-i]}; // sign extend to see whats up 2s17
end

// center value
always @ *
    sum_level_1[HALF_COEFF_LEN] <= {x[HALF_COEFF_LEN][17], x[HALF_COEFF_LEN]};

    
// adder trees
// sum_level_2
always @ *
    if (reset)
        for (i = 0; i <= 25 ;i=i+1)
            sum_level_2[i] = 18'sd 0;
    else
        for (i = 0; i <= 25; i=i+1)
            sum_level_2[i] = LUT_out[2*i] + LUT_out[2*i+1];


// sum_level_3 sum_level_3[12] is left alone
always @ *
    if (reset)
        for (i = 0; i <= 12; i=i+1)
            sum_level_3[i] = 18'sd 0;
    else begin
        for (i = 0; i <= 12; i=i+1)
             sum_level_3[i] = sum_level_2[2*i] + sum_level_2[2*i+1];
    end
// sum_level_4 
always @ *
    if (reset)
        for (i = 0; i <= 5 ; i=i+1)
            sum_level_4[i] = 18'sd 0;
    else 
        for (i = 0; i <= 5 ; i=i+1)
             sum_level_4[i] = sum_level_3[2*i] + sum_level_3[2*i+1];
        
// sum_level_5 - add sum_level_3[12] and LUT_52 here
always @ *
    if (reset)
        for (i = 0; i <= 3 ; i=i+1)
            sum_level_5[i] = 18'sd 0;
    else begin
        for (i = 0; i <= 2; i=i+1)
            sum_level_5[i] = sum_level_4[2*i] + sum_level_4[2*i+1];
        sum_level_5[3] = sum_level_3[12] + LUT_out[52];
    end

// sum_level_6
always @ *
    if (reset)
        for (i = 0; i <= 1 ; i=i+1)
            sum_level_6[i] = 18'sd 0;
    else begin
        for (i = 0; i <= 1 ; i=i+1)
        sum_level_6[i] = sum_level_5[2*i] + sum_level_5[2*i+1];
    end

// sum_level_7
always @ *
    if(reset)
        sum_level_7 = 18'sd 0;
    else
        sum_level_7 = sum_level_6[0] + sum_level_6[1];



always @ (posedge clk or posedge reset)
    if(reset)
        y <= 0;
    else if (sam_clk_en)
        y <= sum_level_7;
	else
		y <= y;
 


