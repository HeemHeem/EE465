module tx_pract_filter #(
    parameter COEFF_LEN = 65,
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
        y <= 18'sd0;
    else if (sam_clk_en)
        y <= sum_out[HALF_COEFF_LEN-1];
	else
		y <= y;


 


// LUT_0 

always @ *
begin
	case(sum_level_1[0])
		19 'sd 0      :	LUT_out[0]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[0]  = 18'sd 505;
		19 'sd 32768  :	LUT_out[0]  = 18'sd 168;
		-19'sd 32768  :	LUT_out[0]  = -18'sd 168;
		-19'sd 98304  :	LUT_out[0]  = -18'sd 505;
		19 'sd 196608 :	LUT_out[0]  = 18'sd 1010;
		19 'sd 131072 :	LUT_out[0]  = 18'sd 673;
		19 'sd 65536  :	LUT_out[0]  = 18'sd 337;
		-19'sd 65536  :	LUT_out[0]  = -18'sd 337;
		-19'sd 131072 :	LUT_out[0]  = -18'sd 673;
		-19'sd 196608 :	LUT_out[0]  = -18'sd 1010;
		default     :	LUT_out[0]  = 18'sd 0;
	endcase
end

// LUT_1 

always @ *
begin
	case(sum_level_1[1])
		19 'sd 0      :	LUT_out[1]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[1]  = 18'sd 207;
		19 'sd 32768  :	LUT_out[1]  = 18'sd 69;
		-19'sd 32768  :	LUT_out[1]  = -18'sd 69;
		-19'sd 98304  :	LUT_out[1]  = -18'sd 207;
		19 'sd 196608 :	LUT_out[1]  = 18'sd 413;
		19 'sd 131072 :	LUT_out[1]  = 18'sd 276;
		19 'sd 65536  :	LUT_out[1]  = 18'sd 138;
		-19'sd 65536  :	LUT_out[1]  = -18'sd 138;
		-19'sd 131072 :	LUT_out[1]  = -18'sd 276;
		-19'sd 196608 :	LUT_out[1]  = -18'sd 413;
		default     :	LUT_out[1]  = 18'sd 0;
	endcase
end

// LUT_2 

always @ *
begin
	case(sum_level_1[2])
		19 'sd 0      :	LUT_out[2]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[2]  = -18'sd 325;
		19 'sd 32768  :	LUT_out[2]  = -18'sd 108;
		-19'sd 32768  :	LUT_out[2]  = 18'sd 108;
		-19'sd 98304  :	LUT_out[2]  = 18'sd 325;
		19 'sd 196608 :	LUT_out[2]  = -18'sd 649;
		19 'sd 131072 :	LUT_out[2]  = -18'sd 433;
		19 'sd 65536  :	LUT_out[2]  = -18'sd 216;
		-19'sd 65536  :	LUT_out[2]  = 18'sd 216;
		-19'sd 131072 :	LUT_out[2]  = 18'sd 433;
		-19'sd 196608 :	LUT_out[2]  = 18'sd 649;
		default     :	LUT_out[2]  = 18'sd 0;
	endcase
end

// LUT_3 

always @ *
begin
	case(sum_level_1[3])
		19 'sd 0      :	LUT_out[3]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[3]  = -18'sd 730;
		19 'sd 32768  :	LUT_out[3]  = -18'sd 243;
		-19'sd 32768  :	LUT_out[3]  = 18'sd 243;
		-19'sd 98304  :	LUT_out[3]  = 18'sd 730;
		19 'sd 196608 :	LUT_out[3]  = -18'sd 1460;
		19 'sd 131072 :	LUT_out[3]  = -18'sd 973;
		19 'sd 65536  :	LUT_out[3]  = -18'sd 487;
		-19'sd 65536  :	LUT_out[3]  = 18'sd 487;
		-19'sd 131072 :	LUT_out[3]  = 18'sd 973;
		-19'sd 196608 :	LUT_out[3]  = 18'sd 1460;
		default     :	LUT_out[3]  = 18'sd 0;
	endcase
end

// LUT_4 

always @ *
begin
	case(sum_level_1[4])
		19 'sd 0      :	LUT_out[4]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[4]  = -18'sd 671;
		19 'sd 32768  :	LUT_out[4]  = -18'sd 224;
		-19'sd 32768  :	LUT_out[4]  = 18'sd 224;
		-19'sd 98304  :	LUT_out[4]  = 18'sd 671;
		19 'sd 196608 :	LUT_out[4]  = -18'sd 1343;
		19 'sd 131072 :	LUT_out[4]  = -18'sd 895;
		19 'sd 65536  :	LUT_out[4]  = -18'sd 448;
		-19'sd 65536  :	LUT_out[4]  = 18'sd 448;
		-19'sd 131072 :	LUT_out[4]  = 18'sd 895;
		-19'sd 196608 :	LUT_out[4]  = 18'sd 1343;
		default     :	LUT_out[4]  = 18'sd 0;
	endcase
end

// LUT_5 

always @ *
begin
	case(sum_level_1[5])
		19 'sd 0      :	LUT_out[5]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[5]  = -18'sd 92;
		19 'sd 32768  :	LUT_out[5]  = -18'sd 31;
		-19'sd 32768  :	LUT_out[5]  = 18'sd 31;
		-19'sd 98304  :	LUT_out[5]  = 18'sd 92;
		19 'sd 196608 :	LUT_out[5]  = -18'sd 185;
		19 'sd 131072 :	LUT_out[5]  = -18'sd 123;
		19 'sd 65536  :	LUT_out[5]  = -18'sd 62;
		-19'sd 65536  :	LUT_out[5]  = 18'sd 62;
		-19'sd 131072 :	LUT_out[5]  = 18'sd 123;
		-19'sd 196608 :	LUT_out[5]  = 18'sd 185;
		default     :	LUT_out[5]  = 18'sd 0;
	endcase
end

// LUT_6 

always @ *
begin
	case(sum_level_1[6])
		19 'sd 0      :	LUT_out[6]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[6]  = 18'sd 686;
		19 'sd 32768  :	LUT_out[6]  = 18'sd 229;
		-19'sd 32768  :	LUT_out[6]  = -18'sd 229;
		-19'sd 98304  :	LUT_out[6]  = -18'sd 686;
		19 'sd 196608 :	LUT_out[6]  = 18'sd 1372;
		19 'sd 131072 :	LUT_out[6]  = 18'sd 915;
		19 'sd 65536  :	LUT_out[6]  = 18'sd 457;
		-19'sd 65536  :	LUT_out[6]  = -18'sd 457;
		-19'sd 131072 :	LUT_out[6]  = -18'sd 915;
		-19'sd 196608 :	LUT_out[6]  = -18'sd 1372;
		default     :	LUT_out[6]  = 18'sd 0;
	endcase
end

// LUT_7 

always @ *
begin
	case(sum_level_1[7])
		19 'sd 0      :	LUT_out[7]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[7]  = 18'sd 1129;
		19 'sd 32768  :	LUT_out[7]  = 18'sd 376;
		-19'sd 32768  :	LUT_out[7]  = -18'sd 376;
		-19'sd 98304  :	LUT_out[7]  = -18'sd 1129;
		19 'sd 196608 :	LUT_out[7]  = 18'sd 2258;
		19 'sd 131072 :	LUT_out[7]  = 18'sd 1505;
		19 'sd 65536  :	LUT_out[7]  = 18'sd 753;
		-19'sd 65536  :	LUT_out[7]  = -18'sd 753;
		-19'sd 131072 :	LUT_out[7]  = -18'sd 1505;
		-19'sd 196608 :	LUT_out[7]  = -18'sd 2258;
		default     :	LUT_out[7]  = 18'sd 0;
	endcase
end

// LUT_8 

always @ *
begin
	case(sum_level_1[8])
		19 'sd 0      :	LUT_out[8]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[8]  = 18'sd 840;
		19 'sd 32768  :	LUT_out[8]  = 18'sd 280;
		-19'sd 32768  :	LUT_out[8]  = -18'sd 280;
		-19'sd 98304  :	LUT_out[8]  = -18'sd 840;
		19 'sd 196608 :	LUT_out[8]  = 18'sd 1681;
		19 'sd 131072 :	LUT_out[8]  = 18'sd 1121;
		19 'sd 65536  :	LUT_out[8]  = 18'sd 560;
		-19'sd 65536  :	LUT_out[8]  = -18'sd 560;
		-19'sd 131072 :	LUT_out[8]  = -18'sd 1121;
		-19'sd 196608 :	LUT_out[8]  = -18'sd 1681;
		default     :	LUT_out[8]  = 18'sd 0;
	endcase
end

// LUT_9 

always @ *
begin
	case(sum_level_1[9])
		19 'sd 0      :	LUT_out[9]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[9]  = -18'sd 122;
		19 'sd 32768  :	LUT_out[9]  = -18'sd 41;
		-19'sd 32768  :	LUT_out[9]  = 18'sd 41;
		-19'sd 98304  :	LUT_out[9]  = 18'sd 122;
		19 'sd 196608 :	LUT_out[9]  = -18'sd 245;
		19 'sd 131072 :	LUT_out[9]  = -18'sd 163;
		19 'sd 65536  :	LUT_out[9]  = -18'sd 82;
		-19'sd 65536  :	LUT_out[9]  = 18'sd 82;
		-19'sd 131072 :	LUT_out[9]  = 18'sd 163;
		-19'sd 196608 :	LUT_out[9]  = 18'sd 245;
		default     :	LUT_out[9]  = 18'sd 0;
	endcase
end

// LUT_10 

always @ *
begin
	case(sum_level_1[10])
		19 'sd 0      :	LUT_out[10] = 18'sd 0;
		19 'sd 98304  :	LUT_out[10] = -18'sd 1202;
		19 'sd 32768  :	LUT_out[10] = -18'sd 401;
		-19'sd 32768  :	LUT_out[10] = 18'sd 401;
		-19'sd 98304  :	LUT_out[10] = 18'sd 1202;
		19 'sd 196608 :	LUT_out[10] = -18'sd 2403;
		19 'sd 131072 :	LUT_out[10] = -18'sd 1602;
		19 'sd 65536  :	LUT_out[10] = -18'sd 801;
		-19'sd 65536  :	LUT_out[10] = 18'sd 801;
		-19'sd 131072 :	LUT_out[10] = 18'sd 1602;
		-19'sd 196608 :	LUT_out[10] = 18'sd 2403;
		default     :	LUT_out[10] = 18'sd 0;
	endcase
end

// LUT_11 

always @ *
begin
	case(sum_level_1[11])
		19 'sd 0      :	LUT_out[11] = 18'sd 0;
		19 'sd 98304  :	LUT_out[11] = -18'sd 1644;
		19 'sd 32768  :	LUT_out[11] = -18'sd 548;
		-19'sd 32768  :	LUT_out[11] = 18'sd 548;
		-19'sd 98304  :	LUT_out[11] = 18'sd 1644;
		19 'sd 196608 :	LUT_out[11] = -18'sd 3289;
		19 'sd 131072 :	LUT_out[11] = -18'sd 2193;
		19 'sd 65536  :	LUT_out[11] = -18'sd 1096;
		-19'sd 65536  :	LUT_out[11] = 18'sd 1096;
		-19'sd 131072 :	LUT_out[11] = 18'sd 2193;
		-19'sd 196608 :	LUT_out[11] = 18'sd 3289;
		default     :	LUT_out[11] = 18'sd 0;
	endcase
end

// LUT_12 

always @ *
begin
	case(sum_level_1[12])
		19 'sd 0      :	LUT_out[12] = 18'sd 0;
		19 'sd 98304  :	LUT_out[12] = -18'sd 1004;
		19 'sd 32768  :	LUT_out[12] = -18'sd 335;
		-19'sd 32768  :	LUT_out[12] = 18'sd 335;
		-19'sd 98304  :	LUT_out[12] = 18'sd 1004;
		19 'sd 196608 :	LUT_out[12] = -18'sd 2008;
		19 'sd 131072 :	LUT_out[12] = -18'sd 1338;
		19 'sd 65536  :	LUT_out[12] = -18'sd 669;
		-19'sd 65536  :	LUT_out[12] = 18'sd 669;
		-19'sd 131072 :	LUT_out[12] = 18'sd 1338;
		-19'sd 196608 :	LUT_out[12] = 18'sd 2008;
		default     :	LUT_out[12] = 18'sd 0;
	endcase
end

// LUT_13 

always @ *
begin
	case(sum_level_1[13])
		19 'sd 0      :	LUT_out[13] = 18'sd 0;
		19 'sd 98304  :	LUT_out[13] = 18'sd 485;
		19 'sd 32768  :	LUT_out[13] = 18'sd 162;
		-19'sd 32768  :	LUT_out[13] = -18'sd 162;
		-19'sd 98304  :	LUT_out[13] = -18'sd 485;
		19 'sd 196608 :	LUT_out[13] = 18'sd 971;
		19 'sd 131072 :	LUT_out[13] = 18'sd 647;
		19 'sd 65536  :	LUT_out[13] = 18'sd 324;
		-19'sd 65536  :	LUT_out[13] = -18'sd 324;
		-19'sd 131072 :	LUT_out[13] = -18'sd 647;
		-19'sd 196608 :	LUT_out[13] = -18'sd 971;
		default     :	LUT_out[13] = 18'sd 0;
	endcase
end

// LUT_14 

always @ *
begin
	case(sum_level_1[14])
		19 'sd 0      :	LUT_out[14] = 18'sd 0;
		19 'sd 98304  :	LUT_out[14] = 18'sd 1941;
		19 'sd 32768  :	LUT_out[14] = 18'sd 647;
		-19'sd 32768  :	LUT_out[14] = -18'sd 647;
		-19'sd 98304  :	LUT_out[14] = -18'sd 1941;
		19 'sd 196608 :	LUT_out[14] = 18'sd 3882;
		19 'sd 131072 :	LUT_out[14] = 18'sd 2588;
		19 'sd 65536  :	LUT_out[14] = 18'sd 1294;
		-19'sd 65536  :	LUT_out[14] = -18'sd 1294;
		-19'sd 131072 :	LUT_out[14] = -18'sd 2588;
		-19'sd 196608 :	LUT_out[14] = -18'sd 3882;
		default     :	LUT_out[14] = 18'sd 0;
	endcase
end

// LUT_15 

always @ *
begin
	case(sum_level_1[15])
		19 'sd 0      :	LUT_out[15] = 18'sd 0;
		19 'sd 98304  :	LUT_out[15] = 18'sd 2328;
		19 'sd 32768  :	LUT_out[15] = 18'sd 776;
		-19'sd 32768  :	LUT_out[15] = -18'sd 776;
		-19'sd 98304  :	LUT_out[15] = -18'sd 2328;
		19 'sd 196608 :	LUT_out[15] = 18'sd 4655;
		19 'sd 131072 :	LUT_out[15] = 18'sd 3104;
		19 'sd 65536  :	LUT_out[15] = 18'sd 1552;
		-19'sd 65536  :	LUT_out[15] = -18'sd 1552;
		-19'sd 131072 :	LUT_out[15] = -18'sd 3104;
		-19'sd 196608 :	LUT_out[15] = -18'sd 4655;
		default     :	LUT_out[15] = 18'sd 0;
	endcase
end

// LUT_16 

always @ *
begin
	case(sum_level_1[16])
		19 'sd 0      :	LUT_out[16] = 18'sd 0;
		19 'sd 98304  :	LUT_out[16] = 18'sd 1153;
		19 'sd 32768  :	LUT_out[16] = 18'sd 384;
		-19'sd 32768  :	LUT_out[16] = -18'sd 384;
		-19'sd 98304  :	LUT_out[16] = -18'sd 1153;
		19 'sd 196608 :	LUT_out[16] = 18'sd 2305;
		19 'sd 131072 :	LUT_out[16] = 18'sd 1537;
		19 'sd 65536  :	LUT_out[16] = 18'sd 768;
		-19'sd 65536  :	LUT_out[16] = -18'sd 768;
		-19'sd 131072 :	LUT_out[16] = -18'sd 1537;
		-19'sd 196608 :	LUT_out[16] = -18'sd 2305;
		default     :	LUT_out[16] = 18'sd 0;
	endcase
end

// LUT_17 

always @ *
begin
	case(sum_level_1[17])
		19 'sd 0      :	LUT_out[17] = 18'sd 0;
		19 'sd 98304  :	LUT_out[17] = -18'sd 1087;
		19 'sd 32768  :	LUT_out[17] = -18'sd 362;
		-19'sd 32768  :	LUT_out[17] = 18'sd 362;
		-19'sd 98304  :	LUT_out[17] = 18'sd 1087;
		19 'sd 196608 :	LUT_out[17] = -18'sd 2175;
		19 'sd 131072 :	LUT_out[17] = -18'sd 1450;
		19 'sd 65536  :	LUT_out[17] = -18'sd 725;
		-19'sd 65536  :	LUT_out[17] = 18'sd 725;
		-19'sd 131072 :	LUT_out[17] = 18'sd 1450;
		-19'sd 196608 :	LUT_out[17] = 18'sd 2175;
		default     :	LUT_out[17] = 18'sd 0;
	endcase
end

// LUT_18 

always @ *
begin
	case(sum_level_1[18])
		19 'sd 0      :	LUT_out[18] = 18'sd 0;
		19 'sd 98304  :	LUT_out[18] = -18'sd 3050;
		19 'sd 32768  :	LUT_out[18] = -18'sd 1017;
		-19'sd 32768  :	LUT_out[18] = 18'sd 1017;
		-19'sd 98304  :	LUT_out[18] = 18'sd 3050;
		19 'sd 196608 :	LUT_out[18] = -18'sd 6101;
		19 'sd 131072 :	LUT_out[18] = -18'sd 4067;
		19 'sd 65536  :	LUT_out[18] = -18'sd 2034;
		-19'sd 65536  :	LUT_out[18] = 18'sd 2034;
		-19'sd 131072 :	LUT_out[18] = 18'sd 4067;
		-19'sd 196608 :	LUT_out[18] = 18'sd 6101;
		default     :	LUT_out[18] = 18'sd 0;
	endcase
end

// LUT_19 

always @ *
begin
	case(sum_level_1[19])
		19 'sd 0      :	LUT_out[19] = 18'sd 0;
		19 'sd 98304  :	LUT_out[19] = -18'sd 3302;
		19 'sd 32768  :	LUT_out[19] = -18'sd 1101;
		-19'sd 32768  :	LUT_out[19] = 18'sd 1101;
		-19'sd 98304  :	LUT_out[19] = 18'sd 3302;
		19 'sd 196608 :	LUT_out[19] = -18'sd 6604;
		19 'sd 131072 :	LUT_out[19] = -18'sd 4402;
		19 'sd 65536  :	LUT_out[19] = -18'sd 2201;
		-19'sd 65536  :	LUT_out[19] = 18'sd 2201;
		-19'sd 131072 :	LUT_out[19] = 18'sd 4402;
		-19'sd 196608 :	LUT_out[19] = 18'sd 6604;
		default     :	LUT_out[19] = 18'sd 0;
	endcase
end

// LUT_20 

always @ *
begin
	case(sum_level_1[20])
		19 'sd 0      :	LUT_out[20] = 18'sd 0;
		19 'sd 98304  :	LUT_out[20] = -18'sd 1278;
		19 'sd 32768  :	LUT_out[20] = -18'sd 426;
		-19'sd 32768  :	LUT_out[20] = 18'sd 426;
		-19'sd 98304  :	LUT_out[20] = 18'sd 1278;
		19 'sd 196608 :	LUT_out[20] = -18'sd 2557;
		19 'sd 131072 :	LUT_out[20] = -18'sd 1704;
		19 'sd 65536  :	LUT_out[20] = -18'sd 852;
		-19'sd 65536  :	LUT_out[20] = 18'sd 852;
		-19'sd 131072 :	LUT_out[20] = 18'sd 1704;
		-19'sd 196608 :	LUT_out[20] = 18'sd 2557;
		default     :	LUT_out[20] = 18'sd 0;
	endcase
end

// LUT_21 

always @ *
begin
	case(sum_level_1[21])
		19 'sd 0      :	LUT_out[21] = 18'sd 0;
		19 'sd 98304  :	LUT_out[21] = 18'sd 2143;
		19 'sd 32768  :	LUT_out[21] = 18'sd 714;
		-19'sd 32768  :	LUT_out[21] = -18'sd 714;
		-19'sd 98304  :	LUT_out[21] = -18'sd 2143;
		19 'sd 196608 :	LUT_out[21] = 18'sd 4285;
		19 'sd 131072 :	LUT_out[21] = 18'sd 2857;
		19 'sd 65536  :	LUT_out[21] = 18'sd 1428;
		-19'sd 65536  :	LUT_out[21] = -18'sd 1428;
		-19'sd 131072 :	LUT_out[21] = -18'sd 2857;
		-19'sd 196608 :	LUT_out[21] = -18'sd 4285;
		default     :	LUT_out[21] = 18'sd 0;
	endcase
end

// LUT_22 

always @ *
begin
	case(sum_level_1[22])
		19 'sd 0      :	LUT_out[22] = 18'sd 0;
		19 'sd 98304  :	LUT_out[22] = 18'sd 4915;
		19 'sd 32768  :	LUT_out[22] = 18'sd 1638;
		-19'sd 32768  :	LUT_out[22] = -18'sd 1638;
		-19'sd 98304  :	LUT_out[22] = -18'sd 4915;
		19 'sd 196608 :	LUT_out[22] = 18'sd 9829;
		19 'sd 131072 :	LUT_out[22] = 18'sd 6553;
		19 'sd 65536  :	LUT_out[22] = 18'sd 3276;
		-19'sd 65536  :	LUT_out[22] = -18'sd 3276;
		-19'sd 131072 :	LUT_out[22] = -18'sd 6553;
		-19'sd 196608 :	LUT_out[22] = -18'sd 9829;
		default     :	LUT_out[22] = 18'sd 0;
	endcase
end

// LUT_23 

always @ *
begin
	case(sum_level_1[23])
		19 'sd 0      :	LUT_out[23] = 18'sd 0;
		19 'sd 98304  :	LUT_out[23] = 18'sd 4923;
		19 'sd 32768  :	LUT_out[23] = 18'sd 1641;
		-19'sd 32768  :	LUT_out[23] = -18'sd 1641;
		-19'sd 98304  :	LUT_out[23] = -18'sd 4923;
		19 'sd 196608 :	LUT_out[23] = 18'sd 9847;
		19 'sd 131072 :	LUT_out[23] = 18'sd 6565;
		19 'sd 65536  :	LUT_out[23] = 18'sd 3282;
		-19'sd 65536  :	LUT_out[23] = -18'sd 3282;
		-19'sd 131072 :	LUT_out[23] = -18'sd 6565;
		-19'sd 196608 :	LUT_out[23] = -18'sd 9847;
		default     :	LUT_out[23] = 18'sd 0;
	endcase
end

// LUT_24 

always @ *
begin
	case(sum_level_1[24])
		19 'sd 0      :	LUT_out[24] = 18'sd 0;
		19 'sd 98304  :	LUT_out[24] = 18'sd 1374;
		19 'sd 32768  :	LUT_out[24] = 18'sd 458;
		-19'sd 32768  :	LUT_out[24] = -18'sd 458;
		-19'sd 98304  :	LUT_out[24] = -18'sd 1374;
		19 'sd 196608 :	LUT_out[24] = 18'sd 2748;
		19 'sd 131072 :	LUT_out[24] = 18'sd 1832;
		19 'sd 65536  :	LUT_out[24] = 18'sd 916;
		-19'sd 65536  :	LUT_out[24] = -18'sd 916;
		-19'sd 131072 :	LUT_out[24] = -18'sd 1832;
		-19'sd 196608 :	LUT_out[24] = -18'sd 2748;
		default     :	LUT_out[24] = 18'sd 0;
	endcase
end

// LUT_25 

always @ *
begin
	case(sum_level_1[25])
		19 'sd 0      :	LUT_out[25] = 18'sd 0;
		19 'sd 98304  :	LUT_out[25] = -18'sd 4349;
		19 'sd 32768  :	LUT_out[25] = -18'sd 1450;
		-19'sd 32768  :	LUT_out[25] = 18'sd 1450;
		-19'sd 98304  :	LUT_out[25] = 18'sd 4349;
		19 'sd 196608 :	LUT_out[25] = -18'sd 8697;
		19 'sd 131072 :	LUT_out[25] = -18'sd 5798;
		19 'sd 65536  :	LUT_out[25] = -18'sd 2899;
		-19'sd 65536  :	LUT_out[25] = 18'sd 2899;
		-19'sd 131072 :	LUT_out[25] = 18'sd 5798;
		-19'sd 196608 :	LUT_out[25] = 18'sd 8697;
		default     :	LUT_out[25] = 18'sd 0;
	endcase
end

// LUT_26 

always @ *
begin
	case(sum_level_1[26])
		19 'sd 0      :	LUT_out[26] = 18'sd 0;
		19 'sd 98304  :	LUT_out[26] = -18'sd 8959;
		19 'sd 32768  :	LUT_out[26] = -18'sd 2986;
		-19'sd 32768  :	LUT_out[26] = 18'sd 2986;
		-19'sd 98304  :	LUT_out[26] = 18'sd 8959;
		19 'sd 196608 :	LUT_out[26] = -18'sd 17917;
		19 'sd 131072 :	LUT_out[26] = -18'sd 11945;
		19 'sd 65536  :	LUT_out[26] = -18'sd 5972;
		-19'sd 65536  :	LUT_out[26] = 18'sd 5972;
		-19'sd 131072 :	LUT_out[26] = 18'sd 11945;
		-19'sd 196608 :	LUT_out[26] = 18'sd 17917;
		default     :	LUT_out[26] = 18'sd 0;
	endcase
end

// LUT_27 

always @ *
begin
	case(sum_level_1[27])
		19 'sd 0      :	LUT_out[27] = 18'sd 0;
		19 'sd 98304  :	LUT_out[27] = -18'sd 8723;
		19 'sd 32768  :	LUT_out[27] = -18'sd 2908;
		-19'sd 32768  :	LUT_out[27] = 18'sd 2908;
		-19'sd 98304  :	LUT_out[27] = 18'sd 8723;
		19 'sd 196608 :	LUT_out[27] = -18'sd 17446;
		19 'sd 131072 :	LUT_out[27] = -18'sd 11630;
		19 'sd 65536  :	LUT_out[27] = -18'sd 5815;
		-19'sd 65536  :	LUT_out[27] = 18'sd 5815;
		-19'sd 131072 :	LUT_out[27] = 18'sd 11630;
		-19'sd 196608 :	LUT_out[27] = 18'sd 17446;
		default     :	LUT_out[27] = 18'sd 0;
	endcase
end

// LUT_28 

always @ *
begin
	case(sum_level_1[28])
		19 'sd 0      :	LUT_out[28] = 18'sd 0;
		19 'sd 98304  :	LUT_out[28] = -18'sd 1434;
		19 'sd 32768  :	LUT_out[28] = -18'sd 478;
		-19'sd 32768  :	LUT_out[28] = 18'sd 478;
		-19'sd 98304  :	LUT_out[28] = 18'sd 1434;
		19 'sd 196608 :	LUT_out[28] = -18'sd 2867;
		19 'sd 131072 :	LUT_out[28] = -18'sd 1911;
		19 'sd 65536  :	LUT_out[28] = -18'sd 956;
		-19'sd 65536  :	LUT_out[28] = 18'sd 956;
		-19'sd 131072 :	LUT_out[28] = 18'sd 1911;
		-19'sd 196608 :	LUT_out[28] = 18'sd 2867;
		default     :	LUT_out[28] = 18'sd 0;
	endcase
end

// LUT_29 

always @ *
begin
	case(sum_level_1[29])
		19 'sd 0      :	LUT_out[29] = 18'sd 0;
		19 'sd 98304  :	LUT_out[29] = 18'sd 12126;
		19 'sd 32768  :	LUT_out[29] = 18'sd 4042;
		-19'sd 32768  :	LUT_out[29] = -18'sd 4042;
		-19'sd 98304  :	LUT_out[29] = -18'sd 12126;
		19 'sd 196608 :	LUT_out[29] = 18'sd 24251;
		19 'sd 131072 :	LUT_out[29] = 18'sd 16167;
		19 'sd 65536  :	LUT_out[29] = 18'sd 8084;
		-19'sd 65536  :	LUT_out[29] = -18'sd 8084;
		-19'sd 131072 :	LUT_out[29] = -18'sd 16167;
		-19'sd 196608 :	LUT_out[29] = -18'sd 24251;
		default     :	LUT_out[29] = 18'sd 0;
	endcase
end

// LUT_30 

always @ *
begin
	case(sum_level_1[30])
		19 'sd 0      :	LUT_out[30] = 18'sd 0;
		19 'sd 98304  :	LUT_out[30] = 18'sd 28075;
		19 'sd 32768  :	LUT_out[30] = 18'sd 9358;
		-19'sd 32768  :	LUT_out[30] = -18'sd 9358;
		-19'sd 98304  :	LUT_out[30] = -18'sd 28075;
		19 'sd 196608 :	LUT_out[30] = 18'sd 56151;
		19 'sd 131072 :	LUT_out[30] = 18'sd 37434;
		19 'sd 65536  :	LUT_out[30] = 18'sd 18717;
		-19'sd 65536  :	LUT_out[30] = -18'sd 18717;
		-19'sd 131072 :	LUT_out[30] = -18'sd 37434;
		-19'sd 196608 :	LUT_out[30] = -18'sd 56151;
		default     :	LUT_out[30] = 18'sd 0;
	endcase
end

// LUT_31 

always @ *
begin
	case(sum_level_1[31])
		19 'sd 0      :	LUT_out[31] = 18'sd 0;
		19 'sd 98304  :	LUT_out[31] = 18'sd 40893;
		19 'sd 32768  :	LUT_out[31] = 18'sd 13631;
		-19'sd 32768  :	LUT_out[31] = -18'sd 13631;
		-19'sd 98304  :	LUT_out[31] = -18'sd 40893;
		19 'sd 196608 :	LUT_out[31] = 18'sd 81786;
		19 'sd 131072 :	LUT_out[31] = 18'sd 54524;
		19 'sd 65536  :	LUT_out[31] = 18'sd 27262;
		-19'sd 65536  :	LUT_out[31] = -18'sd 27262;
		-19'sd 131072 :	LUT_out[31] = -18'sd 54524;
		-19'sd 196608 :	LUT_out[31] = -18'sd 81786;
		default     :	LUT_out[31] = 18'sd 0;
	endcase
end

// LUT_32 

always @ *
begin
	case(sum_level_1[32])
		19 'sd 0      :	LUT_out[32] = 18'sd 0;
		19 'sd 98304  :	LUT_out[32] = 18'sd 45794;
		19 'sd 32768  :	LUT_out[32] = 18'sd 15265;
		-19'sd 32768  :	LUT_out[32] = -18'sd 15265;
		-19'sd 98304  :	LUT_out[32] = -18'sd 45794;
		default     :	LUT_out[32] = 18'sd 0;
	endcase
end


endmodule