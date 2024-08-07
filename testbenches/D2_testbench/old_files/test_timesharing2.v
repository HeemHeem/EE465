module test_timesharing2 #(
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
reg signed [35:0] sum_level_1[5:0];
reg signed [35:0] sum_level_2[2:0];
reg signed [35:0] sum_level_3;
// reg signed [17:0] sum_out[HALF_COEFF_LEN-1:0];
// reg signed [36:0] mult_out[HALF_COEFF_LEN:0]; // 1s35 but changed to 2s35
// reg signed [17:0] b[HALF_COEFF_LEN:0]; // coefficients
reg signed [17:0] hm0, hm1, hm2, hm3, hm4, hm5, hm6, hm7, hm8, hm9, hm10, hm11, hm12, hm13, hm14, hm15, hm16, hm17, hm18, hm19;
reg signed [17:0] xm0, xm1, xm2, xm3, xm4, xm5, xm6, xm7, xm8, xm9, xm10, xm11, xm12, xm13, xm14, xm15, xm16, xm17, xm18, xm19; // hm's- 0s18, xm's 1s17
reg signed [35:0] m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16, m17, m18, m19, m20; // 1s35s
reg signed [35:0] m0_out, m1_out, m2_out, m3_out, m4_out, m5_out, m6_out, m7_out, m8_out, m9_out, m10_out; // 1s35
reg signed [35:0] m0_acc, m1_acc, m2_acc, m3_acc, m4_acc, m5_acc, m6_acc, m7_acc, m8_acc, m9_acc, m10_acc, m11_acc, m12_acc, m13_acc, m14_acc, m15_acc, m16_acc; // 1s35

reg signed [35:0] m0_acc_reg, m1_acc_reg, m2_acc_reg, m3_acc_reg, m4_acc_reg, m5_acc_reg, m6_acc_reg, m7_acc_reg, m8_acc_reg, m9_acc_reg, m10_acc_reg; // 1s35

reg signed [35:0] y_temp; // 1s35
//reg [1:0] counter;
reg [1:0] sub_counter;
initial begin
counter <= 2'd0;
sub_counter <= 2'd0;
end

always @ (posedge clk or posedge reset)
	if(reset)
		sub_counter <= 2'd0;
	else if (sub_counter == 2'd2)
		sub_counter <= 2'd0;
	else
		sub_counter <= sub_counter + 2'd1;


always @ (posedge clk or posedge reset)
	if(reset)
		counter <= 2'd0;
	else if (counter == 2'd3)
		counter <= 2'd0;
	else
		counter <= counter + 2'd1;




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
    

//always @ (posedge clk or posedge reset)
//    if(reset)
//        y <= 0;
//    else if(sam_clk_en)
//        y <= sum_out[HALF_COEFF_LEN-1];
//	else
//		y <= y;

 

/************************************************************m0-1**************************************/
always @ (posedge clk or posedge reset)
	if(reset)
		m0 <= 36'sd0;
	else
		m0 <= xm0 * hm0;

always @ (posedge clk or posedge reset)
	if(reset)
		m1 <= 36'sd0;
	else
		m1 <= xm1 * hm1;

// sum mult outputs
always @ (posedge clk)
	if(reset)
		m0_out = 36'sd0;
	else
		m0_out = m0 + m1;
// acc
always @ (posedge clk or posedge reset)
	if(reset)
		m0_acc <= m0_out;
	else if (sub_counter == 2'd2)
		m0_acc <= m0_out;
	else
		m0_acc <= m0_acc + m0_out;

// reg signed [35:0] m0_acc_delay[2:0];
// always @ (posedge clk) begin
// 	m0_acc_delay[0] <= m0_acc;
// 	m0_acc_delay[1] <= m0_acc_delay[0];
// 	m0_acc_delay[2] <= m0_acc_delay[1];
// end


// acc reg
always @ (posedge clk or posedge reset)
	if(reset)
		// m0_acc_reg <= m0_acc_delay[2];
		m0_acc_reg <= m0_acc;
	else if (sam_clk_en)
		// m0_acc_reg <= m0_acc_delay[2];
		m0_acc_reg <= m0_acc;
	else
		m0_acc_reg <= m0_acc_reg;


/************************************************************m2-3**************************************/



always @ *//(posedge clk or posedge reset)
	if(reset)
		m2 <= 36'sd0;
	else
		m2 <= xm2 * hm2;

always @ *//(posedge clk or posedge reset)
	if(reset)
		m3 <= 36'sd0;
	else
		m3 <= xm3 * hm3;

// sum mult outputs
always @ *
	if(reset)
		m1_out = 36'sd0;
	else
		m1_out = m2 + m3;
// acc
always @ (posedge clk or posedge reset)
	if(reset)
		m1_acc <= m1_out;
	else if (sam_clk_en)
		m1_acc <= m1_out;
	else
		m1_acc <= m1_acc + m1_out;



// reg signed [35:0] m1_acc_delay[2:0];
// always @ (posedge clk) begin
// 	m1_acc_delay[0] <= m1_acc;
// 	m1_acc_delay[1] <= m1_acc_delay[0];
// 	m1_acc_delay[2] <= m1_acc_delay[1];
// end

// acc reg
always @ (posedge clk or posedge reset)
	if(reset)
		m1_acc_reg <= m1_acc;
		// m1_acc_reg <= m1_acc_delay[2];
	else if (sam_clk_en)
		m1_acc_reg <= m1_acc;
		// m1_acc_reg <= m1_acc_delay[2];
	else
		m1_acc_reg <= m1_acc_reg;

/************************************************************m4-5**************************************/


always @ *//(posedge clk or posedge reset)
	if(reset)
		m4 <= 36'sd0;
	else
		m4 <= xm4 * hm4;

always @ *//(posedge clk or posedge reset)
	if(reset)
		m5 <= 36'sd0;
	else
		m5 <= xm5 * hm5;

// sum mult outputs
always @ *
	if(reset)
		m2_out = 36'sd0;
	else
		m2_out = m4 + m5;

// acc
always @ (posedge clk or posedge reset)
	if(reset)
		m2_acc <= m2_out;
	else if (sam_clk_en)
		m2_acc <= m2_out;
	else
		m2_acc <= m2_acc + m2_out;


// reg signed [35:0] m2_acc_delay[2:0];
// always @ (posedge clk) begin
// 	m2_acc_delay[0] <= m2_acc;
// 	m2_acc_delay[1] <= m2_acc_delay[0];
// 	m2_acc_delay[2] <= m2_acc_delay[1];
// end

// acc reg
always @ (posedge clk or posedge reset)
	if(reset)
		m2_acc_reg <= m2_acc;
		// m2_acc_reg <= m2_acc_delay[2];
	else if (sam_clk_en)
		m2_acc_reg <= m2_acc;
		// m2_acc_reg <= m2_acc_delay[2];
	else
		m2_acc_reg <= m2_acc_reg;


/************************************************************m6-7**************************************/


always @ *//(posedge clk or posedge reset)
	if(reset)
		m6 <= 36'sd0;
	else
		m6 <= xm6 * hm6;

always @ *//(posedge clk or posedge reset)
	if(reset)
		m7 <= 36'sd0;
	else
		m7 <= xm7 * hm7;

// sum  mult outputs
always @ *
	if(reset)
		m3_out = 36'sd0;
	else
		m3_out = m6 + m7;
// acc
always @ (posedge clk or posedge reset)
	if(reset)
		m3_acc <= m3_out;
	else if (sam_clk_en)
		m3_acc <= m3_out;
	else
		m3_acc <= m3_acc + m3_out;

// reg signed [35:0] m3_acc_delay[2:0];
// always @ (posedge clk) begin
// 	m3_acc_delay[0] <= m3_acc;
// 	m3_acc_delay[1] <= m3_acc_delay[0];
// 	m3_acc_delay[2] <= m3_acc_delay[1];
// end

// acc reg
always @ (posedge clk or posedge reset)
	if(reset)
		m3_acc_reg <= m3_acc;
		// m3_acc_reg <= m3_acc_delay[2];
	else if (sam_clk_en)
		m3_acc_reg <= m3_acc;
		// m3_acc_reg <= m3_acc_delay[2];
	else
		m3_acc_reg <= m3_acc_reg;


/************************************************************m8-9**************************************/

always @ *//(posedge clk or posedge reset)
	if(reset)
		m8 <= 36'sd0;
	else
		m8 <= xm8 * hm8;

always @ *//(posedge clk or posedge reset)
	if(reset)
		m9 <= 36'sd0;
	else
		m9 <= xm9 * hm9;


// sum mult outputs
always @ *
	if(reset)
		m4_out = 36'sd0;
	else
		m4_out = m8 + m9;


// acc
always @ (posedge clk or posedge reset)
	if(reset)
		m4_acc <= m4_out;
	else if (sam_clk_en)
		m4_acc <= m4_out;
	else
		m4_acc <= m4_acc + m4_out;

// reg signed [35:0] m4_acc_delay[2:0];
// always @ (posedge clk) begin
// 	m4_acc_delay[0] <= m4_acc;
// 	m4_acc_delay[1] <= m4_acc_delay[0];
// 	m4_acc_delay[2] <= m4_acc_delay[1];
// end

// acc reg
always @ (posedge clk or posedge reset)
	if(reset)
		m4_acc_reg <= m4_acc;
		// m4_acc_reg <= m4_acc_delay[2];
	else if (sam_clk_en)
		m4_acc_reg <= m4_acc;
		// m4_acc_reg <= m4_acc_delay[2];
	else
		m4_acc_reg <= m4_acc_reg;

/************************************************************m10-11**************************************/

always @ *//(posedge clk or posedge reset)
	if(reset)
		m10 <= 36'sd0;
	else
		m10 <= xm10 * hm10;

always @ *//(posedge clk or posedge reset)
	if(reset)
		m11 <= 36'sd0;
	else
		m11 <= xm11 * hm11;

// sum mult outputs
always @ *
	if(reset)
		m5_out = 36'sd0;
	else
		m5_out = m10 + m11;

// acc
always @ (posedge clk or posedge reset)
	if(reset)
		m5_acc <= m5_out;
	else if (sam_clk_en)
		m5_acc <= m5_out;
	else
		m5_acc <= m5_acc + m5_out;

// reg signed [35:0] m5_acc_delay[2:0];
// always @ (posedge clk) begin
// 	m5_acc_delay[0] <= m5_acc;
// 	m5_acc_delay[1] <= m5_acc_delay[0];
// 	m5_acc_delay[2] <= m5_acc_delay[1];
// end

// acc reg
always @ (posedge clk or posedge reset)
	if(reset)
		m5_acc_reg <= m5_acc;
	else if (sam_clk_en)
		m5_acc_reg <= m5_acc;
	else
		m5_acc_reg <= m5_acc_reg;

/************************************************************m12-13**************************************/


always @ *//(posedge clk or posedge reset)
	if(reset)
		m12 <= 36'sd0;
	else
		m12 <= xm12 * hm12;

always @ *//(posedge clk or posedge reset)
	if(reset)
		m13 <= 36'sd0;
	else
		m13 <= xm13 * hm13;

// sum mult outputs
always @ *
	if(reset)
		m6_out = 36'sd0;
	else
		m6_out = m12 + m13;

// acc
always @ (posedge clk or posedge reset)
	if(reset)
		m6_acc <= m6_out;
	else if (sam_clk_en)
		m6_acc <= m6_out;
	else
		m6_acc <= m6_acc + m6_out;


// reg signed [35:0] m6_acc_delay[2:0];
// always @ (posedge clk) begin
// 	m6_acc_delay[0] <= m6_acc;
// 	m6_acc_delay[1] <= m6_acc_delay[0];
// 	m6_acc_delay[2] <= m6_acc_delay[1];
// end

// acc reg
always @ (posedge clk or posedge reset)
	if(reset)
		m6_acc_reg <= m6_acc;
		// m6_acc_reg <= m6_acc_delay[2];
	else if (sam_clk_en)
		m6_acc_reg <= m6_acc;
		// m6_acc_reg <= m6_acc_delay[2];
	else
		m6_acc_reg <= m6_acc_reg;


/************************************************************m14-15**************************************/

always @ *//(posedge clk or posedge reset)
	if(reset)
		m14 <= 36'sd0;
	else
		m14 <= xm14 * hm14;

always @ *//(posedge clk or posedge reset)
	if(reset)
		m15 <= 36'sd0;
	else
		m15 <= xm15 * hm15;

// sum mult outputs
always @ *
	if(reset)
		m7_out = 36'sd0;
	else
		m7_out = m14 + m15;

// acc
always @ (posedge clk or posedge reset)
	if(reset)
		m7_acc <= m7_out;
	else if (sam_clk_en)
		m7_acc <= m7_out;
	else
		m7_acc <= m7_acc + m7_out;


// reg signed [35:0] m7_acc_delay[2:0];
// always @ (posedge clk) begin
// 	m7_acc_delay[0] <= m7_acc;
// 	m7_acc_delay[1] <= m7_acc_delay[0];
// 	m7_acc_delay[2] <= m7_acc_delay[1];
// end

// acc reg
always @ (posedge clk or posedge reset)
	if(reset)
		m7_acc_reg <= m7_acc;
		// m7_acc_reg <= m7_acc_delay[2];
	else if (sam_clk_en)
		m7_acc_reg <= m7_acc;
		// m7_acc_reg <= m7_acc_delay[2];
	else
		m7_acc_reg <= m7_acc_reg;


/************************************************************m16-17**************************************/

always @ *//(posedge clk or posedge reset)
	if(reset)
		m16 <= 36'sd0;
	else
		m16 <= xm16 * hm16;

always @ *//(posedge clk or posedge reset)
	if(reset)
		m17 <= 36'sd0;
	else
		m17 <= xm17 * hm17;


// sum mult outputs
always @ *
	if(reset)
		m8_out = 36'sd0;
	else
		m8_out = m16 + m17;

// acc
always @ (posedge clk or posedge reset)
	if(reset)
		m8_acc <= m8_out;
	else if (sam_clk_en)
		m8_acc <= m8_out;
	else
		m8_acc <= m8_acc + m8_out;

// reg signed [35:0] m8_acc_delay[2:0];
// always @ (posedge clk) begin
// 	m8_acc_delay[0] <= m8_acc;
// 	m8_acc_delay[1] <= m8_acc_delay[0];
// 	m8_acc_delay[2] <= m8_acc_delay[1];
// end


// acc reg
always @ (posedge clk or posedge reset)
	if(reset)
		m8_acc_reg <= m8_acc;
		// m8_acc_reg <= m8_acc_delay[2];
	else if (sam_clk_en)
		m8_acc_reg <= m8_acc;
		// m8_acc_reg <= m8_acc_delay[2];

	else
		m8_acc_reg <= m8_acc_reg;

/************************************************************m18-19**************************************/

always @ *//(posedge clk or posedge reset)
	if(reset)
		m18 <= 36'sd0;
	else
		m18 <= xm18 * hm18;

always @ *//(posedge clk or posedge reset)
	if(reset)
		m19 <= 36'sd0;
	else
		m19 <= xm19 * hm19;

// sum mult outputs
always @ *
	if(reset)
		m9_out = 36'sd0;
	else
		m9_out = m18 + m19;


// acc
always @ (posedge clk or posedge reset)
	if(reset)
		m9_acc <= m9_out;
	else if (sam_clk_en)
		m9_acc <= m9_out;
	else
		m9_acc <= m9_acc + m9_out;



// reg signed [35:0] m9_acc_delay[2:0];
// always @ (posedge clk) begin
// 	m9_acc_delay[0] <= m9_acc;
// 	m9_acc_delay[1] <= m9_acc_delay[0];
// 	m9_acc_delay[2] <= m9_acc_delay[1];
// end



// acc reg
always @ (posedge clk or posedge reset)
	if(reset)
		m9_acc_reg <= m9_acc;
		// m9_acc_reg <= m9_acc_delay[2];
	else if (sam_clk_en)
		m9_acc_reg <= m9_acc;
		// m9_acc_reg <= m9_acc_delay[2];

	else
		m9_acc_reg <= m9_acc_reg;

/************************************************************m20**************************************/

wire signed [17:0] h80;

assign h80 = 18'sd 1;//166;

always @ (posedge clk or posedge reset)
	if(reset)
		m20 <= 36'sd0;
	else if (sam_clk_en)
		m20 <= x[80] * h80;
	else
		m20 <= m20;

// reg signed [35:0] m20_delay;
// always @ (posedge clk)
// 	if(sam_clk_en)
// 		m20_delay <= m20;
// 	else
// 		m20_delay <= m20_delay;


/************************************************adder tree *********************************/
/*********************************** sum_level_1 *********************************/
always @ *
	if (reset)
		sum_level_1[0] = 36'sd0;
	else 
		sum_level_1[0] = m0_acc_reg + m1_acc_reg;


always @ *
	if (reset)
		sum_level_1[1] = 36'sd0;
	else 
		sum_level_1[1] = m2_acc_reg + m3_acc_reg;


always @ *
	if (reset)
		sum_level_1[2] = 36'sd0;
	else 
		sum_level_1[2] = m3_acc_reg + m4_acc_reg;

always @ *
	if (reset)
		sum_level_1[3] = 36'sd0;
	else
		sum_level_1[3] = m5_acc_reg + m6_acc_reg;

always @ *
	if (reset)
		sum_level_1[4] = 36'sd0;
	else
		sum_level_1[4] = m7_acc_reg + m8_acc_reg;

always @ *
	if (reset)
		sum_level_1[5] = 36'sd0;
	else
		sum_level_1[5] = m9_acc_reg + m20;


/************************************ sum_level_2 ******************/

always @ *
	if (reset)
		for(i = 0; i < 3; i = i + 1)
			sum_level_2[i] = 36'sd0;

	else
		for(i = 0; i < 3; i= i +1)
			sum_level_2[i] = sum_level_1[2*i] + sum_level_1[2*i + 1];



/*************************************sum_level_3 *******************/
always @ *
	if (reset)
		sum_level_3 = 36'sd0;
	else
		sum_level_3 = sum_level_2[0] + sum_level_2[1];

always @ *
	if (reset)
		y_temp = 36'sd0;
	else
		y_temp = sum_level_3 + sum_level_2[2]; // 1s35


always @ (posedge clk or posedge reset)
	if(reset)
		y <= 18'sd0;
	else if (sam_clk_en)
		y <= y_temp[35:18];
	else
		y <= y;


// initial begin
// 	hm0 = 18'sd1;
// 	hm1 = 18'sd1;
// 	hm2 = 18'sd1;
// 	hm3 = 18'sd1;
// 	hm4 = 18'sd1;
// 	hm5 = 18'sd1;
// 	hm6 = 18'sd1;
// 	hm7 = 18'sd1;
// 	hm8 = 18'sd1;
// 	hm9 = 18'sd1;
// 	hm10 = 18'sd1;
// 	hm11= 18'sd1;
// 	hm12 = 18'sd1;
// 	hm13 = 18'sd1;
// 	hm14 = 18'sd1;
// 	hm15 = 18'sd1;
// 	hm16 = 18'sd1;
// 	hm17 = 18'sd1;
// 	hm18 = 18'sd1;
// 	hm19 = 18'sd1;


// end



/*******************************************LUTS************************************/
always @ *
begin
	case(counter)
		2'd0 : hm0 = 18'sd 166;
		2'd1 : hm0 = 18'sd 194;
		2'd2 : hm0 = 18'sd 61;
		2'd3 : hm0 = -18'sd 149;
		default: hm0 = 18'sd 166;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm1 = -18'sd 275;
		2'd1 : hm1 = -18'sd 198;
		2'd2 : hm1 = 18'sd 62;
		2'd3 : hm1 = 18'sd 332;
		default: hm1 = -18'sd 665;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm2 = 18'sd 398;
		2'd1 : hm2 = 18'sd 163;
		2'd2 : hm2 = -18'sd 256;
		2'd3 : hm2 = -18'sd 575;
		default: hm2 = 18'sd 398;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm3 = -18'sd 529;
		2'd1 : hm3 = -18'sd 73;
		2'd2 : hm3 = 18'sd 540;
		2'd3 : hm3 = 18'sd 889;
		default: hm3 = -18'sd 245;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm4 = 18'sd 662;
		2'd1 : hm4 = -18'sd 96;
		2'd2 : hm4 = -18'sd 946;
		2'd3 : hm4 = -18'sd 1295;
		default: hm4 = 18'sd 662;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm5 = -18'sd 791;
		2'd1 : hm5 = 18'sd 382;
		2'd2 : hm5 = 18'sd 1529;
		2'd3 : hm5 = 18'sd 1833;
		default: hm5 = -18'sd 1099;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm6 = 18'sd 908;
		2'd1 : hm6 = -18'sd 857;
		2'd2 : hm6 = -18'sd 2403;
		2'd3 : hm6 = -18'sd 2601;
		default: hm6 = 18'sd 908;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm7 = -18'sd 1007;
		2'd1 : hm7 = 18'sd 1688;
		2'd2 : hm7 = 18'sd 3871;
		2'd3 : hm7 = 18'sd 3878;
		default: hm7 = -18'sd 249;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm8 = 18'sd 1082;
		2'd1 : hm8 = -18'sd 3425;
		2'd2 : hm8 = -18'sd 7056;
		2'd3 : hm8 = -18'sd 6870;
		default: hm8 = 18'sd 1082;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm9 = -18'sd 1129;
		2'd1 : hm9 = 18'sd 9550;
		2'd2 : hm9 = 18'sd 22113;
		2'd3 : hm9 = 18'sd 32208;
		default: hm9 = -18'sd 1593;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm10 = 18'sd 36068;
		2'd1 : hm10 = 18'sd 32208;
		2'd2 : hm10 = 18'sd 22113;
		2'd3 : hm10 = 18'sd 9550;
		default: hm10 = 18'sd 36068;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm11 = -18'sd 1129;
		2'd1 : hm11 = -18'sd 6870;
		2'd2 : hm11 = -18'sd 7056;
		2'd3 : hm11 = -18'sd 3425;
		default: hm11 = -18'sd 1023;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm12 = 18'sd 1082;
		2'd1 : hm12 = 18'sd 3878;
		2'd2 : hm12 = 18'sd 3871;
		2'd3 : hm12 = 18'sd 1688;
		default: hm12 = 18'sd 1082;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm13 = -18'sd 1007;
		2'd1 : hm13 = -18'sd 2601;
		2'd2 : hm13 = -18'sd 2403;
		2'd3 : hm13 = -18'sd 857;
		default: hm13 = -18'sd 2115;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm14 = 18'sd 908;
		2'd1 : hm14 = 18'sd 1833;
		2'd2 : hm14 = 18'sd 1529;
		2'd3 : hm14 = 18'sd 382;
		default: hm14 = 18'sd 908;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm15 = -18'sd 791;
		2'd1 : hm15 = -18'sd 1295;
		2'd2 : hm15 = -18'sd 946;
		2'd3 : hm15 = -18'sd 96;
		default: hm15 = -18'sd 2161;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm16 = 18'sd 662;
		2'd1 : hm16 = 18'sd 889;
		2'd2 : hm16 = 18'sd 540;
		2'd3 : hm16 = -18'sd 73;
		default: hm16 = 18'sd 662;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm17 = -18'sd 529;
		2'd1 : hm17 = -18'sd 575;
		2'd2 : hm17 = -18'sd 256;
		2'd3 : hm17 = 18'sd 163;
		default: hm17 = -18'sd 2649;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm18 = 18'sd 398;
		2'd1 : hm18 = 18'sd 332;
		2'd2 : hm18 = 18'sd 62;
		2'd3 : hm18 = -18'sd 198;
		default: hm18 = 18'sd 398;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm19 = -18'sd 275;
		2'd1 : hm19 = -18'sd 149;
		2'd2 : hm19 = 18'sd 61;
		2'd3 : hm19 = 18'sd 194;
		default: hm19 = -18'sd 3783;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm0 = x[0];
		2'd1 : xm0 = x[1];
		2'd2 : xm0 = x[2];
		2'd3 : xm0 = x[3];
		default: xm0 = x[0];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm1 = x[4];
		2'd1 : xm1 = x[5];
		2'd2 : xm1 = x[6];
		2'd3 : xm1 = x[7];
		default: xm1 = x[4];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm2 = x[8];
		2'd1 : xm2 = x[9];
		2'd2 : xm2 = x[10];
		2'd3 : xm2 = x[11];
		default: xm2 = x[8];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm3 = x[12];
		2'd1 : xm3 = x[13];
		2'd2 : xm3 = x[14];
		2'd3 : xm3 = x[15];
		default: xm3 = x[12];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm4 = x[16];
		2'd1 : xm4 = x[17];
		2'd2 : xm4 = x[18];
		2'd3 : xm4 = x[19];
		default: xm4 = x[16];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm5 = x[20];
		2'd1 : xm5 = x[21];
		2'd2 : xm5 = x[22];
		2'd3 : xm5 = x[23];
		default: xm5 = x[20];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm6 = x[24];
		2'd1 : xm6 = x[25];
		2'd2 : xm6 = x[26];
		2'd3 : xm6 = x[27];
		default: xm6 = x[24];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm7 = x[28];
		2'd1 : xm7 = x[29];
		2'd2 : xm7 = x[30];
		2'd3 : xm7 = x[31];
		default: xm7 = x[28];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm8 = x[32];
		2'd1 : xm8 = x[33];
		2'd2 : xm8 = x[34];
		2'd3 : xm8 = x[35];
		default: xm8 = x[32];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm9 = x[36];
		2'd1 : xm9 = x[37];
		2'd2 : xm9 = x[38];
		2'd3 : xm9 = x[39];
		default: xm9 = x[36];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm10 = x[40];
		2'd1 : xm10 = x[41];
		2'd2 : xm10 = x[42];
		2'd3 : xm10 = x[43];
		default: xm10 = x[40];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm11 = x[44];
		2'd1 : xm11 = x[45];
		2'd2 : xm11 = x[46];
		2'd3 : xm11 = x[47];
		default: xm11 = x[44];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm12 = x[48];
		2'd1 : xm12 = x[49];
		2'd2 : xm12 = x[50];
		2'd3 : xm12 = x[51];
		default: xm12 = x[48];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm13 = x[52];
		2'd1 : xm13 = x[53];
		2'd2 : xm13 = x[54];
		2'd3 : xm13 = x[55];
		default: xm13 = x[52];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm14 = x[56];
		2'd1 : xm14 = x[57];
		2'd2 : xm14 = x[58];
		2'd3 : xm14 = x[59];
		default: xm14 = x[56];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm15 = x[60];
		2'd1 : xm15 = x[61];
		2'd2 : xm15 = x[62];
		2'd3 : xm15 = x[63];
		default: xm15 = x[60];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm16 = x[64];
		2'd1 : xm16 = x[65];
		2'd2 : xm16 = x[66];
		2'd3 : xm16 = x[67];
		default: xm16 = x[64];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm17 = x[68];
		2'd1 : xm17 = x[69];
		2'd2 : xm17 = x[70];
		2'd3 : xm17 = x[71];
		default: xm17 = x[68];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm18 = x[72];
		2'd1 : xm18 = x[73];
		2'd2 : xm18 = x[74];
		2'd3 : xm18 = x[75];
		default: xm18 = x[72];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm19 = x[76];
		2'd1 : xm19 = x[77];
		2'd2 : xm19 = x[78];
		2'd3 : xm19 = x[79];
		default: xm19 = x[76];
	endcase
end
endmodule