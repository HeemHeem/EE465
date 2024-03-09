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
	else if (counter == 2'd3)
	// else if (sam_clk_en)
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
// add values the require the same coefficients
// always @ *
// begin
//     for(i=0; i<=HALF_COEFF_LEN-1; i= i+1)
//     sum_level_1[i] <= {x[i][17], x[i]} + {x[COEFF_LEN-1-i][17], x[COEFF_LEN-1-i]}; // sign extend to see whats up 2s17
// end

// // center value
// always @ *
//     sum_level_1[HALF_COEFF_LEN] <= {x[HALF_COEFF_LEN][17], x[HALF_COEFF_LEN]};


// // multiply by coefficients
// always @ *
// begin
//     for(i=0; i <= HALF_COEFF_LEN; i=i+1)
//     mult_out[i] <= sum_level_1[i] * b[i]; 
// end

// // sum up mutlipliers
// always @ *
// if (reset)
//     for (i = 0; i <=HALF_COEFF_LEN-1; i=i+1)
//         sum_out[i] = 18'sd 0;
// else
//     begin
//         sum_out[0] = mult_out[0][35:18] + mult_out[1][35:18];
//         for(i = 0; i <= HALF_COEFF_LEN-2 ; i=i+1)
//             sum_out[i+1] <= sum_out[i] + mult_out[i+2][35:18]; 
//     end
    

// always @ (posedge clk or posedge reset)
//     if(reset)
//         y <= 0;
//     else if(sam_clk_en)
//         y <= sum_out[HALF_COEFF_LEN-1];
// 	else
// 		y <= y;

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
		y <= y_temp[35:18];
	else if (sam_clk_en)
		y <= y_temp[35:18];
	else
		y <= y;

/********************** single coeff ***************/

wire signed [17:0] h80;

assign h80 = 18'sd 166;

always @ *
	mout21 = x[80] * h80;

always @ (posedge clk or posedge reset)
	if (reset)
		mout21_reg <= mout21;
	else if (sam_clk_en)
		mout21_reg <= mout21;
	else
		mout21_reg <= mout21_reg;

/************************* m[0]******************/

always @ *
	if(reset)
		m[0] <= 36'sd0;
	else
		m[0] <= xm[0] * h[0];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[0] <= m[0];
	else if (counter == 2'd3)
		m_acc[0] <= m[0];
	else
		m_acc[0] <= m_acc[0] + m[0];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[0] <= m_acc[0];
	else if (sam_clk_en)
		m_acc_reg[0] <= m_acc[0];
	else
		m_acc_reg[0] <= m_acc_reg[0];

/************************* m[1]******************/

always @ *
	if(reset)
		m[1] <= 36'sd0;
	else
		m[1] <= xm[1] * h[1];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[1] <= m[1];
	else if (counter == 2'd3)
		m_acc[1] <= m[1];
	else
		m_acc[1] <= m_acc[1] + m[1];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[1] <= m_acc[1];
	else if (sam_clk_en)
		m_acc_reg[1] <= m_acc[1];
	else
		m_acc_reg[1] <= m_acc_reg[1];

/************************* m[2]******************/

always @ *
	if(reset)
		m[2] <= 36'sd0;
	else
		m[2] <= xm[2] * h[2];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[2] <= m[2];
	else if (counter == 2'd3)
		m_acc[2] <= m[2];
	else
		m_acc[2] <= m_acc[2] + m[2];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[2] <= m_acc[2];
	else if (sam_clk_en)
		m_acc_reg[2] <= m_acc[2];
	else
		m_acc_reg[2] <= m_acc_reg[2];

/************************* m[3]******************/

always @ *
	if(reset)
		m[3] <= 36'sd0;
	else
		m[3] <= xm[3] * h[3];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[3] <= m[3];
	else if (counter == 2'd3)
		m_acc[3] <= m[3];
	else
		m_acc[3] <= m_acc[3] + m[3];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[3] <= m_acc[3];
	else if (sam_clk_en)
		m_acc_reg[3] <= m_acc[3];
	else
		m_acc_reg[3] <= m_acc_reg[3];

/************************* m[4]******************/

always @ *
	if(reset)
		m[4] <= 36'sd0;
	else
		m[4] <= xm[4] * h[4];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[4] <= m[4];
	else if (counter == 2'd3)
		m_acc[4] <= m[4];
	else
		m_acc[4] <= m_acc[4] + m[4];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[4] <= m_acc[4];
	else if (sam_clk_en)
		m_acc_reg[4] <= m_acc[4];
	else
		m_acc_reg[4] <= m_acc_reg[4];

/************************* m[5]******************/

always @ *
	if(reset)
		m[5] <= 36'sd0;
	else
		m[5] <= xm[5] * h[5];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[5] <= m[5];
	else if (counter == 2'd3)
		m_acc[5] <= m[5];
	else
		m_acc[5] <= m_acc[5] + m[5];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[5] <= m_acc[5];
	else if (sam_clk_en)
		m_acc_reg[5] <= m_acc[5];
	else
		m_acc_reg[5] <= m_acc_reg[5];

/************************* m[6]******************/

always @ *
	if(reset)
		m[6] <= 36'sd0;
	else
		m[6] <= xm[6] * h[6];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[6] <= m[6];
	else if (counter == 2'd3)
		m_acc[6] <= m[6];
	else
		m_acc[6] <= m_acc[6] + m[6];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[6] <= m_acc[6];
	else if (sam_clk_en)
		m_acc_reg[6] <= m_acc[6];
	else
		m_acc_reg[6] <= m_acc_reg[6];

/************************* m[7]******************/

always @ *
	if(reset)
		m[7] <= 36'sd0;
	else
		m[7] <= xm[7] * h[7];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[7] <= m[7];
	else if (counter == 2'd3)
		m_acc[7] <= m[7];
	else
		m_acc[7] <= m_acc[7] + m[7];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[7] <= m_acc[7];
	else if (sam_clk_en)
		m_acc_reg[7] <= m_acc[7];
	else
		m_acc_reg[7] <= m_acc_reg[7];

/************************* m[8]******************/

always @ *
	if(reset)
		m[8] <= 36'sd0;
	else
		m[8] <= xm[8] * h[8];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[8] <= m[8];
	else if (counter == 2'd3)
		m_acc[8] <= m[8];
	else
		m_acc[8] <= m_acc[8] + m[8];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[8] <= m_acc[8];
	else if (sam_clk_en)
		m_acc_reg[8] <= m_acc[8];
	else
		m_acc_reg[8] <= m_acc_reg[8];

/************************* m[9]******************/

always @ *
	if(reset)
		m[9] <= 36'sd0;
	else
		m[9] <= xm[9] * h[9];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[9] <= m[9];
	else if (counter == 2'd3)
		m_acc[9] <= m[9];
	else
		m_acc[9] <= m_acc[9] + m[9];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[9] <= m_acc[9];
	else if (sam_clk_en)
		m_acc_reg[9] <= m_acc[9];
	else
		m_acc_reg[9] <= m_acc_reg[9];

/************************* m[10]******************/

always @ *
	if(reset)
		m[10] <= 36'sd0;
	else
		m[10] <= xm[10] * h[10];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[10] <= m[10];
	else if (counter == 2'd3)
		m_acc[10] <= m[10];
	else
		m_acc[10] <= m_acc[10] + m[10];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[10] <= m_acc[10];
	else if (sam_clk_en)
		m_acc_reg[10] <= m_acc[10];
	else
		m_acc_reg[10] <= m_acc_reg[10];

/************************* m[11]******************/

always @ *
	if(reset)
		m[11] <= 36'sd0;
	else
		m[11] <= xm[11] * h[11];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[11] <= m[11];
	else if (counter == 2'd3)
		m_acc[11] <= m[11];
	else
		m_acc[11] <= m_acc[11] + m[11];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[11] <= m_acc[11];
	else if (sam_clk_en)
		m_acc_reg[11] <= m_acc[11];
	else
		m_acc_reg[11] <= m_acc_reg[11];

/************************* m[12]******************/

always @ *
	if(reset)
		m[12] <= 36'sd0;
	else
		m[12] <= xm[12] * h[12];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[12] <= m[12];
	else if (counter == 2'd3)
		m_acc[12] <= m[12];
	else
		m_acc[12] <= m_acc[12] + m[12];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[12] <= m_acc[12];
	else if (sam_clk_en)
		m_acc_reg[12] <= m_acc[12];
	else
		m_acc_reg[12] <= m_acc_reg[12];

/************************* m[13]******************/

always @ *
	if(reset)
		m[13] <= 36'sd0;
	else
		m[13] <= xm[13] * h[13];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[13] <= m[13];
	else if (counter == 2'd3)
		m_acc[13] <= m[13];
	else
		m_acc[13] <= m_acc[13] + m[13];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[13] <= m_acc[13];
	else if (sam_clk_en)
		m_acc_reg[13] <= m_acc[13];
	else
		m_acc_reg[13] <= m_acc_reg[13];

/************************* m[14]******************/

always @ *
	if(reset)
		m[14] <= 36'sd0;
	else
		m[14] <= xm[14] * h[14];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[14] <= m[14];
	else if (counter == 2'd3)
		m_acc[14] <= m[14];
	else
		m_acc[14] <= m_acc[14] + m[14];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[14] <= m_acc[14];
	else if (sam_clk_en)
		m_acc_reg[14] <= m_acc[14];
	else
		m_acc_reg[14] <= m_acc_reg[14];

/************************* m[15]******************/

always @ *
	if(reset)
		m[15] <= 36'sd0;
	else
		m[15] <= xm[15] * h[15];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[15] <= m[15];
	else if (counter == 2'd3)
		m_acc[15] <= m[15];
	else
		m_acc[15] <= m_acc[15] + m[15];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[15] <= m_acc[15];
	else if (sam_clk_en)
		m_acc_reg[15] <= m_acc[15];
	else
		m_acc_reg[15] <= m_acc_reg[15];

/************************* m[16]******************/

always @ *
	if(reset)
		m[16] <= 36'sd0;
	else
		m[16] <= xm[16] * h[16];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[16] <= m[16];
	else if (counter == 2'd3)
		m_acc[16] <= m[16];
	else
		m_acc[16] <= m_acc[16] + m[16];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[16] <= m_acc[16];
	else if (sam_clk_en)
		m_acc_reg[16] <= m_acc[16];
	else
		m_acc_reg[16] <= m_acc_reg[16];

/************************* m[17]******************/

always @ *
	if(reset)
		m[17] <= 36'sd0;
	else
		m[17] <= xm[17] * h[17];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[17] <= m[17];
	else if (counter == 2'd3)
		m_acc[17] <= m[17];
	else
		m_acc[17] <= m_acc[17] + m[17];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[17] <= m_acc[17];
	else if (sam_clk_en)
		m_acc_reg[17] <= m_acc[17];
	else
		m_acc_reg[17] <= m_acc_reg[17];

/************************* m[18]******************/

always @ *
	if(reset)
		m[18] <= 36'sd0;
	else
		m[18] <= xm[18] * h[18];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[18] <= m[18];
	else if (counter == 2'd3)
		m_acc[18] <= m[18];
	else
		m_acc[18] <= m_acc[18] + m[18];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[18] <= m_acc[18];
	else if (sam_clk_en)
		m_acc_reg[18] <= m_acc[18];
	else
		m_acc_reg[18] <= m_acc_reg[18];

/************************* m[19]******************/

always @ *
	if(reset)
		m[19] <= 36'sd0;
	else
		m[19] <= xm[19] * h[19];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[19] <= m[19];
	else if (counter == 2'd3)
		m_acc[19] <= m[19];
	else
		m_acc[19] <= m_acc[19] + m[19];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[19] <= m_acc[19];
	else if (sam_clk_en)
		m_acc_reg[19] <= m_acc[19];
	else
		m_acc_reg[19] <= m_acc_reg[19];

/************************** LUTS ********************/

always @ *
begin
	case(counter)
		2'd0 : h[0] = 18'sd 166;
		2'd1 : h[0] = 18'sd 194;
		2'd2 : h[0] = 18'sd 61;
		2'd3 : h[0] = -18'sd 149;
		default: h[0] = 18'sd 166;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[1] = -18'sd 275;
		2'd1 : h[1] = -18'sd 198;
		2'd2 : h[1] = 18'sd 62;
		2'd3 : h[1] = 18'sd 332;
		default: h[1] = -18'sd 665;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[2] = 18'sd 398;
		2'd1 : h[2] = 18'sd 163;
		2'd2 : h[2] = -18'sd 256;
		2'd3 : h[2] = -18'sd 575;
		default: h[2] = 18'sd 398;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[3] = -18'sd 529;
		2'd1 : h[3] = -18'sd 73;
		2'd2 : h[3] = 18'sd 540;
		2'd3 : h[3] = 18'sd 889;
		default: h[3] = -18'sd 245;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[4] = 18'sd 662;
		2'd1 : h[4] = -18'sd 96;
		2'd2 : h[4] = -18'sd 946;
		2'd3 : h[4] = -18'sd 1295;
		default: h[4] = 18'sd 662;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[5] = -18'sd 791;
		2'd1 : h[5] = 18'sd 382;
		2'd2 : h[5] = 18'sd 1529;
		2'd3 : h[5] = 18'sd 1833;
		default: h[5] = -18'sd 1099;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[6] = 18'sd 908;
		2'd1 : h[6] = -18'sd 857;
		2'd2 : h[6] = -18'sd 2403;
		2'd3 : h[6] = -18'sd 2601;
		default: h[6] = 18'sd 908;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[7] = -18'sd 1007;
		2'd1 : h[7] = 18'sd 1688;
		2'd2 : h[7] = 18'sd 3871;
		2'd3 : h[7] = 18'sd 3878;
		default: h[7] = -18'sd 249;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[8] = 18'sd 1082;
		2'd1 : h[8] = -18'sd 3425;
		2'd2 : h[8] = -18'sd 7056;
		2'd3 : h[8] = -18'sd 6870;
		default: h[8] = 18'sd 1082;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[9] = -18'sd 1129;
		2'd1 : h[9] = 18'sd 9550;
		2'd2 : h[9] = 18'sd 22113;
		2'd3 : h[9] = 18'sd 32208;
		default: h[9] = -18'sd 1593;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[10] = 18'sd 36068;
		2'd1 : h[10] = 18'sd 32208;
		2'd2 : h[10] = 18'sd 22113;
		2'd3 : h[10] = 18'sd 9550;
		default: h[10] = 18'sd 36068;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[11] = -18'sd 1129;
		2'd1 : h[11] = -18'sd 6870;
		2'd2 : h[11] = -18'sd 7056;
		2'd3 : h[11] = -18'sd 3425;
		default: h[11] = -18'sd 1023;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[12] = 18'sd 1082;
		2'd1 : h[12] = 18'sd 3878;
		2'd2 : h[12] = 18'sd 3871;
		2'd3 : h[12] = 18'sd 1688;
		default: h[12] = 18'sd 1082;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[13] = -18'sd 1007;
		2'd1 : h[13] = -18'sd 2601;
		2'd2 : h[13] = -18'sd 2403;
		2'd3 : h[13] = -18'sd 857;
		default: h[13] = -18'sd 2115;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[14] = 18'sd 908;
		2'd1 : h[14] = 18'sd 1833;
		2'd2 : h[14] = 18'sd 1529;
		2'd3 : h[14] = 18'sd 382;
		default: h[14] = 18'sd 908;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[15] = -18'sd 791;
		2'd1 : h[15] = -18'sd 1295;
		2'd2 : h[15] = -18'sd 946;
		2'd3 : h[15] = -18'sd 96;
		default: h[15] = -18'sd 2161;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[16] = 18'sd 662;
		2'd1 : h[16] = 18'sd 889;
		2'd2 : h[16] = 18'sd 540;
		2'd3 : h[16] = -18'sd 73;
		default: h[16] = 18'sd 662;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[17] = -18'sd 529;
		2'd1 : h[17] = -18'sd 575;
		2'd2 : h[17] = -18'sd 256;
		2'd3 : h[17] = 18'sd 163;
		default: h[17] = -18'sd 2649;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[18] = 18'sd 398;
		2'd1 : h[18] = 18'sd 332;
		2'd2 : h[18] = 18'sd 62;
		2'd3 : h[18] = -18'sd 198;
		default: h[18] = 18'sd 398;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : h[19] = -18'sd 275;
		2'd1 : h[19] = -18'sd 149;
		2'd2 : h[19] = 18'sd 61;
		2'd3 : h[19] = 18'sd 194;
		default: h[19] = -18'sd 3783;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[0] = x[0];
		2'd1 : xm[0] = x[1];
		2'd2 : xm[0] = x[2];
		2'd3 : xm[0] = x[3];
		default: xm[0] = x[0];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[1] = x[4];
		2'd1 : xm[1] = x[5];
		2'd2 : xm[1] = x[6];
		2'd3 : xm[1] = x[7];
		default: xm[1] = x[4];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[2] = x[8];
		2'd1 : xm[2] = x[9];
		2'd2 : xm[2] = x[10];
		2'd3 : xm[2] = x[11];
		default: xm[2] = x[8];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[3] = x[12];
		2'd1 : xm[3] = x[13];
		2'd2 : xm[3] = x[14];
		2'd3 : xm[3] = x[15];
		default: xm[3] = x[12];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[4] = x[16];
		2'd1 : xm[4] = x[17];
		2'd2 : xm[4] = x[18];
		2'd3 : xm[4] = x[19];
		default: xm[4] = x[16];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[5] = x[20];
		2'd1 : xm[5] = x[21];
		2'd2 : xm[5] = x[22];
		2'd3 : xm[5] = x[23];
		default: xm[5] = x[20];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[6] = x[24];
		2'd1 : xm[6] = x[25];
		2'd2 : xm[6] = x[26];
		2'd3 : xm[6] = x[27];
		default: xm[6] = x[24];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[7] = x[28];
		2'd1 : xm[7] = x[29];
		2'd2 : xm[7] = x[30];
		2'd3 : xm[7] = x[31];
		default: xm[7] = x[28];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[8] = x[32];
		2'd1 : xm[8] = x[33];
		2'd2 : xm[8] = x[34];
		2'd3 : xm[8] = x[35];
		default: xm[8] = x[32];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[9] = x[36];
		2'd1 : xm[9] = x[37];
		2'd2 : xm[9] = x[38];
		2'd3 : xm[9] = x[39];
		default: xm[9] = x[36];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[10] = x[40];
		2'd1 : xm[10] = x[41];
		2'd2 : xm[10] = x[42];
		2'd3 : xm[10] = x[43];
		default: xm[10] = x[40];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[11] = x[44];
		2'd1 : xm[11] = x[45];
		2'd2 : xm[11] = x[46];
		2'd3 : xm[11] = x[47];
		default: xm[11] = x[44];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[12] = x[48];
		2'd1 : xm[12] = x[49];
		2'd2 : xm[12] = x[50];
		2'd3 : xm[12] = x[51];
		default: xm[12] = x[48];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[13] = x[52];
		2'd1 : xm[13] = x[53];
		2'd2 : xm[13] = x[54];
		2'd3 : xm[13] = x[55];
		default: xm[13] = x[52];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[14] = x[56];
		2'd1 : xm[14] = x[57];
		2'd2 : xm[14] = x[58];
		2'd3 : xm[14] = x[59];
		default: xm[14] = x[56];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[15] = x[60];
		2'd1 : xm[15] = x[61];
		2'd2 : xm[15] = x[62];
		2'd3 : xm[15] = x[63];
		default: xm[15] = x[60];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[16] = x[64];
		2'd1 : xm[16] = x[65];
		2'd2 : xm[16] = x[66];
		2'd3 : xm[16] = x[67];
		default: xm[16] = x[64];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[17] = x[68];
		2'd1 : xm[17] = x[69];
		2'd2 : xm[17] = x[70];
		2'd3 : xm[17] = x[71];
		default: xm[17] = x[68];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[18] = x[72];
		2'd1 : xm[18] = x[73];
		2'd2 : xm[18] = x[74];
		2'd3 : xm[18] = x[75];
		default: xm[18] = x[72];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm[19] = x[76];
		2'd1 : xm[19] = x[77];
		2'd2 : xm[19] = x[78];
		2'd3 : xm[19] = x[79];
		default: xm[19] = x[76];
	endcase
end
endmodule