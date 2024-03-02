module tx_pract_filter( input clk, reset, sym_clk_en, sam_clk_en,
							input [1:0] sw,
                    input signed [17:0] x_in, //1s17
                    output reg signed [17:0] y); //1s17);



// create array of vectors
integer  i;
reg signed [17:0] x[104:0]; // for 105 coefficients 0s18
reg signed [18:0] sum_level_1[52:0];
reg signed [17:0] sum_out[51:0];
reg signed [36:0] LUT_out[52:0]; // 1s35 but changed to 2s35
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
        for(i=1; i<105; i=i+1)
            x[i] <= 0;
    end
    else if (sam_clk_en)
    begin
        for(i=1; i<105; i=i+1)
            x[i] <= x[i-1];
    end
	else
    begin
        for(i=1; i<105; i=i+1)
            x[i] <= x[i];
    end
// add values the require the same coefficients
always @ *
begin
    for(i=0; i<=51; i= i+1)
    sum_level_1[i] <= {x[i][17], x[i]} + {x[104-i][17], x[104-i]}; // sign extend to see whats up 2s17
end

// center value
always @ *
    sum_level_1[52] <= {x[52][17], x[52]};


// multiply by coefficients
// always @ *
// begin
//     for(i=0; i <= 10; i=i+1)
//     mult_out[i] <= sum_level_1[i] * b[i]; 
// end

// sum up mutlipliers
always @ *
if (reset)
    for (i = 0; i <=51; i=i+1)
        sum_out[i] = 18'sd 0;
else
    begin
        sum_out[0] = LUT_out[0][35:18] + LUT_out[1][35:18];
        for(i = 0; i <=50 ; i=i+1)
            sum_out[i+1] <= sum_out[i] + LUT_out[i+2][35:18]; 
    end
    

always @ (posedge clk or posedge reset)
    if(reset)
        y <= 0;
    else if (sam_clk_en)
        y <= sum_out[51];
	else
		y <= y;
 


// LUT_0 

always @ *
begin
	case(sum_level_1[0])
		19 'sd 0      :	LUT_out[0]  = 37'sd 0;
		19 'sd 32767  :	LUT_out[0]  = -37'sd 20282773;
		19 'sd 98302  :	LUT_out[0]  = -37'sd 60848938;
		-19'sd 32767  :	LUT_out[0]  = 37'sd 20282773;
		-19'sd 98302  :	LUT_out[0]  = 37'sd 60848938;
		19 'sd 65534  :	LUT_out[0]  = -37'sd 40565546;
		19 'sd 131069 :	LUT_out[0]  = -37'sd 81131711;
		-19'sd 65535  :	LUT_out[0]  = 37'sd 40566165;
		19 'sd 196604 :	LUT_out[0]  = -37'sd 121697876;
		19 'sd 65535  :	LUT_out[0]  = -37'sd 40566165;
		-19'sd 65534  :	LUT_out[0]  = 37'sd 40565546;
		-19'sd 131069 :	LUT_out[0]  = 37'sd 81131711;
		-19'sd 196604 :	LUT_out[0]  = 37'sd 121697876;
		default     :	LUT_out[0]  = 37'sd 0;
	endcase
end

// LUT_1 

always @ *
begin
	case(sum_level_1[1])
		19 'sd 0      :	LUT_out[1]  = 37'sd 0;
		19 'sd 32767  :	LUT_out[1]  = -37'sd 13139567;
		19 'sd 98302  :	LUT_out[1]  = -37'sd 39419102;
		-19'sd 32767  :	LUT_out[1]  = 37'sd 13139567;
		-19'sd 98302  :	LUT_out[1]  = 37'sd 39419102;
		19 'sd 65534  :	LUT_out[1]  = -37'sd 26279134;
		19 'sd 131069 :	LUT_out[1]  = -37'sd 52558669;
		-19'sd 65535  :	LUT_out[1]  = 37'sd 26279535;
		19 'sd 196604 :	LUT_out[1]  = -37'sd 78838204;
		19 'sd 65535  :	LUT_out[1]  = -37'sd 26279535;
		-19'sd 65534  :	LUT_out[1]  = 37'sd 26279134;
		-19'sd 131069 :	LUT_out[1]  = 37'sd 52558669;
		-19'sd 196604 :	LUT_out[1]  = 37'sd 78838204;
		default     :	LUT_out[1]  = 37'sd 0;
	endcase
end

// LUT_2 

always @ *
begin
	case(sum_level_1[2])
		19 'sd 0      :	LUT_out[2]  = 37'sd 0;
		19 'sd 32767  :	LUT_out[2]  = 37'sd 4816749;
		19 'sd 98302  :	LUT_out[2]  = 37'sd 14450394;
		-19'sd 32767  :	LUT_out[2]  = -37'sd 4816749;
		-19'sd 98302  :	LUT_out[2]  = -37'sd 14450394;
		19 'sd 65534  :	LUT_out[2]  = 37'sd 9633498;
		19 'sd 131069 :	LUT_out[2]  = 37'sd 19267143;
		-19'sd 65535  :	LUT_out[2]  = -37'sd 9633645;
		19 'sd 196604 :	LUT_out[2]  = 37'sd 28900788;
		19 'sd 65535  :	LUT_out[2]  = 37'sd 9633645;
		-19'sd 65534  :	LUT_out[2]  = -37'sd 9633498;
		-19'sd 131069 :	LUT_out[2]  = -37'sd 19267143;
		-19'sd 196604 :	LUT_out[2]  = -37'sd 28900788;
		default     :	LUT_out[2]  = 37'sd 0;
	endcase
end

// LUT_3 

always @ *
begin
	case(sum_level_1[3])
		19 'sd 0      :	LUT_out[3]  = 37'sd 0;
		19 'sd 32767  :	LUT_out[3]  = 37'sd 22019424;
		19 'sd 98302  :	LUT_out[3]  = 37'sd 66058944;
		-19'sd 32767  :	LUT_out[3]  = -37'sd 22019424;
		-19'sd 98302  :	LUT_out[3]  = -37'sd 66058944;
		19 'sd 65534  :	LUT_out[3]  = 37'sd 44038848;
		19 'sd 131069 :	LUT_out[3]  = 37'sd 88078368;
		-19'sd 65535  :	LUT_out[3]  = -37'sd 44039520;
		19 'sd 196604 :	LUT_out[3]  = 37'sd 132117888;
		19 'sd 65535  :	LUT_out[3]  = 37'sd 44039520;
		-19'sd 65534  :	LUT_out[3]  = -37'sd 44038848;
		-19'sd 131069 :	LUT_out[3]  = -37'sd 88078368;
		-19'sd 196604 :	LUT_out[3]  = -37'sd 132117888;
		default     :	LUT_out[3]  = 37'sd 0;
	endcase
end

// LUT_4 

always @ *
begin
	case(sum_level_1[4])
		19 'sd 0      :	LUT_out[4]  = 37'sd 0;
		19 'sd 32767  :	LUT_out[4]  = 37'sd 25885930;
		19 'sd 98302  :	LUT_out[4]  = 37'sd 77658580;
		-19'sd 32767  :	LUT_out[4]  = -37'sd 25885930;
		-19'sd 98302  :	LUT_out[4]  = -37'sd 77658580;
		19 'sd 65534  :	LUT_out[4]  = 37'sd 51771860;
		19 'sd 131069 :	LUT_out[4]  = 37'sd 103544510;
		-19'sd 65535  :	LUT_out[4]  = -37'sd 51772650;
		19 'sd 196604 :	LUT_out[4]  = 37'sd 155317160;
		19 'sd 65535  :	LUT_out[4]  = 37'sd 51772650;
		-19'sd 65534  :	LUT_out[4]  = -37'sd 51771860;
		-19'sd 131069 :	LUT_out[4]  = -37'sd 103544510;
		-19'sd 196604 :	LUT_out[4]  = -37'sd 155317160;
		default     :	LUT_out[4]  = 37'sd 0;
	endcase
end

// LUT_5 

always @ *
begin
	case(sum_level_1[5])
		19 'sd 0      :	LUT_out[5]  = 37'sd 0;
		19 'sd 32767  :	LUT_out[5]  = 37'sd 11599518;
		19 'sd 98302  :	LUT_out[5]  = 37'sd 34798908;
		-19'sd 32767  :	LUT_out[5]  = -37'sd 11599518;
		-19'sd 98302  :	LUT_out[5]  = -37'sd 34798908;
		19 'sd 65534  :	LUT_out[5]  = 37'sd 23199036;
		19 'sd 131069 :	LUT_out[5]  = 37'sd 46398426;
		-19'sd 65535  :	LUT_out[5]  = -37'sd 23199390;
		19 'sd 196604 :	LUT_out[5]  = 37'sd 69597816;
		19 'sd 65535  :	LUT_out[5]  = 37'sd 23199390;
		-19'sd 65534  :	LUT_out[5]  = -37'sd 23199036;
		-19'sd 131069 :	LUT_out[5]  = -37'sd 46398426;
		-19'sd 196604 :	LUT_out[5]  = -37'sd 69597816;
		default     :	LUT_out[5]  = 37'sd 0;
	endcase
end

// LUT_6 

always @ *
begin
	case(sum_level_1[6])
		19 'sd 0      :	LUT_out[6]  = 37'sd 0;
		19 'sd 32767  :	LUT_out[6]  = -37'sd 13237868;
		19 'sd 98302  :	LUT_out[6]  = -37'sd 39714008;
		-19'sd 32767  :	LUT_out[6]  = 37'sd 13237868;
		-19'sd 98302  :	LUT_out[6]  = 37'sd 39714008;
		19 'sd 65534  :	LUT_out[6]  = -37'sd 26475736;
		19 'sd 131069 :	LUT_out[6]  = -37'sd 52951876;
		-19'sd 65535  :	LUT_out[6]  = 37'sd 26476140;
		19 'sd 196604 :	LUT_out[6]  = -37'sd 79428016;
		19 'sd 65535  :	LUT_out[6]  = -37'sd 26476140;
		-19'sd 65534  :	LUT_out[6]  = 37'sd 26475736;
		-19'sd 131069 :	LUT_out[6]  = 37'sd 52951876;
		-19'sd 196604 :	LUT_out[6]  = 37'sd 79428016;
		default     :	LUT_out[6]  = 37'sd 0;
	endcase
end

// LUT_7 

always @ *
begin
	case(sum_level_1[7])
		19 'sd 0      :	LUT_out[7]  = 37'sd 0;
		19 'sd 32767  :	LUT_out[7]  = -37'sd 32504864;
		19 'sd 98302  :	LUT_out[7]  = -37'sd 97515584;
		-19'sd 32767  :	LUT_out[7]  = 37'sd 32504864;
		-19'sd 98302  :	LUT_out[7]  = 37'sd 97515584;
		19 'sd 65534  :	LUT_out[7]  = -37'sd 65009728;
		19 'sd 131069 :	LUT_out[7]  = -37'sd 130020448;
		-19'sd 65535  :	LUT_out[7]  = 37'sd 65010720;
		19 'sd 196604 :	LUT_out[7]  = -37'sd 195031168;
		19 'sd 65535  :	LUT_out[7]  = -37'sd 65010720;
		-19'sd 65534  :	LUT_out[7]  = 37'sd 65009728;
		-19'sd 131069 :	LUT_out[7]  = 37'sd 130020448;
		-19'sd 196604 :	LUT_out[7]  = 37'sd 195031168;
		default     :	LUT_out[7]  = 37'sd 0;
	endcase
end

// LUT_8 

always @ *
begin
	case(sum_level_1[8])
		19 'sd 0      :	LUT_out[8]  = 37'sd 0;
		19 'sd 32767  :	LUT_out[8]  = -37'sd 31751223;
		19 'sd 98302  :	LUT_out[8]  = -37'sd 95254638;
		-19'sd 32767  :	LUT_out[8]  = 37'sd 31751223;
		-19'sd 98302  :	LUT_out[8]  = 37'sd 95254638;
		19 'sd 65534  :	LUT_out[8]  = -37'sd 63502446;
		19 'sd 131069 :	LUT_out[8]  = -37'sd 127005861;
		-19'sd 65535  :	LUT_out[8]  = 37'sd 63503415;
		19 'sd 196604 :	LUT_out[8]  = -37'sd 190509276;
		19 'sd 65535  :	LUT_out[8]  = -37'sd 63503415;
		-19'sd 65534  :	LUT_out[8]  = 37'sd 63502446;
		-19'sd 131069 :	LUT_out[8]  = 37'sd 127005861;
		-19'sd 196604 :	LUT_out[8]  = 37'sd 190509276;
		default     :	LUT_out[8]  = 37'sd 0;
	endcase
end

// LUT_9 

always @ *
begin
	case(sum_level_1[9])
		19 'sd 0      :	LUT_out[9]  = 37'sd 0;
		19 'sd 32767  :	LUT_out[9]  = -37'sd 8486653;
		19 'sd 98302  :	LUT_out[9]  = -37'sd 25460218;
		-19'sd 32767  :	LUT_out[9]  = 37'sd 8486653;
		-19'sd 98302  :	LUT_out[9]  = 37'sd 25460218;
		19 'sd 65534  :	LUT_out[9]  = -37'sd 16973306;
		19 'sd 131069 :	LUT_out[9]  = -37'sd 33946871;
		-19'sd 65535  :	LUT_out[9]  = 37'sd 16973565;
		19 'sd 196604 :	LUT_out[9]  = -37'sd 50920436;
		19 'sd 65535  :	LUT_out[9]  = -37'sd 16973565;
		-19'sd 65534  :	LUT_out[9]  = 37'sd 16973306;
		-19'sd 131069 :	LUT_out[9]  = 37'sd 33946871;
		-19'sd 196604 :	LUT_out[9]  = 37'sd 50920436;
		default     :	LUT_out[9]  = 37'sd 0;
	endcase
end

// LUT_10 

always @ *
begin
	case(sum_level_1[10])
		19 'sd 0      :	LUT_out[10] = 37'sd 0;
		19 'sd 32767  :	LUT_out[10] = 37'sd 24247580;
		19 'sd 98302  :	LUT_out[10] = 37'sd 72743480;
		-19'sd 32767  :	LUT_out[10] = -37'sd 24247580;
		-19'sd 98302  :	LUT_out[10] = -37'sd 72743480;
		19 'sd 65534  :	LUT_out[10] = 37'sd 48495160;
		19 'sd 131069 :	LUT_out[10] = 37'sd 96991060;
		-19'sd 65535  :	LUT_out[10] = -37'sd 48495900;
		19 'sd 196604 :	LUT_out[10] = 37'sd 145486960;
		19 'sd 65535  :	LUT_out[10] = 37'sd 48495900;
		-19'sd 65534  :	LUT_out[10] = -37'sd 48495160;
		-19'sd 131069 :	LUT_out[10] = -37'sd 96991060;
		-19'sd 196604 :	LUT_out[10] = -37'sd 145486960;
		default     :	LUT_out[10] = 37'sd 0;
	endcase
end

// LUT_11 

always @ *
begin
	case(sum_level_1[11])
		19 'sd 0      :	LUT_out[11] = 37'sd 0;
		19 'sd 32767  :	LUT_out[11] = 37'sd 45054625;
		19 'sd 98302  :	LUT_out[11] = 37'sd 135165250;
		-19'sd 32767  :	LUT_out[11] = -37'sd 45054625;
		-19'sd 98302  :	LUT_out[11] = -37'sd 135165250;
		19 'sd 65534  :	LUT_out[11] = 37'sd 90109250;
		19 'sd 131069 :	LUT_out[11] = 37'sd 180219875;
		-19'sd 65535  :	LUT_out[11] = -37'sd 90110625;
		19 'sd 196604 :	LUT_out[11] = 37'sd 270330500;
		19 'sd 65535  :	LUT_out[11] = 37'sd 90110625;
		-19'sd 65534  :	LUT_out[11] = -37'sd 90109250;
		-19'sd 131069 :	LUT_out[11] = -37'sd 180219875;
		-19'sd 196604 :	LUT_out[11] = -37'sd 270330500;
		default     :	LUT_out[11] = 37'sd 0;
	endcase
end

// LUT_12 

always @ *
begin
	case(sum_level_1[12])
		19 'sd 0      :	LUT_out[12] = 37'sd 0;
		19 'sd 32767  :	LUT_out[12] = 37'sd 37780351;
		19 'sd 98302  :	LUT_out[12] = 37'sd 113342206;
		-19'sd 32767  :	LUT_out[12] = -37'sd 37780351;
		-19'sd 98302  :	LUT_out[12] = -37'sd 113342206;
		19 'sd 65534  :	LUT_out[12] = 37'sd 75560702;
		19 'sd 131069 :	LUT_out[12] = 37'sd 151122557;
		-19'sd 65535  :	LUT_out[12] = -37'sd 75561855;
		19 'sd 196604 :	LUT_out[12] = 37'sd 226684412;
		19 'sd 65535  :	LUT_out[12] = 37'sd 75561855;
		-19'sd 65534  :	LUT_out[12] = -37'sd 75560702;
		-19'sd 131069 :	LUT_out[12] = -37'sd 151122557;
		-19'sd 196604 :	LUT_out[12] = -37'sd 226684412;
		default     :	LUT_out[12] = 37'sd 0;
	endcase
end

// LUT_13 

always @ *
begin
	case(sum_level_1[13])
		19 'sd 0      :	LUT_out[13] = 37'sd 0;
		19 'sd 32767  :	LUT_out[13] = 37'sd 3407768;
		19 'sd 98302  :	LUT_out[13] = 37'sd 10223408;
		-19'sd 32767  :	LUT_out[13] = -37'sd 3407768;
		-19'sd 98302  :	LUT_out[13] = -37'sd 10223408;
		19 'sd 65534  :	LUT_out[13] = 37'sd 6815536;
		19 'sd 131069 :	LUT_out[13] = 37'sd 13631176;
		-19'sd 65535  :	LUT_out[13] = -37'sd 6815640;
		19 'sd 196604 :	LUT_out[13] = 37'sd 20446816;
		19 'sd 65535  :	LUT_out[13] = 37'sd 6815640;
		-19'sd 65534  :	LUT_out[13] = -37'sd 6815536;
		-19'sd 131069 :	LUT_out[13] = -37'sd 13631176;
		-19'sd 196604 :	LUT_out[13] = -37'sd 20446816;
		default     :	LUT_out[13] = 37'sd 0;
	endcase
end

// LUT_14 

always @ *
begin
	case(sum_level_1[14])
		19 'sd 0      :	LUT_out[14] = 37'sd 0;
		19 'sd 32767  :	LUT_out[14] = -37'sd 38337390;
		19 'sd 98302  :	LUT_out[14] = -37'sd 115013340;
		-19'sd 32767  :	LUT_out[14] = 37'sd 38337390;
		-19'sd 98302  :	LUT_out[14] = 37'sd 115013340;
		19 'sd 65534  :	LUT_out[14] = -37'sd 76674780;
		19 'sd 131069 :	LUT_out[14] = -37'sd 153350730;
		-19'sd 65535  :	LUT_out[14] = 37'sd 76675950;
		19 'sd 196604 :	LUT_out[14] = -37'sd 230026680;
		19 'sd 65535  :	LUT_out[14] = -37'sd 76675950;
		-19'sd 65534  :	LUT_out[14] = 37'sd 76674780;
		-19'sd 131069 :	LUT_out[14] = 37'sd 153350730;
		-19'sd 196604 :	LUT_out[14] = 37'sd 230026680;
		default     :	LUT_out[14] = 37'sd 0;
	endcase
end

// LUT_15 

always @ *
begin
	case(sum_level_1[15])
		19 'sd 0      :	LUT_out[15] = 37'sd 0;
		19 'sd 32767  :	LUT_out[15] = -37'sd 59898076;
		19 'sd 98302  :	LUT_out[15] = -37'sd 179696056;
		-19'sd 32767  :	LUT_out[15] = 37'sd 59898076;
		-19'sd 98302  :	LUT_out[15] = 37'sd 179696056;
		19 'sd 65534  :	LUT_out[15] = -37'sd 119796152;
		19 'sd 131069 :	LUT_out[15] = -37'sd 239594132;
		-19'sd 65535  :	LUT_out[15] = 37'sd 119797980;
		19 'sd 196604 :	LUT_out[15] = -37'sd 359392112;
		19 'sd 65535  :	LUT_out[15] = -37'sd 119797980;
		-19'sd 65534  :	LUT_out[15] = 37'sd 119796152;
		-19'sd 131069 :	LUT_out[15] = 37'sd 239594132;
		-19'sd 196604 :	LUT_out[15] = 37'sd 359392112;
		default     :	LUT_out[15] = 37'sd 0;
	endcase
end

// LUT_16 

always @ *
begin
	case(sum_level_1[16])
		19 'sd 0      :	LUT_out[16] = 37'sd 0;
		19 'sd 32767  :	LUT_out[16] = -37'sd 43809479;
		19 'sd 98302  :	LUT_out[16] = -37'sd 131429774;
		-19'sd 32767  :	LUT_out[16] = 37'sd 43809479;
		-19'sd 98302  :	LUT_out[16] = 37'sd 131429774;
		19 'sd 65534  :	LUT_out[16] = -37'sd 87618958;
		19 'sd 131069 :	LUT_out[16] = -37'sd 175239253;
		-19'sd 65535  :	LUT_out[16] = 37'sd 87620295;
		19 'sd 196604 :	LUT_out[16] = -37'sd 262859548;
		19 'sd 65535  :	LUT_out[16] = -37'sd 87620295;
		-19'sd 65534  :	LUT_out[16] = 37'sd 87618958;
		-19'sd 131069 :	LUT_out[16] = 37'sd 175239253;
		-19'sd 196604 :	LUT_out[16] = 37'sd 262859548;
		default     :	LUT_out[16] = 37'sd 0;
	endcase
end

// LUT_17 

always @ *
begin
	case(sum_level_1[17])
		19 'sd 0      :	LUT_out[17] = 37'sd 0;
		19 'sd 32767  :	LUT_out[17] = 37'sd 4259710;
		19 'sd 98302  :	LUT_out[17] = 37'sd 12779260;
		-19'sd 32767  :	LUT_out[17] = -37'sd 4259710;
		-19'sd 98302  :	LUT_out[17] = -37'sd 12779260;
		19 'sd 65534  :	LUT_out[17] = 37'sd 8519420;
		19 'sd 131069 :	LUT_out[17] = 37'sd 17038970;
		-19'sd 65535  :	LUT_out[17] = -37'sd 8519550;
		19 'sd 196604 :	LUT_out[17] = 37'sd 25558520;
		19 'sd 65535  :	LUT_out[17] = 37'sd 8519550;
		-19'sd 65534  :	LUT_out[17] = -37'sd 8519420;
		-19'sd 131069 :	LUT_out[17] = -37'sd 17038970;
		-19'sd 196604 :	LUT_out[17] = -37'sd 25558520;
		default     :	LUT_out[17] = 37'sd 0;
	endcase
end

// LUT_18 

always @ *
begin
	case(sum_level_1[18])
		19 'sd 0      :	LUT_out[18] = 37'sd 0;
		19 'sd 32767  :	LUT_out[18] = 37'sd 56228172;
		19 'sd 98302  :	LUT_out[18] = 37'sd 168686232;
		-19'sd 32767  :	LUT_out[18] = -37'sd 56228172;
		-19'sd 98302  :	LUT_out[18] = -37'sd 168686232;
		19 'sd 65534  :	LUT_out[18] = 37'sd 112456344;
		19 'sd 131069 :	LUT_out[18] = 37'sd 224914404;
		-19'sd 65535  :	LUT_out[18] = -37'sd 112458060;
		19 'sd 196604 :	LUT_out[18] = 37'sd 337372464;
		19 'sd 65535  :	LUT_out[18] = 37'sd 112458060;
		-19'sd 65534  :	LUT_out[18] = -37'sd 112456344;
		-19'sd 131069 :	LUT_out[18] = -37'sd 224914404;
		-19'sd 196604 :	LUT_out[18] = -37'sd 337372464;
		default     :	LUT_out[18] = 37'sd 0;
	endcase
end

// LUT_19 

always @ *
begin
	case(sum_level_1[19])
		19 'sd 0      :	LUT_out[19] = 37'sd 0;
		19 'sd 32767  :	LUT_out[19] = 37'sd 77526722;
		19 'sd 98302  :	LUT_out[19] = 37'sd 232582532;
		-19'sd 32767  :	LUT_out[19] = -37'sd 77526722;
		-19'sd 98302  :	LUT_out[19] = -37'sd 232582532;
		19 'sd 65534  :	LUT_out[19] = 37'sd 155053444;
		19 'sd 131069 :	LUT_out[19] = 37'sd 310109254;
		-19'sd 65535  :	LUT_out[19] = -37'sd 155055810;
		19 'sd 196604 :	LUT_out[19] = 37'sd 465165064;
		19 'sd 65535  :	LUT_out[19] = 37'sd 155055810;
		-19'sd 65534  :	LUT_out[19] = -37'sd 155053444;
		-19'sd 131069 :	LUT_out[19] = -37'sd 310109254;
		-19'sd 196604 :	LUT_out[19] = -37'sd 465165064;
		default     :	LUT_out[19] = 37'sd 0;
	endcase
end

// LUT_20 

always @ *
begin
	case(sum_level_1[20])
		19 'sd 0      :	LUT_out[20] = 37'sd 0;
		19 'sd 32767  :	LUT_out[20] = 37'sd 49740306;
		19 'sd 98302  :	LUT_out[20] = 37'sd 149222436;
		-19'sd 32767  :	LUT_out[20] = -37'sd 49740306;
		-19'sd 98302  :	LUT_out[20] = -37'sd 149222436;
		19 'sd 65534  :	LUT_out[20] = 37'sd 99480612;
		19 'sd 131069 :	LUT_out[20] = 37'sd 198962742;
		-19'sd 65535  :	LUT_out[20] = -37'sd 99482130;
		19 'sd 196604 :	LUT_out[20] = 37'sd 298444872;
		19 'sd 65535  :	LUT_out[20] = 37'sd 99482130;
		-19'sd 65534  :	LUT_out[20] = -37'sd 99480612;
		-19'sd 131069 :	LUT_out[20] = -37'sd 198962742;
		-19'sd 196604 :	LUT_out[20] = -37'sd 298444872;
		default     :	LUT_out[20] = 37'sd 0;
	endcase
end

// LUT_21 

always @ *
begin
	case(sum_level_1[21])
		19 'sd 0      :	LUT_out[21] = 37'sd 0;
		19 'sd 32767  :	LUT_out[21] = -37'sd 15236655;
		19 'sd 98302  :	LUT_out[21] = -37'sd 45710430;
		-19'sd 32767  :	LUT_out[21] = 37'sd 15236655;
		-19'sd 98302  :	LUT_out[21] = 37'sd 45710430;
		19 'sd 65534  :	LUT_out[21] = -37'sd 30473310;
		19 'sd 131069 :	LUT_out[21] = -37'sd 60947085;
		-19'sd 65535  :	LUT_out[21] = 37'sd 30473775;
		19 'sd 196604 :	LUT_out[21] = -37'sd 91420860;
		19 'sd 65535  :	LUT_out[21] = -37'sd 30473775;
		-19'sd 65534  :	LUT_out[21] = 37'sd 30473310;
		-19'sd 131069 :	LUT_out[21] = 37'sd 60947085;
		-19'sd 196604 :	LUT_out[21] = 37'sd 91420860;
		default     :	LUT_out[21] = 37'sd 0;
	endcase
end

// LUT_22 

always @ *
begin
	case(sum_level_1[22])
		19 'sd 0      :	LUT_out[22] = 37'sd 0;
		19 'sd 32767  :	LUT_out[22] = -37'sd 78935703;
		19 'sd 98302  :	LUT_out[22] = -37'sd 236809518;
		-19'sd 32767  :	LUT_out[22] = 37'sd 78935703;
		-19'sd 98302  :	LUT_out[22] = 37'sd 236809518;
		19 'sd 65534  :	LUT_out[22] = -37'sd 157871406;
		19 'sd 131069 :	LUT_out[22] = -37'sd 315745221;
		-19'sd 65535  :	LUT_out[22] = 37'sd 157873815;
		19 'sd 196604 :	LUT_out[22] = -37'sd 473619036;
		19 'sd 65535  :	LUT_out[22] = -37'sd 157873815;
		-19'sd 65534  :	LUT_out[22] = 37'sd 157871406;
		-19'sd 131069 :	LUT_out[22] = 37'sd 315745221;
		-19'sd 196604 :	LUT_out[22] = 37'sd 473619036;
		default     :	LUT_out[22] = 37'sd 0;
	endcase
end

// LUT_23 

always @ *
begin
	case(sum_level_1[23])
		19 'sd 0      :	LUT_out[23] = 37'sd 0;
		19 'sd 32767  :	LUT_out[23] = -37'sd 98661437;
		19 'sd 98302  :	LUT_out[23] = -37'sd 295987322;
		-19'sd 32767  :	LUT_out[23] = 37'sd 98661437;
		-19'sd 98302  :	LUT_out[23] = 37'sd 295987322;
		19 'sd 65534  :	LUT_out[23] = -37'sd 197322874;
		19 'sd 131069 :	LUT_out[23] = -37'sd 394648759;
		-19'sd 65535  :	LUT_out[23] = 37'sd 197325885;
		19 'sd 196604 :	LUT_out[23] = -37'sd 591974644;
		19 'sd 65535  :	LUT_out[23] = -37'sd 197325885;
		-19'sd 65534  :	LUT_out[23] = 37'sd 197322874;
		-19'sd 131069 :	LUT_out[23] = 37'sd 394648759;
		-19'sd 196604 :	LUT_out[23] = 37'sd 591974644;
		default     :	LUT_out[23] = 37'sd 0;
	endcase
end

// LUT_24 

always @ *
begin
	case(sum_level_1[24])
		19 'sd 0      :	LUT_out[24] = 37'sd 0;
		19 'sd 32767  :	LUT_out[24] = -37'sd 55376230;
		19 'sd 98302  :	LUT_out[24] = -37'sd 166130380;
		-19'sd 32767  :	LUT_out[24] = 37'sd 55376230;
		-19'sd 98302  :	LUT_out[24] = 37'sd 166130380;
		19 'sd 65534  :	LUT_out[24] = -37'sd 110752460;
		19 'sd 131069 :	LUT_out[24] = -37'sd 221506610;
		-19'sd 65535  :	LUT_out[24] = 37'sd 110754150;
		19 'sd 196604 :	LUT_out[24] = -37'sd 332260760;
		19 'sd 65535  :	LUT_out[24] = -37'sd 110754150;
		-19'sd 65534  :	LUT_out[24] = 37'sd 110752460;
		-19'sd 131069 :	LUT_out[24] = 37'sd 221506610;
		-19'sd 196604 :	LUT_out[24] = 37'sd 332260760;
		default     :	LUT_out[24] = 37'sd 0;
	endcase
end

// LUT_25 

always @ *
begin
	case(sum_level_1[25])
		19 'sd 0      :	LUT_out[25] = 37'sd 0;
		19 'sd 32767  :	LUT_out[25] = 37'sd 30669912;
		19 'sd 98302  :	LUT_out[25] = 37'sd 92010672;
		-19'sd 32767  :	LUT_out[25] = -37'sd 30669912;
		-19'sd 98302  :	LUT_out[25] = -37'sd 92010672;
		19 'sd 65534  :	LUT_out[25] = 37'sd 61339824;
		19 'sd 131069 :	LUT_out[25] = 37'sd 122680584;
		-19'sd 65535  :	LUT_out[25] = -37'sd 61340760;
		19 'sd 196604 :	LUT_out[25] = 37'sd 184021344;
		19 'sd 65535  :	LUT_out[25] = 37'sd 61340760;
		-19'sd 65534  :	LUT_out[25] = -37'sd 61339824;
		-19'sd 131069 :	LUT_out[25] = -37'sd 122680584;
		-19'sd 196604 :	LUT_out[25] = -37'sd 184021344;
		default     :	LUT_out[25] = 37'sd 0;
	endcase
end

// LUT_26 

always @ *
begin
	case(sum_level_1[26])
		19 'sd 0      :	LUT_out[26] = 37'sd 0;
		19 'sd 32767  :	LUT_out[26] = 37'sd 108131100;
		19 'sd 98302  :	LUT_out[26] = 37'sd 324396600;
		-19'sd 32767  :	LUT_out[26] = -37'sd 108131100;
		-19'sd 98302  :	LUT_out[26] = -37'sd 324396600;
		19 'sd 65534  :	LUT_out[26] = 37'sd 216262200;
		19 'sd 131069 :	LUT_out[26] = 37'sd 432527700;
		-19'sd 65535  :	LUT_out[26] = -37'sd 216265500;
		19 'sd 196604 :	LUT_out[26] = 37'sd 648793200;
		19 'sd 65535  :	LUT_out[26] = 37'sd 216265500;
		-19'sd 65534  :	LUT_out[26] = -37'sd 216262200;
		-19'sd 131069 :	LUT_out[26] = -37'sd 432527700;
		-19'sd 196604 :	LUT_out[26] = -37'sd 648793200;
		default     :	LUT_out[26] = 37'sd 0;
	endcase
end

// LUT_27 

always @ *
begin
	case(sum_level_1[27])
		19 'sd 0      :	LUT_out[27] = 37'sd 0;
		19 'sd 32767  :	LUT_out[27] = 37'sd 124514600;
		19 'sd 98302  :	LUT_out[27] = 37'sd 373547600;
		-19'sd 32767  :	LUT_out[27] = -37'sd 124514600;
		-19'sd 98302  :	LUT_out[27] = -37'sd 373547600;
		19 'sd 65534  :	LUT_out[27] = 37'sd 249029200;
		19 'sd 131069 :	LUT_out[27] = 37'sd 498062200;
		-19'sd 65535  :	LUT_out[27] = -37'sd 249033000;
		19 'sd 196604 :	LUT_out[27] = 37'sd 747095200;
		19 'sd 65535  :	LUT_out[27] = 37'sd 249033000;
		-19'sd 65534  :	LUT_out[27] = -37'sd 249029200;
		-19'sd 131069 :	LUT_out[27] = -37'sd 498062200;
		-19'sd 196604 :	LUT_out[27] = -37'sd 747095200;
		default     :	LUT_out[27] = 37'sd 0;
	endcase
end

// LUT_28 

always @ *
begin
	case(sum_level_1[28])
		19 'sd 0      :	LUT_out[28] = 37'sd 0;
		19 'sd 32767  :	LUT_out[28] = 37'sd 60618950;
		19 'sd 98302  :	LUT_out[28] = 37'sd 181858700;
		-19'sd 32767  :	LUT_out[28] = -37'sd 60618950;
		-19'sd 98302  :	LUT_out[28] = -37'sd 181858700;
		19 'sd 65534  :	LUT_out[28] = 37'sd 121237900;
		19 'sd 131069 :	LUT_out[28] = 37'sd 242477650;
		-19'sd 65535  :	LUT_out[28] = -37'sd 121239750;
		19 'sd 196604 :	LUT_out[28] = 37'sd 363717400;
		19 'sd 65535  :	LUT_out[28] = 37'sd 121239750;
		-19'sd 65534  :	LUT_out[28] = -37'sd 121237900;
		-19'sd 131069 :	LUT_out[28] = -37'sd 242477650;
		-19'sd 196604 :	LUT_out[28] = -37'sd 363717400;
		default     :	LUT_out[28] = 37'sd 0;
	endcase
end

// LUT_29 

always @ *
begin
	case(sum_level_1[29])
		19 'sd 0      :	LUT_out[29] = 37'sd 0;
		19 'sd 32767  :	LUT_out[29] = -37'sd 52361666;
		19 'sd 98302  :	LUT_out[29] = -37'sd 157086596;
		-19'sd 32767  :	LUT_out[29] = 37'sd 52361666;
		-19'sd 98302  :	LUT_out[29] = 37'sd 157086596;
		19 'sd 65534  :	LUT_out[29] = -37'sd 104723332;
		19 'sd 131069 :	LUT_out[29] = -37'sd 209448262;
		-19'sd 65535  :	LUT_out[29] = 37'sd 104724930;
		19 'sd 196604 :	LUT_out[29] = -37'sd 314173192;
		19 'sd 65535  :	LUT_out[29] = -37'sd 104724930;
		-19'sd 65534  :	LUT_out[29] = 37'sd 104723332;
		-19'sd 131069 :	LUT_out[29] = 37'sd 209448262;
		-19'sd 196604 :	LUT_out[29] = 37'sd 314173192;
		default     :	LUT_out[29] = 37'sd 0;
	endcase
end

// LUT_30 

always @ *
begin
	case(sum_level_1[30])
		19 'sd 0      :	LUT_out[30] = 37'sd 0;
		19 'sd 32767  :	LUT_out[30] = -37'sd 146632325;
		19 'sd 98302  :	LUT_out[30] = -37'sd 439901450;
		-19'sd 32767  :	LUT_out[30] = 37'sd 146632325;
		-19'sd 98302  :	LUT_out[30] = 37'sd 439901450;
		19 'sd 65534  :	LUT_out[30] = -37'sd 293264650;
		19 'sd 131069 :	LUT_out[30] = -37'sd 586533775;
		-19'sd 65535  :	LUT_out[30] = 37'sd 293269125;
		19 'sd 196604 :	LUT_out[30] = -37'sd 879802900;
		19 'sd 65535  :	LUT_out[30] = -37'sd 293269125;
		-19'sd 65534  :	LUT_out[30] = 37'sd 293264650;
		-19'sd 131069 :	LUT_out[30] = 37'sd 586533775;
		-19'sd 196604 :	LUT_out[30] = 37'sd 879802900;
		default     :	LUT_out[30] = 37'sd 0;
	endcase
end

// LUT_31 

always @ *
begin
	case(sum_level_1[31])
		19 'sd 0      :	LUT_out[31] = 37'sd 0;
		19 'sd 32767  :	LUT_out[31] = -37'sd 157314367;
		19 'sd 98302  :	LUT_out[31] = -37'sd 471947902;
		-19'sd 32767  :	LUT_out[31] = 37'sd 157314367;
		-19'sd 98302  :	LUT_out[31] = 37'sd 471947902;
		19 'sd 65534  :	LUT_out[31] = -37'sd 314628734;
		19 'sd 131069 :	LUT_out[31] = -37'sd 629262269;
		-19'sd 65535  :	LUT_out[31] = 37'sd 314633535;
		19 'sd 196604 :	LUT_out[31] = -37'sd 943895804;
		19 'sd 65535  :	LUT_out[31] = -37'sd 314633535;
		-19'sd 65534  :	LUT_out[31] = 37'sd 314628734;
		-19'sd 131069 :	LUT_out[31] = 37'sd 629262269;
		-19'sd 196604 :	LUT_out[31] = 37'sd 943895804;
		default     :	LUT_out[31] = 37'sd 0;
	endcase
end

// LUT_32 

always @ *
begin
	case(sum_level_1[32])
		19 'sd 0      :	LUT_out[32] = 37'sd 0;
		19 'sd 32767  :	LUT_out[32] = -37'sd 65304631;
		19 'sd 98302  :	LUT_out[32] = -37'sd 195915886;
		-19'sd 32767  :	LUT_out[32] = 37'sd 65304631;
		-19'sd 98302  :	LUT_out[32] = 37'sd 195915886;
		19 'sd 65534  :	LUT_out[32] = -37'sd 130609262;
		19 'sd 131069 :	LUT_out[32] = -37'sd 261220517;
		-19'sd 65535  :	LUT_out[32] = 37'sd 130611255;
		19 'sd 196604 :	LUT_out[32] = -37'sd 391831772;
		19 'sd 65535  :	LUT_out[32] = -37'sd 130611255;
		-19'sd 65534  :	LUT_out[32] = 37'sd 130609262;
		-19'sd 131069 :	LUT_out[32] = 37'sd 261220517;
		-19'sd 196604 :	LUT_out[32] = 37'sd 391831772;
		default     :	LUT_out[32] = 37'sd 0;
	endcase
end

// LUT_33 

always @ *
begin
	case(sum_level_1[33])
		19 'sd 0      :	LUT_out[33] = 37'sd 0;
		19 'sd 32767  :	LUT_out[33] = 37'sd 83654151;
		19 'sd 98302  :	LUT_out[33] = 37'sd 250965006;
		-19'sd 32767  :	LUT_out[33] = -37'sd 83654151;
		-19'sd 98302  :	LUT_out[33] = -37'sd 250965006;
		19 'sd 65534  :	LUT_out[33] = 37'sd 167308302;
		19 'sd 131069 :	LUT_out[33] = 37'sd 334619157;
		-19'sd 65535  :	LUT_out[33] = -37'sd 167310855;
		19 'sd 196604 :	LUT_out[33] = 37'sd 501930012;
		19 'sd 65535  :	LUT_out[33] = 37'sd 167310855;
		-19'sd 65534  :	LUT_out[33] = -37'sd 167308302;
		-19'sd 131069 :	LUT_out[33] = -37'sd 334619157;
		-19'sd 196604 :	LUT_out[33] = -37'sd 501930012;
		default     :	LUT_out[33] = 37'sd 0;
	endcase
end

// LUT_34 

always @ *
begin
	case(sum_level_1[34])
		19 'sd 0      :	LUT_out[34] = 37'sd 0;
		19 'sd 32767  :	LUT_out[34] = 37'sd 199845933;
		19 'sd 98302  :	LUT_out[34] = 37'sd 599543898;
		-19'sd 32767  :	LUT_out[34] = -37'sd 199845933;
		-19'sd 98302  :	LUT_out[34] = -37'sd 599543898;
		19 'sd 65534  :	LUT_out[34] = 37'sd 399691866;
		19 'sd 131069 :	LUT_out[34] = 37'sd 799389831;
		-19'sd 65535  :	LUT_out[34] = -37'sd 399697965;
		19 'sd 196604 :	LUT_out[34] = 37'sd 1199087796;
		19 'sd 65535  :	LUT_out[34] = 37'sd 399697965;
		-19'sd 65534  :	LUT_out[34] = -37'sd 399691866;
		-19'sd 131069 :	LUT_out[34] = -37'sd 799389831;
		-19'sd 196604 :	LUT_out[34] = -37'sd 1199087796;
		default     :	LUT_out[34] = 37'sd 0;
	endcase
end

// LUT_35 

always @ *
begin
	case(sum_level_1[35])
		19 'sd 0      :	LUT_out[35] = 37'sd 0;
		19 'sd 32767  :	LUT_out[35] = 37'sd 201517050;
		19 'sd 98302  :	LUT_out[35] = 37'sd 604557300;
		-19'sd 32767  :	LUT_out[35] = -37'sd 201517050;
		-19'sd 98302  :	LUT_out[35] = -37'sd 604557300;
		19 'sd 65534  :	LUT_out[35] = 37'sd 403034100;
		19 'sd 131069 :	LUT_out[35] = 37'sd 806074350;
		-19'sd 65535  :	LUT_out[35] = -37'sd 403040250;
		19 'sd 196604 :	LUT_out[35] = 37'sd 1209114600;
		19 'sd 65535  :	LUT_out[35] = 37'sd 403040250;
		-19'sd 65534  :	LUT_out[35] = -37'sd 403034100;
		-19'sd 131069 :	LUT_out[35] = -37'sd 806074350;
		-19'sd 196604 :	LUT_out[35] = -37'sd 1209114600;
		default     :	LUT_out[35] = 37'sd 0;
	endcase
end

// LUT_36 

always @ *
begin
	case(sum_level_1[36])
		19 'sd 0      :	LUT_out[36] = 37'sd 0;
		19 'sd 32767  :	LUT_out[36] = 37'sd 69334972;
		19 'sd 98302  :	LUT_out[36] = 37'sd 208007032;
		-19'sd 32767  :	LUT_out[36] = -37'sd 69334972;
		-19'sd 98302  :	LUT_out[36] = -37'sd 208007032;
		19 'sd 65534  :	LUT_out[36] = 37'sd 138669944;
		19 'sd 131069 :	LUT_out[36] = 37'sd 277342004;
		-19'sd 65535  :	LUT_out[36] = -37'sd 138672060;
		19 'sd 196604 :	LUT_out[36] = 37'sd 416014064;
		19 'sd 65535  :	LUT_out[36] = 37'sd 138672060;
		-19'sd 65534  :	LUT_out[36] = -37'sd 138669944;
		-19'sd 131069 :	LUT_out[36] = -37'sd 277342004;
		-19'sd 196604 :	LUT_out[36] = -37'sd 416014064;
		default     :	LUT_out[36] = 37'sd 0;
	endcase
end

// LUT_37 

always @ *
begin
	case(sum_level_1[37])
		19 'sd 0      :	LUT_out[37] = 37'sd 0;
		19 'sd 32767  :	LUT_out[37] = -37'sd 131330136;
		19 'sd 98302  :	LUT_out[37] = -37'sd 393994416;
		-19'sd 32767  :	LUT_out[37] = 37'sd 131330136;
		-19'sd 98302  :	LUT_out[37] = 37'sd 393994416;
		19 'sd 65534  :	LUT_out[37] = -37'sd 262660272;
		19 'sd 131069 :	LUT_out[37] = -37'sd 525324552;
		-19'sd 65535  :	LUT_out[37] = 37'sd 262664280;
		19 'sd 196604 :	LUT_out[37] = -37'sd 787988832;
		19 'sd 65535  :	LUT_out[37] = -37'sd 262664280;
		-19'sd 65534  :	LUT_out[37] = 37'sd 262660272;
		-19'sd 131069 :	LUT_out[37] = 37'sd 525324552;
		-19'sd 196604 :	LUT_out[37] = 37'sd 787988832;
		default     :	LUT_out[37] = 37'sd 0;
	endcase
end

// LUT_38 

always @ *
begin
	case(sum_level_1[38])
		19 'sd 0      :	LUT_out[38] = 37'sd 0;
		19 'sd 32767  :	LUT_out[38] = -37'sd 279436976;
		19 'sd 98302  :	LUT_out[38] = -37'sd 838319456;
		-19'sd 32767  :	LUT_out[38] = 37'sd 279436976;
		-19'sd 98302  :	LUT_out[38] = 37'sd 838319456;
		19 'sd 65534  :	LUT_out[38] = -37'sd 558873952;
		19 'sd 131069 :	LUT_out[38] = -37'sd 1117756432;
		-19'sd 65535  :	LUT_out[38] = 37'sd 558882480;
		19 'sd 196604 :	LUT_out[38] = -37'sd 1676638912;
		19 'sd 65535  :	LUT_out[38] = -37'sd 558882480;
		-19'sd 65534  :	LUT_out[38] = 37'sd 558873952;
		-19'sd 131069 :	LUT_out[38] = 37'sd 1117756432;
		-19'sd 196604 :	LUT_out[38] = 37'sd 1676638912;
		default     :	LUT_out[38] = 37'sd 0;
	endcase
end

// LUT_39 

always @ *
begin
	case(sum_level_1[39])
		19 'sd 0      :	LUT_out[39] = 37'sd 0;
		19 'sd 32767  :	LUT_out[39] = -37'sd 267345953;
		19 'sd 98302  :	LUT_out[39] = -37'sd 802046018;
		-19'sd 32767  :	LUT_out[39] = 37'sd 267345953;
		-19'sd 98302  :	LUT_out[39] = 37'sd 802046018;
		19 'sd 65534  :	LUT_out[39] = -37'sd 534691906;
		19 'sd 131069 :	LUT_out[39] = -37'sd 1069391971;
		-19'sd 65535  :	LUT_out[39] = 37'sd 534700065;
		19 'sd 196604 :	LUT_out[39] = -37'sd 1604092036;
		19 'sd 65535  :	LUT_out[39] = -37'sd 534700065;
		-19'sd 65534  :	LUT_out[39] = 37'sd 534691906;
		-19'sd 131069 :	LUT_out[39] = 37'sd 1069391971;
		-19'sd 196604 :	LUT_out[39] = 37'sd 1604092036;
		default     :	LUT_out[39] = 37'sd 0;
	endcase
end

// LUT_40 

always @ *
begin
	case(sum_level_1[40])
		19 'sd 0      :	LUT_out[40] = 37'sd 0;
		19 'sd 32767  :	LUT_out[40] = -37'sd 72611672;
		19 'sd 98302  :	LUT_out[40] = -37'sd 217837232;
		-19'sd 32767  :	LUT_out[40] = 37'sd 72611672;
		-19'sd 98302  :	LUT_out[40] = 37'sd 217837232;
		19 'sd 65534  :	LUT_out[40] = -37'sd 145223344;
		19 'sd 131069 :	LUT_out[40] = -37'sd 290448904;
		-19'sd 65535  :	LUT_out[40] = 37'sd 145225560;
		19 'sd 196604 :	LUT_out[40] = -37'sd 435674464;
		19 'sd 65535  :	LUT_out[40] = -37'sd 145225560;
		-19'sd 65534  :	LUT_out[40] = 37'sd 145223344;
		-19'sd 131069 :	LUT_out[40] = 37'sd 290448904;
		-19'sd 196604 :	LUT_out[40] = 37'sd 435674464;
		default     :	LUT_out[40] = 37'sd 0;
	endcase
end

// LUT_41 

always @ *
begin
	case(sum_level_1[41])
		19 'sd 0      :	LUT_out[41] = 37'sd 0;
		19 'sd 32767  :	LUT_out[41] = 37'sd 212002490;
		19 'sd 98302  :	LUT_out[41] = 37'sd 636013940;
		-19'sd 32767  :	LUT_out[41] = -37'sd 212002490;
		-19'sd 98302  :	LUT_out[41] = -37'sd 636013940;
		19 'sd 65534  :	LUT_out[41] = 37'sd 424004980;
		19 'sd 131069 :	LUT_out[41] = 37'sd 848016430;
		-19'sd 65535  :	LUT_out[41] = -37'sd 424011450;
		19 'sd 196604 :	LUT_out[41] = 37'sd 1272027880;
		19 'sd 65535  :	LUT_out[41] = 37'sd 424011450;
		-19'sd 65534  :	LUT_out[41] = -37'sd 424004980;
		-19'sd 131069 :	LUT_out[41] = -37'sd 848016430;
		-19'sd 196604 :	LUT_out[41] = -37'sd 1272027880;
		default     :	LUT_out[41] = 37'sd 0;
	endcase
end

// LUT_42 

always @ *
begin
	case(sum_level_1[42])
		19 'sd 0      :	LUT_out[42] = 37'sd 0;
		19 'sd 32767  :	LUT_out[42] = 37'sd 415911531;
		19 'sd 98302  :	LUT_out[42] = 37'sd 1247747286;
		-19'sd 32767  :	LUT_out[42] = -37'sd 415911531;
		-19'sd 98302  :	LUT_out[42] = -37'sd 1247747286;
		19 'sd 65534  :	LUT_out[42] = 37'sd 831823062;
		19 'sd 131069 :	LUT_out[42] = 37'sd 1663658817;
		-19'sd 65535  :	LUT_out[42] = -37'sd 831835755;
		19 'sd 196604 :	LUT_out[42] = 37'sd 2495494572;
		19 'sd 65535  :	LUT_out[42] = 37'sd 831835755;
		-19'sd 65534  :	LUT_out[42] = -37'sd 831823062;
		-19'sd 131069 :	LUT_out[42] = -37'sd 1663658817;
		-19'sd 196604 :	LUT_out[42] = -37'sd 2495494572;
		default     :	LUT_out[42] = 37'sd 0;
	endcase
end

// LUT_43 

always @ *
begin
	case(sum_level_1[43])
		19 'sd 0      :	LUT_out[43] = 37'sd 0;
		19 'sd 32767  :	LUT_out[43] = 37'sd 383341133;
		19 'sd 98302  :	LUT_out[43] = 37'sd 1150035098;
		-19'sd 32767  :	LUT_out[43] = -37'sd 383341133;
		-19'sd 98302  :	LUT_out[43] = -37'sd 1150035098;
		19 'sd 65534  :	LUT_out[43] = 37'sd 766682266;
		19 'sd 131069 :	LUT_out[43] = 37'sd 1533376231;
		-19'sd 65535  :	LUT_out[43] = -37'sd 766693965;
		19 'sd 196604 :	LUT_out[43] = 37'sd 2300070196;
		19 'sd 65535  :	LUT_out[43] = 37'sd 766693965;
		-19'sd 65534  :	LUT_out[43] = -37'sd 766682266;
		-19'sd 131069 :	LUT_out[43] = -37'sd 1533376231;
		-19'sd 196604 :	LUT_out[43] = -37'sd 2300070196;
		default     :	LUT_out[43] = 37'sd 0;
	endcase
end

// LUT_44 

always @ *
begin
	case(sum_level_1[44])
		19 'sd 0      :	LUT_out[44] = 37'sd 0;
		19 'sd 32767  :	LUT_out[44] = 37'sd 75003663;
		19 'sd 98302  :	LUT_out[44] = 37'sd 225013278;
		-19'sd 32767  :	LUT_out[44] = -37'sd 75003663;
		-19'sd 98302  :	LUT_out[44] = -37'sd 225013278;
		19 'sd 65534  :	LUT_out[44] = 37'sd 150007326;
		19 'sd 131069 :	LUT_out[44] = 37'sd 300016941;
		-19'sd 65535  :	LUT_out[44] = -37'sd 150009615;
		19 'sd 196604 :	LUT_out[44] = 37'sd 450026556;
		19 'sd 65535  :	LUT_out[44] = 37'sd 150009615;
		-19'sd 65534  :	LUT_out[44] = -37'sd 150007326;
		-19'sd 131069 :	LUT_out[44] = -37'sd 300016941;
		-19'sd 196604 :	LUT_out[44] = -37'sd 450026556;
		default     :	LUT_out[44] = 37'sd 0;
	endcase
end

// LUT_45 

always @ *
begin
	case(sum_level_1[45])
		19 'sd 0      :	LUT_out[45] = 37'sd 0;
		19 'sd 32767  :	LUT_out[45] = -37'sd 380424870;
		19 'sd 98302  :	LUT_out[45] = -37'sd 1141286220;
		-19'sd 32767  :	LUT_out[45] = 37'sd 380424870;
		-19'sd 98302  :	LUT_out[45] = 37'sd 1141286220;
		19 'sd 65534  :	LUT_out[45] = -37'sd 760849740;
		19 'sd 131069 :	LUT_out[45] = -37'sd 1521711090;
		-19'sd 65535  :	LUT_out[45] = 37'sd 760861350;
		19 'sd 196604 :	LUT_out[45] = -37'sd 2282572440;
		19 'sd 65535  :	LUT_out[45] = -37'sd 760861350;
		-19'sd 65534  :	LUT_out[45] = 37'sd 760849740;
		-19'sd 131069 :	LUT_out[45] = 37'sd 1521711090;
		-19'sd 196604 :	LUT_out[45] = 37'sd 2282572440;
		default     :	LUT_out[45] = 37'sd 0;
	endcase
end

// LUT_46 

always @ *
begin
	case(sum_level_1[46])
		19 'sd 0      :	LUT_out[46] = 37'sd 0;
		19 'sd 32767  :	LUT_out[46] = -37'sd 721463806;
		19 'sd 98302  :	LUT_out[46] = -37'sd 2164413436;
		-19'sd 32767  :	LUT_out[46] = 37'sd 721463806;
		-19'sd 98302  :	LUT_out[46] = 37'sd 2164413436;
		19 'sd 65534  :	LUT_out[46] = -37'sd 1442927612;
		19 'sd 131069 :	LUT_out[46] = -37'sd 2885877242;
		-19'sd 65535  :	LUT_out[46] = 37'sd 1442949630;
		19 'sd 196604 :	LUT_out[46] = -37'sd 4328826872;
		19 'sd 65535  :	LUT_out[46] = -37'sd 1442949630;
		-19'sd 65534  :	LUT_out[46] = 37'sd 1442927612;
		-19'sd 131069 :	LUT_out[46] = 37'sd 2885877242;
		-19'sd 196604 :	LUT_out[46] = 37'sd 4328826872;
		default     :	LUT_out[46] = 37'sd 0;
	endcase
end

// LUT_47 

always @ *
begin
	case(sum_level_1[47])
		19 'sd 0      :	LUT_out[47] = 37'sd 0;
		19 'sd 32767  :	LUT_out[47] = -37'sd 670248985;
		19 'sd 98302  :	LUT_out[47] = -37'sd 2010767410;
		-19'sd 32767  :	LUT_out[47] = 37'sd 670248985;
		-19'sd 98302  :	LUT_out[47] = 37'sd 2010767410;
		19 'sd 65534  :	LUT_out[47] = -37'sd 1340497970;
		19 'sd 131069 :	LUT_out[47] = -37'sd 2681016395;
		-19'sd 65535  :	LUT_out[47] = 37'sd 1340518425;
		19 'sd 196604 :	LUT_out[47] = -37'sd 4021534820;
		19 'sd 65535  :	LUT_out[47] = -37'sd 1340518425;
		-19'sd 65534  :	LUT_out[47] = 37'sd 1340497970;
		-19'sd 131069 :	LUT_out[47] = 37'sd 2681016395;
		-19'sd 196604 :	LUT_out[47] = 37'sd 4021534820;
		default     :	LUT_out[47] = 37'sd 0;
	endcase
end

// LUT_48 

always @ *
begin
	case(sum_level_1[48])
		19 'sd 0      :	LUT_out[48] = 37'sd 0;
		19 'sd 32767  :	LUT_out[48] = -37'sd 76445411;
		19 'sd 98302  :	LUT_out[48] = -37'sd 229338566;
		-19'sd 32767  :	LUT_out[48] = 37'sd 76445411;
		-19'sd 98302  :	LUT_out[48] = 37'sd 229338566;
		19 'sd 65534  :	LUT_out[48] = -37'sd 152890822;
		19 'sd 131069 :	LUT_out[48] = -37'sd 305783977;
		-19'sd 65535  :	LUT_out[48] = 37'sd 152893155;
		19 'sd 196604 :	LUT_out[48] = -37'sd 458677132;
		19 'sd 65535  :	LUT_out[48] = -37'sd 152893155;
		-19'sd 65534  :	LUT_out[48] = 37'sd 152890822;
		-19'sd 131069 :	LUT_out[48] = 37'sd 305783977;
		-19'sd 196604 :	LUT_out[48] = 37'sd 458677132;
		default     :	LUT_out[48] = 37'sd 0;
	endcase
end

// LUT_49 

always @ *
begin
	case(sum_level_1[49])
		19 'sd 0      :	LUT_out[49] = 37'sd 0;
		19 'sd 32767  :	LUT_out[49] = 37'sd 983272136;
		19 'sd 98302  :	LUT_out[49] = 37'sd 2949846416;
		-19'sd 32767  :	LUT_out[49] = -37'sd 983272136;
		-19'sd 98302  :	LUT_out[49] = -37'sd 2949846416;
		19 'sd 65534  :	LUT_out[49] = 37'sd 1966544272;
		19 'sd 131069 :	LUT_out[49] = 37'sd 3933118552;
		-19'sd 65535  :	LUT_out[49] = -37'sd 1966574280;
		19 'sd 196604 :	LUT_out[49] = 37'sd 5899692832;
		19 'sd 65535  :	LUT_out[49] = 37'sd 1966574280;
		-19'sd 65534  :	LUT_out[49] = -37'sd 1966544272;
		-19'sd 131069 :	LUT_out[49] = -37'sd 3933118552;
		-19'sd 196604 :	LUT_out[49] = -37'sd 5899692832;
		default     :	LUT_out[49] = 37'sd 0;
	endcase
end

// LUT_50 

always @ *
begin
	case(sum_level_1[50])
		19 'sd 0      :	LUT_out[50] = 37'sd 0;
		19 'sd 32767  :	LUT_out[50] = 37'sd 2207643858;
		19 'sd 98302  :	LUT_out[50] = 37'sd 6622998948;
		-19'sd 32767  :	LUT_out[50] = -37'sd 2207643858;
		-19'sd 98302  :	LUT_out[50] = -37'sd 6622998948;
		19 'sd 65534  :	LUT_out[50] = 37'sd 4415287716;
		19 'sd 131069 :	LUT_out[50] = 37'sd 8830642806;
		-19'sd 65535  :	LUT_out[50] = -37'sd 4415355090;
		19 'sd 196604 :	LUT_out[50] = 37'sd 13245997896;
		19 'sd 65535  :	LUT_out[50] = 37'sd 4415355090;
		-19'sd 65534  :	LUT_out[50] = -37'sd 4415287716;
		-19'sd 131069 :	LUT_out[50] = -37'sd 8830642806;
		-19'sd 196604 :	LUT_out[50] = -37'sd 13245997896;
		default     :	LUT_out[50] = 37'sd 0;
	endcase
end

// LUT_51 

always @ *
begin
	case(sum_level_1[51])
		19 'sd 0      :	LUT_out[51] = 37'sd 0;
		19 'sd 32767  :	LUT_out[51] = 37'sd 3182265506;
		19 'sd 98302  :	LUT_out[51] = 37'sd 9546893636;
		-19'sd 32767  :	LUT_out[51] = -37'sd 3182265506;
		-19'sd 98302  :	LUT_out[51] = -37'sd 9546893636;
		19 'sd 65534  :	LUT_out[51] = 37'sd 6364531012;
		19 'sd 131069 :	LUT_out[51] = 37'sd 12729159142;
		-19'sd 65535  :	LUT_out[51] = -37'sd 6364628130;
		19 'sd 196604 :	LUT_out[51] = 37'sd 19093787272;
		19 'sd 65535  :	LUT_out[51] = 37'sd 6364628130;
		-19'sd 65534  :	LUT_out[51] = -37'sd 6364531012;
		-19'sd 131069 :	LUT_out[51] = -37'sd 12729159142;
		-19'sd 196604 :	LUT_out[51] = -37'sd 19093787272;
		default     :	LUT_out[51] = 37'sd 0;
	endcase
end

// LUT_52 

always @ *
begin
	case(sum_level_1[52])
		19 'sd 0      :	LUT_out[52] = 37'sd 0;
		19 'sd 32767  :	LUT_out[52] = 37'sd 3553286247;
		19 'sd 98302  :	LUT_out[52] = 37'sd 10659967182;
		-19'sd 32767  :	LUT_out[52] = -37'sd 3553286247;
		-19'sd 98302  :	LUT_out[52] = -37'sd 10659967182;
		default     :	LUT_out[52] = 37'sd 0;
	endcase
end


endmodule