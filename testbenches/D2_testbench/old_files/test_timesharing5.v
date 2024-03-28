module test_timesharing5 #(
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
reg signed [17:0] xd[COEFF_LEN-1:0]; // for 81 coefficients
reg signed [17:0] x[HALF_COEFF_LEN:0];
reg signed [17:0] xm[9:0]; // 1s17
reg signed [17:0] h[9:0]; // 0s18
reg signed [35:0] m[9:0]; // 1s35
reg signed [35:0] m_acc[9:0]; // 1s35
reg signed [35:0] m_acc_reg[9:0]; //1s35
reg signed [35:0] sum_level_1[4:0]; // 1s35
reg signed [35:0] sum_level_2[1:0]; // 1s35
reg signed [35:0] sum_level_3[1:0]; // 1s35 only add sum_level_2[0:3]
// reg signed [35:0] sum_level_4[1:0]; // add sum_level3 and sum_level_2[4] with mout_21
reg signed [35:0] y_temp; // add sum_level4
reg signed [35:0] mout11, mout11_reg, mout11_reg2;

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
        xd[0] <= 18'sd0;
    else if (sam_clk_en)
        xd[0] <= x_in;
	else
		xd[0] <= xd[0];

always @ (posedge clk or posedge reset)
    if(reset) 
    begin
        for(i=1; i<COEFF_LEN; i=i+1)
            xd[i] <= 18'sd0;
    end
    else if (sam_clk_en)
    begin
        for(i=1; i<COEFF_LEN; i=i+1)
            xd[i] <= xd[i-1];
    end
	else
    begin
        for(i=1; i<COEFF_LEN; i=i+1)
            xd[i] <= xd[i];
    end


always @ *
begin
    for(i=0; i<=HALF_COEFF_LEN-1; i= i+1)
    x[i] <= {xd[i][17], xd[i][17:1]} + {xd[COEFF_LEN-1-i][17], xd[COEFF_LEN-1-i][17:1]}; // sign extend to see whats up 2s17
end

// center value
always @ *
	x[HALF_COEFF_LEN] = {xd[HALF_COEFF_LEN][17], xd[HALF_COEFF_LEN][17:1]};

/************************sum_level***********************/

// s1
always @ (posedge clk or posedge reset)
	if(reset)
		for(i=0; i<5; i = i+1)
			sum_level_1[i] = 36'sd0;
	else
		for(i=0; i<5; i = i+1)
			sum_level_1[i] = m_acc_reg[2*i] + m_acc_reg[2*i+1];
 
 // s2
always @ (posedge clk or posedge reset)

	if(reset)
		for(i=0; i<2; i = i + 1)
			sum_level_2[i] = 36'sd0;
	else
		for(i=0; i<2; i = i+1)
			sum_level_2[i] = sum_level_1[2*i] + sum_level_1[2*i+1];

// s3
always @ (posedge clk or posedge reset)

	if(reset)
		for(i=0; i<2; i = i + 1)
			sum_level_3[i] = 36'sd0;
	else begin
		sum_level_3[0] = sum_level_2[0] + sum_level_2[1];
		sum_level_3[1] = sum_level_1[4] + mout11_reg2;
	end

		// for(i = 0; i<2; i = i + 1)
			// sum_level_3[i] = sum_level_2[2*i] + sum_level_2[2*i+1];


// // s4
// always @ (posedge clk or posedge reset)

// 	if(reset)
// 		begin
// 		sum_level_4[0] = 36'sd0;
// 		sum_level_4[1] = 36'sd0;
// 		end
// 	else
// 		begin
// 		sum_level_4[0] = sum_level_3[0] + sum_level_3[1];
// 		sum_level_4[1] = sum_level_2[4] + mout21_reg;
// 		end
// y_temp
always @ *
	if(reset)
		y_temp = 36'sd0;
	else
		y_temp = sum_level_3[0] + sum_level_3[1];

always @ (posedge clk or reset)
	if(reset)
		y <= y_temp[34:17];
	else if (sam_clk_en)
		y <= y_temp[34:17];
	else
		y <= y;
/********************** single coeff ***************/

wire signed [17:0] h40;

assign h40 = 18'sd 36068;

always @ *
	mout11 = x[40] * h40;

always @ (posedge clk or posedge reset)
	if (reset)
		// mout11_reg <= mout11;
		mout11_reg <= 18'sd0;
	else if (sam_clk_en)
		mout11_reg <= mout11;
	else
		mout11_reg <= mout11_reg;

always @ (posedge clk or posedge reset)
	if (reset)
		// mout21_reg2 <= mout21_reg;
		mout11_reg2 <= 18'sd0;
	else if (sam_clk_en)
		mout11_reg2 <= mout11_reg;
	else
		mout11_reg2 <= mout11_reg2;

/************************* m[0]******************/

always @ *
	if(reset)
		m[0] = 36'sd0;
	else
		m[0] = xm[0] * h[0];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[0] <= 36'sd0;
	else if (counter == 2'd0)
		m_acc[0] <= m[0];
	else
		m_acc[0] <= m_acc[0] + m[0];

reg signed [35:0] m0_acc_delay[2:0];

always @ (posedge clk)
		begin
		m0_acc_delay[0] <= m_acc[0];
		m0_acc_delay[1] <= m0_acc_delay[0];
		m0_acc_delay[2] <= m0_acc_delay[1];
		end

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[0] <= 36'sd0;
	else if (sam_clk_en)
		m_acc_reg[0] <= m0_acc_delay[2];
	else
		m_acc_reg[0] <= m_acc_reg[0];

/************************* m[1]******************/

always @ *
	if(reset)
		m[1] = 36'sd0;
	else
		m[1] = xm[1] * h[1];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[1] <= 36'sd0;
	else if (counter == 2'd0)
		m_acc[1] <= m[1];
	else
		m_acc[1] <= m_acc[1] + m[1];

reg signed [35:0] m1_acc_delay[2:0];

always @ (posedge clk)
		begin
		m1_acc_delay[0] <= m_acc[1];
		m1_acc_delay[1] <= m1_acc_delay[0];
		m1_acc_delay[2] <= m1_acc_delay[1];
		end

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[1] <= 36'sd0;
	else if (sam_clk_en)
		m_acc_reg[1] <= m1_acc_delay[2];
	else
		m_acc_reg[1] <= m_acc_reg[1];

/************************* m[2]******************/

always @ *
	if(reset)
		m[2] = 36'sd0;
	else
		m[2] = xm[2] * h[2];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[2] <= 36'sd0;
	else if (counter == 2'd0)
		m_acc[2] <= m[2];
	else
		m_acc[2] <= m_acc[2] + m[2];

reg signed [35:0] m2_acc_delay[2:0];

always @ (posedge clk)
		begin
		m2_acc_delay[0] <= m_acc[2];
		m2_acc_delay[1] <= m2_acc_delay[0];
		m2_acc_delay[2] <= m2_acc_delay[1];
		end

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[2] <= 36'sd0;
	else if (sam_clk_en)
		m_acc_reg[2] <= m2_acc_delay[2];
	else
		m_acc_reg[2] <= m_acc_reg[2];

/************************* m[3]******************/

always @ *
	if(reset)
		m[3] = 36'sd0;
	else
		m[3] = xm[3] * h[3];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[3] <= 36'sd0;
	else if (counter == 2'd0)
		m_acc[3] <= m[3];
	else
		m_acc[3] <= m_acc[3] + m[3];

reg signed [35:0] m3_acc_delay[2:0];

always @ (posedge clk)
		begin
		m3_acc_delay[0] <= m_acc[3];
		m3_acc_delay[1] <= m3_acc_delay[0];
		m3_acc_delay[2] <= m3_acc_delay[1];
		end

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[3] <= 36'sd0;
	else if (sam_clk_en)
		m_acc_reg[3] <= m3_acc_delay[2];
	else
		m_acc_reg[3] <= m_acc_reg[3];

/************************* m[4]******************/

always @ *
	if(reset)
		m[4] = 36'sd0;
	else
		m[4] = xm[4] * h[4];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[4] <= 36'sd0;
	else if (counter == 2'd0)
		m_acc[4] <= m[4];
	else
		m_acc[4] <= m_acc[4] + m[4];

reg signed [35:0] m4_acc_delay[2:0];

always @ (posedge clk)
		begin
		m4_acc_delay[0] <= m_acc[4];
		m4_acc_delay[1] <= m4_acc_delay[0];
		m4_acc_delay[2] <= m4_acc_delay[1];
		end

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[4] <= 36'sd0;
	else if (sam_clk_en)
		m_acc_reg[4] <= m4_acc_delay[2];
	else
		m_acc_reg[4] <= m_acc_reg[4];

/************************* m[5]******************/

always @ *
	if(reset)
		m[5] = 36'sd0;
	else
		m[5] = xm[5] * h[5];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[5] <= 36'sd0;
	else if (counter == 2'd0)
		m_acc[5] <= m[5];
	else
		m_acc[5] <= m_acc[5] + m[5];

reg signed [35:0] m5_acc_delay[2:0];

always @ (posedge clk)
		begin
		m5_acc_delay[0] <= m_acc[5];
		m5_acc_delay[1] <= m5_acc_delay[0];
		m5_acc_delay[2] <= m5_acc_delay[1];
		end

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[5] <= 36'sd0;
	else if (sam_clk_en)
		m_acc_reg[5] <= m5_acc_delay[2];
	else
		m_acc_reg[5] <= m_acc_reg[5];

/************************* m[6]******************/

always @ *
	if(reset)
		m[6] = 36'sd0;
	else
		m[6] = xm[6] * h[6];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[6] <= 36'sd0;
	else if (counter == 2'd0)
		m_acc[6] <= m[6];
	else
		m_acc[6] <= m_acc[6] + m[6];

reg signed [35:0] m6_acc_delay[2:0];

always @ (posedge clk)
		begin
		m6_acc_delay[0] <= m_acc[6];
		m6_acc_delay[1] <= m6_acc_delay[0];
		m6_acc_delay[2] <= m6_acc_delay[1];
		end

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[6] <= 36'sd0;
	else if (sam_clk_en)
		m_acc_reg[6] <= m6_acc_delay[2];
	else
		m_acc_reg[6] <= m_acc_reg[6];

/************************* m[7]******************/

always @ *
	if(reset)
		m[7] = 36'sd0;
	else
		m[7] = xm[7] * h[7];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[7] <= 36'sd0;
	else if (counter == 2'd0)
		m_acc[7] <= m[7];
	else
		m_acc[7] <= m_acc[7] + m[7];

reg signed [35:0] m7_acc_delay[2:0];

always @ (posedge clk)
		begin
		m7_acc_delay[0] <= m_acc[7];
		m7_acc_delay[1] <= m7_acc_delay[0];
		m7_acc_delay[2] <= m7_acc_delay[1];
		end

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[7] <= 36'sd0;
	else if (sam_clk_en)
		m_acc_reg[7] <= m7_acc_delay[2];
	else
		m_acc_reg[7] <= m_acc_reg[7];

/************************* m[8]******************/

always @ *
	if(reset)
		m[8] = 36'sd0;
	else
		m[8] = xm[8] * h[8];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[8] <= 36'sd0;
	else if (counter == 2'd0)
		m_acc[8] <= m[8];
	else
		m_acc[8] <= m_acc[8] + m[8];

reg signed [35:0] m8_acc_delay[2:0];

always @ (posedge clk)
		begin
		m8_acc_delay[0] <= m_acc[8];
		m8_acc_delay[1] <= m8_acc_delay[0];
		m8_acc_delay[2] <= m8_acc_delay[1];
		end

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[8] <= 36'sd0;
	else if (sam_clk_en)
		m_acc_reg[8] <= m8_acc_delay[2];
	else
		m_acc_reg[8] <= m_acc_reg[8];

/************************* m[9]******************/

always @ *
	if(reset)
		m[9] = 36'sd0;
	else
		m[9] = xm[9] * h[9];

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc[9] <= 36'sd0;
	else if (counter == 2'd0)
		m_acc[9] <= m[9];
	else
		m_acc[9] <= m_acc[9] + m[9];

reg signed [35:0] m9_acc_delay[2:0];

always @ (posedge clk)
		begin
		m9_acc_delay[0] <= m_acc[9];
		m9_acc_delay[1] <= m9_acc_delay[0];
		m9_acc_delay[2] <= m9_acc_delay[1];
		end

always @ (posedge clk or posedge reset)
	if(reset)
		m_acc_reg[9] <= 36'sd0;
	else if (sam_clk_en)
		m_acc_reg[9] <= m9_acc_delay[2];
	else
		m_acc_reg[9] <= m_acc_reg[9];

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
		default: h[1] = -18'sd 275;
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
		default: h[3] = -18'sd 529;
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
		default: h[5] = -18'sd 791;
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
		default: h[7] = -18'sd 1007;
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
		default: h[9] = -18'sd 1129;
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
endmodule