module tx_pract_filter2 #(
    parameter COEFF_LEN = 113,
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

// sum levels
reg signed [17:0] s2[27:0];
reg signed [17:0] s3[13:0];
reg signed [17:0] s4[6:0];
reg signed [17:0] s5[3:0];
reg signed [17:0] s6[1:0];
reg signed [17:0] s7;
// reg signed [17:0] y_temp;
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



// sum_levels

// s2
always @ *
	if(reset)
		for(i=0; i<=27; i=i+1)
			s2[i] = 18'sd0;
	else
		for(i=0; i<=27; i=i+1)
			s2[i] = LUT_out[2*i] + LUT_out[2*i+1];

// s3
always @ *
	if(reset)
		for(i=0; i<=13; i=i+1)
			s3[i] = 18'sd0;
	else
		for(i=0; i<=13; i=i+1)
			s3[i] = s2[2*i] + s2[2*i+1];

// s4
always @ *
	if(reset)
		for(i=0; i<=6; i=i+1)
			s4[i] = 18'sd0;
	else
		for(i=0; i<=6; i=i+1)
			s4[i] = s3[2*i] + s3[2*i+1];

// s5
always @ *
	if(reset)
		for(i=0; i<=3; i=i+1)
			s5[i] = 18'sd0;
	else begin
		s5[3] = s4[6] + LUT_out[56];
		for(i=0; i<=2; i=i+1)
			s5[i] = s4[2*i] + s4[2*i+1];
	end

// s6
always @ *
	if(reset)
		for(i=0; i<=1; i=i+1)
			s6[i] = 18'sd0;
	else
		for(i=0; i<=1; i=i+1)
			s6[i] = s5[2*i] + s5[2*i+1];

// s7
always @ *
	if(reset)
		s7 = 18'sd0;
	else
		s7 = s6[0] + s6[1];




// always @ *
// if (reset)
//     for (i = 0; i <=HALF_COEFF_LEN-1; i=i+1)
//         sum_out[i] = 18'sd 0;
// else
//     begin
//         sum_out[0] = LUT_out[0] + LUT_out[1];
//         for(i = 0; i <= HALF_COEFF_LEN-2 ; i=i+1)
//             sum_out[i+1] <= sum_out[i] + LUT_out[i+2]; 
//     end
    

always @ (posedge clk or posedge reset)
    if(reset)
        y <= 0;
    else if (sam_clk_en)
        y <= s7;
	else
		y <= y;


 


// LUT_0 

always @ *
begin
	case(sum_level_1[0])
		19 'sd 0      :	LUT_out[0]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[0]  = 18'sd 57;
		19 'sd 32768  :	LUT_out[0]  = 18'sd 19;
		-19'sd 32768  :	LUT_out[0]  = -18'sd 19;
		-19'sd 98304  :	LUT_out[0]  = -18'sd 57;
		19 'sd 196608 :	LUT_out[0]  = 18'sd 115;
		19 'sd 131072 :	LUT_out[0]  = 18'sd 76;
		19 'sd 65536  :	LUT_out[0]  = 18'sd 38;
		-19'sd 65536  :	LUT_out[0]  = -18'sd 38;
		-19'sd 131072 :	LUT_out[0]  = -18'sd 76;
		-19'sd 196608 :	LUT_out[0]  = -18'sd 115;
		default     :	LUT_out[0]  = 18'sd 0;
	endcase
end

// LUT_1 

always @ *
begin
	case(sum_level_1[1])
		19 'sd 0      :	LUT_out[1]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[1]  = 18'sd 75;
		19 'sd 32768  :	LUT_out[1]  = 18'sd 25;
		-19'sd 32768  :	LUT_out[1]  = -18'sd 25;
		-19'sd 98304  :	LUT_out[1]  = -18'sd 75;
		19 'sd 196608 :	LUT_out[1]  = 18'sd 149;
		19 'sd 131072 :	LUT_out[1]  = 18'sd 99;
		19 'sd 65536  :	LUT_out[1]  = 18'sd 50;
		-19'sd 65536  :	LUT_out[1]  = -18'sd 50;
		-19'sd 131072 :	LUT_out[1]  = -18'sd 99;
		-19'sd 196608 :	LUT_out[1]  = -18'sd 149;
		default     :	LUT_out[1]  = 18'sd 0;
	endcase
end

// LUT_2 

always @ *
begin
	case(sum_level_1[2])
		19 'sd 0      :	LUT_out[2]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[2]  = 18'sd 35;
		19 'sd 32768  :	LUT_out[2]  = 18'sd 12;
		-19'sd 32768  :	LUT_out[2]  = -18'sd 12;
		-19'sd 98304  :	LUT_out[2]  = -18'sd 35;
		19 'sd 196608 :	LUT_out[2]  = 18'sd 70;
		19 'sd 131072 :	LUT_out[2]  = 18'sd 47;
		19 'sd 65536  :	LUT_out[2]  = 18'sd 23;
		-19'sd 65536  :	LUT_out[2]  = -18'sd 23;
		-19'sd 131072 :	LUT_out[2]  = -18'sd 47;
		-19'sd 196608 :	LUT_out[2]  = -18'sd 70;
		default     :	LUT_out[2]  = 18'sd 0;
	endcase
end

// LUT_3 

always @ *
begin
	case(sum_level_1[3])
		19 'sd 0      :	LUT_out[3]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[3]  = -18'sd 40;
		19 'sd 32768  :	LUT_out[3]  = -18'sd 13;
		-19'sd 32768  :	LUT_out[3]  = 18'sd 13;
		-19'sd 98304  :	LUT_out[3]  = 18'sd 40;
		19 'sd 196608 :	LUT_out[3]  = -18'sd 81;
		19 'sd 131072 :	LUT_out[3]  = -18'sd 54;
		19 'sd 65536  :	LUT_out[3]  = -18'sd 27;
		-19'sd 65536  :	LUT_out[3]  = 18'sd 27;
		-19'sd 131072 :	LUT_out[3]  = 18'sd 54;
		-19'sd 196608 :	LUT_out[3]  = 18'sd 81;
		default     :	LUT_out[3]  = 18'sd 0;
	endcase
end

// LUT_4 

always @ *
begin
	case(sum_level_1[4])
		19 'sd 0      :	LUT_out[4]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[4]  = -18'sd 98;
		19 'sd 32768  :	LUT_out[4]  = -18'sd 33;
		-19'sd 32768  :	LUT_out[4]  = 18'sd 33;
		-19'sd 98304  :	LUT_out[4]  = 18'sd 98;
		19 'sd 196608 :	LUT_out[4]  = -18'sd 197;
		19 'sd 131072 :	LUT_out[4]  = -18'sd 131;
		19 'sd 65536  :	LUT_out[4]  = -18'sd 66;
		-19'sd 65536  :	LUT_out[4]  = 18'sd 66;
		-19'sd 131072 :	LUT_out[4]  = 18'sd 131;
		-19'sd 196608 :	LUT_out[4]  = 18'sd 197;
		default     :	LUT_out[4]  = 18'sd 0;
	endcase
end

// LUT_5 

always @ *
begin
	case(sum_level_1[5])
		19 'sd 0      :	LUT_out[5]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[5]  = -18'sd 89;
		19 'sd 32768  :	LUT_out[5]  = -18'sd 30;
		-19'sd 32768  :	LUT_out[5]  = 18'sd 30;
		-19'sd 98304  :	LUT_out[5]  = 18'sd 89;
		19 'sd 196608 :	LUT_out[5]  = -18'sd 178;
		19 'sd 131072 :	LUT_out[5]  = -18'sd 119;
		19 'sd 65536  :	LUT_out[5]  = -18'sd 59;
		-19'sd 65536  :	LUT_out[5]  = 18'sd 59;
		-19'sd 131072 :	LUT_out[5]  = 18'sd 119;
		-19'sd 196608 :	LUT_out[5]  = 18'sd 178;
		default     :	LUT_out[5]  = 18'sd 0;
	endcase
end

// LUT_6 

always @ *
begin
	case(sum_level_1[6])
		19 'sd 0      :	LUT_out[6]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[6]  = -18'sd 7;
		19 'sd 32768  :	LUT_out[6]  = -18'sd 2;
		-19'sd 32768  :	LUT_out[6]  = 18'sd 2;
		-19'sd 98304  :	LUT_out[6]  = 18'sd 7;
		19 'sd 196608 :	LUT_out[6]  = -18'sd 14;
		19 'sd 131072 :	LUT_out[6]  = -18'sd 9;
		19 'sd 65536  :	LUT_out[6]  = -18'sd 5;
		-19'sd 65536  :	LUT_out[6]  = 18'sd 5;
		-19'sd 131072 :	LUT_out[6]  = 18'sd 9;
		-19'sd 196608 :	LUT_out[6]  = 18'sd 14;
		default     :	LUT_out[6]  = 18'sd 0;
	endcase
end

// LUT_7 

always @ *
begin
	case(sum_level_1[7])
		19 'sd 0      :	LUT_out[7]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[7]  = 18'sd 99;
		19 'sd 32768  :	LUT_out[7]  = 18'sd 33;
		-19'sd 32768  :	LUT_out[7]  = -18'sd 33;
		-19'sd 98304  :	LUT_out[7]  = -18'sd 99;
		19 'sd 196608 :	LUT_out[7]  = 18'sd 199;
		19 'sd 131072 :	LUT_out[7]  = 18'sd 132;
		19 'sd 65536  :	LUT_out[7]  = 18'sd 66;
		-19'sd 65536  :	LUT_out[7]  = -18'sd 66;
		-19'sd 131072 :	LUT_out[7]  = -18'sd 132;
		-19'sd 196608 :	LUT_out[7]  = -18'sd 199;
		default     :	LUT_out[7]  = 18'sd 0;
	endcase
end

// LUT_8 

always @ *
begin
	case(sum_level_1[8])
		19 'sd 0      :	LUT_out[8]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[8]  = 18'sd 151;
		19 'sd 32768  :	LUT_out[8]  = 18'sd 50;
		-19'sd 32768  :	LUT_out[8]  = -18'sd 50;
		-19'sd 98304  :	LUT_out[8]  = -18'sd 151;
		19 'sd 196608 :	LUT_out[8]  = 18'sd 302;
		19 'sd 131072 :	LUT_out[8]  = 18'sd 202;
		19 'sd 65536  :	LUT_out[8]  = 18'sd 101;
		-19'sd 65536  :	LUT_out[8]  = -18'sd 101;
		-19'sd 131072 :	LUT_out[8]  = -18'sd 202;
		-19'sd 196608 :	LUT_out[8]  = -18'sd 302;
		default     :	LUT_out[8]  = 18'sd 0;
	endcase
end

// LUT_9 

always @ *
begin
	case(sum_level_1[9])
		19 'sd 0      :	LUT_out[9]  = 18'sd 0;
		19 'sd 98304  :	LUT_out[9]  = 18'sd 97;
		19 'sd 32768  :	LUT_out[9]  = 18'sd 32;
		-19'sd 32768  :	LUT_out[9]  = -18'sd 32;
		-19'sd 98304  :	LUT_out[9]  = -18'sd 97;
		19 'sd 196608 :	LUT_out[9]  = 18'sd 193;
		19 'sd 131072 :	LUT_out[9]  = 18'sd 129;
		19 'sd 65536  :	LUT_out[9]  = 18'sd 64;
		-19'sd 65536  :	LUT_out[9]  = -18'sd 64;
		-19'sd 131072 :	LUT_out[9]  = -18'sd 129;
		-19'sd 196608 :	LUT_out[9]  = -18'sd 193;
		default     :	LUT_out[9]  = 18'sd 0;
	endcase
end

// LUT_10 

always @ *
begin
	case(sum_level_1[10])
		19 'sd 0      :	LUT_out[10] = 18'sd 0;
		19 'sd 98304  :	LUT_out[10] = -18'sd 45;
		19 'sd 32768  :	LUT_out[10] = -18'sd 15;
		-19'sd 32768  :	LUT_out[10] = 18'sd 15;
		-19'sd 98304  :	LUT_out[10] = 18'sd 45;
		19 'sd 196608 :	LUT_out[10] = -18'sd 90;
		19 'sd 131072 :	LUT_out[10] = -18'sd 60;
		19 'sd 65536  :	LUT_out[10] = -18'sd 30;
		-19'sd 65536  :	LUT_out[10] = 18'sd 30;
		-19'sd 131072 :	LUT_out[10] = 18'sd 60;
		-19'sd 196608 :	LUT_out[10] = 18'sd 90;
		default     :	LUT_out[10] = 18'sd 0;
	endcase
end

// LUT_11 

always @ *
begin
	case(sum_level_1[11])
		19 'sd 0      :	LUT_out[11] = 18'sd 0;
		19 'sd 98304  :	LUT_out[11] = -18'sd 185;
		19 'sd 32768  :	LUT_out[11] = -18'sd 62;
		-19'sd 32768  :	LUT_out[11] = 18'sd 62;
		-19'sd 98304  :	LUT_out[11] = 18'sd 185;
		19 'sd 196608 :	LUT_out[11] = -18'sd 370;
		19 'sd 131072 :	LUT_out[11] = -18'sd 247;
		19 'sd 65536  :	LUT_out[11] = -18'sd 123;
		-19'sd 65536  :	LUT_out[11] = 18'sd 123;
		-19'sd 131072 :	LUT_out[11] = 18'sd 247;
		-19'sd 196608 :	LUT_out[11] = 18'sd 370;
		default     :	LUT_out[11] = 18'sd 0;
	endcase
end

// LUT_12 

always @ *
begin
	case(sum_level_1[12])
		19 'sd 0      :	LUT_out[12] = 18'sd 0;
		19 'sd 98304  :	LUT_out[12] = -18'sd 216;
		19 'sd 32768  :	LUT_out[12] = -18'sd 72;
		-19'sd 32768  :	LUT_out[12] = 18'sd 72;
		-19'sd 98304  :	LUT_out[12] = 18'sd 216;
		19 'sd 196608 :	LUT_out[12] = -18'sd 432;
		19 'sd 131072 :	LUT_out[12] = -18'sd 288;
		19 'sd 65536  :	LUT_out[12] = -18'sd 144;
		-19'sd 65536  :	LUT_out[12] = 18'sd 144;
		-19'sd 131072 :	LUT_out[12] = 18'sd 288;
		-19'sd 196608 :	LUT_out[12] = 18'sd 432;
		default     :	LUT_out[12] = 18'sd 0;
	endcase
end

// LUT_13 

always @ *
begin
	case(sum_level_1[13])
		19 'sd 0      :	LUT_out[13] = 18'sd 0;
		19 'sd 98304  :	LUT_out[13] = -18'sd 91;
		19 'sd 32768  :	LUT_out[13] = -18'sd 30;
		-19'sd 32768  :	LUT_out[13] = 18'sd 30;
		-19'sd 98304  :	LUT_out[13] = 18'sd 91;
		19 'sd 196608 :	LUT_out[13] = -18'sd 182;
		19 'sd 131072 :	LUT_out[13] = -18'sd 122;
		19 'sd 65536  :	LUT_out[13] = -18'sd 61;
		-19'sd 65536  :	LUT_out[13] = 18'sd 61;
		-19'sd 131072 :	LUT_out[13] = 18'sd 122;
		-19'sd 196608 :	LUT_out[13] = 18'sd 182;
		default     :	LUT_out[13] = 18'sd 0;
	endcase
end

// LUT_14 

always @ *
begin
	case(sum_level_1[14])
		19 'sd 0      :	LUT_out[14] = 18'sd 0;
		19 'sd 98304  :	LUT_out[14] = 18'sd 130;
		19 'sd 32768  :	LUT_out[14] = 18'sd 43;
		-19'sd 32768  :	LUT_out[14] = -18'sd 43;
		-19'sd 98304  :	LUT_out[14] = -18'sd 130;
		19 'sd 196608 :	LUT_out[14] = 18'sd 259;
		19 'sd 131072 :	LUT_out[14] = 18'sd 173;
		19 'sd 65536  :	LUT_out[14] = 18'sd 86;
		-19'sd 65536  :	LUT_out[14] = -18'sd 86;
		-19'sd 131072 :	LUT_out[14] = -18'sd 173;
		-19'sd 196608 :	LUT_out[14] = -18'sd 259;
		default     :	LUT_out[14] = 18'sd 0;
	endcase
end

// LUT_15 

always @ *
begin
	case(sum_level_1[15])
		19 'sd 0      :	LUT_out[15] = 18'sd 0;
		19 'sd 98304  :	LUT_out[15] = 18'sd 303;
		19 'sd 32768  :	LUT_out[15] = 18'sd 101;
		-19'sd 32768  :	LUT_out[15] = -18'sd 101;
		-19'sd 98304  :	LUT_out[15] = -18'sd 303;
		19 'sd 196608 :	LUT_out[15] = 18'sd 606;
		19 'sd 131072 :	LUT_out[15] = 18'sd 404;
		19 'sd 65536  :	LUT_out[15] = 18'sd 202;
		-19'sd 65536  :	LUT_out[15] = -18'sd 202;
		-19'sd 131072 :	LUT_out[15] = -18'sd 404;
		-19'sd 196608 :	LUT_out[15] = -18'sd 606;
		default     :	LUT_out[15] = 18'sd 0;
	endcase
end

// LUT_16 

always @ *
begin
	case(sum_level_1[16])
		19 'sd 0      :	LUT_out[16] = 18'sd 0;
		19 'sd 98304  :	LUT_out[16] = 18'sd 292;
		19 'sd 32768  :	LUT_out[16] = 18'sd 97;
		-19'sd 32768  :	LUT_out[16] = -18'sd 97;
		-19'sd 98304  :	LUT_out[16] = -18'sd 292;
		19 'sd 196608 :	LUT_out[16] = 18'sd 583;
		19 'sd 131072 :	LUT_out[16] = 18'sd 389;
		19 'sd 65536  :	LUT_out[16] = 18'sd 194;
		-19'sd 65536  :	LUT_out[16] = -18'sd 194;
		-19'sd 131072 :	LUT_out[16] = -18'sd 389;
		-19'sd 196608 :	LUT_out[16] = -18'sd 583;
		default     :	LUT_out[16] = 18'sd 0;
	endcase
end

// LUT_17 

always @ *
begin
	case(sum_level_1[17])
		19 'sd 0      :	LUT_out[17] = 18'sd 0;
		19 'sd 98304  :	LUT_out[17] = 18'sd 65;
		19 'sd 32768  :	LUT_out[17] = 18'sd 22;
		-19'sd 32768  :	LUT_out[17] = -18'sd 22;
		-19'sd 98304  :	LUT_out[17] = -18'sd 65;
		19 'sd 196608 :	LUT_out[17] = 18'sd 131;
		19 'sd 131072 :	LUT_out[17] = 18'sd 87;
		19 'sd 65536  :	LUT_out[17] = 18'sd 44;
		-19'sd 65536  :	LUT_out[17] = -18'sd 44;
		-19'sd 131072 :	LUT_out[17] = -18'sd 87;
		-19'sd 196608 :	LUT_out[17] = -18'sd 131;
		default     :	LUT_out[17] = 18'sd 0;
	endcase
end

// LUT_18 

always @ *
begin
	case(sum_level_1[18])
		19 'sd 0      :	LUT_out[18] = 18'sd 0;
		19 'sd 98304  :	LUT_out[18] = -18'sd 256;
		19 'sd 32768  :	LUT_out[18] = -18'sd 85;
		-19'sd 32768  :	LUT_out[18] = 18'sd 85;
		-19'sd 98304  :	LUT_out[18] = 18'sd 256;
		19 'sd 196608 :	LUT_out[18] = -18'sd 512;
		19 'sd 131072 :	LUT_out[18] = -18'sd 341;
		19 'sd 65536  :	LUT_out[18] = -18'sd 171;
		-19'sd 65536  :	LUT_out[18] = 18'sd 171;
		-19'sd 131072 :	LUT_out[18] = 18'sd 341;
		-19'sd 196608 :	LUT_out[18] = 18'sd 512;
		default     :	LUT_out[18] = 18'sd 0;
	endcase
end

// LUT_19 

always @ *
begin
	case(sum_level_1[19])
		19 'sd 0      :	LUT_out[19] = 18'sd 0;
		19 'sd 98304  :	LUT_out[19] = -18'sd 460;
		19 'sd 32768  :	LUT_out[19] = -18'sd 153;
		-19'sd 32768  :	LUT_out[19] = 18'sd 153;
		-19'sd 98304  :	LUT_out[19] = 18'sd 460;
		19 'sd 196608 :	LUT_out[19] = -18'sd 919;
		19 'sd 131072 :	LUT_out[19] = -18'sd 613;
		19 'sd 65536  :	LUT_out[19] = -18'sd 306;
		-19'sd 65536  :	LUT_out[19] = 18'sd 306;
		-19'sd 131072 :	LUT_out[19] = 18'sd 613;
		-19'sd 196608 :	LUT_out[19] = 18'sd 919;
		default     :	LUT_out[19] = 18'sd 0;
	endcase
end

// LUT_20 

always @ *
begin
	case(sum_level_1[20])
		19 'sd 0      :	LUT_out[20] = 18'sd 0;
		19 'sd 98304  :	LUT_out[20] = -18'sd 377;
		19 'sd 32768  :	LUT_out[20] = -18'sd 126;
		-19'sd 32768  :	LUT_out[20] = 18'sd 126;
		-19'sd 98304  :	LUT_out[20] = 18'sd 377;
		19 'sd 196608 :	LUT_out[20] = -18'sd 753;
		19 'sd 131072 :	LUT_out[20] = -18'sd 502;
		19 'sd 65536  :	LUT_out[20] = -18'sd 251;
		-19'sd 65536  :	LUT_out[20] = 18'sd 251;
		-19'sd 131072 :	LUT_out[20] = 18'sd 502;
		-19'sd 196608 :	LUT_out[20] = 18'sd 753;
		default     :	LUT_out[20] = 18'sd 0;
	endcase
end

// LUT_21 

always @ *
begin
	case(sum_level_1[21])
		19 'sd 0      :	LUT_out[21] = 18'sd 0;
		19 'sd 98304  :	LUT_out[21] = -18'sd 10;
		19 'sd 32768  :	LUT_out[21] = -18'sd 3;
		-19'sd 32768  :	LUT_out[21] = 18'sd 3;
		-19'sd 98304  :	LUT_out[21] = 18'sd 10;
		19 'sd 196608 :	LUT_out[21] = -18'sd 20;
		19 'sd 131072 :	LUT_out[21] = -18'sd 13;
		19 'sd 65536  :	LUT_out[21] = -18'sd 7;
		-19'sd 65536  :	LUT_out[21] = 18'sd 7;
		-19'sd 131072 :	LUT_out[21] = 18'sd 13;
		-19'sd 196608 :	LUT_out[21] = 18'sd 20;
		default     :	LUT_out[21] = 18'sd 0;
	endcase
end

// LUT_22 

always @ *
begin
	case(sum_level_1[22])
		19 'sd 0      :	LUT_out[22] = 18'sd 0;
		19 'sd 98304  :	LUT_out[22] = 18'sd 436;
		19 'sd 32768  :	LUT_out[22] = 18'sd 145;
		-19'sd 32768  :	LUT_out[22] = -18'sd 145;
		-19'sd 98304  :	LUT_out[22] = -18'sd 436;
		19 'sd 196608 :	LUT_out[22] = 18'sd 872;
		19 'sd 131072 :	LUT_out[22] = 18'sd 581;
		19 'sd 65536  :	LUT_out[22] = 18'sd 291;
		-19'sd 65536  :	LUT_out[22] = -18'sd 291;
		-19'sd 131072 :	LUT_out[22] = -18'sd 581;
		-19'sd 196608 :	LUT_out[22] = -18'sd 872;
		default     :	LUT_out[22] = 18'sd 0;
	endcase
end

// LUT_23 

always @ *
begin
	case(sum_level_1[23])
		19 'sd 0      :	LUT_out[23] = 18'sd 0;
		19 'sd 98304  :	LUT_out[23] = 18'sd 662;
		19 'sd 32768  :	LUT_out[23] = 18'sd 221;
		-19'sd 32768  :	LUT_out[23] = -18'sd 221;
		-19'sd 98304  :	LUT_out[23] = -18'sd 662;
		19 'sd 196608 :	LUT_out[23] = 18'sd 1324;
		19 'sd 131072 :	LUT_out[23] = 18'sd 882;
		19 'sd 65536  :	LUT_out[23] = 18'sd 441;
		-19'sd 65536  :	LUT_out[23] = -18'sd 441;
		-19'sd 131072 :	LUT_out[23] = -18'sd 882;
		-19'sd 196608 :	LUT_out[23] = -18'sd 1324;
		default     :	LUT_out[23] = 18'sd 0;
	endcase
end

// LUT_24 

always @ *
begin
	case(sum_level_1[24])
		19 'sd 0      :	LUT_out[24] = 18'sd 0;
		19 'sd 98304  :	LUT_out[24] = 18'sd 468;
		19 'sd 32768  :	LUT_out[24] = 18'sd 156;
		-19'sd 32768  :	LUT_out[24] = -18'sd 156;
		-19'sd 98304  :	LUT_out[24] = -18'sd 468;
		19 'sd 196608 :	LUT_out[24] = 18'sd 937;
		19 'sd 131072 :	LUT_out[24] = 18'sd 625;
		19 'sd 65536  :	LUT_out[24] = 18'sd 312;
		-19'sd 65536  :	LUT_out[24] = -18'sd 312;
		-19'sd 131072 :	LUT_out[24] = -18'sd 625;
		-19'sd 196608 :	LUT_out[24] = -18'sd 937;
		default     :	LUT_out[24] = 18'sd 0;
	endcase
end

// LUT_25 

always @ *
begin
	case(sum_level_1[25])
		19 'sd 0      :	LUT_out[25] = 18'sd 0;
		19 'sd 98304  :	LUT_out[25] = -18'sd 87;
		19 'sd 32768  :	LUT_out[25] = -18'sd 29;
		-19'sd 32768  :	LUT_out[25] = 18'sd 29;
		-19'sd 98304  :	LUT_out[25] = 18'sd 87;
		19 'sd 196608 :	LUT_out[25] = -18'sd 174;
		19 'sd 131072 :	LUT_out[25] = -18'sd 116;
		19 'sd 65536  :	LUT_out[25] = -18'sd 58;
		-19'sd 65536  :	LUT_out[25] = 18'sd 58;
		-19'sd 131072 :	LUT_out[25] = 18'sd 116;
		-19'sd 196608 :	LUT_out[25] = 18'sd 174;
		default     :	LUT_out[25] = 18'sd 0;
	endcase
end

// LUT_26 

always @ *
begin
	case(sum_level_1[26])
		19 'sd 0      :	LUT_out[26] = 18'sd 0;
		19 'sd 98304  :	LUT_out[26] = -18'sd 685;
		19 'sd 32768  :	LUT_out[26] = -18'sd 228;
		-19'sd 32768  :	LUT_out[26] = 18'sd 228;
		-19'sd 98304  :	LUT_out[26] = 18'sd 685;
		19 'sd 196608 :	LUT_out[26] = -18'sd 1370;
		19 'sd 131072 :	LUT_out[26] = -18'sd 913;
		19 'sd 65536  :	LUT_out[26] = -18'sd 457;
		-19'sd 65536  :	LUT_out[26] = 18'sd 457;
		-19'sd 131072 :	LUT_out[26] = 18'sd 913;
		-19'sd 196608 :	LUT_out[26] = 18'sd 1370;
		default     :	LUT_out[26] = 18'sd 0;
	endcase
end

// LUT_27 

always @ *
begin
	case(sum_level_1[27])
		19 'sd 0      :	LUT_out[27] = 18'sd 0;
		19 'sd 98304  :	LUT_out[27] = -18'sd 919;
		19 'sd 32768  :	LUT_out[27] = -18'sd 306;
		-19'sd 32768  :	LUT_out[27] = 18'sd 306;
		-19'sd 98304  :	LUT_out[27] = 18'sd 919;
		19 'sd 196608 :	LUT_out[27] = -18'sd 1839;
		19 'sd 131072 :	LUT_out[27] = -18'sd 1226;
		19 'sd 65536  :	LUT_out[27] = -18'sd 613;
		-19'sd 65536  :	LUT_out[27] = 18'sd 613;
		-19'sd 131072 :	LUT_out[27] = 18'sd 1226;
		-19'sd 196608 :	LUT_out[27] = 18'sd 1839;
		default     :	LUT_out[27] = 18'sd 0;
	endcase
end

// LUT_28 

always @ *
begin
	case(sum_level_1[28])
		19 'sd 0      :	LUT_out[28] = 18'sd 0;
		19 'sd 98304  :	LUT_out[28] = -18'sd 563;
		19 'sd 32768  :	LUT_out[28] = -18'sd 188;
		-19'sd 32768  :	LUT_out[28] = 18'sd 188;
		-19'sd 98304  :	LUT_out[28] = 18'sd 563;
		19 'sd 196608 :	LUT_out[28] = -18'sd 1127;
		19 'sd 131072 :	LUT_out[28] = -18'sd 751;
		19 'sd 65536  :	LUT_out[28] = -18'sd 376;
		-19'sd 65536  :	LUT_out[28] = 18'sd 376;
		-19'sd 131072 :	LUT_out[28] = 18'sd 751;
		-19'sd 196608 :	LUT_out[28] = 18'sd 1127;
		default     :	LUT_out[28] = 18'sd 0;
	endcase
end

// LUT_29 

always @ *
begin
	case(sum_level_1[29])
		19 'sd 0      :	LUT_out[29] = 18'sd 0;
		19 'sd 98304  :	LUT_out[29] = 18'sd 242;
		19 'sd 32768  :	LUT_out[29] = 18'sd 81;
		-19'sd 32768  :	LUT_out[29] = -18'sd 81;
		-19'sd 98304  :	LUT_out[29] = -18'sd 242;
		19 'sd 196608 :	LUT_out[29] = 18'sd 485;
		19 'sd 131072 :	LUT_out[29] = 18'sd 323;
		19 'sd 65536  :	LUT_out[29] = 18'sd 162;
		-19'sd 65536  :	LUT_out[29] = -18'sd 162;
		-19'sd 131072 :	LUT_out[29] = -18'sd 323;
		-19'sd 196608 :	LUT_out[29] = -18'sd 485;
		default     :	LUT_out[29] = 18'sd 0;
	endcase
end

// LUT_30 

always @ *
begin
	case(sum_level_1[30])
		19 'sd 0      :	LUT_out[30] = 18'sd 0;
		19 'sd 98304  :	LUT_out[30] = 18'sd 1025;
		19 'sd 32768  :	LUT_out[30] = 18'sd 342;
		-19'sd 32768  :	LUT_out[30] = -18'sd 342;
		-19'sd 98304  :	LUT_out[30] = -18'sd 1025;
		19 'sd 196608 :	LUT_out[30] = 18'sd 2051;
		19 'sd 131072 :	LUT_out[30] = 18'sd 1367;
		19 'sd 65536  :	LUT_out[30] = 18'sd 684;
		-19'sd 65536  :	LUT_out[30] = -18'sd 684;
		-19'sd 131072 :	LUT_out[30] = -18'sd 1367;
		-19'sd 196608 :	LUT_out[30] = -18'sd 2051;
		default     :	LUT_out[30] = 18'sd 0;
	endcase
end

// LUT_31 

always @ *
begin
	case(sum_level_1[31])
		19 'sd 0      :	LUT_out[31] = 18'sd 0;
		19 'sd 98304  :	LUT_out[31] = 18'sd 1247;
		19 'sd 32768  :	LUT_out[31] = 18'sd 416;
		-19'sd 32768  :	LUT_out[31] = -18'sd 416;
		-19'sd 98304  :	LUT_out[31] = -18'sd 1247;
		19 'sd 196608 :	LUT_out[31] = 18'sd 2493;
		19 'sd 131072 :	LUT_out[31] = 18'sd 1662;
		19 'sd 65536  :	LUT_out[31] = 18'sd 831;
		-19'sd 65536  :	LUT_out[31] = -18'sd 831;
		-19'sd 131072 :	LUT_out[31] = -18'sd 1662;
		-19'sd 196608 :	LUT_out[31] = -18'sd 2493;
		default     :	LUT_out[31] = 18'sd 0;
	endcase
end

// LUT_32 

always @ *
begin
	case(sum_level_1[32])
		19 'sd 0      :	LUT_out[32] = 18'sd 0;
		19 'sd 98304  :	LUT_out[32] = 18'sd 658;
		19 'sd 32768  :	LUT_out[32] = 18'sd 219;
		-19'sd 32768  :	LUT_out[32] = -18'sd 219;
		-19'sd 98304  :	LUT_out[32] = -18'sd 658;
		19 'sd 196608 :	LUT_out[32] = 18'sd 1316;
		19 'sd 131072 :	LUT_out[32] = 18'sd 877;
		19 'sd 65536  :	LUT_out[32] = 18'sd 439;
		-19'sd 65536  :	LUT_out[32] = -18'sd 439;
		-19'sd 131072 :	LUT_out[32] = -18'sd 877;
		-19'sd 196608 :	LUT_out[32] = -18'sd 1316;
		default     :	LUT_out[32] = 18'sd 0;
	endcase
end

// LUT_33 

always @ *
begin
	case(sum_level_1[33])
		19 'sd 0      :	LUT_out[33] = 18'sd 0;
		19 'sd 98304  :	LUT_out[33] = -18'sd 481;
		19 'sd 32768  :	LUT_out[33] = -18'sd 160;
		-19'sd 32768  :	LUT_out[33] = 18'sd 160;
		-19'sd 98304  :	LUT_out[33] = 18'sd 481;
		19 'sd 196608 :	LUT_out[33] = -18'sd 962;
		19 'sd 131072 :	LUT_out[33] = -18'sd 641;
		19 'sd 65536  :	LUT_out[33] = -18'sd 321;
		-19'sd 65536  :	LUT_out[33] = 18'sd 321;
		-19'sd 131072 :	LUT_out[33] = 18'sd 641;
		-19'sd 196608 :	LUT_out[33] = 18'sd 962;
		default     :	LUT_out[33] = 18'sd 0;
	endcase
end

// LUT_34 

always @ *
begin
	case(sum_level_1[34])
		19 'sd 0      :	LUT_out[34] = 18'sd 0;
		19 'sd 98304  :	LUT_out[34] = -18'sd 1492;
		19 'sd 32768  :	LUT_out[34] = -18'sd 497;
		-19'sd 32768  :	LUT_out[34] = 18'sd 497;
		-19'sd 98304  :	LUT_out[34] = 18'sd 1492;
		19 'sd 196608 :	LUT_out[34] = -18'sd 2984;
		19 'sd 131072 :	LUT_out[34] = -18'sd 1990;
		19 'sd 65536  :	LUT_out[34] = -18'sd 995;
		-19'sd 65536  :	LUT_out[34] = 18'sd 995;
		-19'sd 131072 :	LUT_out[34] = 18'sd 1990;
		-19'sd 196608 :	LUT_out[34] = 18'sd 2984;
		default     :	LUT_out[34] = 18'sd 0;
	endcase
end

// LUT_35 

always @ *
begin
	case(sum_level_1[35])
		19 'sd 0      :	LUT_out[35] = 18'sd 0;
		19 'sd 98304  :	LUT_out[35] = -18'sd 1669;
		19 'sd 32768  :	LUT_out[35] = -18'sd 556;
		-19'sd 32768  :	LUT_out[35] = 18'sd 556;
		-19'sd 98304  :	LUT_out[35] = 18'sd 1669;
		19 'sd 196608 :	LUT_out[35] = -18'sd 3339;
		19 'sd 131072 :	LUT_out[35] = -18'sd 2226;
		19 'sd 65536  :	LUT_out[35] = -18'sd 1113;
		-19'sd 65536  :	LUT_out[35] = 18'sd 1113;
		-19'sd 131072 :	LUT_out[35] = 18'sd 2226;
		-19'sd 196608 :	LUT_out[35] = 18'sd 3339;
		default     :	LUT_out[35] = 18'sd 0;
	endcase
end

// LUT_36 

always @ *
begin
	case(sum_level_1[36])
		19 'sd 0      :	LUT_out[36] = 18'sd 0;
		19 'sd 98304  :	LUT_out[36] = -18'sd 748;
		19 'sd 32768  :	LUT_out[36] = -18'sd 249;
		-19'sd 32768  :	LUT_out[36] = 18'sd 249;
		-19'sd 98304  :	LUT_out[36] = 18'sd 748;
		19 'sd 196608 :	LUT_out[36] = -18'sd 1495;
		19 'sd 131072 :	LUT_out[36] = -18'sd 997;
		19 'sd 65536  :	LUT_out[36] = -18'sd 498;
		-19'sd 65536  :	LUT_out[36] = 18'sd 498;
		-19'sd 131072 :	LUT_out[36] = 18'sd 997;
		-19'sd 196608 :	LUT_out[36] = 18'sd 1495;
		default     :	LUT_out[36] = 18'sd 0;
	endcase
end

// LUT_37 

always @ *
begin
	case(sum_level_1[37])
		19 'sd 0      :	LUT_out[37] = 18'sd 0;
		19 'sd 98304  :	LUT_out[37] = 18'sd 844;
		19 'sd 32768  :	LUT_out[37] = 18'sd 281;
		-19'sd 32768  :	LUT_out[37] = -18'sd 281;
		-19'sd 98304  :	LUT_out[37] = -18'sd 844;
		19 'sd 196608 :	LUT_out[37] = 18'sd 1688;
		19 'sd 131072 :	LUT_out[37] = 18'sd 1125;
		19 'sd 65536  :	LUT_out[37] = 18'sd 563;
		-19'sd 65536  :	LUT_out[37] = -18'sd 563;
		-19'sd 131072 :	LUT_out[37] = -18'sd 1125;
		-19'sd 196608 :	LUT_out[37] = -18'sd 1688;
		default     :	LUT_out[37] = 18'sd 0;
	endcase
end

// LUT_38 

always @ *
begin
	case(sum_level_1[38])
		19 'sd 0      :	LUT_out[38] = 18'sd 0;
		19 'sd 98304  :	LUT_out[38] = 18'sd 2151;
		19 'sd 32768  :	LUT_out[38] = 18'sd 717;
		-19'sd 32768  :	LUT_out[38] = -18'sd 717;
		-19'sd 98304  :	LUT_out[38] = -18'sd 2151;
		19 'sd 196608 :	LUT_out[38] = 18'sd 4301;
		19 'sd 131072 :	LUT_out[38] = 18'sd 2867;
		19 'sd 65536  :	LUT_out[38] = 18'sd 1434;
		-19'sd 65536  :	LUT_out[38] = -18'sd 1434;
		-19'sd 131072 :	LUT_out[38] = -18'sd 2867;
		-19'sd 196608 :	LUT_out[38] = -18'sd 4301;
		default     :	LUT_out[38] = 18'sd 0;
	endcase
end

// LUT_39 

always @ *
begin
	case(sum_level_1[39])
		19 'sd 0      :	LUT_out[39] = 18'sd 0;
		19 'sd 98304  :	LUT_out[39] = 18'sd 2240;
		19 'sd 32768  :	LUT_out[39] = 18'sd 747;
		-19'sd 32768  :	LUT_out[39] = -18'sd 747;
		-19'sd 98304  :	LUT_out[39] = -18'sd 2240;
		19 'sd 196608 :	LUT_out[39] = 18'sd 4480;
		19 'sd 131072 :	LUT_out[39] = 18'sd 2986;
		19 'sd 65536  :	LUT_out[39] = 18'sd 1493;
		-19'sd 65536  :	LUT_out[39] = -18'sd 1493;
		-19'sd 131072 :	LUT_out[39] = -18'sd 2986;
		-19'sd 196608 :	LUT_out[39] = -18'sd 4480;
		default     :	LUT_out[39] = 18'sd 0;
	endcase
end

// LUT_40 

always @ *
begin
	case(sum_level_1[40])
		19 'sd 0      :	LUT_out[40] = 18'sd 0;
		19 'sd 98304  :	LUT_out[40] = 18'sd 828;
		19 'sd 32768  :	LUT_out[40] = 18'sd 276;
		-19'sd 32768  :	LUT_out[40] = -18'sd 276;
		-19'sd 98304  :	LUT_out[40] = -18'sd 828;
		19 'sd 196608 :	LUT_out[40] = 18'sd 1656;
		19 'sd 131072 :	LUT_out[40] = 18'sd 1104;
		19 'sd 65536  :	LUT_out[40] = 18'sd 552;
		-19'sd 65536  :	LUT_out[40] = -18'sd 552;
		-19'sd 131072 :	LUT_out[40] = -18'sd 1104;
		-19'sd 196608 :	LUT_out[40] = -18'sd 1656;
		default     :	LUT_out[40] = 18'sd 0;
	endcase
end

// LUT_41 

always @ *
begin
	case(sum_level_1[41])
		19 'sd 0      :	LUT_out[41] = 18'sd 0;
		19 'sd 98304  :	LUT_out[41] = -18'sd 1415;
		19 'sd 32768  :	LUT_out[41] = -18'sd 472;
		-19'sd 32768  :	LUT_out[41] = 18'sd 472;
		-19'sd 98304  :	LUT_out[41] = 18'sd 1415;
		19 'sd 196608 :	LUT_out[41] = -18'sd 2830;
		19 'sd 131072 :	LUT_out[41] = -18'sd 1887;
		19 'sd 65536  :	LUT_out[41] = -18'sd 943;
		-19'sd 65536  :	LUT_out[41] = 18'sd 943;
		-19'sd 131072 :	LUT_out[41] = 18'sd 1887;
		-19'sd 196608 :	LUT_out[41] = 18'sd 2830;
		default     :	LUT_out[41] = 18'sd 0;
	endcase
end

// LUT_42 

always @ *
begin
	case(sum_level_1[42])
		19 'sd 0      :	LUT_out[42] = 18'sd 0;
		19 'sd 98304  :	LUT_out[42] = -18'sd 3139;
		19 'sd 32768  :	LUT_out[42] = -18'sd 1046;
		-19'sd 32768  :	LUT_out[42] = 18'sd 1046;
		-19'sd 98304  :	LUT_out[42] = 18'sd 3139;
		19 'sd 196608 :	LUT_out[42] = -18'sd 6278;
		19 'sd 131072 :	LUT_out[42] = -18'sd 4186;
		19 'sd 65536  :	LUT_out[42] = -18'sd 2093;
		-19'sd 65536  :	LUT_out[42] = 18'sd 2093;
		-19'sd 131072 :	LUT_out[42] = 18'sd 4186;
		-19'sd 196608 :	LUT_out[42] = 18'sd 6278;
		default     :	LUT_out[42] = 18'sd 0;
	endcase
end

// LUT_43 

always @ *
begin
	case(sum_level_1[43])
		19 'sd 0      :	LUT_out[43] = 18'sd 0;
		19 'sd 98304  :	LUT_out[43] = -18'sd 3077;
		19 'sd 32768  :	LUT_out[43] = -18'sd 1026;
		-19'sd 32768  :	LUT_out[43] = 18'sd 1026;
		-19'sd 98304  :	LUT_out[43] = 18'sd 3077;
		19 'sd 196608 :	LUT_out[43] = -18'sd 6153;
		19 'sd 131072 :	LUT_out[43] = -18'sd 4102;
		19 'sd 65536  :	LUT_out[43] = -18'sd 2051;
		-19'sd 65536  :	LUT_out[43] = 18'sd 2051;
		-19'sd 131072 :	LUT_out[43] = 18'sd 4102;
		-19'sd 196608 :	LUT_out[43] = 18'sd 6153;
		default     :	LUT_out[43] = 18'sd 0;
	endcase
end

// LUT_44 

always @ *
begin
	case(sum_level_1[44])
		19 'sd 0      :	LUT_out[44] = 18'sd 0;
		19 'sd 98304  :	LUT_out[44] = -18'sd 896;
		19 'sd 32768  :	LUT_out[44] = -18'sd 299;
		-19'sd 32768  :	LUT_out[44] = 18'sd 299;
		-19'sd 98304  :	LUT_out[44] = 18'sd 896;
		19 'sd 196608 :	LUT_out[44] = -18'sd 1791;
		19 'sd 131072 :	LUT_out[44] = -18'sd 1194;
		19 'sd 65536  :	LUT_out[44] = -18'sd 597;
		-19'sd 65536  :	LUT_out[44] = 18'sd 597;
		-19'sd 131072 :	LUT_out[44] = 18'sd 1194;
		-19'sd 196608 :	LUT_out[44] = 18'sd 1791;
		default     :	LUT_out[44] = 18'sd 0;
	endcase
end

// LUT_45 

always @ *
begin
	case(sum_level_1[45])
		19 'sd 0      :	LUT_out[45] = 18'sd 0;
		19 'sd 98304  :	LUT_out[45] = 18'sd 2394;
		19 'sd 32768  :	LUT_out[45] = 18'sd 798;
		-19'sd 32768  :	LUT_out[45] = -18'sd 798;
		-19'sd 98304  :	LUT_out[45] = -18'sd 2394;
		19 'sd 196608 :	LUT_out[45] = 18'sd 4788;
		19 'sd 131072 :	LUT_out[45] = 18'sd 3192;
		19 'sd 65536  :	LUT_out[45] = 18'sd 1596;
		-19'sd 65536  :	LUT_out[45] = -18'sd 1596;
		-19'sd 131072 :	LUT_out[45] = -18'sd 3192;
		-19'sd 196608 :	LUT_out[45] = -18'sd 4788;
		default     :	LUT_out[45] = 18'sd 0;
	endcase
end

// LUT_46 

always @ *
begin
	case(sum_level_1[46])
		19 'sd 0      :	LUT_out[46] = 18'sd 0;
		19 'sd 98304  :	LUT_out[46] = 18'sd 4821;
		19 'sd 32768  :	LUT_out[46] = 18'sd 1607;
		-19'sd 32768  :	LUT_out[46] = -18'sd 1607;
		-19'sd 98304  :	LUT_out[46] = -18'sd 4821;
		19 'sd 196608 :	LUT_out[46] = 18'sd 9643;
		19 'sd 131072 :	LUT_out[46] = 18'sd 6428;
		19 'sd 65536  :	LUT_out[46] = 18'sd 3214;
		-19'sd 65536  :	LUT_out[46] = -18'sd 3214;
		-19'sd 131072 :	LUT_out[46] = -18'sd 6428;
		-19'sd 196608 :	LUT_out[46] = -18'sd 9643;
		default     :	LUT_out[46] = 18'sd 0;
	endcase
end

// LUT_47 

always @ *
begin
	case(sum_level_1[47])
		19 'sd 0      :	LUT_out[47] = 18'sd 0;
		19 'sd 98304  :	LUT_out[47] = 18'sd 4519;
		19 'sd 32768  :	LUT_out[47] = 18'sd 1506;
		-19'sd 32768  :	LUT_out[47] = -18'sd 1506;
		-19'sd 98304  :	LUT_out[47] = -18'sd 4519;
		19 'sd 196608 :	LUT_out[47] = 18'sd 9037;
		19 'sd 131072 :	LUT_out[47] = 18'sd 6025;
		19 'sd 65536  :	LUT_out[47] = 18'sd 3012;
		-19'sd 65536  :	LUT_out[47] = -18'sd 3012;
		-19'sd 131072 :	LUT_out[47] = -18'sd 6025;
		-19'sd 196608 :	LUT_out[47] = -18'sd 9037;
		default     :	LUT_out[47] = 18'sd 0;
	endcase
end

// LUT_48 

always @ *
begin
	case(sum_level_1[48])
		19 'sd 0      :	LUT_out[48] = 18'sd 0;
		19 'sd 98304  :	LUT_out[48] = 18'sd 947;
		19 'sd 32768  :	LUT_out[48] = 18'sd 316;
		-19'sd 32768  :	LUT_out[48] = -18'sd 316;
		-19'sd 98304  :	LUT_out[48] = -18'sd 947;
		19 'sd 196608 :	LUT_out[48] = 18'sd 1893;
		19 'sd 131072 :	LUT_out[48] = 18'sd 1262;
		19 'sd 65536  :	LUT_out[48] = 18'sd 631;
		-19'sd 65536  :	LUT_out[48] = -18'sd 631;
		-19'sd 131072 :	LUT_out[48] = -18'sd 1262;
		-19'sd 196608 :	LUT_out[48] = -18'sd 1893;
		default     :	LUT_out[48] = 18'sd 0;
	endcase
end

// LUT_49 

always @ *
begin
	case(sum_level_1[49])
		19 'sd 0      :	LUT_out[49] = 18'sd 0;
		19 'sd 98304  :	LUT_out[49] = -18'sd 4435;
		19 'sd 32768  :	LUT_out[49] = -18'sd 1478;
		-19'sd 32768  :	LUT_out[49] = 18'sd 1478;
		-19'sd 98304  :	LUT_out[49] = 18'sd 4435;
		19 'sd 196608 :	LUT_out[49] = -18'sd 8871;
		19 'sd 131072 :	LUT_out[49] = -18'sd 5914;
		19 'sd 65536  :	LUT_out[49] = -18'sd 2957;
		-19'sd 65536  :	LUT_out[49] = 18'sd 2957;
		-19'sd 131072 :	LUT_out[49] = 18'sd 5914;
		-19'sd 196608 :	LUT_out[49] = 18'sd 8871;
		default     :	LUT_out[49] = 18'sd 0;
	endcase
end

// LUT_50 

always @ *
begin
	case(sum_level_1[50])
		19 'sd 0      :	LUT_out[50] = 18'sd 0;
		19 'sd 98304  :	LUT_out[50] = -18'sd 8538;
		19 'sd 32768  :	LUT_out[50] = -18'sd 2846;
		-19'sd 32768  :	LUT_out[50] = 18'sd 2846;
		-19'sd 98304  :	LUT_out[50] = 18'sd 8538;
		19 'sd 196608 :	LUT_out[50] = -18'sd 17075;
		19 'sd 131072 :	LUT_out[50] = -18'sd 11384;
		19 'sd 65536  :	LUT_out[50] = -18'sd 5692;
		-19'sd 65536  :	LUT_out[50] = 18'sd 5692;
		-19'sd 131072 :	LUT_out[50] = 18'sd 11384;
		-19'sd 196608 :	LUT_out[50] = 18'sd 17075;
		default     :	LUT_out[50] = 18'sd 0;
	endcase
end

// LUT_51 

always @ *
begin
	case(sum_level_1[51])
		19 'sd 0      :	LUT_out[51] = 18'sd 0;
		19 'sd 98304  :	LUT_out[51] = -18'sd 8007;
		19 'sd 32768  :	LUT_out[51] = -18'sd 2669;
		-19'sd 32768  :	LUT_out[51] = 18'sd 2669;
		-19'sd 98304  :	LUT_out[51] = 18'sd 8007;
		19 'sd 196608 :	LUT_out[51] = -18'sd 16014;
		19 'sd 131072 :	LUT_out[51] = -18'sd 10676;
		19 'sd 65536  :	LUT_out[51] = -18'sd 5338;
		-19'sd 65536  :	LUT_out[51] = 18'sd 5338;
		-19'sd 131072 :	LUT_out[51] = 18'sd 10676;
		-19'sd 196608 :	LUT_out[51] = 18'sd 16014;
		default     :	LUT_out[51] = 18'sd 0;
	endcase
end

// LUT_52 

always @ *
begin
	case(sum_level_1[52])
		19 'sd 0      :	LUT_out[52] = 18'sd 0;
		19 'sd 98304  :	LUT_out[52] = -18'sd 978;
		19 'sd 32768  :	LUT_out[52] = -18'sd 326;
		-19'sd 32768  :	LUT_out[52] = 18'sd 326;
		-19'sd 98304  :	LUT_out[52] = 18'sd 978;
		19 'sd 196608 :	LUT_out[52] = -18'sd 1957;
		19 'sd 131072 :	LUT_out[52] = -18'sd 1305;
		19 'sd 65536  :	LUT_out[52] = -18'sd 652;
		-19'sd 65536  :	LUT_out[52] = 18'sd 652;
		-19'sd 131072 :	LUT_out[52] = 18'sd 1305;
		-19'sd 196608 :	LUT_out[52] = 18'sd 1957;
		default     :	LUT_out[52] = 18'sd 0;
	endcase
end

// LUT_53 

always @ *
begin
	case(sum_level_1[53])
		19 'sd 0      :	LUT_out[53] = 18'sd 0;
		19 'sd 98304  :	LUT_out[53] = 18'sd 11688;
		19 'sd 32768  :	LUT_out[53] = 18'sd 3896;
		-19'sd 32768  :	LUT_out[53] = -18'sd 3896;
		-19'sd 98304  :	LUT_out[53] = -18'sd 11688;
		19 'sd 196608 :	LUT_out[53] = 18'sd 23377;
		19 'sd 131072 :	LUT_out[53] = 18'sd 15584;
		19 'sd 65536  :	LUT_out[53] = 18'sd 7792;
		-19'sd 65536  :	LUT_out[53] = -18'sd 7792;
		-19'sd 131072 :	LUT_out[53] = -18'sd 15584;
		-19'sd 196608 :	LUT_out[53] = -18'sd 23377;
		default     :	LUT_out[53] = 18'sd 0;
	endcase
end

// LUT_54 

always @ *
begin
	case(sum_level_1[54])
		19 'sd 0      :	LUT_out[54] = 18'sd 0;
		19 'sd 98304  :	LUT_out[54] = 18'sd 26392;
		19 'sd 32768  :	LUT_out[54] = 18'sd 8797;
		-19'sd 32768  :	LUT_out[54] = -18'sd 8797;
		-19'sd 98304  :	LUT_out[54] = -18'sd 26392;
		19 'sd 196608 :	LUT_out[54] = 18'sd 52785;
		19 'sd 131072 :	LUT_out[54] = 18'sd 35190;
		19 'sd 65536  :	LUT_out[54] = 18'sd 17595;
		-19'sd 65536  :	LUT_out[54] = -18'sd 17595;
		-19'sd 131072 :	LUT_out[54] = -18'sd 35190;
		-19'sd 196608 :	LUT_out[54] = -18'sd 52785;
		default     :	LUT_out[54] = 18'sd 0;
	endcase
end

// LUT_55 

always @ *
begin
	case(sum_level_1[55])
		19 'sd 0      :	LUT_out[55] = 18'sd 0;
		19 'sd 98304  :	LUT_out[55] = 18'sd 38128;
		19 'sd 32768  :	LUT_out[55] = 18'sd 12709;
		-19'sd 32768  :	LUT_out[55] = -18'sd 12709;
		-19'sd 98304  :	LUT_out[55] = -18'sd 38128;
		19 'sd 196608 :	LUT_out[55] = 18'sd 76256;
		19 'sd 131072 :	LUT_out[55] = 18'sd 50837;
		19 'sd 65536  :	LUT_out[55] = 18'sd 25419;
		-19'sd 65536  :	LUT_out[55] = -18'sd 25419;
		-19'sd 131072 :	LUT_out[55] = -18'sd 50837;
		-19'sd 196608 :	LUT_out[55] = -18'sd 76256;
		default     :	LUT_out[55] = 18'sd 0;
	endcase
end

// LUT_56 

always @ *
begin
	case(sum_level_1[56])
		19 'sd 0      :	LUT_out[56] = 18'sd 0;
		19 'sd 98304  :	LUT_out[56] = 18'sd 42601;
		19 'sd 32768  :	LUT_out[56] = 18'sd 14200;
		-19'sd 32768  :	LUT_out[56] = -18'sd 14200;
		-19'sd 98304  :	LUT_out[56] = -18'sd 42601;
		default     :	LUT_out[56] = 18'sd 0;
	endcase
end


endmodule