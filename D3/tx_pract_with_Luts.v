module srrc_filter( input clk, reset, sym_clk_en, sam_clk_en,
							input [1:0] sw,
                    input signed [17:0] x_in, //1s17
                    output reg signed [17:0] y); //1s17);



// create array of vectors
integer  i;
reg signed [17:0] x[104:0]; // for 21 coefficients 0s18
reg signed [18:0] sum_level_1[52:0];
reg signed [17:0] sum_out[51:0];
reg signed [36:0] LUT_out[52:0]; // 1s35 but changed to 2s35
// reg signed [17:0] b[10:0]; // coefficients

always @ (posedge clk or posedge reset)
    if(reset)
        x[0] <= 0;
    else
        x[0] <= x_in;

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
		19 'sd 98304  :	LUT_out[0]  = -37'sd 60850176;
		19 'sd 32768  :	LUT_out[0]  = -37'sd 20283392;
		-19'sd 32768  :	LUT_out[0]  = 37'sd 20283392;
		-19'sd 98304  :	LUT_out[0]  = 37'sd 60850176;
		19 'sd 196608 :	LUT_out[0]  = -37'sd 121700352;
		19 'sd 131072 :	LUT_out[0]  = -37'sd 81133568;
		19 'sd 65536  :	LUT_out[0]  = -37'sd 40566784;
		-19'sd 65536  :	LUT_out[0]  = 37'sd 40566784;
		-19'sd 131072 :	LUT_out[0]  = 37'sd 81133568;
		-19'sd 196608 :	LUT_out[0]  = 37'sd 121700352;
		default     :	LUT_out[0]  = 37'sd 0;
	endcase
end

// LUT_1 

always @ *
begin
	case(sum_level_1[1])
		19 'sd 0      :	LUT_out[1]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[1]  = -37'sd 39419904;
		19 'sd 32768  :	LUT_out[1]  = -37'sd 13139968;
		-19'sd 32768  :	LUT_out[1]  = 37'sd 13139968;
		-19'sd 98304  :	LUT_out[1]  = 37'sd 39419904;
		19 'sd 196608 :	LUT_out[1]  = -37'sd 78839808;
		19 'sd 131072 :	LUT_out[1]  = -37'sd 52559872;
		19 'sd 65536  :	LUT_out[1]  = -37'sd 26279936;
		-19'sd 65536  :	LUT_out[1]  = 37'sd 26279936;
		-19'sd 131072 :	LUT_out[1]  = 37'sd 52559872;
		-19'sd 196608 :	LUT_out[1]  = 37'sd 78839808;
		default     :	LUT_out[1]  = 37'sd 0;
	endcase
end

// LUT_2 

always @ *
begin
	case(sum_level_1[2])
		19 'sd 0      :	LUT_out[2]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[2]  = 37'sd 14450688;
		19 'sd 32768  :	LUT_out[2]  = 37'sd 4816896;
		-19'sd 32768  :	LUT_out[2]  = -37'sd 4816896;
		-19'sd 98304  :	LUT_out[2]  = -37'sd 14450688;
		19 'sd 196608 :	LUT_out[2]  = 37'sd 28901376;
		19 'sd 131072 :	LUT_out[2]  = 37'sd 19267584;
		19 'sd 65536  :	LUT_out[2]  = 37'sd 9633792;
		-19'sd 65536  :	LUT_out[2]  = -37'sd 9633792;
		-19'sd 131072 :	LUT_out[2]  = -37'sd 19267584;
		-19'sd 196608 :	LUT_out[2]  = -37'sd 28901376;
		default     :	LUT_out[2]  = 37'sd 0;
	endcase
end

// LUT_3 

always @ *
begin
	case(sum_level_1[3])
		19 'sd 0      :	LUT_out[3]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[3]  = 37'sd 66060288;
		19 'sd 32768  :	LUT_out[3]  = 37'sd 22020096;
		-19'sd 32768  :	LUT_out[3]  = -37'sd 22020096;
		-19'sd 98304  :	LUT_out[3]  = -37'sd 66060288;
		19 'sd 196608 :	LUT_out[3]  = 37'sd 132120576;
		19 'sd 131072 :	LUT_out[3]  = 37'sd 88080384;
		19 'sd 65536  :	LUT_out[3]  = 37'sd 44040192;
		-19'sd 65536  :	LUT_out[3]  = -37'sd 44040192;
		-19'sd 131072 :	LUT_out[3]  = -37'sd 88080384;
		-19'sd 196608 :	LUT_out[3]  = -37'sd 132120576;
		default     :	LUT_out[3]  = 37'sd 0;
	endcase
end

// LUT_4 

always @ *
begin
	case(sum_level_1[4])
		19 'sd 0      :	LUT_out[4]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[4]  = 37'sd 77660160;
		19 'sd 32768  :	LUT_out[4]  = 37'sd 25886720;
		-19'sd 32768  :	LUT_out[4]  = -37'sd 25886720;
		-19'sd 98304  :	LUT_out[4]  = -37'sd 77660160;
		19 'sd 196608 :	LUT_out[4]  = 37'sd 155320320;
		19 'sd 131072 :	LUT_out[4]  = 37'sd 103546880;
		19 'sd 65536  :	LUT_out[4]  = 37'sd 51773440;
		-19'sd 65536  :	LUT_out[4]  = -37'sd 51773440;
		-19'sd 131072 :	LUT_out[4]  = -37'sd 103546880;
		-19'sd 196608 :	LUT_out[4]  = -37'sd 155320320;
		default     :	LUT_out[4]  = 37'sd 0;
	endcase
end

// LUT_5 

always @ *
begin
	case(sum_level_1[5])
		19 'sd 0      :	LUT_out[5]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[5]  = 37'sd 34799616;
		19 'sd 32768  :	LUT_out[5]  = 37'sd 11599872;
		-19'sd 32768  :	LUT_out[5]  = -37'sd 11599872;
		-19'sd 98304  :	LUT_out[5]  = -37'sd 34799616;
		19 'sd 196608 :	LUT_out[5]  = 37'sd 69599232;
		19 'sd 131072 :	LUT_out[5]  = 37'sd 46399488;
		19 'sd 65536  :	LUT_out[5]  = 37'sd 23199744;
		-19'sd 65536  :	LUT_out[5]  = -37'sd 23199744;
		-19'sd 131072 :	LUT_out[5]  = -37'sd 46399488;
		-19'sd 196608 :	LUT_out[5]  = -37'sd 69599232;
		default     :	LUT_out[5]  = 37'sd 0;
	endcase
end

// LUT_6 

always @ *
begin
	case(sum_level_1[6])
		19 'sd 0      :	LUT_out[6]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[6]  = -37'sd 39714816;
		19 'sd 32768  :	LUT_out[6]  = -37'sd 13238272;
		-19'sd 32768  :	LUT_out[6]  = 37'sd 13238272;
		-19'sd 98304  :	LUT_out[6]  = 37'sd 39714816;
		19 'sd 196608 :	LUT_out[6]  = -37'sd 79429632;
		19 'sd 131072 :	LUT_out[6]  = -37'sd 52953088;
		19 'sd 65536  :	LUT_out[6]  = -37'sd 26476544;
		-19'sd 65536  :	LUT_out[6]  = 37'sd 26476544;
		-19'sd 131072 :	LUT_out[6]  = 37'sd 52953088;
		-19'sd 196608 :	LUT_out[6]  = 37'sd 79429632;
		default     :	LUT_out[6]  = 37'sd 0;
	endcase
end

// LUT_7 

always @ *
begin
	case(sum_level_1[7])
		19 'sd 0      :	LUT_out[7]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[7]  = -37'sd 97517568;
		19 'sd 32768  :	LUT_out[7]  = -37'sd 32505856;
		-19'sd 32768  :	LUT_out[7]  = 37'sd 32505856;
		-19'sd 98304  :	LUT_out[7]  = 37'sd 97517568;
		19 'sd 196608 :	LUT_out[7]  = -37'sd 195035136;
		19 'sd 131072 :	LUT_out[7]  = -37'sd 130023424;
		19 'sd 65536  :	LUT_out[7]  = -37'sd 65011712;
		-19'sd 65536  :	LUT_out[7]  = 37'sd 65011712;
		-19'sd 131072 :	LUT_out[7]  = 37'sd 130023424;
		-19'sd 196608 :	LUT_out[7]  = 37'sd 195035136;
		default     :	LUT_out[7]  = 37'sd 0;
	endcase
end

// LUT_8 

always @ *
begin
	case(sum_level_1[8])
		19 'sd 0      :	LUT_out[8]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[8]  = -37'sd 95256576;
		19 'sd 32768  :	LUT_out[8]  = -37'sd 31752192;
		-19'sd 32768  :	LUT_out[8]  = 37'sd 31752192;
		-19'sd 98304  :	LUT_out[8]  = 37'sd 95256576;
		19 'sd 196608 :	LUT_out[8]  = -37'sd 190513152;
		19 'sd 131072 :	LUT_out[8]  = -37'sd 127008768;
		19 'sd 65536  :	LUT_out[8]  = -37'sd 63504384;
		-19'sd 65536  :	LUT_out[8]  = 37'sd 63504384;
		-19'sd 131072 :	LUT_out[8]  = 37'sd 127008768;
		-19'sd 196608 :	LUT_out[8]  = 37'sd 190513152;
		default     :	LUT_out[8]  = 37'sd 0;
	endcase
end

// LUT_9 

always @ *
begin
	case(sum_level_1[9])
		19 'sd 0      :	LUT_out[9]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[9]  = -37'sd 25460736;
		19 'sd 32768  :	LUT_out[9]  = -37'sd 8486912;
		-19'sd 32768  :	LUT_out[9]  = 37'sd 8486912;
		-19'sd 98304  :	LUT_out[9]  = 37'sd 25460736;
		19 'sd 196608 :	LUT_out[9]  = -37'sd 50921472;
		19 'sd 131072 :	LUT_out[9]  = -37'sd 33947648;
		19 'sd 65536  :	LUT_out[9]  = -37'sd 16973824;
		-19'sd 65536  :	LUT_out[9]  = 37'sd 16973824;
		-19'sd 131072 :	LUT_out[9]  = 37'sd 33947648;
		-19'sd 196608 :	LUT_out[9]  = 37'sd 50921472;
		default     :	LUT_out[9]  = 37'sd 0;
	endcase
end

// LUT_10 

always @ *
begin
	case(sum_level_1[10])
		19 'sd 0      :	LUT_out[10] = 37'sd 0;
		19 'sd 98304  :	LUT_out[10] = 37'sd 72744960;
		19 'sd 32768  :	LUT_out[10] = 37'sd 24248320;
		-19'sd 32768  :	LUT_out[10] = -37'sd 24248320;
		-19'sd 98304  :	LUT_out[10] = -37'sd 72744960;
		19 'sd 196608 :	LUT_out[10] = 37'sd 145489920;
		19 'sd 131072 :	LUT_out[10] = 37'sd 96993280;
		19 'sd 65536  :	LUT_out[10] = 37'sd 48496640;
		-19'sd 65536  :	LUT_out[10] = -37'sd 48496640;
		-19'sd 131072 :	LUT_out[10] = -37'sd 96993280;
		-19'sd 196608 :	LUT_out[10] = -37'sd 145489920;
		default     :	LUT_out[10] = 37'sd 0;
	endcase
end

// LUT_11 

always @ *
begin
	case(sum_level_1[11])
		19 'sd 0      :	LUT_out[11] = 37'sd 0;
		19 'sd 98304  :	LUT_out[11] = 37'sd 135168000;
		19 'sd 32768  :	LUT_out[11] = 37'sd 45056000;
		-19'sd 32768  :	LUT_out[11] = -37'sd 45056000;
		-19'sd 98304  :	LUT_out[11] = -37'sd 135168000;
		19 'sd 196608 :	LUT_out[11] = 37'sd 270336000;
		19 'sd 131072 :	LUT_out[11] = 37'sd 180224000;
		19 'sd 65536  :	LUT_out[11] = 37'sd 90112000;
		-19'sd 65536  :	LUT_out[11] = -37'sd 90112000;
		-19'sd 131072 :	LUT_out[11] = -37'sd 180224000;
		-19'sd 196608 :	LUT_out[11] = -37'sd 270336000;
		default     :	LUT_out[11] = 37'sd 0;
	endcase
end

// LUT_12 

always @ *
begin
	case(sum_level_1[12])
		19 'sd 0      :	LUT_out[12] = 37'sd 0;
		19 'sd 98304  :	LUT_out[12] = 37'sd 113344512;
		19 'sd 32768  :	LUT_out[12] = 37'sd 37781504;
		-19'sd 32768  :	LUT_out[12] = -37'sd 37781504;
		-19'sd 98304  :	LUT_out[12] = -37'sd 113344512;
		19 'sd 196608 :	LUT_out[12] = 37'sd 226689024;
		19 'sd 131072 :	LUT_out[12] = 37'sd 151126016;
		19 'sd 65536  :	LUT_out[12] = 37'sd 75563008;
		-19'sd 65536  :	LUT_out[12] = -37'sd 75563008;
		-19'sd 131072 :	LUT_out[12] = -37'sd 151126016;
		-19'sd 196608 :	LUT_out[12] = -37'sd 226689024;
		default     :	LUT_out[12] = 37'sd 0;
	endcase
end

// LUT_13 

always @ *
begin
	case(sum_level_1[13])
		19 'sd 0      :	LUT_out[13] = 37'sd 0;
		19 'sd 98304  :	LUT_out[13] = 37'sd 10223616;
		19 'sd 32768  :	LUT_out[13] = 37'sd 3407872;
		-19'sd 32768  :	LUT_out[13] = -37'sd 3407872;
		-19'sd 98304  :	LUT_out[13] = -37'sd 10223616;
		19 'sd 196608 :	LUT_out[13] = 37'sd 20447232;
		19 'sd 131072 :	LUT_out[13] = 37'sd 13631488;
		19 'sd 65536  :	LUT_out[13] = 37'sd 6815744;
		-19'sd 65536  :	LUT_out[13] = -37'sd 6815744;
		-19'sd 131072 :	LUT_out[13] = -37'sd 13631488;
		-19'sd 196608 :	LUT_out[13] = -37'sd 20447232;
		default     :	LUT_out[13] = 37'sd 0;
	endcase
end

// LUT_14 

always @ *
begin
	case(sum_level_1[14])
		19 'sd 0      :	LUT_out[14] = 37'sd 0;
		19 'sd 98304  :	LUT_out[14] = -37'sd 115015680;
		19 'sd 32768  :	LUT_out[14] = -37'sd 38338560;
		-19'sd 32768  :	LUT_out[14] = 37'sd 38338560;
		-19'sd 98304  :	LUT_out[14] = 37'sd 115015680;
		19 'sd 196608 :	LUT_out[14] = -37'sd 230031360;
		19 'sd 131072 :	LUT_out[14] = -37'sd 153354240;
		19 'sd 65536  :	LUT_out[14] = -37'sd 76677120;
		-19'sd 65536  :	LUT_out[14] = 37'sd 76677120;
		-19'sd 131072 :	LUT_out[14] = 37'sd 153354240;
		-19'sd 196608 :	LUT_out[14] = 37'sd 230031360;
		default     :	LUT_out[14] = 37'sd 0;
	endcase
end

// LUT_15 

always @ *
begin
	case(sum_level_1[15])
		19 'sd 0      :	LUT_out[15] = 37'sd 0;
		19 'sd 98304  :	LUT_out[15] = -37'sd 179699712;
		19 'sd 32768  :	LUT_out[15] = -37'sd 59899904;
		-19'sd 32768  :	LUT_out[15] = 37'sd 59899904;
		-19'sd 98304  :	LUT_out[15] = 37'sd 179699712;
		19 'sd 196608 :	LUT_out[15] = -37'sd 359399424;
		19 'sd 131072 :	LUT_out[15] = -37'sd 239599616;
		19 'sd 65536  :	LUT_out[15] = -37'sd 119799808;
		-19'sd 65536  :	LUT_out[15] = 37'sd 119799808;
		-19'sd 131072 :	LUT_out[15] = 37'sd 239599616;
		-19'sd 196608 :	LUT_out[15] = 37'sd 359399424;
		default     :	LUT_out[15] = 37'sd 0;
	endcase
end

// LUT_16 

always @ *
begin
	case(sum_level_1[16])
		19 'sd 0      :	LUT_out[16] = 37'sd 0;
		19 'sd 98304  :	LUT_out[16] = -37'sd 131432448;
		19 'sd 32768  :	LUT_out[16] = -37'sd 43810816;
		-19'sd 32768  :	LUT_out[16] = 37'sd 43810816;
		-19'sd 98304  :	LUT_out[16] = 37'sd 131432448;
		19 'sd 196608 :	LUT_out[16] = -37'sd 262864896;
		19 'sd 131072 :	LUT_out[16] = -37'sd 175243264;
		19 'sd 65536  :	LUT_out[16] = -37'sd 87621632;
		-19'sd 65536  :	LUT_out[16] = 37'sd 87621632;
		-19'sd 131072 :	LUT_out[16] = 37'sd 175243264;
		-19'sd 196608 :	LUT_out[16] = 37'sd 262864896;
		default     :	LUT_out[16] = 37'sd 0;
	endcase
end

// LUT_17 

always @ *
begin
	case(sum_level_1[17])
		19 'sd 0      :	LUT_out[17] = 37'sd 0;
		19 'sd 98304  :	LUT_out[17] = 37'sd 12779520;
		19 'sd 32768  :	LUT_out[17] = 37'sd 4259840;
		-19'sd 32768  :	LUT_out[17] = -37'sd 4259840;
		-19'sd 98304  :	LUT_out[17] = -37'sd 12779520;
		19 'sd 196608 :	LUT_out[17] = 37'sd 25559040;
		19 'sd 131072 :	LUT_out[17] = 37'sd 17039360;
		19 'sd 65536  :	LUT_out[17] = 37'sd 8519680;
		-19'sd 65536  :	LUT_out[17] = -37'sd 8519680;
		-19'sd 131072 :	LUT_out[17] = -37'sd 17039360;
		-19'sd 196608 :	LUT_out[17] = -37'sd 25559040;
		default     :	LUT_out[17] = 37'sd 0;
	endcase
end

// LUT_18 

always @ *
begin
	case(sum_level_1[18])
		19 'sd 0      :	LUT_out[18] = 37'sd 0;
		19 'sd 98304  :	LUT_out[18] = 37'sd 168689664;
		19 'sd 32768  :	LUT_out[18] = 37'sd 56229888;
		-19'sd 32768  :	LUT_out[18] = -37'sd 56229888;
		-19'sd 98304  :	LUT_out[18] = -37'sd 168689664;
		19 'sd 196608 :	LUT_out[18] = 37'sd 337379328;
		19 'sd 131072 :	LUT_out[18] = 37'sd 224919552;
		19 'sd 65536  :	LUT_out[18] = 37'sd 112459776;
		-19'sd 65536  :	LUT_out[18] = -37'sd 112459776;
		-19'sd 131072 :	LUT_out[18] = -37'sd 224919552;
		-19'sd 196608 :	LUT_out[18] = -37'sd 337379328;
		default     :	LUT_out[18] = 37'sd 0;
	endcase
end

// LUT_19 

always @ *
begin
	case(sum_level_1[19])
		19 'sd 0      :	LUT_out[19] = 37'sd 0;
		19 'sd 98304  :	LUT_out[19] = 37'sd 232587264;
		19 'sd 32768  :	LUT_out[19] = 37'sd 77529088;
		-19'sd 32768  :	LUT_out[19] = -37'sd 77529088;
		-19'sd 98304  :	LUT_out[19] = -37'sd 232587264;
		19 'sd 196608 :	LUT_out[19] = 37'sd 465174528;
		19 'sd 131072 :	LUT_out[19] = 37'sd 310116352;
		19 'sd 65536  :	LUT_out[19] = 37'sd 155058176;
		-19'sd 65536  :	LUT_out[19] = -37'sd 155058176;
		-19'sd 131072 :	LUT_out[19] = -37'sd 310116352;
		-19'sd 196608 :	LUT_out[19] = -37'sd 465174528;
		default     :	LUT_out[19] = 37'sd 0;
	endcase
end

// LUT_20 

always @ *
begin
	case(sum_level_1[20])
		19 'sd 0      :	LUT_out[20] = 37'sd 0;
		19 'sd 98304  :	LUT_out[20] = 37'sd 149225472;
		19 'sd 32768  :	LUT_out[20] = 37'sd 49741824;
		-19'sd 32768  :	LUT_out[20] = -37'sd 49741824;
		-19'sd 98304  :	LUT_out[20] = -37'sd 149225472;
		19 'sd 196608 :	LUT_out[20] = 37'sd 298450944;
		19 'sd 131072 :	LUT_out[20] = 37'sd 198967296;
		19 'sd 65536  :	LUT_out[20] = 37'sd 99483648;
		-19'sd 65536  :	LUT_out[20] = -37'sd 99483648;
		-19'sd 131072 :	LUT_out[20] = -37'sd 198967296;
		-19'sd 196608 :	LUT_out[20] = -37'sd 298450944;
		default     :	LUT_out[20] = 37'sd 0;
	endcase
end

// LUT_21 

always @ *
begin
	case(sum_level_1[21])
		19 'sd 0      :	LUT_out[21] = 37'sd 0;
		19 'sd 98304  :	LUT_out[21] = -37'sd 45711360;
		19 'sd 32768  :	LUT_out[21] = -37'sd 15237120;
		-19'sd 32768  :	LUT_out[21] = 37'sd 15237120;
		-19'sd 98304  :	LUT_out[21] = 37'sd 45711360;
		19 'sd 196608 :	LUT_out[21] = -37'sd 91422720;
		19 'sd 131072 :	LUT_out[21] = -37'sd 60948480;
		19 'sd 65536  :	LUT_out[21] = -37'sd 30474240;
		-19'sd 65536  :	LUT_out[21] = 37'sd 30474240;
		-19'sd 131072 :	LUT_out[21] = 37'sd 60948480;
		-19'sd 196608 :	LUT_out[21] = 37'sd 91422720;
		default     :	LUT_out[21] = 37'sd 0;
	endcase
end

// LUT_22 

always @ *
begin
	case(sum_level_1[22])
		19 'sd 0      :	LUT_out[22] = 37'sd 0;
		19 'sd 98304  :	LUT_out[22] = -37'sd 236814336;
		19 'sd 32768  :	LUT_out[22] = -37'sd 78938112;
		-19'sd 32768  :	LUT_out[22] = 37'sd 78938112;
		-19'sd 98304  :	LUT_out[22] = 37'sd 236814336;
		19 'sd 196608 :	LUT_out[22] = -37'sd 473628672;
		19 'sd 131072 :	LUT_out[22] = -37'sd 315752448;
		19 'sd 65536  :	LUT_out[22] = -37'sd 157876224;
		-19'sd 65536  :	LUT_out[22] = 37'sd 157876224;
		-19'sd 131072 :	LUT_out[22] = 37'sd 315752448;
		-19'sd 196608 :	LUT_out[22] = 37'sd 473628672;
		default     :	LUT_out[22] = 37'sd 0;
	endcase
end

// LUT_23 

always @ *
begin
	case(sum_level_1[23])
		19 'sd 0      :	LUT_out[23] = 37'sd 0;
		19 'sd 98304  :	LUT_out[23] = -37'sd 295993344;
		19 'sd 32768  :	LUT_out[23] = -37'sd 98664448;
		-19'sd 32768  :	LUT_out[23] = 37'sd 98664448;
		-19'sd 98304  :	LUT_out[23] = 37'sd 295993344;
		19 'sd 196608 :	LUT_out[23] = -37'sd 591986688;
		19 'sd 131072 :	LUT_out[23] = -37'sd 394657792;
		19 'sd 65536  :	LUT_out[23] = -37'sd 197328896;
		-19'sd 65536  :	LUT_out[23] = 37'sd 197328896;
		-19'sd 131072 :	LUT_out[23] = 37'sd 394657792;
		-19'sd 196608 :	LUT_out[23] = 37'sd 591986688;
		default     :	LUT_out[23] = 37'sd 0;
	endcase
end

// LUT_24 

always @ *
begin
	case(sum_level_1[24])
		19 'sd 0      :	LUT_out[24] = 37'sd 0;
		19 'sd 98304  :	LUT_out[24] = -37'sd 166133760;
		19 'sd 32768  :	LUT_out[24] = -37'sd 55377920;
		-19'sd 32768  :	LUT_out[24] = 37'sd 55377920;
		-19'sd 98304  :	LUT_out[24] = 37'sd 166133760;
		19 'sd 196608 :	LUT_out[24] = -37'sd 332267520;
		19 'sd 131072 :	LUT_out[24] = -37'sd 221511680;
		19 'sd 65536  :	LUT_out[24] = -37'sd 110755840;
		-19'sd 65536  :	LUT_out[24] = 37'sd 110755840;
		-19'sd 131072 :	LUT_out[24] = 37'sd 221511680;
		-19'sd 196608 :	LUT_out[24] = 37'sd 332267520;
		default     :	LUT_out[24] = 37'sd 0;
	endcase
end

// LUT_25 

always @ *
begin
	case(sum_level_1[25])
		19 'sd 0      :	LUT_out[25] = 37'sd 0;
		19 'sd 98304  :	LUT_out[25] = 37'sd 92012544;
		19 'sd 32768  :	LUT_out[25] = 37'sd 30670848;
		-19'sd 32768  :	LUT_out[25] = -37'sd 30670848;
		-19'sd 98304  :	LUT_out[25] = -37'sd 92012544;
		19 'sd 196608 :	LUT_out[25] = 37'sd 184025088;
		19 'sd 131072 :	LUT_out[25] = 37'sd 122683392;
		19 'sd 65536  :	LUT_out[25] = 37'sd 61341696;
		-19'sd 65536  :	LUT_out[25] = -37'sd 61341696;
		-19'sd 131072 :	LUT_out[25] = -37'sd 122683392;
		-19'sd 196608 :	LUT_out[25] = -37'sd 184025088;
		default     :	LUT_out[25] = 37'sd 0;
	endcase
end

// LUT_26 

always @ *
begin
	case(sum_level_1[26])
		19 'sd 0      :	LUT_out[26] = 37'sd 0;
		19 'sd 98304  :	LUT_out[26] = 37'sd 324403200;
		19 'sd 32768  :	LUT_out[26] = 37'sd 108134400;
		-19'sd 32768  :	LUT_out[26] = -37'sd 108134400;
		-19'sd 98304  :	LUT_out[26] = -37'sd 324403200;
		19 'sd 196608 :	LUT_out[26] = 37'sd 648806400;
		19 'sd 131072 :	LUT_out[26] = 37'sd 432537600;
		19 'sd 65536  :	LUT_out[26] = 37'sd 216268800;
		-19'sd 65536  :	LUT_out[26] = -37'sd 216268800;
		-19'sd 131072 :	LUT_out[26] = -37'sd 432537600;
		-19'sd 196608 :	LUT_out[26] = -37'sd 648806400;
		default     :	LUT_out[26] = 37'sd 0;
	endcase
end

// LUT_27 

always @ *
begin
	case(sum_level_1[27])
		19 'sd 0      :	LUT_out[27] = 37'sd 0;
		19 'sd 98304  :	LUT_out[27] = 37'sd 373555200;
		19 'sd 32768  :	LUT_out[27] = 37'sd 124518400;
		-19'sd 32768  :	LUT_out[27] = -37'sd 124518400;
		-19'sd 98304  :	LUT_out[27] = -37'sd 373555200;
		19 'sd 196608 :	LUT_out[27] = 37'sd 747110400;
		19 'sd 131072 :	LUT_out[27] = 37'sd 498073600;
		19 'sd 65536  :	LUT_out[27] = 37'sd 249036800;
		-19'sd 65536  :	LUT_out[27] = -37'sd 249036800;
		-19'sd 131072 :	LUT_out[27] = -37'sd 498073600;
		-19'sd 196608 :	LUT_out[27] = -37'sd 747110400;
		default     :	LUT_out[27] = 37'sd 0;
	endcase
end

// LUT_28 

always @ *
begin
	case(sum_level_1[28])
		19 'sd 0      :	LUT_out[28] = 37'sd 0;
		19 'sd 98304  :	LUT_out[28] = 37'sd 181862400;
		19 'sd 32768  :	LUT_out[28] = 37'sd 60620800;
		-19'sd 32768  :	LUT_out[28] = -37'sd 60620800;
		-19'sd 98304  :	LUT_out[28] = -37'sd 181862400;
		19 'sd 196608 :	LUT_out[28] = 37'sd 363724800;
		19 'sd 131072 :	LUT_out[28] = 37'sd 242483200;
		19 'sd 65536  :	LUT_out[28] = 37'sd 121241600;
		-19'sd 65536  :	LUT_out[28] = -37'sd 121241600;
		-19'sd 131072 :	LUT_out[28] = -37'sd 242483200;
		-19'sd 196608 :	LUT_out[28] = -37'sd 363724800;
		default     :	LUT_out[28] = 37'sd 0;
	endcase
end

// LUT_29 

always @ *
begin
	case(sum_level_1[29])
		19 'sd 0      :	LUT_out[29] = 37'sd 0;
		19 'sd 98304  :	LUT_out[29] = -37'sd 157089792;
		19 'sd 32768  :	LUT_out[29] = -37'sd 52363264;
		-19'sd 32768  :	LUT_out[29] = 37'sd 52363264;
		-19'sd 98304  :	LUT_out[29] = 37'sd 157089792;
		19 'sd 196608 :	LUT_out[29] = -37'sd 314179584;
		19 'sd 131072 :	LUT_out[29] = -37'sd 209453056;
		19 'sd 65536  :	LUT_out[29] = -37'sd 104726528;
		-19'sd 65536  :	LUT_out[29] = 37'sd 104726528;
		-19'sd 131072 :	LUT_out[29] = 37'sd 209453056;
		-19'sd 196608 :	LUT_out[29] = 37'sd 314179584;
		default     :	LUT_out[29] = 37'sd 0;
	endcase
end

// LUT_30 

always @ *
begin
	case(sum_level_1[30])
		19 'sd 0      :	LUT_out[30] = 37'sd 0;
		19 'sd 98304  :	LUT_out[30] = -37'sd 439910400;
		19 'sd 32768  :	LUT_out[30] = -37'sd 146636800;
		-19'sd 32768  :	LUT_out[30] = 37'sd 146636800;
		-19'sd 98304  :	LUT_out[30] = 37'sd 439910400;
		19 'sd 196608 :	LUT_out[30] = -37'sd 879820800;
		19 'sd 131072 :	LUT_out[30] = -37'sd 586547200;
		19 'sd 65536  :	LUT_out[30] = -37'sd 293273600;
		-19'sd 65536  :	LUT_out[30] = 37'sd 293273600;
		-19'sd 131072 :	LUT_out[30] = 37'sd 586547200;
		-19'sd 196608 :	LUT_out[30] = 37'sd 879820800;
		default     :	LUT_out[30] = 37'sd 0;
	endcase
end

// LUT_31 

always @ *
begin
	case(sum_level_1[31])
		19 'sd 0      :	LUT_out[31] = 37'sd 0;
		19 'sd 98304  :	LUT_out[31] = -37'sd 471957504;
		19 'sd 32768  :	LUT_out[31] = -37'sd 157319168;
		-19'sd 32768  :	LUT_out[31] = 37'sd 157319168;
		-19'sd 98304  :	LUT_out[31] = 37'sd 471957504;
		19 'sd 196608 :	LUT_out[31] = -37'sd 943915008;
		19 'sd 131072 :	LUT_out[31] = -37'sd 629276672;
		19 'sd 65536  :	LUT_out[31] = -37'sd 314638336;
		-19'sd 65536  :	LUT_out[31] = 37'sd 314638336;
		-19'sd 131072 :	LUT_out[31] = 37'sd 629276672;
		-19'sd 196608 :	LUT_out[31] = 37'sd 943915008;
		default     :	LUT_out[31] = 37'sd 0;
	endcase
end

// LUT_32 

always @ *
begin
	case(sum_level_1[32])
		19 'sd 0      :	LUT_out[32] = 37'sd 0;
		19 'sd 98304  :	LUT_out[32] = -37'sd 195919872;
		19 'sd 32768  :	LUT_out[32] = -37'sd 65306624;
		-19'sd 32768  :	LUT_out[32] = 37'sd 65306624;
		-19'sd 98304  :	LUT_out[32] = 37'sd 195919872;
		19 'sd 196608 :	LUT_out[32] = -37'sd 391839744;
		19 'sd 131072 :	LUT_out[32] = -37'sd 261226496;
		19 'sd 65536  :	LUT_out[32] = -37'sd 130613248;
		-19'sd 65536  :	LUT_out[32] = 37'sd 130613248;
		-19'sd 131072 :	LUT_out[32] = 37'sd 261226496;
		-19'sd 196608 :	LUT_out[32] = 37'sd 391839744;
		default     :	LUT_out[32] = 37'sd 0;
	endcase
end

// LUT_33 

always @ *
begin
	case(sum_level_1[33])
		19 'sd 0      :	LUT_out[33] = 37'sd 0;
		19 'sd 98304  :	LUT_out[33] = 37'sd 250970112;
		19 'sd 32768  :	LUT_out[33] = 37'sd 83656704;
		-19'sd 32768  :	LUT_out[33] = -37'sd 83656704;
		-19'sd 98304  :	LUT_out[33] = -37'sd 250970112;
		19 'sd 196608 :	LUT_out[33] = 37'sd 501940224;
		19 'sd 131072 :	LUT_out[33] = 37'sd 334626816;
		19 'sd 65536  :	LUT_out[33] = 37'sd 167313408;
		-19'sd 65536  :	LUT_out[33] = -37'sd 167313408;
		-19'sd 131072 :	LUT_out[33] = -37'sd 334626816;
		-19'sd 196608 :	LUT_out[33] = -37'sd 501940224;
		default     :	LUT_out[33] = 37'sd 0;
	endcase
end

// LUT_34 

always @ *
begin
	case(sum_level_1[34])
		19 'sd 0      :	LUT_out[34] = 37'sd 0;
		19 'sd 98304  :	LUT_out[34] = 37'sd 599556096;
		19 'sd 32768  :	LUT_out[34] = 37'sd 199852032;
		-19'sd 32768  :	LUT_out[34] = -37'sd 199852032;
		-19'sd 98304  :	LUT_out[34] = -37'sd 599556096;
		19 'sd 196608 :	LUT_out[34] = 37'sd 1199112192;
		19 'sd 131072 :	LUT_out[34] = 37'sd 799408128;
		19 'sd 65536  :	LUT_out[34] = 37'sd 399704064;
		-19'sd 65536  :	LUT_out[34] = -37'sd 399704064;
		-19'sd 131072 :	LUT_out[34] = -37'sd 799408128;
		-19'sd 196608 :	LUT_out[34] = -37'sd 1199112192;
		default     :	LUT_out[34] = 37'sd 0;
	endcase
end

// LUT_35 

always @ *
begin
	case(sum_level_1[35])
		19 'sd 0      :	LUT_out[35] = 37'sd 0;
		19 'sd 98304  :	LUT_out[35] = 37'sd 604569600;
		19 'sd 32768  :	LUT_out[35] = 37'sd 201523200;
		-19'sd 32768  :	LUT_out[35] = -37'sd 201523200;
		-19'sd 98304  :	LUT_out[35] = -37'sd 604569600;
		19 'sd 196608 :	LUT_out[35] = 37'sd 1209139200;
		19 'sd 131072 :	LUT_out[35] = 37'sd 806092800;
		19 'sd 65536  :	LUT_out[35] = 37'sd 403046400;
		-19'sd 65536  :	LUT_out[35] = -37'sd 403046400;
		-19'sd 131072 :	LUT_out[35] = -37'sd 806092800;
		-19'sd 196608 :	LUT_out[35] = -37'sd 1209139200;
		default     :	LUT_out[35] = 37'sd 0;
	endcase
end

// LUT_36 

always @ *
begin
	case(sum_level_1[36])
		19 'sd 0      :	LUT_out[36] = 37'sd 0;
		19 'sd 98304  :	LUT_out[36] = 37'sd 208011264;
		19 'sd 32768  :	LUT_out[36] = 37'sd 69337088;
		-19'sd 32768  :	LUT_out[36] = -37'sd 69337088;
		-19'sd 98304  :	LUT_out[36] = -37'sd 208011264;
		19 'sd 196608 :	LUT_out[36] = 37'sd 416022528;
		19 'sd 131072 :	LUT_out[36] = 37'sd 277348352;
		19 'sd 65536  :	LUT_out[36] = 37'sd 138674176;
		-19'sd 65536  :	LUT_out[36] = -37'sd 138674176;
		-19'sd 131072 :	LUT_out[36] = -37'sd 277348352;
		-19'sd 196608 :	LUT_out[36] = -37'sd 416022528;
		default     :	LUT_out[36] = 37'sd 0;
	endcase
end

// LUT_37 

always @ *
begin
	case(sum_level_1[37])
		19 'sd 0      :	LUT_out[37] = 37'sd 0;
		19 'sd 98304  :	LUT_out[37] = -37'sd 394002432;
		19 'sd 32768  :	LUT_out[37] = -37'sd 131334144;
		-19'sd 32768  :	LUT_out[37] = 37'sd 131334144;
		-19'sd 98304  :	LUT_out[37] = 37'sd 394002432;
		19 'sd 196608 :	LUT_out[37] = -37'sd 788004864;
		19 'sd 131072 :	LUT_out[37] = -37'sd 525336576;
		19 'sd 65536  :	LUT_out[37] = -37'sd 262668288;
		-19'sd 65536  :	LUT_out[37] = 37'sd 262668288;
		-19'sd 131072 :	LUT_out[37] = 37'sd 525336576;
		-19'sd 196608 :	LUT_out[37] = 37'sd 788004864;
		default     :	LUT_out[37] = 37'sd 0;
	endcase
end

// LUT_38 

always @ *
begin
	case(sum_level_1[38])
		19 'sd 0      :	LUT_out[38] = 37'sd 0;
		19 'sd 98304  :	LUT_out[38] = -37'sd 838336512;
		19 'sd 32768  :	LUT_out[38] = -37'sd 279445504;
		-19'sd 32768  :	LUT_out[38] = 37'sd 279445504;
		-19'sd 98304  :	LUT_out[38] = 37'sd 838336512;
		19 'sd 196608 :	LUT_out[38] = -37'sd 1676673024;
		19 'sd 131072 :	LUT_out[38] = -37'sd 1117782016;
		19 'sd 65536  :	LUT_out[38] = -37'sd 558891008;
		-19'sd 65536  :	LUT_out[38] = 37'sd 558891008;
		-19'sd 131072 :	LUT_out[38] = 37'sd 1117782016;
		-19'sd 196608 :	LUT_out[38] = 37'sd 1676673024;
		default     :	LUT_out[38] = 37'sd 0;
	endcase
end

// LUT_39 

always @ *
begin
	case(sum_level_1[39])
		19 'sd 0      :	LUT_out[39] = 37'sd 0;
		19 'sd 98304  :	LUT_out[39] = -37'sd 802062336;
		19 'sd 32768  :	LUT_out[39] = -37'sd 267354112;
		-19'sd 32768  :	LUT_out[39] = 37'sd 267354112;
		-19'sd 98304  :	LUT_out[39] = 37'sd 802062336;
		19 'sd 196608 :	LUT_out[39] = -37'sd 1604124672;
		19 'sd 131072 :	LUT_out[39] = -37'sd 1069416448;
		19 'sd 65536  :	LUT_out[39] = -37'sd 534708224;
		-19'sd 65536  :	LUT_out[39] = 37'sd 534708224;
		-19'sd 131072 :	LUT_out[39] = 37'sd 1069416448;
		-19'sd 196608 :	LUT_out[39] = 37'sd 1604124672;
		default     :	LUT_out[39] = 37'sd 0;
	endcase
end

// LUT_40 

always @ *
begin
	case(sum_level_1[40])
		19 'sd 0      :	LUT_out[40] = 37'sd 0;
		19 'sd 98304  :	LUT_out[40] = -37'sd 217841664;
		19 'sd 32768  :	LUT_out[40] = -37'sd 72613888;
		-19'sd 32768  :	LUT_out[40] = 37'sd 72613888;
		-19'sd 98304  :	LUT_out[40] = 37'sd 217841664;
		19 'sd 196608 :	LUT_out[40] = -37'sd 435683328;
		19 'sd 131072 :	LUT_out[40] = -37'sd 290455552;
		19 'sd 65536  :	LUT_out[40] = -37'sd 145227776;
		-19'sd 65536  :	LUT_out[40] = 37'sd 145227776;
		-19'sd 131072 :	LUT_out[40] = 37'sd 290455552;
		-19'sd 196608 :	LUT_out[40] = 37'sd 435683328;
		default     :	LUT_out[40] = 37'sd 0;
	endcase
end

// LUT_41 

always @ *
begin
	case(sum_level_1[41])
		19 'sd 0      :	LUT_out[41] = 37'sd 0;
		19 'sd 98304  :	LUT_out[41] = 37'sd 636026880;
		19 'sd 32768  :	LUT_out[41] = 37'sd 212008960;
		-19'sd 32768  :	LUT_out[41] = -37'sd 212008960;
		-19'sd 98304  :	LUT_out[41] = -37'sd 636026880;
		19 'sd 196608 :	LUT_out[41] = 37'sd 1272053760;
		19 'sd 131072 :	LUT_out[41] = 37'sd 848035840;
		19 'sd 65536  :	LUT_out[41] = 37'sd 424017920;
		-19'sd 65536  :	LUT_out[41] = -37'sd 424017920;
		-19'sd 131072 :	LUT_out[41] = -37'sd 848035840;
		-19'sd 196608 :	LUT_out[41] = -37'sd 1272053760;
		default     :	LUT_out[41] = 37'sd 0;
	endcase
end

// LUT_42 

always @ *
begin
	case(sum_level_1[42])
		19 'sd 0      :	LUT_out[42] = 37'sd 0;
		19 'sd 98304  :	LUT_out[42] = 37'sd 1247772672;
		19 'sd 32768  :	LUT_out[42] = 37'sd 415924224;
		-19'sd 32768  :	LUT_out[42] = -37'sd 415924224;
		-19'sd 98304  :	LUT_out[42] = -37'sd 1247772672;
		19 'sd 196608 :	LUT_out[42] = 37'sd 2495545344;
		19 'sd 131072 :	LUT_out[42] = 37'sd 1663696896;
		19 'sd 65536  :	LUT_out[42] = 37'sd 831848448;
		-19'sd 65536  :	LUT_out[42] = -37'sd 831848448;
		-19'sd 131072 :	LUT_out[42] = -37'sd 1663696896;
		-19'sd 196608 :	LUT_out[42] = -37'sd 2495545344;
		default     :	LUT_out[42] = 37'sd 0;
	endcase
end

// LUT_43 

always @ *
begin
	case(sum_level_1[43])
		19 'sd 0      :	LUT_out[43] = 37'sd 0;
		19 'sd 98304  :	LUT_out[43] = 37'sd 1150058496;
		19 'sd 32768  :	LUT_out[43] = 37'sd 383352832;
		-19'sd 32768  :	LUT_out[43] = -37'sd 383352832;
		-19'sd 98304  :	LUT_out[43] = -37'sd 1150058496;
		19 'sd 196608 :	LUT_out[43] = 37'sd 2300116992;
		19 'sd 131072 :	LUT_out[43] = 37'sd 1533411328;
		19 'sd 65536  :	LUT_out[43] = 37'sd 766705664;
		-19'sd 65536  :	LUT_out[43] = -37'sd 766705664;
		-19'sd 131072 :	LUT_out[43] = -37'sd 1533411328;
		-19'sd 196608 :	LUT_out[43] = -37'sd 2300116992;
		default     :	LUT_out[43] = 37'sd 0;
	endcase
end

// LUT_44 

always @ *
begin
	case(sum_level_1[44])
		19 'sd 0      :	LUT_out[44] = 37'sd 0;
		19 'sd 98304  :	LUT_out[44] = 37'sd 225017856;
		19 'sd 32768  :	LUT_out[44] = 37'sd 75005952;
		-19'sd 32768  :	LUT_out[44] = -37'sd 75005952;
		-19'sd 98304  :	LUT_out[44] = -37'sd 225017856;
		19 'sd 196608 :	LUT_out[44] = 37'sd 450035712;
		19 'sd 131072 :	LUT_out[44] = 37'sd 300023808;
		19 'sd 65536  :	LUT_out[44] = 37'sd 150011904;
		-19'sd 65536  :	LUT_out[44] = -37'sd 150011904;
		-19'sd 131072 :	LUT_out[44] = -37'sd 300023808;
		-19'sd 196608 :	LUT_out[44] = -37'sd 450035712;
		default     :	LUT_out[44] = 37'sd 0;
	endcase
end

// LUT_45 

always @ *
begin
	case(sum_level_1[45])
		19 'sd 0      :	LUT_out[45] = 37'sd 0;
		19 'sd 98304  :	LUT_out[45] = -37'sd 1141309440;
		19 'sd 32768  :	LUT_out[45] = -37'sd 380436480;
		-19'sd 32768  :	LUT_out[45] = 37'sd 380436480;
		-19'sd 98304  :	LUT_out[45] = 37'sd 1141309440;
		19 'sd 196608 :	LUT_out[45] = -37'sd 2282618880;
		19 'sd 131072 :	LUT_out[45] = -37'sd 1521745920;
		19 'sd 65536  :	LUT_out[45] = -37'sd 760872960;
		-19'sd 65536  :	LUT_out[45] = 37'sd 760872960;
		-19'sd 131072 :	LUT_out[45] = 37'sd 1521745920;
		-19'sd 196608 :	LUT_out[45] = 37'sd 2282618880;
		default     :	LUT_out[45] = 37'sd 0;
	endcase
end

// LUT_46 

always @ *
begin
	case(sum_level_1[46])
		19 'sd 0      :	LUT_out[46] = 37'sd 0;
		19 'sd 98304  :	LUT_out[46] = -37'sd 2164457472;
		19 'sd 32768  :	LUT_out[46] = -37'sd 721485824;
		-19'sd 32768  :	LUT_out[46] = 37'sd 721485824;
		-19'sd 98304  :	LUT_out[46] = 37'sd 2164457472;
		19 'sd 196608 :	LUT_out[46] = -37'sd 4328914944;
		19 'sd 131072 :	LUT_out[46] = -37'sd 2885943296;
		19 'sd 65536  :	LUT_out[46] = -37'sd 1442971648;
		-19'sd 65536  :	LUT_out[46] = 37'sd 1442971648;
		-19'sd 131072 :	LUT_out[46] = 37'sd 2885943296;
		-19'sd 196608 :	LUT_out[46] = 37'sd 4328914944;
		default     :	LUT_out[46] = 37'sd 0;
	endcase
end

// LUT_47 

always @ *
begin
	case(sum_level_1[47])
		19 'sd 0      :	LUT_out[47] = 37'sd 0;
		19 'sd 98304  :	LUT_out[47] = -37'sd 2010808320;
		19 'sd 32768  :	LUT_out[47] = -37'sd 670269440;
		-19'sd 32768  :	LUT_out[47] = 37'sd 670269440;
		-19'sd 98304  :	LUT_out[47] = 37'sd 2010808320;
		19 'sd 196608 :	LUT_out[47] = -37'sd 4021616640;
		19 'sd 131072 :	LUT_out[47] = -37'sd 2681077760;
		19 'sd 65536  :	LUT_out[47] = -37'sd 1340538880;
		-19'sd 65536  :	LUT_out[47] = 37'sd 1340538880;
		-19'sd 131072 :	LUT_out[47] = 37'sd 2681077760;
		-19'sd 196608 :	LUT_out[47] = 37'sd 4021616640;
		default     :	LUT_out[47] = 37'sd 0;
	endcase
end

// LUT_48 

always @ *
begin
	case(sum_level_1[48])
		19 'sd 0      :	LUT_out[48] = 37'sd 0;
		19 'sd 98304  :	LUT_out[48] = -37'sd 229343232;
		19 'sd 32768  :	LUT_out[48] = -37'sd 76447744;
		-19'sd 32768  :	LUT_out[48] = 37'sd 76447744;
		-19'sd 98304  :	LUT_out[48] = 37'sd 229343232;
		19 'sd 196608 :	LUT_out[48] = -37'sd 458686464;
		19 'sd 131072 :	LUT_out[48] = -37'sd 305790976;
		19 'sd 65536  :	LUT_out[48] = -37'sd 152895488;
		-19'sd 65536  :	LUT_out[48] = 37'sd 152895488;
		-19'sd 131072 :	LUT_out[48] = 37'sd 305790976;
		-19'sd 196608 :	LUT_out[48] = 37'sd 458686464;
		default     :	LUT_out[48] = 37'sd 0;
	endcase
end

// LUT_49 

always @ *
begin
	case(sum_level_1[49])
		19 'sd 0      :	LUT_out[49] = 37'sd 0;
		19 'sd 98304  :	LUT_out[49] = 37'sd 2949906432;
		19 'sd 32768  :	LUT_out[49] = 37'sd 983302144;
		-19'sd 32768  :	LUT_out[49] = -37'sd 983302144;
		-19'sd 98304  :	LUT_out[49] = -37'sd 2949906432;
		19 'sd 196608 :	LUT_out[49] = 37'sd 5899812864;
		19 'sd 131072 :	LUT_out[49] = 37'sd 3933208576;
		19 'sd 65536  :	LUT_out[49] = 37'sd 1966604288;
		-19'sd 65536  :	LUT_out[49] = -37'sd 1966604288;
		-19'sd 131072 :	LUT_out[49] = -37'sd 3933208576;
		-19'sd 196608 :	LUT_out[49] = -37'sd 5899812864;
		default     :	LUT_out[49] = 37'sd 0;
	endcase
end

// LUT_50 

always @ *
begin
	case(sum_level_1[50])
		19 'sd 0      :	LUT_out[50] = 37'sd 0;
		19 'sd 98304  :	LUT_out[50] = 37'sd 6623133696;
		19 'sd 32768  :	LUT_out[50] = 37'sd 2207711232;
		-19'sd 32768  :	LUT_out[50] = -37'sd 2207711232;
		-19'sd 98304  :	LUT_out[50] = -37'sd 6623133696;
		19 'sd 196608 :	LUT_out[50] = 37'sd 13246267392;
		19 'sd 131072 :	LUT_out[50] = 37'sd 8830844928;
		19 'sd 65536  :	LUT_out[50] = 37'sd 4415422464;
		-19'sd 65536  :	LUT_out[50] = -37'sd 4415422464;
		-19'sd 131072 :	LUT_out[50] = -37'sd 8830844928;
		-19'sd 196608 :	LUT_out[50] = -37'sd 13246267392;
		default     :	LUT_out[50] = 37'sd 0;
	endcase
end

// LUT_51 

always @ *
begin
	case(sum_level_1[51])
		19 'sd 0      :	LUT_out[51] = 37'sd 0;
		19 'sd 98304  :	LUT_out[51] = 37'sd 9547087872;
		19 'sd 32768  :	LUT_out[51] = 37'sd 3182362624;
		-19'sd 32768  :	LUT_out[51] = -37'sd 3182362624;
		-19'sd 98304  :	LUT_out[51] = -37'sd 9547087872;
		19 'sd 196608 :	LUT_out[51] = 37'sd 19094175744;
		19 'sd 131072 :	LUT_out[51] = 37'sd 12729450496;
		19 'sd 65536  :	LUT_out[51] = 37'sd 6364725248;
		-19'sd 65536  :	LUT_out[51] = -37'sd 6364725248;
		-19'sd 131072 :	LUT_out[51] = -37'sd 12729450496;
		-19'sd 196608 :	LUT_out[51] = -37'sd 19094175744;
		default     :	LUT_out[51] = 37'sd 0;
	endcase
end

// LUT_52 

always @ *
begin
	case(sum_level_1[52])
		19 'sd 0      :	LUT_out[52] = 37'sd 0;
		19 'sd 98304  :	LUT_out[52] = 37'sd 10660184064;
		19 'sd 32768  :	LUT_out[52] = 37'sd 3553394688;
		-19'sd 32768  :	LUT_out[52] = -37'sd 3553394688;
		-19'sd 98304  :	LUT_out[52] = -37'sd 10660184064;
		default     :	LUT_out[52] = 37'sd 0;
	endcase
end


endmodule