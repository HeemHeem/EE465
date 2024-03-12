module tx_gs_filter2 #(
    parameter COEFF_LEN = 81,
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


 


// LUT_0 

always @ *
begin
	case(sum_level_1[0])
		19 'sd 0      :	LUT_out[0]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[0]  = 18'sd 210;
		19 'sd 32768  :	LUT_out[0]  = 18'sd 70;
		-19'sd 32768  :	LUT_out[0]  = -18'sd 70;
		-19'sd 98304  :	LUT_out[0]  = -18'sd 210;
		19 'sd 196608 :	LUT_out[0]  = 18'sd 421;
		19 'sd 131072 :	LUT_out[0]  = 18'sd 280;
		19 'sd 65536  :	LUT_out[0]  = 18'sd 140;
		-19'sd 65536  :	LUT_out[0]  = -18'sd 140;
		-19'sd 131072 :	LUT_out[0]  = -18'sd 280;
		-19'sd 196608 :	LUT_out[0]  = -18'sd 421;
		default     :	LUT_out[0]  = 18'sd 0;
	endcase
end

// LUT_1 

always @ *
begin
	case(sum_level_1[1])
		19 'sd 0      :	LUT_out[1]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[1]  = 18'sd 246;
		19 'sd 32768  :	LUT_out[1]  = 18'sd 82;
		-19'sd 32768  :	LUT_out[1]  = -18'sd 82;
		-19'sd 98304  :	LUT_out[1]  = -18'sd 246;
		19 'sd 196608 :	LUT_out[1]  = 18'sd 492;
		19 'sd 131072 :	LUT_out[1]  = 18'sd 328;
		19 'sd 65536  :	LUT_out[1]  = 18'sd 164;
		-19'sd 65536  :	LUT_out[1]  = -18'sd 164;
		-19'sd 131072 :	LUT_out[1]  = -18'sd 328;
		-19'sd 196608 :	LUT_out[1]  = -18'sd 492;
		default     :	LUT_out[1]  = 18'sd 0;
	endcase
end

// LUT_2 

always @ *
begin
	case(sum_level_1[2])
		19 'sd 0      :	LUT_out[2]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[2]  = 18'sd 78;
		19 'sd 32768  :	LUT_out[2]  = 18'sd 26;
		-19'sd 32768  :	LUT_out[2]  = -18'sd 26;
		-19'sd 98304  :	LUT_out[2]  = -18'sd 78;
		19 'sd 196608 :	LUT_out[2]  = 18'sd 155;
		19 'sd 131072 :	LUT_out[2]  = 18'sd 103;
		19 'sd 65536  :	LUT_out[2]  = 18'sd 52;
		-19'sd 65536  :	LUT_out[2]  = -18'sd 52;
		-19'sd 131072 :	LUT_out[2]  = -18'sd 103;
		-19'sd 196608 :	LUT_out[2]  = -18'sd 155;
		default     :	LUT_out[2]  = 18'sd 0;
	endcase
end

// LUT_3 

always @ *
begin
	case(sum_level_1[3])
		19 'sd 0      :	LUT_out[3]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[3]  = -18'sd 188;
		19 'sd 32768  :	LUT_out[3]  = -18'sd 63;
		-19'sd 32768  :	LUT_out[3]  = 18'sd 63;
		-19'sd 98304  :	LUT_out[3]  = 18'sd 188;
		19 'sd 196608 :	LUT_out[3]  = -18'sd 377;
		19 'sd 131072 :	LUT_out[3]  = -18'sd 251;
		19 'sd 65536  :	LUT_out[3]  = -18'sd 126;
		-19'sd 65536  :	LUT_out[3]  = 18'sd 126;
		-19'sd 131072 :	LUT_out[3]  = 18'sd 251;
		-19'sd 196608 :	LUT_out[3]  = 18'sd 377;
		default     :	LUT_out[3]  = 18'sd 0;
	endcase
end

// LUT_4 

always @ *
begin
	case(sum_level_1[4])
		19 'sd 0      :	LUT_out[4]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[4]  = -18'sd 348;
		19 'sd 32768  :	LUT_out[4]  = -18'sd 116;
		-19'sd 32768  :	LUT_out[4]  = 18'sd 116;
		-19'sd 98304  :	LUT_out[4]  = 18'sd 348;
		19 'sd 196608 :	LUT_out[4]  = -18'sd 697;
		19 'sd 131072 :	LUT_out[4]  = -18'sd 464;
		19 'sd 65536  :	LUT_out[4]  = -18'sd 232;
		-19'sd 65536  :	LUT_out[4]  = 18'sd 232;
		-19'sd 131072 :	LUT_out[4]  = 18'sd 464;
		-19'sd 196608 :	LUT_out[4]  = 18'sd 697;
		default     :	LUT_out[4]  = 18'sd 0;
	endcase
end

// LUT_5 

always @ *
begin
	case(sum_level_1[5])
		19 'sd 0      :	LUT_out[5]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[5]  = -18'sd 250;
		19 'sd 32768  :	LUT_out[5]  = -18'sd 83;
		-19'sd 32768  :	LUT_out[5]  = 18'sd 83;
		-19'sd 98304  :	LUT_out[5]  = 18'sd 250;
		19 'sd 196608 :	LUT_out[5]  = -18'sd 500;
		19 'sd 131072 :	LUT_out[5]  = -18'sd 334;
		19 'sd 65536  :	LUT_out[5]  = -18'sd 167;
		-19'sd 65536  :	LUT_out[5]  = 18'sd 167;
		-19'sd 131072 :	LUT_out[5]  = 18'sd 334;
		-19'sd 196608 :	LUT_out[5]  = 18'sd 500;
		default     :	LUT_out[5]  = 18'sd 0;
	endcase
end

// LUT_6 

always @ *
begin
	case(sum_level_1[6])
		19 'sd 0      :	LUT_out[6]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[6]  = 18'sd 78;
		19 'sd 32768  :	LUT_out[6]  = 18'sd 26;
		-19'sd 32768  :	LUT_out[6]  = -18'sd 26;
		-19'sd 98304  :	LUT_out[6]  = -18'sd 78;
		19 'sd 196608 :	LUT_out[6]  = 18'sd 157;
		19 'sd 131072 :	LUT_out[6]  = 18'sd 105;
		19 'sd 65536  :	LUT_out[6]  = 18'sd 52;
		-19'sd 65536  :	LUT_out[6]  = -18'sd 52;
		-19'sd 131072 :	LUT_out[6]  = -18'sd 105;
		-19'sd 196608 :	LUT_out[6]  = -18'sd 157;
		default     :	LUT_out[6]  = 18'sd 0;
	endcase
end

// LUT_7 

always @ *
begin
	case(sum_level_1[7])
		19 'sd 0      :	LUT_out[7]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[7]  = 18'sd 420;
		19 'sd 32768  :	LUT_out[7]  = 18'sd 140;
		-19'sd 32768  :	LUT_out[7]  = -18'sd 140;
		-19'sd 98304  :	LUT_out[7]  = -18'sd 420;
		19 'sd 196608 :	LUT_out[7]  = 18'sd 840;
		19 'sd 131072 :	LUT_out[7]  = 18'sd 560;
		19 'sd 65536  :	LUT_out[7]  = 18'sd 280;
		-19'sd 65536  :	LUT_out[7]  = -18'sd 280;
		-19'sd 131072 :	LUT_out[7]  = -18'sd 560;
		-19'sd 196608 :	LUT_out[7]  = -18'sd 840;
		default     :	LUT_out[7]  = 18'sd 0;
	endcase
end

// LUT_8 

always @ *
begin
	case(sum_level_1[8])
		19 'sd 0      :	LUT_out[8]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[8]  = 18'sd 503;
		19 'sd 32768  :	LUT_out[8]  = 18'sd 168;
		-19'sd 32768  :	LUT_out[8]  = -18'sd 168;
		-19'sd 98304  :	LUT_out[8]  = -18'sd 503;
		19 'sd 196608 :	LUT_out[8]  = 18'sd 1007;
		19 'sd 131072 :	LUT_out[8]  = 18'sd 671;
		19 'sd 65536  :	LUT_out[8]  = 18'sd 336;
		-19'sd 65536  :	LUT_out[8]  = -18'sd 336;
		-19'sd 131072 :	LUT_out[8]  = -18'sd 671;
		-19'sd 196608 :	LUT_out[8]  = -18'sd 1007;
		default     :	LUT_out[8]  = 18'sd 0;
	endcase
end

// LUT_9 

always @ *
begin
	case(sum_level_1[9])
		19 'sd 0      :	LUT_out[9]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[9]  = 18'sd 206;
		19 'sd 32768  :	LUT_out[9]  = 18'sd 69;
		-19'sd 32768  :	LUT_out[9]  = -18'sd 69;
		-19'sd 98304  :	LUT_out[9]  = -18'sd 206;
		19 'sd 196608 :	LUT_out[9]  = 18'sd 412;
		19 'sd 131072 :	LUT_out[9]  = 18'sd 275;
		19 'sd 65536  :	LUT_out[9]  = 18'sd 137;
		-19'sd 65536  :	LUT_out[9]  = -18'sd 137;
		-19'sd 131072 :	LUT_out[9]  = -18'sd 275;
		-19'sd 196608 :	LUT_out[9]  = -18'sd 412;
		default     :	LUT_out[9]  = 18'sd 0;
	endcase
end

// LUT_10 

always @ *
begin
	case(sum_level_1[10])
		19 'sd 0      :	LUT_out[10] = 18'sd 0;
		19 'sd 98304  :	LUT_out[10] = -18'sd 324;
		19 'sd 32768  :	LUT_out[10] = -18'sd 108;
		-19'sd 32768  :	LUT_out[10] = 18'sd 108;
		-19'sd 98304  :	LUT_out[10] = 18'sd 324;
		19 'sd 196608 :	LUT_out[10] = -18'sd 647;
		19 'sd 131072 :	LUT_out[10] = -18'sd 432;
		19 'sd 65536  :	LUT_out[10] = -18'sd 216;
		-19'sd 65536  :	LUT_out[10] = 18'sd 216;
		-19'sd 131072 :	LUT_out[10] = 18'sd 432;
		-19'sd 196608 :	LUT_out[10] = 18'sd 647;
		default     :	LUT_out[10] = 18'sd 0;
	endcase
end

// LUT_11 

always @ *
begin
	case(sum_level_1[11])
		19 'sd 0      :	LUT_out[11] = 18'sd 0;
		19 'sd 98304  :	LUT_out[11] = -18'sd 728;
		19 'sd 32768  :	LUT_out[11] = -18'sd 243;
		-19'sd 32768  :	LUT_out[11] = 18'sd 243;
		-19'sd 98304  :	LUT_out[11] = 18'sd 728;
		19 'sd 196608 :	LUT_out[11] = -18'sd 1455;
		19 'sd 131072 :	LUT_out[11] = -18'sd 970;
		19 'sd 65536  :	LUT_out[11] = -18'sd 485;
		-19'sd 65536  :	LUT_out[11] = 18'sd 485;
		-19'sd 131072 :	LUT_out[11] = 18'sd 970;
		-19'sd 196608 :	LUT_out[11] = 18'sd 1455;
		default     :	LUT_out[11] = 18'sd 0;
	endcase
end

// LUT_12 

always @ *
begin
	case(sum_level_1[12])
		19 'sd 0      :	LUT_out[12] = 18'sd 0;
		19 'sd 98304  :	LUT_out[12] = -18'sd 669;
		19 'sd 32768  :	LUT_out[12] = -18'sd 223;
		-19'sd 32768  :	LUT_out[12] = 18'sd 223;
		-19'sd 98304  :	LUT_out[12] = 18'sd 669;
		19 'sd 196608 :	LUT_out[12] = -18'sd 1338;
		19 'sd 131072 :	LUT_out[12] = -18'sd 892;
		19 'sd 65536  :	LUT_out[12] = -18'sd 446;
		-19'sd 65536  :	LUT_out[12] = 18'sd 446;
		-19'sd 131072 :	LUT_out[12] = 18'sd 892;
		-19'sd 196608 :	LUT_out[12] = 18'sd 1338;
		default     :	LUT_out[12] = 18'sd 0;
	endcase
end

// LUT_13 

always @ *
begin
	case(sum_level_1[13])
		19 'sd 0      :	LUT_out[13] = 18'sd 0;
		19 'sd 98304  :	LUT_out[13] = -18'sd 92;
		19 'sd 32768  :	LUT_out[13] = -18'sd 31;
		-19'sd 32768  :	LUT_out[13] = 18'sd 31;
		-19'sd 98304  :	LUT_out[13] = 18'sd 92;
		19 'sd 196608 :	LUT_out[13] = -18'sd 184;
		19 'sd 131072 :	LUT_out[13] = -18'sd 123;
		19 'sd 65536  :	LUT_out[13] = -18'sd 61;
		-19'sd 65536  :	LUT_out[13] = 18'sd 61;
		-19'sd 131072 :	LUT_out[13] = 18'sd 123;
		-19'sd 196608 :	LUT_out[13] = 18'sd 184;
		default     :	LUT_out[13] = 18'sd 0;
	endcase
end

// LUT_14 

always @ *
begin
	case(sum_level_1[14])
		19 'sd 0      :	LUT_out[14] = 18'sd 0;
		19 'sd 98304  :	LUT_out[14] = 18'sd 684;
		19 'sd 32768  :	LUT_out[14] = 18'sd 228;
		-19'sd 32768  :	LUT_out[14] = -18'sd 228;
		-19'sd 98304  :	LUT_out[14] = -18'sd 684;
		19 'sd 196608 :	LUT_out[14] = 18'sd 1368;
		19 'sd 131072 :	LUT_out[14] = 18'sd 912;
		19 'sd 65536  :	LUT_out[14] = 18'sd 456;
		-19'sd 65536  :	LUT_out[14] = -18'sd 456;
		-19'sd 131072 :	LUT_out[14] = -18'sd 912;
		-19'sd 196608 :	LUT_out[14] = -18'sd 1368;
		default     :	LUT_out[14] = 18'sd 0;
	endcase
end

// LUT_15 

always @ *
begin
	case(sum_level_1[15])
		19 'sd 0      :	LUT_out[15] = 18'sd 0;
		19 'sd 98304  :	LUT_out[15] = 18'sd 1126;
		19 'sd 32768  :	LUT_out[15] = 18'sd 375;
		-19'sd 32768  :	LUT_out[15] = -18'sd 375;
		-19'sd 98304  :	LUT_out[15] = -18'sd 1126;
		19 'sd 196608 :	LUT_out[15] = 18'sd 2251;
		19 'sd 131072 :	LUT_out[15] = 18'sd 1501;
		19 'sd 65536  :	LUT_out[15] = 18'sd 750;
		-19'sd 65536  :	LUT_out[15] = -18'sd 750;
		-19'sd 131072 :	LUT_out[15] = -18'sd 1501;
		-19'sd 196608 :	LUT_out[15] = -18'sd 2251;
		default     :	LUT_out[15] = 18'sd 0;
	endcase
end

// LUT_16 

always @ *
begin
	case(sum_level_1[16])
		19 'sd 0      :	LUT_out[16] = 18'sd 0;
		19 'sd 98304  :	LUT_out[16] = 18'sd 838;
		19 'sd 32768  :	LUT_out[16] = 18'sd 279;
		-19'sd 32768  :	LUT_out[16] = -18'sd 279;
		-19'sd 98304  :	LUT_out[16] = -18'sd 838;
		19 'sd 196608 :	LUT_out[16] = 18'sd 1676;
		19 'sd 131072 :	LUT_out[16] = 18'sd 1117;
		19 'sd 65536  :	LUT_out[16] = 18'sd 559;
		-19'sd 65536  :	LUT_out[16] = -18'sd 559;
		-19'sd 131072 :	LUT_out[16] = -18'sd 1117;
		-19'sd 196608 :	LUT_out[16] = -18'sd 1676;
		default     :	LUT_out[16] = 18'sd 0;
	endcase
end

// LUT_17 

always @ *
begin
	case(sum_level_1[17])
		19 'sd 0      :	LUT_out[17] = 18'sd 0;
		19 'sd 98304  :	LUT_out[17] = -18'sd 122;
		19 'sd 32768  :	LUT_out[17] = -18'sd 41;
		-19'sd 32768  :	LUT_out[17] = 18'sd 41;
		-19'sd 98304  :	LUT_out[17] = 18'sd 122;
		19 'sd 196608 :	LUT_out[17] = -18'sd 244;
		19 'sd 131072 :	LUT_out[17] = -18'sd 163;
		19 'sd 65536  :	LUT_out[17] = -18'sd 81;
		-19'sd 65536  :	LUT_out[17] = 18'sd 81;
		-19'sd 131072 :	LUT_out[17] = 18'sd 163;
		-19'sd 196608 :	LUT_out[17] = 18'sd 244;
		default     :	LUT_out[17] = 18'sd 0;
	endcase
end

// LUT_18 

always @ *
begin
	case(sum_level_1[18])
		19 'sd 0      :	LUT_out[18] = 18'sd 0;
		19 'sd 98304  :	LUT_out[18] = -18'sd 1198;
		19 'sd 32768  :	LUT_out[18] = -18'sd 399;
		-19'sd 32768  :	LUT_out[18] = 18'sd 399;
		-19'sd 98304  :	LUT_out[18] = 18'sd 1198;
		19 'sd 196608 :	LUT_out[18] = -18'sd 2396;
		19 'sd 131072 :	LUT_out[18] = -18'sd 1597;
		19 'sd 65536  :	LUT_out[18] = -18'sd 799;
		-19'sd 65536  :	LUT_out[18] = 18'sd 799;
		-19'sd 131072 :	LUT_out[18] = 18'sd 1597;
		-19'sd 196608 :	LUT_out[18] = 18'sd 2396;
		default     :	LUT_out[18] = 18'sd 0;
	endcase
end

// LUT_19 

always @ *
begin
	case(sum_level_1[19])
		19 'sd 0      :	LUT_out[19] = 18'sd 0;
		19 'sd 98304  :	LUT_out[19] = -18'sd 1639;
		19 'sd 32768  :	LUT_out[19] = -18'sd 546;
		-19'sd 32768  :	LUT_out[19] = 18'sd 546;
		-19'sd 98304  :	LUT_out[19] = 18'sd 1639;
		19 'sd 196608 :	LUT_out[19] = -18'sd 3278;
		19 'sd 131072 :	LUT_out[19] = -18'sd 2186;
		19 'sd 65536  :	LUT_out[19] = -18'sd 1093;
		-19'sd 65536  :	LUT_out[19] = 18'sd 1093;
		-19'sd 131072 :	LUT_out[19] = 18'sd 2186;
		-19'sd 196608 :	LUT_out[19] = 18'sd 3278;
		default     :	LUT_out[19] = 18'sd 0;
	endcase
end

// LUT_20 

always @ *
begin
	case(sum_level_1[20])
		19 'sd 0      :	LUT_out[20] = 18'sd 0;
		19 'sd 98304  :	LUT_out[20] = -18'sd 1001;
		19 'sd 32768  :	LUT_out[20] = -18'sd 334;
		-19'sd 32768  :	LUT_out[20] = 18'sd 334;
		-19'sd 98304  :	LUT_out[20] = 18'sd 1001;
		19 'sd 196608 :	LUT_out[20] = -18'sd 2001;
		19 'sd 131072 :	LUT_out[20] = -18'sd 1334;
		19 'sd 65536  :	LUT_out[20] = -18'sd 667;
		-19'sd 65536  :	LUT_out[20] = 18'sd 667;
		-19'sd 131072 :	LUT_out[20] = 18'sd 1334;
		-19'sd 196608 :	LUT_out[20] = 18'sd 2001;
		default     :	LUT_out[20] = 18'sd 0;
	endcase
end

// LUT_21 

always @ *
begin
	case(sum_level_1[21])
		19 'sd 0      :	LUT_out[21] = 18'sd 0;
		19 'sd 98304  :	LUT_out[21] = 18'sd 484;
		19 'sd 32768  :	LUT_out[21] = 18'sd 161;
		-19'sd 32768  :	LUT_out[21] = -18'sd 161;
		-19'sd 98304  :	LUT_out[21] = -18'sd 484;
		19 'sd 196608 :	LUT_out[21] = 18'sd 968;
		19 'sd 131072 :	LUT_out[21] = 18'sd 645;
		19 'sd 65536  :	LUT_out[21] = 18'sd 323;
		-19'sd 65536  :	LUT_out[21] = -18'sd 323;
		-19'sd 131072 :	LUT_out[21] = -18'sd 645;
		-19'sd 196608 :	LUT_out[21] = -18'sd 968;
		default     :	LUT_out[21] = 18'sd 0;
	endcase
end

// LUT_22 

always @ *
begin
	case(sum_level_1[22])
		19 'sd 0      :	LUT_out[22] = 18'sd 0;
		19 'sd 98304  :	LUT_out[22] = 18'sd 1935;
		19 'sd 32768  :	LUT_out[22] = 18'sd 645;
		-19'sd 32768  :	LUT_out[22] = -18'sd 645;
		-19'sd 98304  :	LUT_out[22] = -18'sd 1935;
		19 'sd 196608 :	LUT_out[22] = 18'sd 3869;
		19 'sd 131072 :	LUT_out[22] = 18'sd 2580;
		19 'sd 65536  :	LUT_out[22] = 18'sd 1290;
		-19'sd 65536  :	LUT_out[22] = -18'sd 1290;
		-19'sd 131072 :	LUT_out[22] = -18'sd 2580;
		-19'sd 196608 :	LUT_out[22] = -18'sd 3869;
		default     :	LUT_out[22] = 18'sd 0;
	endcase
end

// LUT_23 

always @ *
begin
	case(sum_level_1[23])
		19 'sd 0      :	LUT_out[23] = 18'sd 0;
		19 'sd 98304  :	LUT_out[23] = 18'sd 2320;
		19 'sd 32768  :	LUT_out[23] = 18'sd 773;
		-19'sd 32768  :	LUT_out[23] = -18'sd 773;
		-19'sd 98304  :	LUT_out[23] = -18'sd 2320;
		19 'sd 196608 :	LUT_out[23] = 18'sd 4641;
		19 'sd 131072 :	LUT_out[23] = 18'sd 3094;
		19 'sd 65536  :	LUT_out[23] = 18'sd 1547;
		-19'sd 65536  :	LUT_out[23] = -18'sd 1547;
		-19'sd 131072 :	LUT_out[23] = -18'sd 3094;
		-19'sd 196608 :	LUT_out[23] = -18'sd 4641;
		default     :	LUT_out[23] = 18'sd 0;
	endcase
end

// LUT_24 

always @ *
begin
	case(sum_level_1[24])
		19 'sd 0      :	LUT_out[24] = 18'sd 0;
		19 'sd 98304  :	LUT_out[24] = 18'sd 1149;
		19 'sd 32768  :	LUT_out[24] = 18'sd 383;
		-19'sd 32768  :	LUT_out[24] = -18'sd 383;
		-19'sd 98304  :	LUT_out[24] = -18'sd 1149;
		19 'sd 196608 :	LUT_out[24] = 18'sd 2298;
		19 'sd 131072 :	LUT_out[24] = 18'sd 1532;
		19 'sd 65536  :	LUT_out[24] = 18'sd 766;
		-19'sd 65536  :	LUT_out[24] = -18'sd 766;
		-19'sd 131072 :	LUT_out[24] = -18'sd 1532;
		-19'sd 196608 :	LUT_out[24] = -18'sd 2298;
		default     :	LUT_out[24] = 18'sd 0;
	endcase
end

// LUT_25 

always @ *
begin
	case(sum_level_1[25])
		19 'sd 0      :	LUT_out[25] = 18'sd 0;
		19 'sd 98304  :	LUT_out[25] = -18'sd 1084;
		19 'sd 32768  :	LUT_out[25] = -18'sd 361;
		-19'sd 32768  :	LUT_out[25] = 18'sd 361;
		-19'sd 98304  :	LUT_out[25] = 18'sd 1084;
		19 'sd 196608 :	LUT_out[25] = -18'sd 2168;
		19 'sd 131072 :	LUT_out[25] = -18'sd 1445;
		19 'sd 65536  :	LUT_out[25] = -18'sd 723;
		-19'sd 65536  :	LUT_out[25] = 18'sd 723;
		-19'sd 131072 :	LUT_out[25] = 18'sd 1445;
		-19'sd 196608 :	LUT_out[25] = 18'sd 2168;
		default     :	LUT_out[25] = 18'sd 0;
	endcase
end

// LUT_26 

always @ *
begin
	case(sum_level_1[26])
		19 'sd 0      :	LUT_out[26] = 18'sd 0;
		19 'sd 98304  :	LUT_out[26] = -18'sd 3041;
		19 'sd 32768  :	LUT_out[26] = -18'sd 1014;
		-19'sd 32768  :	LUT_out[26] = 18'sd 1014;
		-19'sd 98304  :	LUT_out[26] = 18'sd 3041;
		19 'sd 196608 :	LUT_out[26] = -18'sd 6081;
		19 'sd 131072 :	LUT_out[26] = -18'sd 4054;
		19 'sd 65536  :	LUT_out[26] = -18'sd 2027;
		-19'sd 65536  :	LUT_out[26] = 18'sd 2027;
		-19'sd 131072 :	LUT_out[26] = 18'sd 4054;
		-19'sd 196608 :	LUT_out[26] = 18'sd 6081;
		default     :	LUT_out[26] = 18'sd 0;
	endcase
end

// LUT_27 

always @ *
begin
	case(sum_level_1[27])
		19 'sd 0      :	LUT_out[27] = 18'sd 0;
		19 'sd 98304  :	LUT_out[27] = -18'sd 3291;
		19 'sd 32768  :	LUT_out[27] = -18'sd 1097;
		-19'sd 32768  :	LUT_out[27] = 18'sd 1097;
		-19'sd 98304  :	LUT_out[27] = 18'sd 3291;
		19 'sd 196608 :	LUT_out[27] = -18'sd 6583;
		19 'sd 131072 :	LUT_out[27] = -18'sd 4389;
		19 'sd 65536  :	LUT_out[27] = -18'sd 2194;
		-19'sd 65536  :	LUT_out[27] = 18'sd 2194;
		-19'sd 131072 :	LUT_out[27] = 18'sd 4389;
		-19'sd 196608 :	LUT_out[27] = 18'sd 6583;
		default     :	LUT_out[27] = 18'sd 0;
	endcase
end

// LUT_28 

always @ *
begin
	case(sum_level_1[28])
		19 'sd 0      :	LUT_out[28] = 18'sd 0;
		19 'sd 98304  :	LUT_out[28] = -18'sd 1274;
		19 'sd 32768  :	LUT_out[28] = -18'sd 425;
		-19'sd 32768  :	LUT_out[28] = 18'sd 425;
		-19'sd 98304  :	LUT_out[28] = 18'sd 1274;
		19 'sd 196608 :	LUT_out[28] = -18'sd 2548;
		19 'sd 131072 :	LUT_out[28] = -18'sd 1699;
		19 'sd 65536  :	LUT_out[28] = -18'sd 849;
		-19'sd 65536  :	LUT_out[28] = 18'sd 849;
		-19'sd 131072 :	LUT_out[28] = 18'sd 1699;
		-19'sd 196608 :	LUT_out[28] = 18'sd 2548;
		default     :	LUT_out[28] = 18'sd 0;
	endcase
end

// LUT_29 

always @ *
begin
	case(sum_level_1[29])
		19 'sd 0      :	LUT_out[29] = 18'sd 0;
		19 'sd 98304  :	LUT_out[29] = 18'sd 2136;
		19 'sd 32768  :	LUT_out[29] = 18'sd 712;
		-19'sd 32768  :	LUT_out[29] = -18'sd 712;
		-19'sd 98304  :	LUT_out[29] = -18'sd 2136;
		19 'sd 196608 :	LUT_out[29] = 18'sd 4272;
		19 'sd 131072 :	LUT_out[29] = 18'sd 2848;
		19 'sd 65536  :	LUT_out[29] = 18'sd 1424;
		-19'sd 65536  :	LUT_out[29] = -18'sd 1424;
		-19'sd 131072 :	LUT_out[29] = -18'sd 2848;
		-19'sd 196608 :	LUT_out[29] = -18'sd 4272;
		default     :	LUT_out[29] = 18'sd 0;
	endcase
end

// LUT_30 

always @ *
begin
	case(sum_level_1[30])
		19 'sd 0      :	LUT_out[30] = 18'sd 0;
		19 'sd 98304  :	LUT_out[30] = 18'sd 4899;
		19 'sd 32768  :	LUT_out[30] = 18'sd 1633;
		-19'sd 32768  :	LUT_out[30] = -18'sd 1633;
		-19'sd 98304  :	LUT_out[30] = -18'sd 4899;
		19 'sd 196608 :	LUT_out[30] = 18'sd 9798;
		19 'sd 131072 :	LUT_out[30] = 18'sd 6532;
		19 'sd 65536  :	LUT_out[30] = 18'sd 3266;
		-19'sd 65536  :	LUT_out[30] = -18'sd 3266;
		-19'sd 131072 :	LUT_out[30] = -18'sd 6532;
		-19'sd 196608 :	LUT_out[30] = -18'sd 9798;
		default     :	LUT_out[30] = 18'sd 0;
	endcase
end

// LUT_31 

always @ *
begin
	case(sum_level_1[31])
		19 'sd 0      :	LUT_out[31] = 18'sd 0;
		19 'sd 98304  :	LUT_out[31] = 18'sd 4908;
		19 'sd 32768  :	LUT_out[31] = 18'sd 1636;
		-19'sd 32768  :	LUT_out[31] = -18'sd 1636;
		-19'sd 98304  :	LUT_out[31] = -18'sd 4908;
		19 'sd 196608 :	LUT_out[31] = 18'sd 9816;
		19 'sd 131072 :	LUT_out[31] = 18'sd 6544;
		19 'sd 65536  :	LUT_out[31] = 18'sd 3272;
		-19'sd 65536  :	LUT_out[31] = -18'sd 3272;
		-19'sd 131072 :	LUT_out[31] = -18'sd 6544;
		-19'sd 196608 :	LUT_out[31] = -18'sd 9816;
		default     :	LUT_out[31] = 18'sd 0;
	endcase
end

// LUT_32 

always @ *
begin
	case(sum_level_1[32])
		19 'sd 0      :	LUT_out[32] = 18'sd 0;
		19 'sd 98304  :	LUT_out[32] = 18'sd 1369;
		19 'sd 32768  :	LUT_out[32] = 18'sd 456;
		-19'sd 32768  :	LUT_out[32] = -18'sd 456;
		-19'sd 98304  :	LUT_out[32] = -18'sd 1369;
		19 'sd 196608 :	LUT_out[32] = 18'sd 2739;
		19 'sd 131072 :	LUT_out[32] = 18'sd 1826;
		19 'sd 65536  :	LUT_out[32] = 18'sd 913;
		-19'sd 65536  :	LUT_out[32] = -18'sd 913;
		-19'sd 131072 :	LUT_out[32] = -18'sd 1826;
		-19'sd 196608 :	LUT_out[32] = -18'sd 2739;
		default     :	LUT_out[32] = 18'sd 0;
	endcase
end

// LUT_33 

always @ *
begin
	case(sum_level_1[33])
		19 'sd 0      :	LUT_out[33] = 18'sd 0;
		19 'sd 98304  :	LUT_out[33] = -18'sd 4335;
		19 'sd 32768  :	LUT_out[33] = -18'sd 1445;
		-19'sd 32768  :	LUT_out[33] = 18'sd 1445;
		-19'sd 98304  :	LUT_out[33] = 18'sd 4335;
		19 'sd 196608 :	LUT_out[33] = -18'sd 8670;
		19 'sd 131072 :	LUT_out[33] = -18'sd 5780;
		19 'sd 65536  :	LUT_out[33] = -18'sd 2890;
		-19'sd 65536  :	LUT_out[33] = 18'sd 2890;
		-19'sd 131072 :	LUT_out[33] = 18'sd 5780;
		-19'sd 196608 :	LUT_out[33] = 18'sd 8670;
		default     :	LUT_out[33] = 18'sd 0;
	endcase
end

// LUT_34 

always @ *
begin
	case(sum_level_1[34])
		19 'sd 0      :	LUT_out[34] = 18'sd 0;
		19 'sd 98304  :	LUT_out[34] = -18'sd 8930;
		19 'sd 32768  :	LUT_out[34] = -18'sd 2977;
		-19'sd 32768  :	LUT_out[34] = 18'sd 2977;
		-19'sd 98304  :	LUT_out[34] = 18'sd 8930;
		19 'sd 196608 :	LUT_out[34] = -18'sd 17860;
		19 'sd 131072 :	LUT_out[34] = -18'sd 11907;
		19 'sd 65536  :	LUT_out[34] = -18'sd 5953;
		-19'sd 65536  :	LUT_out[34] = 18'sd 5953;
		-19'sd 131072 :	LUT_out[34] = 18'sd 11907;
		-19'sd 196608 :	LUT_out[34] = 18'sd 17860;
		default     :	LUT_out[34] = 18'sd 0;
	endcase
end

// LUT_35 

always @ *
begin
	case(sum_level_1[35])
		19 'sd 0      :	LUT_out[35] = 18'sd 0;
		19 'sd 98304  :	LUT_out[35] = -18'sd 8695;
		19 'sd 32768  :	LUT_out[35] = -18'sd 2898;
		-19'sd 32768  :	LUT_out[35] = 18'sd 2898;
		-19'sd 98304  :	LUT_out[35] = 18'sd 8695;
		19 'sd 196608 :	LUT_out[35] = -18'sd 17390;
		19 'sd 131072 :	LUT_out[35] = -18'sd 11594;
		19 'sd 65536  :	LUT_out[35] = -18'sd 5797;
		-19'sd 65536  :	LUT_out[35] = 18'sd 5797;
		-19'sd 131072 :	LUT_out[35] = 18'sd 11594;
		-19'sd 196608 :	LUT_out[35] = 18'sd 17390;
		default     :	LUT_out[35] = 18'sd 0;
	endcase
end

// LUT_36 

always @ *
begin
	case(sum_level_1[36])
		19 'sd 0      :	LUT_out[36] = 18'sd 0;
		19 'sd 98304  :	LUT_out[36] = -18'sd 1429;
		19 'sd 32768  :	LUT_out[36] = -18'sd 476;
		-19'sd 32768  :	LUT_out[36] = 18'sd 476;
		-19'sd 98304  :	LUT_out[36] = 18'sd 1429;
		19 'sd 196608 :	LUT_out[36] = -18'sd 2858;
		19 'sd 131072 :	LUT_out[36] = -18'sd 1905;
		19 'sd 65536  :	LUT_out[36] = -18'sd 953;
		-19'sd 65536  :	LUT_out[36] = 18'sd 953;
		-19'sd 131072 :	LUT_out[36] = 18'sd 1905;
		-19'sd 196608 :	LUT_out[36] = 18'sd 2858;
		default     :	LUT_out[36] = 18'sd 0;
	endcase
end

// LUT_37 

always @ *
begin
	case(sum_level_1[37])
		19 'sd 0      :	LUT_out[37] = 18'sd 0;
		19 'sd 98304  :	LUT_out[37] = 18'sd 12087;
		19 'sd 32768  :	LUT_out[37] = 18'sd 4029;
		-19'sd 32768  :	LUT_out[37] = -18'sd 4029;
		-19'sd 98304  :	LUT_out[37] = -18'sd 12087;
		19 'sd 196608 :	LUT_out[37] = 18'sd 24174;
		19 'sd 131072 :	LUT_out[37] = 18'sd 16116;
		19 'sd 65536  :	LUT_out[37] = 18'sd 8058;
		-19'sd 65536  :	LUT_out[37] = -18'sd 8058;
		-19'sd 131072 :	LUT_out[37] = -18'sd 16116;
		-19'sd 196608 :	LUT_out[37] = -18'sd 24174;
		default     :	LUT_out[37] = 18'sd 0;
	endcase
end

// LUT_38 

always @ *
begin
	case(sum_level_1[38])
		19 'sd 0      :	LUT_out[38] = 18'sd 0;
		19 'sd 98304  :	LUT_out[38] = 18'sd 27986;
		19 'sd 32768  :	LUT_out[38] = 18'sd 9329;
		-19'sd 32768  :	LUT_out[38] = -18'sd 9329;
		-19'sd 98304  :	LUT_out[38] = -18'sd 27986;
		19 'sd 196608 :	LUT_out[38] = 18'sd 55973;
		19 'sd 131072 :	LUT_out[38] = 18'sd 37315;
		19 'sd 65536  :	LUT_out[38] = 18'sd 18658;
		-19'sd 65536  :	LUT_out[38] = -18'sd 18658;
		-19'sd 131072 :	LUT_out[38] = -18'sd 37315;
		-19'sd 196608 :	LUT_out[38] = -18'sd 55973;
		default     :	LUT_out[38] = 18'sd 0;
	endcase
end

// LUT_39 

always @ *
begin
	case(sum_level_1[39])
		19 'sd 0      :	LUT_out[39] = 18'sd 0;
		19 'sd 98304  :	LUT_out[39] = 18'sd 40763;
		19 'sd 32768  :	LUT_out[39] = 18'sd 13588;
		-19'sd 32768  :	LUT_out[39] = -18'sd 13588;
		-19'sd 98304  :	LUT_out[39] = -18'sd 40763;
		19 'sd 196608 :	LUT_out[39] = 18'sd 81527;
		19 'sd 131072 :	LUT_out[39] = 18'sd 54351;
		19 'sd 65536  :	LUT_out[39] = 18'sd 27176;
		-19'sd 65536  :	LUT_out[39] = -18'sd 27176;
		-19'sd 131072 :	LUT_out[39] = -18'sd 54351;
		-19'sd 196608 :	LUT_out[39] = -18'sd 81527;
		default     :	LUT_out[39] = 18'sd 0;
	endcase
end

// LUT_40 

always @ *
begin
	case(sum_level_1[40])
		19 'sd 0      :	LUT_out[40] = 18'sd 0;
		19 'sd 98304  :	LUT_out[40] = 18'sd 45648;
		19 'sd 32768  :	LUT_out[40] = 18'sd 15216;
		-19'sd 32768  :	LUT_out[40] = -18'sd 15216;
		-19'sd 98304  :	LUT_out[40] = -18'sd 45648;
		default     :	LUT_out[40] = 18'sd 0;
	endcase
end


endmodule