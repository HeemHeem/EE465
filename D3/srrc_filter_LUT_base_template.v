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
reg signed [18:0] sum_level_1[HALF_COEFF_LEN:0];
reg signed [17:0] sum_out[HALF_COEFF_LEN-1:0];
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


// multiply by coefficients
// always @ *
// begin
//     for(i=0; i <= 10; i=i+1)
//     mult_out[i] <= sum_level_1[i] * b[i]; 
// end

// sum up mutlipliers
always @ *
if (reset)
    for (i = 0; i <=HALF_COEFF_LEN-1; i=i+1)
        sum_out[i] = 18'sd 0;
else
    begin
        sum_out[0] = LUT_out[0] + LUT_out[1];
        for(i = 0; i <= HALF_COEFF_LEN-2 ; i=i+1)
            sum_out[i+1] <= sum_out[i] + LUT_out[i+2]; 
    end
    

always @ (posedge clk or posedge reset)
    if(reset)
        y <= 0;
    else if (sam_clk_en)
        y <= sum_out[HALF_COEFF_LEN-1];
	else
		y <= y;


 


