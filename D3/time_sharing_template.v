module test_timesharing3 #(
    parameter COEFF_LEN = 81,
    parameter HALF_COEFF_LEN = (COEFF_LEN-1)/2
)
( input clk, reset, sym_clk_en, sam_clk_en,
							input [1:0] sw,
                    input signed [17:0] x_in, //1s17
                    output reg signed [17:0] y, //1s17);
					output reg [1:0] counter);


// create array of vectors
integer  i;
reg signed [17:0] x[COEFF_LEN-1:0]; // for 81 coefficients
reg signed [17:0] xm[19:0]; // 1s17
reg signed [17:0] h[19:0]; // 0s18
reg signed [35:0] m[19:0]; // 1s35
reg signed [35:0] m_acc[19:0]; // 1s35
reg signed [35:0] m_acc_reg[19:0]; //1s35
reg signed [35:0] sum_level_1[9:0]; // 1s35
reg signed [35:0] sum_level_2[4:0]; // 1s35
reg signed [35:0] sum_level_3[1:0]; // 1s35 only add sum_level_2[0:3]
reg signed [35:0] sum_level_4[1:0]; // add sum_level3 and sum_level_2[4] with mout_21
reg signed [35:0] y_temp; // add sum_level4
reg signed [35:0] mout21, mout21_reg;

always @ (posedge clk or posedge reset)
	if (reset)
		counter <= 2'd0;
	// else if (counter == 2'd3)
	else if (sam_clk_en)
		counter <= 2'd0;
	else
		counter <= counter + 2'd1;

initial begin
	counter = 2'd0;
end



// reg signed [18:0] sum_level_1[HALF_COEFF_LEN:0]; // 2s18
// reg signed [17:0] sum_out[HALF_COEFF_LEN-1:0];
// reg signed [36:0] mult_out[HALF_COEFF_LEN:0]; // 1s35 but changed to 2s35
// reg signed [17:0] b[HALF_COEFF_LEN:0]; // coefficients

always @ (posedge clk or posedge reset)
    if(reset)
        x[0] <= 18'sd0;
    else if (sam_clk_en)
        x[0] <= x_in;
	else
		x[0] <= x[0];

always @ (posedge clk or posedge reset)
    if(reset) 
    begin
        for(i=1; i<COEFF_LEN; i=i+1)
            x[i] <= 18'sd0;
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


/************************sum_level***********************/

// s1
always @ (posedge clk or posedge reset)
	if(reset)
		for(i=0; i<10; i = i+1)
			sum_level_1[i] = 36'sd0;
	else
		for(i=0; i<10; i = i+1)
			sum_level_1[i] = m_acc_reg[2*i] + m_acc_reg[2*i+1];
 
 // s2
always @ (posedge clk or posedge reset)

	if(reset)
		for(i=0; i<5; i = i + 1)
			sum_level_2[i] = 36'sd0;
	else
		for(i=0; i<5; i = i+1)
			sum_level_2[i] = sum_level_1[2*i] + sum_level_1[2*i+1];

// s3
always @ (posedge clk or posedge reset)

	if(reset)
		for(i=0; i<2; i = i + 1)
			sum_level_3[i] = 36'sd0;
	else
		for(i = 0; i<2; i = i + 1)
			sum_level_3[i] = sum_level_2[2*i] + sum_level_2[2*i+1];


// s4
always @ (posedge clk or posedge reset)

	if(reset)
		begin
		sum_level_4[0] = 36'sd0;
		sum_level_4[1] = 36'sd0;
		end
	else
		begin
		sum_level_4[0] = sum_level_3[0] + sum_level_3[1];
		sum_level_4[1] = sum_level_2[4] + mout21_reg;
		end
// y_temp
always @ *
	if(reset)
		y_temp = 36'sd0;
	else
		y_temp = sum_level_4[0] + sum_level_4[1];

always @ (posedge clk or posedge reset)
	if(reset)
		y <= y_temp;
	else if (sam_clk_en)
		y <= y_temp;
	else
		y <= y;
