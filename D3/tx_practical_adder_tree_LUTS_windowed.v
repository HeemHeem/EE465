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
        for (i = 0; i <= 25 , i=i+1)
            sum_level_2[i] = 18'sd 0;
    else
        for (i = 0; i <= 25, i=i+1)
            sum_level_2[i] = LUT_out[2*i] + LUT_out[2*i+1];


// sum_level_3 sum_level_3[12] is left alone
always @ *
    if (reset)
        for (i = 0; i <= 12 , i=i+1)
            sum_level_3[i] = 18'sd 0;
    else begin
        for (i = 0; i <= 12, i=i+1)
             sum_level_3[i] = sum_level_2[2*i] + sum_level_2[2*i+1];
    end
// sum_level_4 
always @ *
    if (reset)
        for (i = 0; i <= 5 , i=i+1)
            sum_level_4[i] = 18'sd 0;
    else 
        for (i = 0; i <= 5, i=i+1)
             sum_level_4[i] = sum_level_3[2*i] + sum_level_3[2*i+1];
        
// sum_level_5 - add sum_level_3[12] and LUT_52 here
always @ *
    if (reset)
        for (i = 0; i <= 3 , i=i+1)
            sum_level_5[i] = 18'sd 0;
    else begin
        for (i = 0; i <= 2, i=i+1)
            sum_level_5[i] = sum_level_4[2*i] + sum_level_4[2*i+1];
        sum_level_5[3] = sum_level_3[12] + LUT_out[52];
    end

// sum_level_6
always @ 
    if (reset)
        for (i = 0; i <= 1 , i=i+1)
            sum_level_6[i] = 18'sd 0;
    else begin
        for (i = 0; i <= 1, i=i+1)
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
		19 'sd 98304  :	LUT_out[0]  = -18'sd 32;
		19 'sd 32768  :	LUT_out[0]  = -18'sd 11;
		-19'sd 32768  :	LUT_out[0]  = 18'sd 11;
		-19'sd 98304  :	LUT_out[0]  = 18'sd 32;
		19 'sd 196608 :	LUT_out[0]  = -18'sd 65;
		19 'sd 131072 :	LUT_out[0]  = -18'sd 43;
		19 'sd 65536  :	LUT_out[0]  = -18'sd 22;
		-19'sd 65536  :	LUT_out[0]  = 18'sd 22;
		-19'sd 131072 :	LUT_out[0]  = 18'sd 43;
		-19'sd 196608 :	LUT_out[0]  = 18'sd 65;
		default     :	LUT_out[0]  = 18'sd 0;
	endcase
end

// LUT_1 

always @ *
begin
	case(sum_level_1[1])
		19 'sd 0      :	LUT_out[1]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[1]  = -18'sd 22;
		19 'sd 32768  :	LUT_out[1]  = -18'sd 7;
		-19'sd 32768  :	LUT_out[1]  = 18'sd 7;
		-19'sd 98304  :	LUT_out[1]  = 18'sd 22;
		19 'sd 196608 :	LUT_out[1]  = -18'sd 44;
		19 'sd 131072 :	LUT_out[1]  = -18'sd 29;
		19 'sd 65536  :	LUT_out[1]  = -18'sd 15;
		-19'sd 65536  :	LUT_out[1]  = 18'sd 15;
		-19'sd 131072 :	LUT_out[1]  = 18'sd 29;
		-19'sd 196608 :	LUT_out[1]  = 18'sd 44;
		default     :	LUT_out[1]  = 18'sd 0;
	endcase
end

// LUT_2 

always @ *
begin
	case(sum_level_1[2])
		19 'sd 0      :	LUT_out[2]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[2]  = 18'sd 8;
		19 'sd 32768  :	LUT_out[2]  = 18'sd 3;
		-19'sd 32768  :	LUT_out[2]  = -18'sd 3;
		-19'sd 98304  :	LUT_out[2]  = -18'sd 8;
		19 'sd 196608 :	LUT_out[2]  = 18'sd 17;
		19 'sd 131072 :	LUT_out[2]  = 18'sd 11;
		19 'sd 65536  :	LUT_out[2]  = 18'sd 6;
		-19'sd 65536  :	LUT_out[2]  = -18'sd 6;
		-19'sd 131072 :	LUT_out[2]  = -18'sd 11;
		-19'sd 196608 :	LUT_out[2]  = -18'sd 17;
		default     :	LUT_out[2]  = 18'sd 0;
	endcase
end

// LUT_3 

always @ *
begin
	case(sum_level_1[3])
		19 'sd 0      :	LUT_out[3]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[3]  = 18'sd 39;
		19 'sd 32768  :	LUT_out[3]  = 18'sd 13;
		-19'sd 32768  :	LUT_out[3]  = -18'sd 13;
		-19'sd 98304  :	LUT_out[3]  = -18'sd 39;
		19 'sd 196608 :	LUT_out[3]  = 18'sd 78;
		19 'sd 131072 :	LUT_out[3]  = 18'sd 52;
		19 'sd 65536  :	LUT_out[3]  = 18'sd 26;
		-19'sd 65536  :	LUT_out[3]  = -18'sd 26;
		-19'sd 131072 :	LUT_out[3]  = -18'sd 52;
		-19'sd 196608 :	LUT_out[3]  = -18'sd 78;
		default     :	LUT_out[3]  = 18'sd 0;
	endcase
end

// LUT_4 

always @ *
begin
	case(sum_level_1[4])
		19 'sd 0      :	LUT_out[4]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[4]  = 18'sd 48;
		19 'sd 32768  :	LUT_out[4]  = 18'sd 16;
		-19'sd 32768  :	LUT_out[4]  = -18'sd 16;
		-19'sd 98304  :	LUT_out[4]  = -18'sd 48;
		19 'sd 196608 :	LUT_out[4]  = 18'sd 95;
		19 'sd 131072 :	LUT_out[4]  = 18'sd 64;
		19 'sd 65536  :	LUT_out[4]  = 18'sd 32;
		-19'sd 65536  :	LUT_out[4]  = -18'sd 32;
		-19'sd 131072 :	LUT_out[4]  = -18'sd 64;
		-19'sd 196608 :	LUT_out[4]  = -18'sd 95;
		default     :	LUT_out[4]  = 18'sd 0;
	endcase
end

// LUT_5 

always @ *
begin
	case(sum_level_1[5])
		19 'sd 0      :	LUT_out[5]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[5]  = 18'sd 22;
		19 'sd 32768  :	LUT_out[5]  = 18'sd 7;
		-19'sd 32768  :	LUT_out[5]  = -18'sd 7;
		-19'sd 98304  :	LUT_out[5]  = -18'sd 22;
		19 'sd 196608 :	LUT_out[5]  = 18'sd 44;
		19 'sd 131072 :	LUT_out[5]  = 18'sd 29;
		19 'sd 65536  :	LUT_out[5]  = 18'sd 15;
		-19'sd 65536  :	LUT_out[5]  = -18'sd 15;
		-19'sd 131072 :	LUT_out[5]  = -18'sd 29;
		-19'sd 196608 :	LUT_out[5]  = -18'sd 44;
		default     :	LUT_out[5]  = 18'sd 0;
	endcase
end

// LUT_6 

always @ *
begin
	case(sum_level_1[6])
		19 'sd 0      :	LUT_out[6]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[6]  = -18'sd 26;
		19 'sd 32768  :	LUT_out[6]  = -18'sd 9;
		-19'sd 32768  :	LUT_out[6]  = 18'sd 9;
		-19'sd 98304  :	LUT_out[6]  = 18'sd 26;
		19 'sd 196608 :	LUT_out[6]  = -18'sd 52;
		19 'sd 131072 :	LUT_out[6]  = -18'sd 35;
		19 'sd 65536  :	LUT_out[6]  = -18'sd 17;
		-19'sd 65536  :	LUT_out[6]  = 18'sd 17;
		-19'sd 131072 :	LUT_out[6]  = 18'sd 35;
		-19'sd 196608 :	LUT_out[6]  = 18'sd 52;
		default     :	LUT_out[6]  = 18'sd 0;
	endcase
end

// LUT_7 

always @ *
begin
	case(sum_level_1[7])
		19 'sd 0      :	LUT_out[7]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[7]  = -18'sd 66;
		19 'sd 32768  :	LUT_out[7]  = -18'sd 22;
		-19'sd 32768  :	LUT_out[7]  = 18'sd 22;
		-19'sd 98304  :	LUT_out[7]  = 18'sd 66;
		19 'sd 196608 :	LUT_out[7]  = -18'sd 132;
		19 'sd 131072 :	LUT_out[7]  = -18'sd 88;
		19 'sd 65536  :	LUT_out[7]  = -18'sd 44;
		-19'sd 65536  :	LUT_out[7]  = 18'sd 44;
		-19'sd 131072 :	LUT_out[7]  = 18'sd 88;
		-19'sd 196608 :	LUT_out[7]  = 18'sd 132;
		default     :	LUT_out[7]  = 18'sd 0;
	endcase
end

// LUT_8 

always @ *
begin
	case(sum_level_1[8])
		19 'sd 0      :	LUT_out[8]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[8]  = -18'sd 66;
		19 'sd 32768  :	LUT_out[8]  = -18'sd 22;
		-19'sd 32768  :	LUT_out[8]  = 18'sd 22;
		-19'sd 98304  :	LUT_out[8]  = 18'sd 66;
		19 'sd 196608 :	LUT_out[8]  = -18'sd 132;
		19 'sd 131072 :	LUT_out[8]  = -18'sd 88;
		19 'sd 65536  :	LUT_out[8]  = -18'sd 44;
		-19'sd 65536  :	LUT_out[8]  = 18'sd 44;
		-19'sd 131072 :	LUT_out[8]  = 18'sd 88;
		-19'sd 196608 :	LUT_out[8]  = 18'sd 132;
		default     :	LUT_out[8]  = 18'sd 0;
	endcase
end

// LUT_9 

always @ *
begin
	case(sum_level_1[9])
		19 'sd 0      :	LUT_out[9]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[9]  = -18'sd 18;
		19 'sd 32768  :	LUT_out[9]  = -18'sd 6;
		-19'sd 32768  :	LUT_out[9]  = 18'sd 6;
		-19'sd 98304  :	LUT_out[9]  = 18'sd 18;
		19 'sd 196608 :	LUT_out[9]  = -18'sd 36;
		19 'sd 131072 :	LUT_out[9]  = -18'sd 24;
		19 'sd 65536  :	LUT_out[9]  = -18'sd 12;
		-19'sd 65536  :	LUT_out[9]  = 18'sd 12;
		-19'sd 131072 :	LUT_out[9]  = 18'sd 24;
		-19'sd 196608 :	LUT_out[9]  = 18'sd 36;
		default     :	LUT_out[9]  = 18'sd 0;
	endcase
end

// LUT_10 

always @ *
begin
	case(sum_level_1[10])
		19 'sd 0      :	LUT_out[10] = 18'sd 0;
		19 'sd 98304  :	LUT_out[10] = 18'sd 53;
		19 'sd 32768  :	LUT_out[10] = 18'sd 18;
		-19'sd 32768  :	LUT_out[10] = -18'sd 18;
		-19'sd 98304  :	LUT_out[10] = -18'sd 53;
		19 'sd 196608 :	LUT_out[10] = 18'sd 107;
		19 'sd 131072 :	LUT_out[10] = 18'sd 71;
		19 'sd 65536  :	LUT_out[10] = 18'sd 36;
		-19'sd 65536  :	LUT_out[10] = -18'sd 36;
		-19'sd 131072 :	LUT_out[10] = -18'sd 71;
		-19'sd 196608 :	LUT_out[10] = -18'sd 107;
		default     :	LUT_out[10] = 18'sd 0;
	endcase
end

// LUT_11 

always @ *
begin
	case(sum_level_1[11])
		19 'sd 0      :	LUT_out[11] = 18'sd 0;
		19 'sd 98304  :	LUT_out[11] = 18'sd 102;
		19 'sd 32768  :	LUT_out[11] = 18'sd 34;
		-19'sd 32768  :	LUT_out[11] = -18'sd 34;
		-19'sd 98304  :	LUT_out[11] = -18'sd 102;
		19 'sd 196608 :	LUT_out[11] = 18'sd 204;
		19 'sd 131072 :	LUT_out[11] = 18'sd 136;
		19 'sd 65536  :	LUT_out[11] = 18'sd 68;
		-19'sd 65536  :	LUT_out[11] = -18'sd 68;
		-19'sd 131072 :	LUT_out[11] = -18'sd 136;
		-19'sd 196608 :	LUT_out[11] = -18'sd 204;
		default     :	LUT_out[11] = 18'sd 0;
	endcase
end

// LUT_12 

always @ *
begin
	case(sum_level_1[12])
		19 'sd 0      :	LUT_out[12] = 18'sd 0;
		19 'sd 98304  :	LUT_out[12] = 18'sd 88;
		19 'sd 32768  :	LUT_out[12] = 18'sd 29;
		-19'sd 32768  :	LUT_out[12] = -18'sd 29;
		-19'sd 98304  :	LUT_out[12] = -18'sd 88;
		19 'sd 196608 :	LUT_out[12] = 18'sd 175;
		19 'sd 131072 :	LUT_out[12] = 18'sd 117;
		19 'sd 65536  :	LUT_out[12] = 18'sd 58;
		-19'sd 65536  :	LUT_out[12] = -18'sd 58;
		-19'sd 131072 :	LUT_out[12] = -18'sd 117;
		-19'sd 196608 :	LUT_out[12] = -18'sd 175;
		default     :	LUT_out[12] = 18'sd 0;
	endcase
end

// LUT_13 

always @ *
begin
	case(sum_level_1[13])
		19 'sd 0      :	LUT_out[13] = 18'sd 0;
		19 'sd 98304  :	LUT_out[13] = 18'sd 8;
		19 'sd 32768  :	LUT_out[13] = 18'sd 3;
		-19'sd 32768  :	LUT_out[13] = -18'sd 3;
		-19'sd 98304  :	LUT_out[13] = -18'sd 8;
		19 'sd 196608 :	LUT_out[13] = 18'sd 16;
		19 'sd 131072 :	LUT_out[13] = 18'sd 11;
		19 'sd 65536  :	LUT_out[13] = 18'sd 5;
		-19'sd 65536  :	LUT_out[13] = -18'sd 5;
		-19'sd 131072 :	LUT_out[13] = -18'sd 11;
		-19'sd 196608 :	LUT_out[13] = -18'sd 16;
		default     :	LUT_out[13] = 18'sd 0;
	endcase
end

// LUT_14 

always @ *
begin
	case(sum_level_1[14])
		19 'sd 0      :	LUT_out[14] = 18'sd 0;
		19 'sd 98304  :	LUT_out[14] = -18'sd 93;
		19 'sd 32768  :	LUT_out[14] = -18'sd 31;
		-19'sd 32768  :	LUT_out[14] = 18'sd 31;
		-19'sd 98304  :	LUT_out[14] = 18'sd 93;
		19 'sd 196608 :	LUT_out[14] = -18'sd 186;
		19 'sd 131072 :	LUT_out[14] = -18'sd 124;
		19 'sd 65536  :	LUT_out[14] = -18'sd 62;
		-19'sd 65536  :	LUT_out[14] = 18'sd 62;
		-19'sd 131072 :	LUT_out[14] = 18'sd 124;
		-19'sd 196608 :	LUT_out[14] = 18'sd 186;
		default     :	LUT_out[14] = 18'sd 0;
	endcase
end

// LUT_15 

always @ *
begin
	case(sum_level_1[15])
		19 'sd 0      :	LUT_out[15] = 18'sd 0;
		19 'sd 98304  :	LUT_out[15] = -18'sd 149;
		19 'sd 32768  :	LUT_out[15] = -18'sd 50;
		-19'sd 32768  :	LUT_out[15] = 18'sd 50;
		-19'sd 98304  :	LUT_out[15] = 18'sd 149;
		19 'sd 196608 :	LUT_out[15] = -18'sd 298;
		19 'sd 131072 :	LUT_out[15] = -18'sd 199;
		19 'sd 65536  :	LUT_out[15] = -18'sd 99;
		-19'sd 65536  :	LUT_out[15] = 18'sd 99;
		-19'sd 131072 :	LUT_out[15] = 18'sd 199;
		-19'sd 196608 :	LUT_out[15] = 18'sd 298;
		default     :	LUT_out[15] = 18'sd 0;
	endcase
end

// LUT_16 

always @ *
begin
	case(sum_level_1[16])
		19 'sd 0      :	LUT_out[16] = 18'sd 0;
		19 'sd 98304  :	LUT_out[16] = -18'sd 111;
		19 'sd 32768  :	LUT_out[16] = -18'sd 37;
		-19'sd 32768  :	LUT_out[16] = 18'sd 37;
		-19'sd 98304  :	LUT_out[16] = 18'sd 111;
		19 'sd 196608 :	LUT_out[16] = -18'sd 223;
		19 'sd 131072 :	LUT_out[16] = -18'sd 149;
		19 'sd 65536  :	LUT_out[16] = -18'sd 74;
		-19'sd 65536  :	LUT_out[16] = 18'sd 74;
		-19'sd 131072 :	LUT_out[16] = 18'sd 149;
		-19'sd 196608 :	LUT_out[16] = 18'sd 223;
		default     :	LUT_out[16] = 18'sd 0;
	endcase
end

// LUT_17 

always @ *
begin
	case(sum_level_1[17])
		19 'sd 0      :	LUT_out[17] = 18'sd 0;
		19 'sd 98304  :	LUT_out[17] = 18'sd 11;
		19 'sd 32768  :	LUT_out[17] = 18'sd 4;
		-19'sd 32768  :	LUT_out[17] = -18'sd 4;
		-19'sd 98304  :	LUT_out[17] = -18'sd 11;
		19 'sd 196608 :	LUT_out[17] = 18'sd 22;
		19 'sd 131072 :	LUT_out[17] = 18'sd 15;
		19 'sd 65536  :	LUT_out[17] = 18'sd 7;
		-19'sd 65536  :	LUT_out[17] = -18'sd 7;
		-19'sd 131072 :	LUT_out[17] = -18'sd 15;
		-19'sd 196608 :	LUT_out[17] = -18'sd 22;
		default     :	LUT_out[17] = 18'sd 0;
	endcase
end

// LUT_18 

always @ *
begin
	case(sum_level_1[18])
		19 'sd 0      :	LUT_out[18] = 18'sd 0;
		19 'sd 98304  :	LUT_out[18] = 18'sd 149;
		19 'sd 32768  :	LUT_out[18] = 18'sd 50;
		-19'sd 32768  :	LUT_out[18] = -18'sd 50;
		-19'sd 98304  :	LUT_out[18] = -18'sd 149;
		19 'sd 196608 :	LUT_out[18] = 18'sd 298;
		19 'sd 131072 :	LUT_out[18] = 18'sd 199;
		19 'sd 65536  :	LUT_out[18] = 18'sd 99;
		-19'sd 65536  :	LUT_out[18] = -18'sd 99;
		-19'sd 131072 :	LUT_out[18] = -18'sd 199;
		-19'sd 196608 :	LUT_out[18] = -18'sd 298;
		default     :	LUT_out[18] = 18'sd 0;
	endcase
end

// LUT_19 

always @ *
begin
	case(sum_level_1[19])
		19 'sd 0      :	LUT_out[19] = 18'sd 0;
		19 'sd 98304  :	LUT_out[19] = 18'sd 210;
		19 'sd 32768  :	LUT_out[19] = 18'sd 70;
		-19'sd 32768  :	LUT_out[19] = -18'sd 70;
		-19'sd 98304  :	LUT_out[19] = -18'sd 210;
		19 'sd 196608 :	LUT_out[19] = 18'sd 419;
		19 'sd 131072 :	LUT_out[19] = 18'sd 279;
		19 'sd 65536  :	LUT_out[19] = 18'sd 140;
		-19'sd 65536  :	LUT_out[19] = -18'sd 140;
		-19'sd 131072 :	LUT_out[19] = -18'sd 279;
		-19'sd 196608 :	LUT_out[19] = -18'sd 419;
		default     :	LUT_out[19] = 18'sd 0;
	endcase
end

// LUT_20 

always @ *
begin
	case(sum_level_1[20])
		19 'sd 0      :	LUT_out[20] = 18'sd 0;
		19 'sd 98304  :	LUT_out[20] = 18'sd 137;
		19 'sd 32768  :	LUT_out[20] = 18'sd 46;
		-19'sd 32768  :	LUT_out[20] = -18'sd 46;
		-19'sd 98304  :	LUT_out[20] = -18'sd 137;
		19 'sd 196608 :	LUT_out[20] = 18'sd 274;
		19 'sd 131072 :	LUT_out[20] = 18'sd 183;
		19 'sd 65536  :	LUT_out[20] = 18'sd 91;
		-19'sd 65536  :	LUT_out[20] = -18'sd 91;
		-19'sd 131072 :	LUT_out[20] = -18'sd 183;
		-19'sd 196608 :	LUT_out[20] = -18'sd 274;
		default     :	LUT_out[20] = 18'sd 0;
	endcase
end

// LUT_21 

always @ *
begin
	case(sum_level_1[21])
		19 'sd 0      :	LUT_out[21] = 18'sd 0;
		19 'sd 98304  :	LUT_out[21] = -18'sd 43;
		19 'sd 32768  :	LUT_out[21] = -18'sd 14;
		-19'sd 32768  :	LUT_out[21] = 18'sd 14;
		-19'sd 98304  :	LUT_out[21] = 18'sd 43;
		19 'sd 196608 :	LUT_out[21] = -18'sd 85;
		19 'sd 131072 :	LUT_out[21] = -18'sd 57;
		19 'sd 65536  :	LUT_out[21] = -18'sd 28;
		-19'sd 65536  :	LUT_out[21] = 18'sd 28;
		-19'sd 131072 :	LUT_out[21] = 18'sd 57;
		-19'sd 196608 :	LUT_out[21] = 18'sd 85;
		default     :	LUT_out[21] = 18'sd 0;
	endcase
end

// LUT_22 

always @ *
begin
	case(sum_level_1[22])
		19 'sd 0      :	LUT_out[22] = 18'sd 0;
		19 'sd 98304  :	LUT_out[22] = -18'sd 225;
		19 'sd 32768  :	LUT_out[22] = -18'sd 75;
		-19'sd 32768  :	LUT_out[22] = 18'sd 75;
		-19'sd 98304  :	LUT_out[22] = 18'sd 225;
		19 'sd 196608 :	LUT_out[22] = -18'sd 450;
		19 'sd 131072 :	LUT_out[22] = -18'sd 300;
		19 'sd 65536  :	LUT_out[22] = -18'sd 150;
		-19'sd 65536  :	LUT_out[22] = 18'sd 150;
		-19'sd 131072 :	LUT_out[22] = 18'sd 300;
		-19'sd 196608 :	LUT_out[22] = 18'sd 450;
		default     :	LUT_out[22] = 18'sd 0;
	endcase
end

// LUT_23 

always @ *
begin
	case(sum_level_1[23])
		19 'sd 0      :	LUT_out[23] = 18'sd 0;
		19 'sd 98304  :	LUT_out[23] = -18'sd 286;
		19 'sd 32768  :	LUT_out[23] = -18'sd 95;
		-19'sd 32768  :	LUT_out[23] = 18'sd 95;
		-19'sd 98304  :	LUT_out[23] = 18'sd 286;
		19 'sd 196608 :	LUT_out[23] = -18'sd 572;
		19 'sd 131072 :	LUT_out[23] = -18'sd 382;
		19 'sd 65536  :	LUT_out[23] = -18'sd 191;
		-19'sd 65536  :	LUT_out[23] = 18'sd 191;
		-19'sd 131072 :	LUT_out[23] = 18'sd 382;
		-19'sd 196608 :	LUT_out[23] = 18'sd 572;
		default     :	LUT_out[23] = 18'sd 0;
	endcase
end

// LUT_24 

always @ *
begin
	case(sum_level_1[24])
		19 'sd 0      :	LUT_out[24] = 18'sd 0;
		19 'sd 98304  :	LUT_out[24] = -18'sd 163;
		19 'sd 32768  :	LUT_out[24] = -18'sd 54;
		-19'sd 32768  :	LUT_out[24] = 18'sd 54;
		-19'sd 98304  :	LUT_out[24] = 18'sd 163;
		19 'sd 196608 :	LUT_out[24] = -18'sd 326;
		19 'sd 131072 :	LUT_out[24] = -18'sd 218;
		19 'sd 65536  :	LUT_out[24] = -18'sd 109;
		-19'sd 65536  :	LUT_out[24] = 18'sd 109;
		-19'sd 131072 :	LUT_out[24] = 18'sd 218;
		-19'sd 196608 :	LUT_out[24] = 18'sd 326;
		default     :	LUT_out[24] = 18'sd 0;
	endcase
end

// LUT_25 

always @ *
begin
	case(sum_level_1[25])
		19 'sd 0      :	LUT_out[25] = 18'sd 0;
		19 'sd 98304  :	LUT_out[25] = 18'sd 92;
		19 'sd 32768  :	LUT_out[25] = 18'sd 31;
		-19'sd 32768  :	LUT_out[25] = -18'sd 31;
		-19'sd 98304  :	LUT_out[25] = -18'sd 92;
		19 'sd 196608 :	LUT_out[25] = 18'sd 184;
		19 'sd 131072 :	LUT_out[25] = 18'sd 122;
		19 'sd 65536  :	LUT_out[25] = 18'sd 61;
		-19'sd 65536  :	LUT_out[25] = -18'sd 61;
		-19'sd 131072 :	LUT_out[25] = -18'sd 122;
		-19'sd 196608 :	LUT_out[25] = -18'sd 184;
		default     :	LUT_out[25] = 18'sd 0;
	endcase
end

// LUT_26 

always @ *
begin
	case(sum_level_1[26])
		19 'sd 0      :	LUT_out[26] = 18'sd 0;
		19 'sd 98304  :	LUT_out[26] = 18'sd 328;
		19 'sd 32768  :	LUT_out[26] = 18'sd 109;
		-19'sd 32768  :	LUT_out[26] = -18'sd 109;
		-19'sd 98304  :	LUT_out[26] = -18'sd 328;
		19 'sd 196608 :	LUT_out[26] = 18'sd 657;
		19 'sd 131072 :	LUT_out[26] = 18'sd 438;
		19 'sd 65536  :	LUT_out[26] = 18'sd 219;
		-19'sd 65536  :	LUT_out[26] = -18'sd 219;
		-19'sd 131072 :	LUT_out[26] = -18'sd 438;
		-19'sd 196608 :	LUT_out[26] = -18'sd 657;
		default     :	LUT_out[26] = 18'sd 0;
	endcase
end

// LUT_27 

always @ *
begin
	case(sum_level_1[27])
		19 'sd 0      :	LUT_out[27] = 18'sd 0;
		19 'sd 98304  :	LUT_out[27] = 18'sd 384;
		19 'sd 32768  :	LUT_out[27] = 18'sd 128;
		-19'sd 32768  :	LUT_out[27] = -18'sd 128;
		-19'sd 98304  :	LUT_out[27] = -18'sd 384;
		19 'sd 196608 :	LUT_out[27] = 18'sd 767;
		19 'sd 131072 :	LUT_out[27] = 18'sd 511;
		19 'sd 65536  :	LUT_out[27] = 18'sd 256;
		-19'sd 65536  :	LUT_out[27] = -18'sd 256;
		-19'sd 131072 :	LUT_out[27] = -18'sd 511;
		-19'sd 196608 :	LUT_out[27] = -18'sd 767;
		default     :	LUT_out[27] = 18'sd 0;
	endcase
end

// LUT_28 

always @ *
begin
	case(sum_level_1[28])
		19 'sd 0      :	LUT_out[28] = 18'sd 0;
		19 'sd 98304  :	LUT_out[28] = 18'sd 189;
		19 'sd 32768  :	LUT_out[28] = 18'sd 63;
		-19'sd 32768  :	LUT_out[28] = -18'sd 63;
		-19'sd 98304  :	LUT_out[28] = -18'sd 189;
		19 'sd 196608 :	LUT_out[28] = 18'sd 379;
		19 'sd 131072 :	LUT_out[28] = 18'sd 252;
		19 'sd 65536  :	LUT_out[28] = 18'sd 126;
		-19'sd 65536  :	LUT_out[28] = -18'sd 126;
		-19'sd 131072 :	LUT_out[28] = -18'sd 252;
		-19'sd 196608 :	LUT_out[28] = -18'sd 379;
		default     :	LUT_out[28] = 18'sd 0;
	endcase
end

// LUT_29 

always @ *
begin
	case(sum_level_1[29])
		19 'sd 0      :	LUT_out[29] = 18'sd 0;
		19 'sd 98304  :	LUT_out[29] = -18'sd 166;
		19 'sd 32768  :	LUT_out[29] = -18'sd 55;
		-19'sd 32768  :	LUT_out[29] = 18'sd 55;
		-19'sd 98304  :	LUT_out[29] = 18'sd 166;
		19 'sd 196608 :	LUT_out[29] = -18'sd 331;
		19 'sd 131072 :	LUT_out[29] = -18'sd 221;
		19 'sd 65536  :	LUT_out[29] = -18'sd 110;
		-19'sd 65536  :	LUT_out[29] = 18'sd 110;
		-19'sd 131072 :	LUT_out[29] = 18'sd 221;
		-19'sd 196608 :	LUT_out[29] = 18'sd 331;
		default     :	LUT_out[29] = 18'sd 0;
	endcase
end

// LUT_30 

always @ *
begin
	case(sum_level_1[30])
		19 'sd 0      :	LUT_out[30] = 18'sd 0;
		19 'sd 98304  :	LUT_out[30] = -18'sd 469;
		19 'sd 32768  :	LUT_out[30] = -18'sd 156;
		-19'sd 32768  :	LUT_out[30] = 18'sd 156;
		-19'sd 98304  :	LUT_out[30] = 18'sd 469;
		19 'sd 196608 :	LUT_out[30] = -18'sd 939;
		19 'sd 131072 :	LUT_out[30] = -18'sd 626;
		19 'sd 65536  :	LUT_out[30] = -18'sd 313;
		-19'sd 65536  :	LUT_out[30] = 18'sd 313;
		-19'sd 131072 :	LUT_out[30] = 18'sd 626;
		-19'sd 196608 :	LUT_out[30] = 18'sd 939;
		default     :	LUT_out[30] = 18'sd 0;
	endcase
end

// LUT_31 

always @ *
begin
	case(sum_level_1[31])
		19 'sd 0      :	LUT_out[31] = 18'sd 0;
		19 'sd 98304  :	LUT_out[31] = -18'sd 510;
		19 'sd 32768  :	LUT_out[31] = -18'sd 170;
		-19'sd 32768  :	LUT_out[31] = 18'sd 170;
		-19'sd 98304  :	LUT_out[31] = 18'sd 510;
		19 'sd 196608 :	LUT_out[31] = -18'sd 1019;
		19 'sd 131072 :	LUT_out[31] = -18'sd 679;
		19 'sd 65536  :	LUT_out[31] = -18'sd 340;
		-19'sd 65536  :	LUT_out[31] = 18'sd 340;
		-19'sd 131072 :	LUT_out[31] = 18'sd 679;
		-19'sd 196608 :	LUT_out[31] = 18'sd 1019;
		default     :	LUT_out[31] = 18'sd 0;
	endcase
end

// LUT_32 

always @ *
begin
	case(sum_level_1[32])
		19 'sd 0      :	LUT_out[32] = 18'sd 0;
		19 'sd 98304  :	LUT_out[32] = -18'sd 214;
		19 'sd 32768  :	LUT_out[32] = -18'sd 71;
		-19'sd 32768  :	LUT_out[32] = 18'sd 71;
		-19'sd 98304  :	LUT_out[32] = 18'sd 214;
		19 'sd 196608 :	LUT_out[32] = -18'sd 428;
		19 'sd 131072 :	LUT_out[32] = -18'sd 285;
		19 'sd 65536  :	LUT_out[32] = -18'sd 143;
		-19'sd 65536  :	LUT_out[32] = 18'sd 143;
		-19'sd 131072 :	LUT_out[32] = 18'sd 285;
		-19'sd 196608 :	LUT_out[32] = 18'sd 428;
		default     :	LUT_out[32] = 18'sd 0;
	endcase
end

// LUT_33 

always @ *
begin
	case(sum_level_1[33])
		19 'sd 0      :	LUT_out[33] = 18'sd 0;
		19 'sd 98304  :	LUT_out[33] = 18'sd 277;
		19 'sd 32768  :	LUT_out[33] = 18'sd 92;
		-19'sd 32768  :	LUT_out[33] = -18'sd 92;
		-19'sd 98304  :	LUT_out[33] = -18'sd 277;
		19 'sd 196608 :	LUT_out[33] = 18'sd 554;
		19 'sd 131072 :	LUT_out[33] = 18'sd 369;
		19 'sd 65536  :	LUT_out[33] = 18'sd 185;
		-19'sd 65536  :	LUT_out[33] = -18'sd 185;
		-19'sd 131072 :	LUT_out[33] = -18'sd 369;
		-19'sd 196608 :	LUT_out[33] = -18'sd 554;
		default     :	LUT_out[33] = 18'sd 0;
	endcase
end

// LUT_34 

always @ *
begin
	case(sum_level_1[34])
		19 'sd 0      :	LUT_out[34] = 18'sd 0;
		19 'sd 98304  :	LUT_out[34] = 18'sd 668;
		19 'sd 32768  :	LUT_out[34] = 18'sd 223;
		-19'sd 32768  :	LUT_out[34] = -18'sd 223;
		-19'sd 98304  :	LUT_out[34] = -18'sd 668;
		19 'sd 196608 :	LUT_out[34] = 18'sd 1336;
		19 'sd 131072 :	LUT_out[34] = 18'sd 891;
		19 'sd 65536  :	LUT_out[34] = 18'sd 445;
		-19'sd 65536  :	LUT_out[34] = -18'sd 445;
		-19'sd 131072 :	LUT_out[34] = -18'sd 891;
		-19'sd 196608 :	LUT_out[34] = -18'sd 1336;
		default     :	LUT_out[34] = 18'sd 0;
	endcase
end

// LUT_35 

always @ *
begin
	case(sum_level_1[35])
		19 'sd 0      :	LUT_out[35] = 18'sd 0;
		19 'sd 98304  :	LUT_out[35] = 18'sd 680;
		19 'sd 32768  :	LUT_out[35] = 18'sd 227;
		-19'sd 32768  :	LUT_out[35] = -18'sd 227;
		-19'sd 98304  :	LUT_out[35] = -18'sd 680;
		19 'sd 196608 :	LUT_out[35] = 18'sd 1360;
		19 'sd 131072 :	LUT_out[35] = 18'sd 906;
		19 'sd 65536  :	LUT_out[35] = 18'sd 453;
		-19'sd 65536  :	LUT_out[35] = -18'sd 453;
		-19'sd 131072 :	LUT_out[35] = -18'sd 906;
		-19'sd 196608 :	LUT_out[35] = -18'sd 1360;
		default     :	LUT_out[35] = 18'sd 0;
	endcase
end

// LUT_36 

always @ *
begin
	case(sum_level_1[36])
		19 'sd 0      :	LUT_out[36] = 18'sd 0;
		19 'sd 98304  :	LUT_out[36] = 18'sd 236;
		19 'sd 32768  :	LUT_out[36] = 18'sd 79;
		-19'sd 32768  :	LUT_out[36] = -18'sd 79;
		-19'sd 98304  :	LUT_out[36] = -18'sd 236;
		19 'sd 196608 :	LUT_out[36] = 18'sd 472;
		19 'sd 131072 :	LUT_out[36] = 18'sd 315;
		19 'sd 65536  :	LUT_out[36] = 18'sd 157;
		-19'sd 65536  :	LUT_out[36] = -18'sd 157;
		-19'sd 131072 :	LUT_out[36] = -18'sd 315;
		-19'sd 196608 :	LUT_out[36] = -18'sd 472;
		default     :	LUT_out[36] = 18'sd 0;
	endcase
end

// LUT_37 

always @ *
begin
	case(sum_level_1[37])
		19 'sd 0      :	LUT_out[37] = 18'sd 0;
		19 'sd 98304  :	LUT_out[37] = -18'sd 451;
		19 'sd 32768  :	LUT_out[37] = -18'sd 150;
		-19'sd 32768  :	LUT_out[37] = 18'sd 150;
		-19'sd 98304  :	LUT_out[37] = 18'sd 451;
		19 'sd 196608 :	LUT_out[37] = -18'sd 901;
		19 'sd 131072 :	LUT_out[37] = -18'sd 601;
		19 'sd 65536  :	LUT_out[37] = -18'sd 300;
		-19'sd 65536  :	LUT_out[37] = 18'sd 300;
		-19'sd 131072 :	LUT_out[37] = 18'sd 601;
		-19'sd 196608 :	LUT_out[37] = 18'sd 901;
		default     :	LUT_out[37] = 18'sd 0;
	endcase
end

// LUT_38 

always @ *
begin
	case(sum_level_1[38])
		19 'sd 0      :	LUT_out[38] = 18'sd 0;
		19 'sd 98304  :	LUT_out[38] = -18'sd 966;
		19 'sd 32768  :	LUT_out[38] = -18'sd 322;
		-19'sd 32768  :	LUT_out[38] = 18'sd 322;
		-19'sd 98304  :	LUT_out[38] = 18'sd 966;
		19 'sd 196608 :	LUT_out[38] = -18'sd 1932;
		19 'sd 131072 :	LUT_out[38] = -18'sd 1288;
		19 'sd 65536  :	LUT_out[38] = -18'sd 644;
		-19'sd 65536  :	LUT_out[38] = 18'sd 644;
		-19'sd 131072 :	LUT_out[38] = 18'sd 1288;
		-19'sd 196608 :	LUT_out[38] = 18'sd 1932;
		default     :	LUT_out[38] = 18'sd 0;
	endcase
end

// LUT_39 

always @ *
begin
	case(sum_level_1[39])
		19 'sd 0      :	LUT_out[39] = 18'sd 0;
		19 'sd 98304  :	LUT_out[39] = -18'sd 931;
		19 'sd 32768  :	LUT_out[39] = -18'sd 310;
		-19'sd 32768  :	LUT_out[39] = 18'sd 310;
		-19'sd 98304  :	LUT_out[39] = 18'sd 931;
		19 'sd 196608 :	LUT_out[39] = -18'sd 1862;
		19 'sd 131072 :	LUT_out[39] = -18'sd 1241;
		19 'sd 65536  :	LUT_out[39] = -18'sd 621;
		-19'sd 65536  :	LUT_out[39] = 18'sd 621;
		-19'sd 131072 :	LUT_out[39] = 18'sd 1241;
		-19'sd 196608 :	LUT_out[39] = 18'sd 1862;
		default     :	LUT_out[39] = 18'sd 0;
	endcase
end

// LUT_40 

always @ *
begin
	case(sum_level_1[40])
		19 'sd 0      :	LUT_out[40] = 18'sd 0;
		19 'sd 98304  :	LUT_out[40] = -18'sd 254;
		19 'sd 32768  :	LUT_out[40] = -18'sd 85;
		-19'sd 32768  :	LUT_out[40] = 18'sd 85;
		-19'sd 98304  :	LUT_out[40] = 18'sd 254;
		19 'sd 196608 :	LUT_out[40] = -18'sd 509;
		19 'sd 131072 :	LUT_out[40] = -18'sd 339;
		19 'sd 65536  :	LUT_out[40] = -18'sd 170;
		-19'sd 65536  :	LUT_out[40] = 18'sd 170;
		-19'sd 131072 :	LUT_out[40] = 18'sd 339;
		-19'sd 196608 :	LUT_out[40] = 18'sd 509;
		default     :	LUT_out[40] = 18'sd 0;
	endcase
end

// LUT_41 

always @ *
begin
	case(sum_level_1[41])
		19 'sd 0      :	LUT_out[41] = 18'sd 0;
		19 'sd 98304  :	LUT_out[41] = 18'sd 748;
		19 'sd 32768  :	LUT_out[41] = 18'sd 249;
		-19'sd 32768  :	LUT_out[41] = -18'sd 249;
		-19'sd 98304  :	LUT_out[41] = -18'sd 748;
		19 'sd 196608 :	LUT_out[41] = 18'sd 1495;
		19 'sd 131072 :	LUT_out[41] = 18'sd 997;
		19 'sd 65536  :	LUT_out[41] = 18'sd 498;
		-19'sd 65536  :	LUT_out[41] = -18'sd 498;
		-19'sd 131072 :	LUT_out[41] = -18'sd 997;
		-19'sd 196608 :	LUT_out[41] = -18'sd 1495;
		default     :	LUT_out[41] = 18'sd 0;
	endcase
end

// LUT_42 

always @ *
begin
	case(sum_level_1[42])
		19 'sd 0      :	LUT_out[42] = 18'sd 0;
		19 'sd 98304  :	LUT_out[42] = 18'sd 1475;
		19 'sd 32768  :	LUT_out[42] = 18'sd 492;
		-19'sd 32768  :	LUT_out[42] = -18'sd 492;
		-19'sd 98304  :	LUT_out[42] = -18'sd 1475;
		19 'sd 196608 :	LUT_out[42] = 18'sd 2949;
		19 'sd 131072 :	LUT_out[42] = 18'sd 1966;
		19 'sd 65536  :	LUT_out[42] = 18'sd 983;
		-19'sd 65536  :	LUT_out[42] = -18'sd 983;
		-19'sd 131072 :	LUT_out[42] = -18'sd 1966;
		-19'sd 196608 :	LUT_out[42] = -18'sd 2949;
		default     :	LUT_out[42] = 18'sd 0;
	endcase
end

// LUT_43 

always @ *
begin
	case(sum_level_1[43])
		19 'sd 0      :	LUT_out[43] = 18'sd 0;
		19 'sd 98304  :	LUT_out[43] = 18'sd 1366;
		19 'sd 32768  :	LUT_out[43] = 18'sd 455;
		-19'sd 32768  :	LUT_out[43] = -18'sd 455;
		-19'sd 98304  :	LUT_out[43] = -18'sd 1366;
		19 'sd 196608 :	LUT_out[43] = 18'sd 2732;
		19 'sd 131072 :	LUT_out[43] = 18'sd 1821;
		19 'sd 65536  :	LUT_out[43] = 18'sd 911;
		-19'sd 65536  :	LUT_out[43] = -18'sd 911;
		-19'sd 131072 :	LUT_out[43] = -18'sd 1821;
		-19'sd 196608 :	LUT_out[43] = -18'sd 2732;
		default     :	LUT_out[43] = 18'sd 0;
	endcase
end

// LUT_44 

always @ *
begin
	case(sum_level_1[44])
		19 'sd 0      :	LUT_out[44] = 18'sd 0;
		19 'sd 98304  :	LUT_out[44] = 18'sd 268;
		19 'sd 32768  :	LUT_out[44] = 18'sd 89;
		-19'sd 32768  :	LUT_out[44] = -18'sd 89;
		-19'sd 98304  :	LUT_out[44] = -18'sd 268;
		19 'sd 196608 :	LUT_out[44] = 18'sd 537;
		19 'sd 131072 :	LUT_out[44] = 18'sd 358;
		19 'sd 65536  :	LUT_out[44] = 18'sd 179;
		-19'sd 65536  :	LUT_out[44] = -18'sd 179;
		-19'sd 131072 :	LUT_out[44] = -18'sd 358;
		-19'sd 196608 :	LUT_out[44] = -18'sd 537;
		default     :	LUT_out[44] = 18'sd 0;
	endcase
end

// LUT_45 

always @ *
begin
	case(sum_level_1[45])
		19 'sd 0      :	LUT_out[45] = 18'sd 0;
		19 'sd 98304  :	LUT_out[45] = -18'sd 1367;
		19 'sd 32768  :	LUT_out[45] = -18'sd 456;
		-19'sd 32768  :	LUT_out[45] = 18'sd 456;
		-19'sd 98304  :	LUT_out[45] = 18'sd 1367;
		19 'sd 196608 :	LUT_out[45] = -18'sd 2734;
		19 'sd 131072 :	LUT_out[45] = -18'sd 1822;
		19 'sd 65536  :	LUT_out[45] = -18'sd 911;
		-19'sd 65536  :	LUT_out[45] = 18'sd 911;
		-19'sd 131072 :	LUT_out[45] = 18'sd 1822;
		-19'sd 196608 :	LUT_out[45] = 18'sd 2734;
		default     :	LUT_out[45] = 18'sd 0;
	endcase
end

// LUT_46 

always @ *
begin
	case(sum_level_1[46])
		19 'sd 0      :	LUT_out[46] = 18'sd 0;
		19 'sd 98304  :	LUT_out[46] = -18'sd 2601;
		19 'sd 32768  :	LUT_out[46] = -18'sd 867;
		-19'sd 32768  :	LUT_out[46] = 18'sd 867;
		-19'sd 98304  :	LUT_out[46] = 18'sd 2601;
		19 'sd 196608 :	LUT_out[46] = -18'sd 5202;
		19 'sd 131072 :	LUT_out[46] = -18'sd 3468;
		19 'sd 65536  :	LUT_out[46] = -18'sd 1734;
		-19'sd 65536  :	LUT_out[46] = 18'sd 1734;
		-19'sd 131072 :	LUT_out[46] = 18'sd 3468;
		-19'sd 196608 :	LUT_out[46] = 18'sd 5202;
		default     :	LUT_out[46] = 18'sd 0;
	endcase
end

// LUT_47 

always @ *
begin
	case(sum_level_1[47])
		19 'sd 0      :	LUT_out[47] = 18'sd 0;
		19 'sd 98304  :	LUT_out[47] = -18'sd 2423;
		19 'sd 32768  :	LUT_out[47] = -18'sd 808;
		-19'sd 32768  :	LUT_out[47] = 18'sd 808;
		-19'sd 98304  :	LUT_out[47] = 18'sd 2423;
		19 'sd 196608 :	LUT_out[47] = -18'sd 4846;
		19 'sd 131072 :	LUT_out[47] = -18'sd 3231;
		19 'sd 65536  :	LUT_out[47] = -18'sd 1615;
		-19'sd 65536  :	LUT_out[47] = 18'sd 1615;
		-19'sd 131072 :	LUT_out[47] = 18'sd 3231;
		-19'sd 196608 :	LUT_out[47] = 18'sd 4846;
		default     :	LUT_out[47] = 18'sd 0;
	endcase
end

// LUT_48 

always @ *
begin
	case(sum_level_1[48])
		19 'sd 0      :	LUT_out[48] = 18'sd 0;
		19 'sd 98304  :	LUT_out[48] = -18'sd 277;
		19 'sd 32768  :	LUT_out[48] = -18'sd 92;
		-19'sd 32768  :	LUT_out[48] = 18'sd 92;
		-19'sd 98304  :	LUT_out[48] = 18'sd 277;
		19 'sd 196608 :	LUT_out[48] = -18'sd 554;
		19 'sd 131072 :	LUT_out[48] = -18'sd 369;
		19 'sd 65536  :	LUT_out[48] = -18'sd 185;
		-19'sd 65536  :	LUT_out[48] = 18'sd 185;
		-19'sd 131072 :	LUT_out[48] = 18'sd 369;
		-19'sd 196608 :	LUT_out[48] = 18'sd 554;
		default     :	LUT_out[48] = 18'sd 0;
	endcase
end

// LUT_49 

always @ *
begin
	case(sum_level_1[49])
		19 'sd 0      :	LUT_out[49] = 18'sd 0;
		19 'sd 98304  :	LUT_out[49] = 18'sd 3570;
		19 'sd 32768  :	LUT_out[49] = 18'sd 1190;
		-19'sd 32768  :	LUT_out[49] = -18'sd 1190;
		-19'sd 98304  :	LUT_out[49] = -18'sd 3570;
		19 'sd 196608 :	LUT_out[49] = 18'sd 7140;
		19 'sd 131072 :	LUT_out[49] = 18'sd 4760;
		19 'sd 65536  :	LUT_out[49] = 18'sd 2380;
		-19'sd 65536  :	LUT_out[49] = -18'sd 2380;
		-19'sd 131072 :	LUT_out[49] = -18'sd 4760;
		-19'sd 196608 :	LUT_out[49] = -18'sd 7140;
		default     :	LUT_out[49] = 18'sd 0;
	endcase
end

// LUT_50 

always @ *
begin
	case(sum_level_1[50])
		19 'sd 0      :	LUT_out[50] = 18'sd 0;
		19 'sd 98304  :	LUT_out[50] = 18'sd 8025;
		19 'sd 32768  :	LUT_out[50] = 18'sd 2675;
		-19'sd 32768  :	LUT_out[50] = -18'sd 2675;
		-19'sd 98304  :	LUT_out[50] = -18'sd 8025;
		19 'sd 196608 :	LUT_out[50] = 18'sd 16050;
		19 'sd 131072 :	LUT_out[50] = 18'sd 10700;
		19 'sd 65536  :	LUT_out[50] = 18'sd 5350;
		-19'sd 65536  :	LUT_out[50] = -18'sd 5350;
		-19'sd 131072 :	LUT_out[50] = -18'sd 10700;
		-19'sd 196608 :	LUT_out[50] = -18'sd 16050;
		default     :	LUT_out[50] = 18'sd 0;
	endcase
end

// LUT_51 

always @ *
begin
	case(sum_level_1[51])
		19 'sd 0      :	LUT_out[51] = 18'sd 0;
		19 'sd 98304  :	LUT_out[51] = 18'sd 11577;
		19 'sd 32768  :	LUT_out[51] = 18'sd 3859;
		-19'sd 32768  :	LUT_out[51] = -18'sd 3859;
		-19'sd 98304  :	LUT_out[51] = -18'sd 11577;
		19 'sd 196608 :	LUT_out[51] = 18'sd 23154;
		19 'sd 131072 :	LUT_out[51] = 18'sd 15436;
		19 'sd 65536  :	LUT_out[51] = 18'sd 7718;
		-19'sd 65536  :	LUT_out[51] = -18'sd 7718;
		-19'sd 131072 :	LUT_out[51] = -18'sd 15436;
		-19'sd 196608 :	LUT_out[51] = -18'sd 23154;
		default     :	LUT_out[51] = 18'sd 0;
	endcase
end

// LUT_52 

always @ *
begin
	case(sum_level_1[52])
		19 'sd 0      :	LUT_out[52] = 18'sd 0;
		19 'sd 98304  :	LUT_out[52] = 18'sd 12930;
		19 'sd 32768  :	LUT_out[52] = 18'sd 4310;
		-19'sd 32768  :	LUT_out[52] = -18'sd 4310;
		-19'sd 98304  :	LUT_out[52] = -18'sd 12930;
		default     :	LUT_out[52] = 18'sd 0;
	endcase
end


endmodule