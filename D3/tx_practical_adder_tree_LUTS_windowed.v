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
        for (i = 0; i <= 25; i=i+1)
            sum_level_2[i] = 18'sd 0;
    else
        for (i = 0; i <= 25; i=i+1)
            sum_level_2[i] = LUT_out[2*i] + LUT_out[2*i+1];


// sum_level_3 sum_level_3[12] is left alone
always @ *
    if (reset)
        for (i = 0; i <= 12 ; i=i+1)
            sum_level_3[i] = 18'sd 0;
    else begin
        for (i = 0; i <= 12 ; i=i+1)
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
        for (i = 0; i <= 2 ; i=i+1)
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


 


// LUT_0 

always @ *
begin
	case(sum_level_1[0])
		19 'sd 0      :	LUT_out[0]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[0]  = -18'sd 105;
		19 'sd 32768  :	LUT_out[0]  = -18'sd 35;
		-19'sd 32768  :	LUT_out[0]  = 18'sd 35;
		-19'sd 98304  :	LUT_out[0]  = 18'sd 105;
		19 'sd 196608 :	LUT_out[0]  = -18'sd 211;
		19 'sd 131072 :	LUT_out[0]  = -18'sd 141;
		19 'sd 65536  :	LUT_out[0]  = -18'sd 70;
		-19'sd 65536  :	LUT_out[0]  = 18'sd 70;
		-19'sd 131072 :	LUT_out[0]  = 18'sd 141;
		-19'sd 196608 :	LUT_out[0]  = 18'sd 211;
		default     :	LUT_out[0]  = 18'sd 0;
	endcase
end

// LUT_1 

always @ *
begin
	case(sum_level_1[1])
		19 'sd 0      :	LUT_out[1]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[1]  = -18'sd 71;
		19 'sd 32768  :	LUT_out[1]  = -18'sd 24;
		-19'sd 32768  :	LUT_out[1]  = 18'sd 24;
		-19'sd 98304  :	LUT_out[1]  = 18'sd 71;
		19 'sd 196608 :	LUT_out[1]  = -18'sd 142;
		19 'sd 131072 :	LUT_out[1]  = -18'sd 95;
		19 'sd 65536  :	LUT_out[1]  = -18'sd 47;
		-19'sd 65536  :	LUT_out[1]  = 18'sd 47;
		-19'sd 131072 :	LUT_out[1]  = 18'sd 95;
		-19'sd 196608 :	LUT_out[1]  = 18'sd 142;
		default     :	LUT_out[1]  = 18'sd 0;
	endcase
end

// LUT_2 

always @ *
begin
	case(sum_level_1[2])
		19 'sd 0      :	LUT_out[2]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[2]  = 18'sd 27;
		19 'sd 32768  :	LUT_out[2]  = 18'sd 9;
		-19'sd 32768  :	LUT_out[2]  = -18'sd 9;
		-19'sd 98304  :	LUT_out[2]  = -18'sd 27;
		19 'sd 196608 :	LUT_out[2]  = 18'sd 54;
		19 'sd 131072 :	LUT_out[2]  = 18'sd 36;
		19 'sd 65536  :	LUT_out[2]  = 18'sd 18;
		-19'sd 65536  :	LUT_out[2]  = -18'sd 18;
		-19'sd 131072 :	LUT_out[2]  = -18'sd 36;
		-19'sd 196608 :	LUT_out[2]  = -18'sd 54;
		default     :	LUT_out[2]  = 18'sd 0;
	endcase
end

// LUT_3 

always @ *
begin
	case(sum_level_1[3])
		19 'sd 0      :	LUT_out[3]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[3]  = 18'sd 128;
		19 'sd 32768  :	LUT_out[3]  = 18'sd 43;
		-19'sd 32768  :	LUT_out[3]  = -18'sd 43;
		-19'sd 98304  :	LUT_out[3]  = -18'sd 128;
		19 'sd 196608 :	LUT_out[3]  = 18'sd 256;
		19 'sd 131072 :	LUT_out[3]  = 18'sd 170;
		19 'sd 65536  :	LUT_out[3]  = 18'sd 85;
		-19'sd 65536  :	LUT_out[3]  = -18'sd 85;
		-19'sd 131072 :	LUT_out[3]  = -18'sd 170;
		-19'sd 196608 :	LUT_out[3]  = -18'sd 256;
		default     :	LUT_out[3]  = 18'sd 0;
	endcase
end

// LUT_4 

always @ *
begin
	case(sum_level_1[4])
		19 'sd 0      :	LUT_out[4]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[4]  = 18'sd 155;
		19 'sd 32768  :	LUT_out[4]  = 18'sd 52;
		-19'sd 32768  :	LUT_out[4]  = -18'sd 52;
		-19'sd 98304  :	LUT_out[4]  = -18'sd 155;
		19 'sd 196608 :	LUT_out[4]  = 18'sd 310;
		19 'sd 131072 :	LUT_out[4]  = 18'sd 207;
		19 'sd 65536  :	LUT_out[4]  = 18'sd 103;
		-19'sd 65536  :	LUT_out[4]  = -18'sd 103;
		-19'sd 131072 :	LUT_out[4]  = -18'sd 207;
		-19'sd 196608 :	LUT_out[4]  = -18'sd 310;
		default     :	LUT_out[4]  = 18'sd 0;
	endcase
end

// LUT_5 

always @ *
begin
	case(sum_level_1[5])
		19 'sd 0      :	LUT_out[5]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[5]  = 18'sd 72;
		19 'sd 32768  :	LUT_out[5]  = 18'sd 24;
		-19'sd 32768  :	LUT_out[5]  = -18'sd 24;
		-19'sd 98304  :	LUT_out[5]  = -18'sd 72;
		19 'sd 196608 :	LUT_out[5]  = 18'sd 144;
		19 'sd 131072 :	LUT_out[5]  = 18'sd 96;
		19 'sd 65536  :	LUT_out[5]  = 18'sd 48;
		-19'sd 65536  :	LUT_out[5]  = -18'sd 48;
		-19'sd 131072 :	LUT_out[5]  = -18'sd 96;
		-19'sd 196608 :	LUT_out[5]  = -18'sd 144;
		default     :	LUT_out[5]  = 18'sd 0;
	endcase
end

// LUT_6 

always @ *
begin
	case(sum_level_1[6])
		19 'sd 0      :	LUT_out[6]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[6]  = -18'sd 85;
		19 'sd 32768  :	LUT_out[6]  = -18'sd 28;
		-19'sd 32768  :	LUT_out[6]  = 18'sd 28;
		-19'sd 98304  :	LUT_out[6]  = 18'sd 85;
		19 'sd 196608 :	LUT_out[6]  = -18'sd 169;
		19 'sd 131072 :	LUT_out[6]  = -18'sd 113;
		19 'sd 65536  :	LUT_out[6]  = -18'sd 56;
		-19'sd 65536  :	LUT_out[6]  = 18'sd 56;
		-19'sd 131072 :	LUT_out[6]  = 18'sd 113;
		-19'sd 196608 :	LUT_out[6]  = 18'sd 169;
		default     :	LUT_out[6]  = 18'sd 0;
	endcase
end

// LUT_7 

always @ *
begin
	case(sum_level_1[7])
		19 'sd 0      :	LUT_out[7]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[7]  = -18'sd 214;
		19 'sd 32768  :	LUT_out[7]  = -18'sd 71;
		-19'sd 32768  :	LUT_out[7]  = 18'sd 71;
		-19'sd 98304  :	LUT_out[7]  = 18'sd 214;
		19 'sd 196608 :	LUT_out[7]  = -18'sd 429;
		19 'sd 131072 :	LUT_out[7]  = -18'sd 286;
		19 'sd 65536  :	LUT_out[7]  = -18'sd 143;
		-19'sd 65536  :	LUT_out[7]  = 18'sd 143;
		-19'sd 131072 :	LUT_out[7]  = 18'sd 286;
		-19'sd 196608 :	LUT_out[7]  = 18'sd 429;
		default     :	LUT_out[7]  = 18'sd 0;
	endcase
end

// LUT_8 

always @ *
begin
	case(sum_level_1[8])
		19 'sd 0      :	LUT_out[8]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[8]  = -18'sd 215;
		19 'sd 32768  :	LUT_out[8]  = -18'sd 72;
		-19'sd 32768  :	LUT_out[8]  = 18'sd 72;
		-19'sd 98304  :	LUT_out[8]  = 18'sd 215;
		19 'sd 196608 :	LUT_out[8]  = -18'sd 431;
		19 'sd 131072 :	LUT_out[8]  = -18'sd 287;
		19 'sd 65536  :	LUT_out[8]  = -18'sd 144;
		-19'sd 65536  :	LUT_out[8]  = 18'sd 144;
		-19'sd 131072 :	LUT_out[8]  = 18'sd 287;
		-19'sd 196608 :	LUT_out[8]  = 18'sd 431;
		default     :	LUT_out[8]  = 18'sd 0;
	endcase
end

// LUT_9 

always @ *
begin
	case(sum_level_1[9])
		19 'sd 0      :	LUT_out[9]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[9]  = -18'sd 59;
		19 'sd 32768  :	LUT_out[9]  = -18'sd 20;
		-19'sd 32768  :	LUT_out[9]  = 18'sd 20;
		-19'sd 98304  :	LUT_out[9]  = 18'sd 59;
		19 'sd 196608 :	LUT_out[9]  = -18'sd 119;
		19 'sd 131072 :	LUT_out[9]  = -18'sd 79;
		19 'sd 65536  :	LUT_out[9]  = -18'sd 40;
		-19'sd 65536  :	LUT_out[9]  = 18'sd 40;
		-19'sd 131072 :	LUT_out[9]  = 18'sd 79;
		-19'sd 196608 :	LUT_out[9]  = 18'sd 119;
		default     :	LUT_out[9]  = 18'sd 0;
	endcase
end

// LUT_10 

always @ *
begin
	case(sum_level_1[10])
		19 'sd 0      :	LUT_out[10] = 18'sd 0;
		19 'sd 98304  :	LUT_out[10] = 18'sd 174;
		19 'sd 32768  :	LUT_out[10] = 18'sd 58;
		-19'sd 32768  :	LUT_out[10] = -18'sd 58;
		-19'sd 98304  :	LUT_out[10] = -18'sd 174;
		19 'sd 196608 :	LUT_out[10] = 18'sd 348;
		19 'sd 131072 :	LUT_out[10] = 18'sd 232;
		19 'sd 65536  :	LUT_out[10] = 18'sd 116;
		-19'sd 65536  :	LUT_out[10] = -18'sd 116;
		-19'sd 131072 :	LUT_out[10] = -18'sd 232;
		-19'sd 196608 :	LUT_out[10] = -18'sd 348;
		default     :	LUT_out[10] = 18'sd 0;
	endcase
end

// LUT_11 

always @ *
begin
	case(sum_level_1[11])
		19 'sd 0      :	LUT_out[11] = 18'sd 0;
		19 'sd 98304  :	LUT_out[11] = 18'sd 332;
		19 'sd 32768  :	LUT_out[11] = 18'sd 111;
		-19'sd 32768  :	LUT_out[11] = -18'sd 111;
		-19'sd 98304  :	LUT_out[11] = -18'sd 332;
		19 'sd 196608 :	LUT_out[11] = 18'sd 663;
		19 'sd 131072 :	LUT_out[11] = 18'sd 442;
		19 'sd 65536  :	LUT_out[11] = 18'sd 221;
		-19'sd 65536  :	LUT_out[11] = -18'sd 221;
		-19'sd 131072 :	LUT_out[11] = -18'sd 442;
		-19'sd 196608 :	LUT_out[11] = -18'sd 663;
		default     :	LUT_out[11] = 18'sd 0;
	endcase
end

// LUT_12 

always @ *
begin
	case(sum_level_1[12])
		19 'sd 0      :	LUT_out[12] = 18'sd 0;
		19 'sd 98304  :	LUT_out[12] = 18'sd 285;
		19 'sd 32768  :	LUT_out[12] = 18'sd 95;
		-19'sd 32768  :	LUT_out[12] = -18'sd 95;
		-19'sd 98304  :	LUT_out[12] = -18'sd 285;
		19 'sd 196608 :	LUT_out[12] = 18'sd 570;
		19 'sd 131072 :	LUT_out[12] = 18'sd 380;
		19 'sd 65536  :	LUT_out[12] = 18'sd 190;
		-19'sd 65536  :	LUT_out[12] = -18'sd 190;
		-19'sd 131072 :	LUT_out[12] = -18'sd 380;
		-19'sd 196608 :	LUT_out[12] = -18'sd 570;
		default     :	LUT_out[12] = 18'sd 0;
	endcase
end

// LUT_13 

always @ *
begin
	case(sum_level_1[13])
		19 'sd 0      :	LUT_out[13] = 18'sd 0;
		19 'sd 98304  :	LUT_out[13] = 18'sd 26;
		19 'sd 32768  :	LUT_out[13] = 18'sd 9;
		-19'sd 32768  :	LUT_out[13] = -18'sd 9;
		-19'sd 98304  :	LUT_out[13] = -18'sd 26;
		19 'sd 196608 :	LUT_out[13] = 18'sd 53;
		19 'sd 131072 :	LUT_out[13] = 18'sd 35;
		19 'sd 65536  :	LUT_out[13] = 18'sd 18;
		-19'sd 65536  :	LUT_out[13] = -18'sd 18;
		-19'sd 131072 :	LUT_out[13] = -18'sd 35;
		-19'sd 196608 :	LUT_out[13] = -18'sd 53;
		default     :	LUT_out[13] = 18'sd 0;
	endcase
end

// LUT_14 

always @ *
begin
	case(sum_level_1[14])
		19 'sd 0      :	LUT_out[14] = 18'sd 0;
		19 'sd 98304  :	LUT_out[14] = -18'sd 304;
		19 'sd 32768  :	LUT_out[14] = -18'sd 101;
		-19'sd 32768  :	LUT_out[14] = 18'sd 101;
		-19'sd 98304  :	LUT_out[14] = 18'sd 304;
		19 'sd 196608 :	LUT_out[14] = -18'sd 607;
		19 'sd 131072 :	LUT_out[14] = -18'sd 405;
		19 'sd 65536  :	LUT_out[14] = -18'sd 202;
		-19'sd 65536  :	LUT_out[14] = 18'sd 202;
		-19'sd 131072 :	LUT_out[14] = 18'sd 405;
		-19'sd 196608 :	LUT_out[14] = 18'sd 607;
		default     :	LUT_out[14] = 18'sd 0;
	endcase
end

// LUT_15 

always @ *
begin
	case(sum_level_1[15])
		19 'sd 0      :	LUT_out[15] = 18'sd 0;
		19 'sd 98304  :	LUT_out[15] = -18'sd 485;
		19 'sd 32768  :	LUT_out[15] = -18'sd 162;
		-19'sd 32768  :	LUT_out[15] = 18'sd 162;
		-19'sd 98304  :	LUT_out[15] = 18'sd 485;
		19 'sd 196608 :	LUT_out[15] = -18'sd 971;
		19 'sd 131072 :	LUT_out[15] = -18'sd 647;
		19 'sd 65536  :	LUT_out[15] = -18'sd 324;
		-19'sd 65536  :	LUT_out[15] = 18'sd 324;
		-19'sd 131072 :	LUT_out[15] = 18'sd 647;
		-19'sd 196608 :	LUT_out[15] = 18'sd 971;
		default     :	LUT_out[15] = 18'sd 0;
	endcase
end

// LUT_16 

always @ *
begin
	case(sum_level_1[16])
		19 'sd 0      :	LUT_out[16] = 18'sd 0;
		19 'sd 98304  :	LUT_out[16] = -18'sd 363;
		19 'sd 32768  :	LUT_out[16] = -18'sd 121;
		-19'sd 32768  :	LUT_out[16] = 18'sd 121;
		-19'sd 98304  :	LUT_out[16] = 18'sd 363;
		19 'sd 196608 :	LUT_out[16] = -18'sd 726;
		19 'sd 131072 :	LUT_out[16] = -18'sd 484;
		19 'sd 65536  :	LUT_out[16] = -18'sd 242;
		-19'sd 65536  :	LUT_out[16] = 18'sd 242;
		-19'sd 131072 :	LUT_out[16] = 18'sd 484;
		-19'sd 196608 :	LUT_out[16] = 18'sd 726;
		default     :	LUT_out[16] = 18'sd 0;
	endcase
end

// LUT_17 

always @ *
begin
	case(sum_level_1[17])
		19 'sd 0      :	LUT_out[17] = 18'sd 0;
		19 'sd 98304  :	LUT_out[17] = 18'sd 36;
		19 'sd 32768  :	LUT_out[17] = 18'sd 12;
		-19'sd 32768  :	LUT_out[17] = -18'sd 12;
		-19'sd 98304  :	LUT_out[17] = -18'sd 36;
		19 'sd 196608 :	LUT_out[17] = 18'sd 72;
		19 'sd 131072 :	LUT_out[17] = 18'sd 48;
		19 'sd 65536  :	LUT_out[17] = 18'sd 24;
		-19'sd 65536  :	LUT_out[17] = -18'sd 24;
		-19'sd 131072 :	LUT_out[17] = -18'sd 48;
		-19'sd 196608 :	LUT_out[17] = -18'sd 72;
		default     :	LUT_out[17] = 18'sd 0;
	endcase
end

// LUT_18 

always @ *
begin
	case(sum_level_1[18])
		19 'sd 0      :	LUT_out[18] = 18'sd 0;
		19 'sd 98304  :	LUT_out[18] = 18'sd 485;
		19 'sd 32768  :	LUT_out[18] = 18'sd 162;
		-19'sd 32768  :	LUT_out[18] = -18'sd 162;
		-19'sd 98304  :	LUT_out[18] = -18'sd 485;
		19 'sd 196608 :	LUT_out[18] = 18'sd 970;
		19 'sd 131072 :	LUT_out[18] = 18'sd 647;
		19 'sd 65536  :	LUT_out[18] = 18'sd 323;
		-19'sd 65536  :	LUT_out[18] = -18'sd 323;
		-19'sd 131072 :	LUT_out[18] = -18'sd 647;
		-19'sd 196608 :	LUT_out[18] = -18'sd 970;
		default     :	LUT_out[18] = 18'sd 0;
	endcase
end

// LUT_19 

always @ *
begin
	case(sum_level_1[19])
		19 'sd 0      :	LUT_out[19] = 18'sd 0;
		19 'sd 98304  :	LUT_out[19] = 18'sd 683;
		19 'sd 32768  :	LUT_out[19] = 18'sd 228;
		-19'sd 32768  :	LUT_out[19] = -18'sd 228;
		-19'sd 98304  :	LUT_out[19] = -18'sd 683;
		19 'sd 196608 :	LUT_out[19] = 18'sd 1365;
		19 'sd 131072 :	LUT_out[19] = 18'sd 910;
		19 'sd 65536  :	LUT_out[19] = 18'sd 455;
		-19'sd 65536  :	LUT_out[19] = -18'sd 455;
		-19'sd 131072 :	LUT_out[19] = -18'sd 910;
		-19'sd 196608 :	LUT_out[19] = -18'sd 1365;
		default     :	LUT_out[19] = 18'sd 0;
	endcase
end

// LUT_20 

always @ *
begin
	case(sum_level_1[20])
		19 'sd 0      :	LUT_out[20] = 18'sd 0;
		19 'sd 98304  :	LUT_out[20] = 18'sd 446;
		19 'sd 32768  :	LUT_out[20] = 18'sd 149;
		-19'sd 32768  :	LUT_out[20] = -18'sd 149;
		-19'sd 98304  :	LUT_out[20] = -18'sd 446;
		19 'sd 196608 :	LUT_out[20] = 18'sd 892;
		19 'sd 131072 :	LUT_out[20] = 18'sd 595;
		19 'sd 65536  :	LUT_out[20] = 18'sd 297;
		-19'sd 65536  :	LUT_out[20] = -18'sd 297;
		-19'sd 131072 :	LUT_out[20] = -18'sd 595;
		-19'sd 196608 :	LUT_out[20] = -18'sd 892;
		default     :	LUT_out[20] = 18'sd 0;
	endcase
end

// LUT_21 

always @ *
begin
	case(sum_level_1[21])
		19 'sd 0      :	LUT_out[21] = 18'sd 0;
		19 'sd 98304  :	LUT_out[21] = -18'sd 139;
		19 'sd 32768  :	LUT_out[21] = -18'sd 46;
		-19'sd 32768  :	LUT_out[21] = 18'sd 46;
		-19'sd 98304  :	LUT_out[21] = 18'sd 139;
		19 'sd 196608 :	LUT_out[21] = -18'sd 278;
		19 'sd 131072 :	LUT_out[21] = -18'sd 186;
		19 'sd 65536  :	LUT_out[21] = -18'sd 93;
		-19'sd 65536  :	LUT_out[21] = 18'sd 93;
		-19'sd 131072 :	LUT_out[21] = 18'sd 186;
		-19'sd 196608 :	LUT_out[21] = 18'sd 278;
		default     :	LUT_out[21] = 18'sd 0;
	endcase
end

// LUT_22 

always @ *
begin
	case(sum_level_1[22])
		19 'sd 0      :	LUT_out[22] = 18'sd 0;
		19 'sd 98304  :	LUT_out[22] = -18'sd 734;
		19 'sd 32768  :	LUT_out[22] = -18'sd 245;
		-19'sd 32768  :	LUT_out[22] = 18'sd 245;
		-19'sd 98304  :	LUT_out[22] = 18'sd 734;
		19 'sd 196608 :	LUT_out[22] = -18'sd 1467;
		19 'sd 131072 :	LUT_out[22] = -18'sd 978;
		19 'sd 65536  :	LUT_out[22] = -18'sd 489;
		-19'sd 65536  :	LUT_out[22] = 18'sd 489;
		-19'sd 131072 :	LUT_out[22] = 18'sd 978;
		-19'sd 196608 :	LUT_out[22] = 18'sd 1467;
		default     :	LUT_out[22] = 18'sd 0;
	endcase
end

// LUT_23 

always @ *
begin
	case(sum_level_1[23])
		19 'sd 0      :	LUT_out[23] = 18'sd 0;
		19 'sd 98304  :	LUT_out[23] = -18'sd 932;
		19 'sd 32768  :	LUT_out[23] = -18'sd 311;
		-19'sd 32768  :	LUT_out[23] = 18'sd 311;
		-19'sd 98304  :	LUT_out[23] = 18'sd 932;
		19 'sd 196608 :	LUT_out[23] = -18'sd 1865;
		19 'sd 131072 :	LUT_out[23] = -18'sd 1243;
		19 'sd 65536  :	LUT_out[23] = -18'sd 622;
		-19'sd 65536  :	LUT_out[23] = 18'sd 622;
		-19'sd 131072 :	LUT_out[23] = 18'sd 1243;
		-19'sd 196608 :	LUT_out[23] = 18'sd 1865;
		default     :	LUT_out[23] = 18'sd 0;
	endcase
end

// LUT_24 

always @ *
begin
	case(sum_level_1[24])
		19 'sd 0      :	LUT_out[24] = 18'sd 0;
		19 'sd 98304  :	LUT_out[24] = -18'sd 532;
		19 'sd 32768  :	LUT_out[24] = -18'sd 177;
		-19'sd 32768  :	LUT_out[24] = 18'sd 177;
		-19'sd 98304  :	LUT_out[24] = 18'sd 532;
		19 'sd 196608 :	LUT_out[24] = -18'sd 1064;
		19 'sd 131072 :	LUT_out[24] = -18'sd 709;
		19 'sd 65536  :	LUT_out[24] = -18'sd 355;
		-19'sd 65536  :	LUT_out[24] = 18'sd 355;
		-19'sd 131072 :	LUT_out[24] = 18'sd 709;
		-19'sd 196608 :	LUT_out[24] = 18'sd 1064;
		default     :	LUT_out[24] = 18'sd 0;
	endcase
end

// LUT_25 

always @ *
begin
	case(sum_level_1[25])
		19 'sd 0      :	LUT_out[25] = 18'sd 0;
		19 'sd 98304  :	LUT_out[25] = 18'sd 299;
		19 'sd 32768  :	LUT_out[25] = 18'sd 100;
		-19'sd 32768  :	LUT_out[25] = -18'sd 100;
		-19'sd 98304  :	LUT_out[25] = -18'sd 299;
		19 'sd 196608 :	LUT_out[25] = 18'sd 598;
		19 'sd 131072 :	LUT_out[25] = 18'sd 399;
		19 'sd 65536  :	LUT_out[25] = 18'sd 199;
		-19'sd 65536  :	LUT_out[25] = -18'sd 199;
		-19'sd 131072 :	LUT_out[25] = -18'sd 399;
		-19'sd 196608 :	LUT_out[25] = -18'sd 598;
		default     :	LUT_out[25] = 18'sd 0;
	endcase
end

// LUT_26 

always @ *
begin
	case(sum_level_1[26])
		19 'sd 0      :	LUT_out[26] = 18'sd 0;
		19 'sd 98304  :	LUT_out[26] = 18'sd 1070;
		19 'sd 32768  :	LUT_out[26] = 18'sd 357;
		-19'sd 32768  :	LUT_out[26] = -18'sd 357;
		-19'sd 98304  :	LUT_out[26] = -18'sd 1070;
		19 'sd 196608 :	LUT_out[26] = 18'sd 2140;
		19 'sd 131072 :	LUT_out[26] = 18'sd 1427;
		19 'sd 65536  :	LUT_out[26] = 18'sd 713;
		-19'sd 65536  :	LUT_out[26] = -18'sd 713;
		-19'sd 131072 :	LUT_out[26] = -18'sd 1427;
		-19'sd 196608 :	LUT_out[26] = -18'sd 2140;
		default     :	LUT_out[26] = 18'sd 0;
	endcase
end

// LUT_27 

always @ *
begin
	case(sum_level_1[27])
		19 'sd 0      :	LUT_out[27] = 18'sd 0;
		19 'sd 98304  :	LUT_out[27] = 18'sd 1250;
		19 'sd 32768  :	LUT_out[27] = 18'sd 417;
		-19'sd 32768  :	LUT_out[27] = -18'sd 417;
		-19'sd 98304  :	LUT_out[27] = -18'sd 1250;
		19 'sd 196608 :	LUT_out[27] = 18'sd 2499;
		19 'sd 131072 :	LUT_out[27] = 18'sd 1666;
		19 'sd 65536  :	LUT_out[27] = 18'sd 833;
		-19'sd 65536  :	LUT_out[27] = -18'sd 833;
		-19'sd 131072 :	LUT_out[27] = -18'sd 1666;
		-19'sd 196608 :	LUT_out[27] = -18'sd 2499;
		default     :	LUT_out[27] = 18'sd 0;
	endcase
end

// LUT_28 

always @ *
begin
	case(sum_level_1[28])
		19 'sd 0      :	LUT_out[28] = 18'sd 0;
		19 'sd 98304  :	LUT_out[28] = 18'sd 617;
		19 'sd 32768  :	LUT_out[28] = 18'sd 206;
		-19'sd 32768  :	LUT_out[28] = -18'sd 206;
		-19'sd 98304  :	LUT_out[28] = -18'sd 617;
		19 'sd 196608 :	LUT_out[28] = 18'sd 1233;
		19 'sd 131072 :	LUT_out[28] = 18'sd 822;
		19 'sd 65536  :	LUT_out[28] = 18'sd 411;
		-19'sd 65536  :	LUT_out[28] = -18'sd 411;
		-19'sd 131072 :	LUT_out[28] = -18'sd 822;
		-19'sd 196608 :	LUT_out[28] = -18'sd 1233;
		default     :	LUT_out[28] = 18'sd 0;
	endcase
end

// LUT_29 

always @ *
begin
	case(sum_level_1[29])
		19 'sd 0      :	LUT_out[29] = 18'sd 0;
		19 'sd 98304  :	LUT_out[29] = -18'sd 539;
		19 'sd 32768  :	LUT_out[29] = -18'sd 180;
		-19'sd 32768  :	LUT_out[29] = 18'sd 180;
		-19'sd 98304  :	LUT_out[29] = 18'sd 539;
		19 'sd 196608 :	LUT_out[29] = -18'sd 1079;
		19 'sd 131072 :	LUT_out[29] = -18'sd 719;
		19 'sd 65536  :	LUT_out[29] = -18'sd 360;
		-19'sd 65536  :	LUT_out[29] = 18'sd 360;
		-19'sd 131072 :	LUT_out[29] = 18'sd 719;
		-19'sd 196608 :	LUT_out[29] = 18'sd 1079;
		default     :	LUT_out[29] = 18'sd 0;
	endcase
end

// LUT_30 

always @ *
begin
	case(sum_level_1[30])
		19 'sd 0      :	LUT_out[30] = 18'sd 0;
		19 'sd 98304  :	LUT_out[30] = -18'sd 1529;
		19 'sd 32768  :	LUT_out[30] = -18'sd 510;
		-19'sd 32768  :	LUT_out[30] = 18'sd 510;
		-19'sd 98304  :	LUT_out[30] = 18'sd 1529;
		19 'sd 196608 :	LUT_out[30] = -18'sd 3059;
		19 'sd 131072 :	LUT_out[30] = -18'sd 2039;
		19 'sd 65536  :	LUT_out[30] = -18'sd 1020;
		-19'sd 65536  :	LUT_out[30] = 18'sd 1020;
		-19'sd 131072 :	LUT_out[30] = 18'sd 2039;
		-19'sd 196608 :	LUT_out[30] = 18'sd 3059;
		default     :	LUT_out[30] = 18'sd 0;
	endcase
end

// LUT_31 

always @ *
begin
	case(sum_level_1[31])
		19 'sd 0      :	LUT_out[31] = 18'sd 0;
		19 'sd 98304  :	LUT_out[31] = -18'sd 1660;
		19 'sd 32768  :	LUT_out[31] = -18'sd 553;
		-19'sd 32768  :	LUT_out[31] = 18'sd 553;
		-19'sd 98304  :	LUT_out[31] = 18'sd 1660;
		19 'sd 196608 :	LUT_out[31] = -18'sd 3320;
		19 'sd 131072 :	LUT_out[31] = -18'sd 2213;
		19 'sd 65536  :	LUT_out[31] = -18'sd 1107;
		-19'sd 65536  :	LUT_out[31] = 18'sd 1107;
		-19'sd 131072 :	LUT_out[31] = 18'sd 2213;
		-19'sd 196608 :	LUT_out[31] = 18'sd 3320;
		default     :	LUT_out[31] = 18'sd 0;
	endcase
end

// LUT_32 

always @ *
begin
	case(sum_level_1[32])
		19 'sd 0      :	LUT_out[32] = 18'sd 0;
		19 'sd 98304  :	LUT_out[32] = -18'sd 697;
		19 'sd 32768  :	LUT_out[32] = -18'sd 232;
		-19'sd 32768  :	LUT_out[32] = 18'sd 232;
		-19'sd 98304  :	LUT_out[32] = 18'sd 697;
		19 'sd 196608 :	LUT_out[32] = -18'sd 1394;
		19 'sd 131072 :	LUT_out[32] = -18'sd 929;
		19 'sd 65536  :	LUT_out[32] = -18'sd 465;
		-19'sd 65536  :	LUT_out[32] = 18'sd 465;
		-19'sd 131072 :	LUT_out[32] = 18'sd 929;
		-19'sd 196608 :	LUT_out[32] = 18'sd 1394;
		default     :	LUT_out[32] = 18'sd 0;
	endcase
end

// LUT_33 

always @ *
begin
	case(sum_level_1[33])
		19 'sd 0      :	LUT_out[33] = 18'sd 0;
		19 'sd 98304  :	LUT_out[33] = 18'sd 902;
		19 'sd 32768  :	LUT_out[33] = 18'sd 301;
		-19'sd 32768  :	LUT_out[33] = -18'sd 301;
		-19'sd 98304  :	LUT_out[33] = -18'sd 902;
		19 'sd 196608 :	LUT_out[33] = 18'sd 1804;
		19 'sd 131072 :	LUT_out[33] = 18'sd 1203;
		19 'sd 65536  :	LUT_out[33] = 18'sd 601;
		-19'sd 65536  :	LUT_out[33] = -18'sd 601;
		-19'sd 131072 :	LUT_out[33] = -18'sd 1203;
		-19'sd 196608 :	LUT_out[33] = -18'sd 1804;
		default     :	LUT_out[33] = 18'sd 0;
	endcase
end

// LUT_34 

always @ *
begin
	case(sum_level_1[34])
		19 'sd 0      :	LUT_out[34] = 18'sd 0;
		19 'sd 98304  :	LUT_out[34] = 18'sd 2176;
		19 'sd 32768  :	LUT_out[34] = 18'sd 725;
		-19'sd 32768  :	LUT_out[34] = -18'sd 725;
		-19'sd 98304  :	LUT_out[34] = -18'sd 2176;
		19 'sd 196608 :	LUT_out[34] = 18'sd 4352;
		19 'sd 131072 :	LUT_out[34] = 18'sd 2901;
		19 'sd 65536  :	LUT_out[34] = 18'sd 1451;
		-19'sd 65536  :	LUT_out[34] = -18'sd 1451;
		-19'sd 131072 :	LUT_out[34] = -18'sd 2901;
		-19'sd 196608 :	LUT_out[34] = -18'sd 4352;
		default     :	LUT_out[34] = 18'sd 0;
	endcase
end

// LUT_35 

always @ *
begin
	case(sum_level_1[35])
		19 'sd 0      :	LUT_out[35] = 18'sd 0;
		19 'sd 98304  :	LUT_out[35] = 18'sd 2215;
		19 'sd 32768  :	LUT_out[35] = 18'sd 738;
		-19'sd 32768  :	LUT_out[35] = -18'sd 738;
		-19'sd 98304  :	LUT_out[35] = -18'sd 2215;
		19 'sd 196608 :	LUT_out[35] = 18'sd 4430;
		19 'sd 131072 :	LUT_out[35] = 18'sd 2953;
		19 'sd 65536  :	LUT_out[35] = 18'sd 1477;
		-19'sd 65536  :	LUT_out[35] = -18'sd 1477;
		-19'sd 131072 :	LUT_out[35] = -18'sd 2953;
		-19'sd 196608 :	LUT_out[35] = -18'sd 4430;
		default     :	LUT_out[35] = 18'sd 0;
	endcase
end

// LUT_36 

always @ *
begin
	case(sum_level_1[36])
		19 'sd 0      :	LUT_out[36] = 18'sd 0;
		19 'sd 98304  :	LUT_out[36] = 18'sd 769;
		19 'sd 32768  :	LUT_out[36] = 18'sd 256;
		-19'sd 32768  :	LUT_out[36] = -18'sd 256;
		-19'sd 98304  :	LUT_out[36] = -18'sd 769;
		19 'sd 196608 :	LUT_out[36] = 18'sd 1538;
		19 'sd 131072 :	LUT_out[36] = 18'sd 1025;
		19 'sd 65536  :	LUT_out[36] = 18'sd 513;
		-19'sd 65536  :	LUT_out[36] = -18'sd 513;
		-19'sd 131072 :	LUT_out[36] = -18'sd 1025;
		-19'sd 196608 :	LUT_out[36] = -18'sd 1538;
		default     :	LUT_out[36] = 18'sd 0;
	endcase
end

// LUT_37 

always @ *
begin
	case(sum_level_1[37])
		19 'sd 0      :	LUT_out[37] = 18'sd 0;
		19 'sd 98304  :	LUT_out[37] = -18'sd 1468;
		19 'sd 32768  :	LUT_out[37] = -18'sd 489;
		-19'sd 32768  :	LUT_out[37] = 18'sd 489;
		-19'sd 98304  :	LUT_out[37] = 18'sd 1468;
		19 'sd 196608 :	LUT_out[37] = -18'sd 2936;
		19 'sd 131072 :	LUT_out[37] = -18'sd 1957;
		19 'sd 65536  :	LUT_out[37] = -18'sd 979;
		-19'sd 65536  :	LUT_out[37] = 18'sd 979;
		-19'sd 131072 :	LUT_out[37] = 18'sd 1957;
		-19'sd 196608 :	LUT_out[37] = 18'sd 2936;
		default     :	LUT_out[37] = 18'sd 0;
	endcase
end

// LUT_38 

always @ *
begin
	case(sum_level_1[38])
		19 'sd 0      :	LUT_out[38] = 18'sd 0;
		19 'sd 98304  :	LUT_out[38] = -18'sd 3148;
		19 'sd 32768  :	LUT_out[38] = -18'sd 1049;
		-19'sd 32768  :	LUT_out[38] = 18'sd 1049;
		-19'sd 98304  :	LUT_out[38] = 18'sd 3148;
		19 'sd 196608 :	LUT_out[38] = -18'sd 6295;
		19 'sd 131072 :	LUT_out[38] = -18'sd 4197;
		19 'sd 65536  :	LUT_out[38] = -18'sd 2098;
		-19'sd 65536  :	LUT_out[38] = 18'sd 2098;
		-19'sd 131072 :	LUT_out[38] = 18'sd 4197;
		-19'sd 196608 :	LUT_out[38] = 18'sd 6295;
		default     :	LUT_out[38] = 18'sd 0;
	endcase
end

// LUT_39 

always @ *
begin
	case(sum_level_1[39])
		19 'sd 0      :	LUT_out[39] = 18'sd 0;
		19 'sd 98304  :	LUT_out[39] = -18'sd 3033;
		19 'sd 32768  :	LUT_out[39] = -18'sd 1011;
		-19'sd 32768  :	LUT_out[39] = 18'sd 1011;
		-19'sd 98304  :	LUT_out[39] = 18'sd 3033;
		19 'sd 196608 :	LUT_out[39] = -18'sd 6065;
		19 'sd 131072 :	LUT_out[39] = -18'sd 4044;
		19 'sd 65536  :	LUT_out[39] = -18'sd 2022;
		-19'sd 65536  :	LUT_out[39] = 18'sd 2022;
		-19'sd 131072 :	LUT_out[39] = 18'sd 4044;
		-19'sd 196608 :	LUT_out[39] = 18'sd 6065;
		default     :	LUT_out[39] = 18'sd 0;
	endcase
end

// LUT_40 

always @ *
begin
	case(sum_level_1[40])
		19 'sd 0      :	LUT_out[40] = 18'sd 0;
		19 'sd 98304  :	LUT_out[40] = -18'sd 829;
		19 'sd 32768  :	LUT_out[40] = -18'sd 276;
		-19'sd 32768  :	LUT_out[40] = 18'sd 276;
		-19'sd 98304  :	LUT_out[40] = 18'sd 829;
		19 'sd 196608 :	LUT_out[40] = -18'sd 1658;
		19 'sd 131072 :	LUT_out[40] = -18'sd 1105;
		19 'sd 65536  :	LUT_out[40] = -18'sd 553;
		-19'sd 65536  :	LUT_out[40] = 18'sd 553;
		-19'sd 131072 :	LUT_out[40] = 18'sd 1105;
		-19'sd 196608 :	LUT_out[40] = 18'sd 1658;
		default     :	LUT_out[40] = 18'sd 0;
	endcase
end

// LUT_41 

always @ *
begin
	case(sum_level_1[41])
		19 'sd 0      :	LUT_out[41] = 18'sd 0;
		19 'sd 98304  :	LUT_out[41] = 18'sd 2436;
		19 'sd 32768  :	LUT_out[41] = 18'sd 812;
		-19'sd 32768  :	LUT_out[41] = -18'sd 812;
		-19'sd 98304  :	LUT_out[41] = -18'sd 2436;
		19 'sd 196608 :	LUT_out[41] = 18'sd 4871;
		19 'sd 131072 :	LUT_out[41] = 18'sd 3247;
		19 'sd 65536  :	LUT_out[41] = 18'sd 1624;
		-19'sd 65536  :	LUT_out[41] = -18'sd 1624;
		-19'sd 131072 :	LUT_out[41] = -18'sd 3247;
		-19'sd 196608 :	LUT_out[41] = -18'sd 4871;
		default     :	LUT_out[41] = 18'sd 0;
	endcase
end

// LUT_42 

always @ *
begin
	case(sum_level_1[42])
		19 'sd 0      :	LUT_out[42] = 18'sd 0;
		19 'sd 98304  :	LUT_out[42] = 18'sd 4804;
		19 'sd 32768  :	LUT_out[42] = 18'sd 1601;
		-19'sd 32768  :	LUT_out[42] = -18'sd 1601;
		-19'sd 98304  :	LUT_out[42] = -18'sd 4804;
		19 'sd 196608 :	LUT_out[42] = 18'sd 9608;
		19 'sd 131072 :	LUT_out[42] = 18'sd 6405;
		19 'sd 65536  :	LUT_out[42] = 18'sd 3203;
		-19'sd 65536  :	LUT_out[42] = -18'sd 3203;
		-19'sd 131072 :	LUT_out[42] = -18'sd 6405;
		-19'sd 196608 :	LUT_out[42] = -18'sd 9608;
		default     :	LUT_out[42] = 18'sd 0;
	endcase
end

// LUT_43 

always @ *
begin
	case(sum_level_1[43])
		19 'sd 0      :	LUT_out[43] = 18'sd 0;
		19 'sd 98304  :	LUT_out[43] = 18'sd 4450;
		19 'sd 32768  :	LUT_out[43] = 18'sd 1483;
		-19'sd 32768  :	LUT_out[43] = -18'sd 1483;
		-19'sd 98304  :	LUT_out[43] = -18'sd 4450;
		19 'sd 196608 :	LUT_out[43] = 18'sd 8900;
		19 'sd 131072 :	LUT_out[43] = 18'sd 5933;
		19 'sd 65536  :	LUT_out[43] = 18'sd 2967;
		-19'sd 65536  :	LUT_out[43] = -18'sd 2967;
		-19'sd 131072 :	LUT_out[43] = -18'sd 5933;
		-19'sd 196608 :	LUT_out[43] = -18'sd 8900;
		default     :	LUT_out[43] = 18'sd 0;
	endcase
end

// LUT_44 

always @ *
begin
	case(sum_level_1[44])
		19 'sd 0      :	LUT_out[44] = 18'sd 0;
		19 'sd 98304  :	LUT_out[44] = 18'sd 874;
		19 'sd 32768  :	LUT_out[44] = 18'sd 291;
		-19'sd 32768  :	LUT_out[44] = -18'sd 291;
		-19'sd 98304  :	LUT_out[44] = -18'sd 874;
		19 'sd 196608 :	LUT_out[44] = 18'sd 1749;
		19 'sd 131072 :	LUT_out[44] = 18'sd 1166;
		19 'sd 65536  :	LUT_out[44] = 18'sd 583;
		-19'sd 65536  :	LUT_out[44] = -18'sd 583;
		-19'sd 131072 :	LUT_out[44] = -18'sd 1166;
		-19'sd 196608 :	LUT_out[44] = -18'sd 1749;
		default     :	LUT_out[44] = 18'sd 0;
	endcase
end

// LUT_45 

always @ *
begin
	case(sum_level_1[45])
		19 'sd 0      :	LUT_out[45] = 18'sd 0;
		19 'sd 98304  :	LUT_out[45] = -18'sd 4453;
		19 'sd 32768  :	LUT_out[45] = -18'sd 1484;
		-19'sd 32768  :	LUT_out[45] = 18'sd 1484;
		-19'sd 98304  :	LUT_out[45] = 18'sd 4453;
		19 'sd 196608 :	LUT_out[45] = -18'sd 8906;
		19 'sd 131072 :	LUT_out[45] = -18'sd 5937;
		19 'sd 65536  :	LUT_out[45] = -18'sd 2969;
		-19'sd 65536  :	LUT_out[45] = 18'sd 2969;
		-19'sd 131072 :	LUT_out[45] = 18'sd 5937;
		-19'sd 196608 :	LUT_out[45] = 18'sd 8906;
		default     :	LUT_out[45] = 18'sd 0;
	endcase
end

// LUT_46 

always @ *
begin
	case(sum_level_1[46])
		19 'sd 0      :	LUT_out[46] = 18'sd 0;
		19 'sd 98304  :	LUT_out[46] = -18'sd 8473;
		19 'sd 32768  :	LUT_out[46] = -18'sd 2824;
		-19'sd 32768  :	LUT_out[46] = 18'sd 2824;
		-19'sd 98304  :	LUT_out[46] = 18'sd 8473;
		19 'sd 196608 :	LUT_out[46] = -18'sd 16947;
		19 'sd 131072 :	LUT_out[46] = -18'sd 11298;
		19 'sd 65536  :	LUT_out[46] = -18'sd 5649;
		-19'sd 65536  :	LUT_out[46] = 18'sd 5649;
		-19'sd 131072 :	LUT_out[46] = 18'sd 11298;
		-19'sd 196608 :	LUT_out[46] = 18'sd 16947;
		default     :	LUT_out[46] = 18'sd 0;
	endcase
end

// LUT_47 

always @ *
begin
	case(sum_level_1[47])
		19 'sd 0      :	LUT_out[47] = 18'sd 0;
		19 'sd 98304  :	LUT_out[47] = -18'sd 7894;
		19 'sd 32768  :	LUT_out[47] = -18'sd 2631;
		-19'sd 32768  :	LUT_out[47] = 18'sd 2631;
		-19'sd 98304  :	LUT_out[47] = 18'sd 7894;
		19 'sd 196608 :	LUT_out[47] = -18'sd 15788;
		19 'sd 131072 :	LUT_out[47] = -18'sd 10526;
		19 'sd 65536  :	LUT_out[47] = -18'sd 5263;
		-19'sd 65536  :	LUT_out[47] = 18'sd 5263;
		-19'sd 131072 :	LUT_out[47] = 18'sd 10526;
		-19'sd 196608 :	LUT_out[47] = 18'sd 15788;
		default     :	LUT_out[47] = 18'sd 0;
	endcase
end

// LUT_48 

always @ *
begin
	case(sum_level_1[48])
		19 'sd 0      :	LUT_out[48] = 18'sd 0;
		19 'sd 98304  :	LUT_out[48] = -18'sd 903;
		19 'sd 32768  :	LUT_out[48] = -18'sd 301;
		-19'sd 32768  :	LUT_out[48] = 18'sd 301;
		-19'sd 98304  :	LUT_out[48] = 18'sd 903;
		19 'sd 196608 :	LUT_out[48] = -18'sd 1805;
		19 'sd 131072 :	LUT_out[48] = -18'sd 1203;
		19 'sd 65536  :	LUT_out[48] = -18'sd 602;
		-19'sd 65536  :	LUT_out[48] = 18'sd 602;
		-19'sd 131072 :	LUT_out[48] = 18'sd 1203;
		-19'sd 196608 :	LUT_out[48] = 18'sd 1805;
		default     :	LUT_out[48] = 18'sd 0;
	endcase
end

// LUT_49 

always @ *
begin
	case(sum_level_1[49])
		19 'sd 0      :	LUT_out[49] = 18'sd 0;
		19 'sd 98304  :	LUT_out[49] = 18'sd 11629;
		19 'sd 32768  :	LUT_out[49] = 18'sd 3876;
		-19'sd 32768  :	LUT_out[49] = -18'sd 3876;
		-19'sd 98304  :	LUT_out[49] = -18'sd 11629;
		19 'sd 196608 :	LUT_out[49] = 18'sd 23259;
		19 'sd 131072 :	LUT_out[49] = 18'sd 15506;
		19 'sd 65536  :	LUT_out[49] = 18'sd 7753;
		-19'sd 65536  :	LUT_out[49] = -18'sd 7753;
		-19'sd 131072 :	LUT_out[49] = -18'sd 15506;
		-19'sd 196608 :	LUT_out[49] = -18'sd 23259;
		default     :	LUT_out[49] = 18'sd 0;
	endcase
end

// LUT_50 

always @ *
begin
	case(sum_level_1[50])
		19 'sd 0      :	LUT_out[50] = 18'sd 0;
		19 'sd 98304  :	LUT_out[50] = 18'sd 26144;
		19 'sd 32768  :	LUT_out[50] = 18'sd 8715;
		-19'sd 32768  :	LUT_out[50] = -18'sd 8715;
		-19'sd 98304  :	LUT_out[50] = -18'sd 26144;
		19 'sd 196608 :	LUT_out[50] = 18'sd 52287;
		19 'sd 131072 :	LUT_out[50] = 18'sd 34858;
		19 'sd 65536  :	LUT_out[50] = 18'sd 17429;
		-19'sd 65536  :	LUT_out[50] = -18'sd 17429;
		-19'sd 131072 :	LUT_out[50] = -18'sd 34858;
		-19'sd 196608 :	LUT_out[50] = -18'sd 52287;
		default     :	LUT_out[50] = 18'sd 0;
	endcase
end

// LUT_51 

always @ *
begin
	case(sum_level_1[51])
		19 'sd 0      :	LUT_out[51] = 18'sd 0;
		19 'sd 98304  :	LUT_out[51] = 18'sd 37714;
		19 'sd 32768  :	LUT_out[51] = 18'sd 12571;
		-19'sd 32768  :	LUT_out[51] = -18'sd 12571;
		-19'sd 98304  :	LUT_out[51] = -18'sd 37714;
		19 'sd 196608 :	LUT_out[51] = 18'sd 75429;
		19 'sd 131072 :	LUT_out[51] = 18'sd 50286;
		19 'sd 65536  :	LUT_out[51] = 18'sd 25143;
		-19'sd 65536  :	LUT_out[51] = -18'sd 25143;
		-19'sd 131072 :	LUT_out[51] = -18'sd 50286;
		-19'sd 196608 :	LUT_out[51] = -18'sd 75429;
		default     :	LUT_out[51] = 18'sd 0;
	endcase
end

// LUT_52 

always @ *
begin
	case(sum_level_1[52])
		19 'sd 0      :	LUT_out[52] = 18'sd 0;
		19 'sd 98304  :	LUT_out[52] = 18'sd 42122;
		19 'sd 32768  :	LUT_out[52] = 18'sd 14041;
		-19'sd 32768  :	LUT_out[52] = -18'sd 14041;
		-19'sd 98304  :	LUT_out[52] = -18'sd 42122;
		default     :	LUT_out[52] = 18'sd 0;
	endcase
end


endmodule