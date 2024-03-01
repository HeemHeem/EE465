module tx_gs_filter( input clk, reset, sym_clk_en, sam_clk_en,
							input [1:0] sw,
                    input signed [17:0] x_in, //1s17
                    output reg signed [17:0] y); //1s17);



// create array of vectors
integer  i;
reg signed [17:0] x[64:0]; // for 65 coefficients
reg signed [18:0] sum_level_1[32:0]; // 33 additions
reg signed [17:0] sum_out[31:0];
reg signed [36:0] LUT_out[32:0]; // 1s35 but changed to 2s35
//reg signed [17:0] b[10:0]; // coefficients

always @ (posedge clk or posedge reset)
    if(reset)
        x[0] <= 0;
    else if(sam_clk_en)
        x[0] <= x_in;
	else
		x[0] <= x[0];

always @ (posedge clk or posedge reset)
    if(reset) 
    begin
        for(i=1; i<65; i=i+1)
            x[i] <= 0;
    end
    else if (sam_clk_en)
    begin
        for(i=1; i<65; i=i+1)
            x[i] <= x[i-1];
    end
	else
	begin
		for(i=1; i <65; i=i+1)
			x[i] <= x[i];
	end



// add values the require the same coefficients
always @ *
begin
    for(i=0; i<=31; i= i+1)
    sum_level_1[i] <= {x[i][17], x[i]} + {x[64-i][17], x[64-i]}; // sign extend to see whats up 2s17
end

// center value
always @ *
    sum_level_1[32] <= {x[32][17], x[32]};


// multiply by coefficients
// always @ *
// begin
//     for(i=0; i <= 10; i=i+1)
//     mult_out[i] <= sum_level_1[i] * b[i]; 
// end

// sum up mutlipliers
always @ *
if (reset)
    for (i = 0; i <=31; i=i+1)
        sum_out[i] = 18'sd 0;
else
    begin
        sum_out[0] = LUT_out[0][35:18] + LUT_out[1][35:18];
        for(i = 0; i <=30 ; i=i+1)
            sum_out[i+1] <= sum_out[i] + LUT_out[i+2][35:18]; 
    end
    

always @ (posedge clk or posedge reset)
    if(reset)
        y <= 0;
    else if (sam_clk_en)
        y <= sum_out[31];
	else
		y <= y;
 


// LUT_0 

always @ *
begin
	case(sum_level_1[0])
		19 'sd 0      :	LUT_out[0]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[0]  = 37'sd 132415488;
		19 'sd 32768  :	LUT_out[0]  = 37'sd 44138496;
		-19'sd 32768  :	LUT_out[0]  = -37'sd 44138496;
		-19'sd 98304  :	LUT_out[0]  = -37'sd 132415488;
		19 'sd 196608 :	LUT_out[0]  = 37'sd 264830976;
		19 'sd 131072 :	LUT_out[0]  = 37'sd 176553984;
		19 'sd 65536  :	LUT_out[0]  = 37'sd 88276992;
		-19'sd 65536  :	LUT_out[0]  = -37'sd 88276992;
		-19'sd 131072 :	LUT_out[0]  = -37'sd 176553984;
		-19'sd 196608 :	LUT_out[0]  = -37'sd 264830976;
		default     :	LUT_out[0]  = 37'sd 0;
	endcase
end

// LUT_1 

always @ *
begin
	case(sum_level_1[1])
		19 'sd 0      :	LUT_out[1]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[1]  = 37'sd 54165504;
		19 'sd 32768  :	LUT_out[1]  = 37'sd 18055168;
		-19'sd 32768  :	LUT_out[1]  = -37'sd 18055168;
		-19'sd 98304  :	LUT_out[1]  = -37'sd 54165504;
		19 'sd 196608 :	LUT_out[1]  = 37'sd 108331008;
		19 'sd 131072 :	LUT_out[1]  = 37'sd 72220672;
		19 'sd 65536  :	LUT_out[1]  = 37'sd 36110336;
		-19'sd 65536  :	LUT_out[1]  = -37'sd 36110336;
		-19'sd 131072 :	LUT_out[1]  = -37'sd 72220672;
		-19'sd 196608 :	LUT_out[1]  = -37'sd 108331008;
		default     :	LUT_out[1]  = 37'sd 0;
	endcase
end

// LUT_2 

always @ *
begin
	case(sum_level_1[2])
		19 'sd 0      :	LUT_out[2]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[2]  = -37'sd 85131264;
		19 'sd 32768  :	LUT_out[2]  = -37'sd 28377088;
		-19'sd 32768  :	LUT_out[2]  = 37'sd 28377088;
		-19'sd 98304  :	LUT_out[2]  = 37'sd 85131264;
		19 'sd 196608 :	LUT_out[2]  = -37'sd 170262528;
		19 'sd 131072 :	LUT_out[2]  = -37'sd 113508352;
		19 'sd 65536  :	LUT_out[2]  = -37'sd 56754176;
		-19'sd 65536  :	LUT_out[2]  = 37'sd 56754176;
		-19'sd 131072 :	LUT_out[2]  = 37'sd 113508352;
		-19'sd 196608 :	LUT_out[2]  = 37'sd 170262528;
		default     :	LUT_out[2]  = 37'sd 0;
	endcase
end

// LUT_3 

always @ *
begin
	case(sum_level_1[3])
		19 'sd 0      :	LUT_out[3]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[3]  = -37'sd 191299584;
		19 'sd 32768  :	LUT_out[3]  = -37'sd 63766528;
		-19'sd 32768  :	LUT_out[3]  = 37'sd 63766528;
		-19'sd 98304  :	LUT_out[3]  = 37'sd 191299584;
		19 'sd 196608 :	LUT_out[3]  = -37'sd 382599168;
		19 'sd 131072 :	LUT_out[3]  = -37'sd 255066112;
		19 'sd 65536  :	LUT_out[3]  = -37'sd 127533056;
		-19'sd 65536  :	LUT_out[3]  = 37'sd 127533056;
		-19'sd 131072 :	LUT_out[3]  = 37'sd 255066112;
		-19'sd 196608 :	LUT_out[3]  = 37'sd 382599168;
		default     :	LUT_out[3]  = 37'sd 0;
	endcase
end

// LUT_4 

always @ *
begin
	case(sum_level_1[4])
		19 'sd 0      :	LUT_out[4]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[4]  = -37'sd 175964160;
		19 'sd 32768  :	LUT_out[4]  = -37'sd 58654720;
		-19'sd 32768  :	LUT_out[4]  = 37'sd 58654720;
		-19'sd 98304  :	LUT_out[4]  = 37'sd 175964160;
		19 'sd 196608 :	LUT_out[4]  = -37'sd 351928320;
		19 'sd 131072 :	LUT_out[4]  = -37'sd 234618880;
		19 'sd 65536  :	LUT_out[4]  = -37'sd 117309440;
		-19'sd 65536  :	LUT_out[4]  = 37'sd 117309440;
		-19'sd 131072 :	LUT_out[4]  = 37'sd 234618880;
		-19'sd 196608 :	LUT_out[4]  = 37'sd 351928320;
		default     :	LUT_out[4]  = 37'sd 0;
	endcase
end

// LUT_5 

always @ *
begin
	case(sum_level_1[5])
		19 'sd 0      :	LUT_out[5]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[5]  = -37'sd 24182784;
		19 'sd 32768  :	LUT_out[5]  = -37'sd 8060928;
		-19'sd 32768  :	LUT_out[5]  = 37'sd 8060928;
		-19'sd 98304  :	LUT_out[5]  = 37'sd 24182784;
		19 'sd 196608 :	LUT_out[5]  = -37'sd 48365568;
		19 'sd 131072 :	LUT_out[5]  = -37'sd 32243712;
		19 'sd 65536  :	LUT_out[5]  = -37'sd 16121856;
		-19'sd 65536  :	LUT_out[5]  = 37'sd 16121856;
		-19'sd 131072 :	LUT_out[5]  = 37'sd 32243712;
		-19'sd 196608 :	LUT_out[5]  = 37'sd 48365568;
		default     :	LUT_out[5]  = 37'sd 0;
	endcase
end

// LUT_6 

always @ *
begin
	case(sum_level_1[6])
		19 'sd 0      :	LUT_out[6]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[6]  = 37'sd 179798016;
		19 'sd 32768  :	LUT_out[6]  = 37'sd 59932672;
		-19'sd 32768  :	LUT_out[6]  = -37'sd 59932672;
		-19'sd 98304  :	LUT_out[6]  = -37'sd 179798016;
		19 'sd 196608 :	LUT_out[6]  = 37'sd 359596032;
		19 'sd 131072 :	LUT_out[6]  = 37'sd 239730688;
		19 'sd 65536  :	LUT_out[6]  = 37'sd 119865344;
		-19'sd 65536  :	LUT_out[6]  = -37'sd 119865344;
		-19'sd 131072 :	LUT_out[6]  = -37'sd 239730688;
		-19'sd 196608 :	LUT_out[6]  = -37'sd 359596032;
		default     :	LUT_out[6]  = 37'sd 0;
	endcase
end

// LUT_7 

always @ *
begin
	case(sum_level_1[7])
		19 'sd 0      :	LUT_out[7]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[7]  = 37'sd 295993344;
		19 'sd 32768  :	LUT_out[7]  = 37'sd 98664448;
		-19'sd 32768  :	LUT_out[7]  = -37'sd 98664448;
		-19'sd 98304  :	LUT_out[7]  = -37'sd 295993344;
		19 'sd 196608 :	LUT_out[7]  = 37'sd 591986688;
		19 'sd 131072 :	LUT_out[7]  = 37'sd 394657792;
		19 'sd 65536  :	LUT_out[7]  = 37'sd 197328896;
		-19'sd 65536  :	LUT_out[7]  = -37'sd 197328896;
		-19'sd 131072 :	LUT_out[7]  = -37'sd 394657792;
		-19'sd 196608 :	LUT_out[7]  = -37'sd 591986688;
		default     :	LUT_out[7]  = 37'sd 0;
	endcase
end

// LUT_8 

always @ *
begin
	case(sum_level_1[8])
		19 'sd 0      :	LUT_out[8]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[8]  = 37'sd 220299264;
		19 'sd 32768  :	LUT_out[8]  = 37'sd 73433088;
		-19'sd 32768  :	LUT_out[8]  = -37'sd 73433088;
		-19'sd 98304  :	LUT_out[8]  = -37'sd 220299264;
		19 'sd 196608 :	LUT_out[8]  = 37'sd 440598528;
		19 'sd 131072 :	LUT_out[8]  = 37'sd 293732352;
		19 'sd 65536  :	LUT_out[8]  = 37'sd 146866176;
		-19'sd 65536  :	LUT_out[8]  = -37'sd 146866176;
		-19'sd 131072 :	LUT_out[8]  = -37'sd 293732352;
		-19'sd 196608 :	LUT_out[8]  = -37'sd 440598528;
		default     :	LUT_out[8]  = 37'sd 0;
	endcase
end

// LUT_9 

always @ *
begin
	case(sum_level_1[9])
		19 'sd 0      :	LUT_out[9]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[9]  = -37'sd 32047104;
		19 'sd 32768  :	LUT_out[9]  = -37'sd 10682368;
		-19'sd 32768  :	LUT_out[9]  = 37'sd 10682368;
		-19'sd 98304  :	LUT_out[9]  = 37'sd 32047104;
		19 'sd 196608 :	LUT_out[9]  = -37'sd 64094208;
		19 'sd 131072 :	LUT_out[9]  = -37'sd 42729472;
		19 'sd 65536  :	LUT_out[9]  = -37'sd 21364736;
		-19'sd 65536  :	LUT_out[9]  = 37'sd 21364736;
		-19'sd 131072 :	LUT_out[9]  = 37'sd 42729472;
		-19'sd 196608 :	LUT_out[9]  = 37'sd 64094208;
		default     :	LUT_out[9]  = 37'sd 0;
	endcase
end

// LUT_10 

always @ *
begin
	case(sum_level_1[10])
		19 'sd 0      :	LUT_out[10] = 37'sd 0;
		19 'sd 98304  :	LUT_out[10] = -37'sd 314966016;
		19 'sd 32768  :	LUT_out[10] = -37'sd 104988672;
		-19'sd 32768  :	LUT_out[10] = 37'sd 104988672;
		-19'sd 98304  :	LUT_out[10] = 37'sd 314966016;
		19 'sd 196608 :	LUT_out[10] = -37'sd 629932032;
		19 'sd 131072 :	LUT_out[10] = -37'sd 419954688;
		19 'sd 65536  :	LUT_out[10] = -37'sd 209977344;
		-19'sd 65536  :	LUT_out[10] = 37'sd 209977344;
		-19'sd 131072 :	LUT_out[10] = 37'sd 419954688;
		-19'sd 196608 :	LUT_out[10] = 37'sd 629932032;
		default     :	LUT_out[10] = 37'sd 0;
	endcase
end

// LUT_11 

always @ *
begin
	case(sum_level_1[11])
		19 'sd 0      :	LUT_out[11] = 37'sd 0;
		19 'sd 98304  :	LUT_out[11] = -37'sd 431063040;
		19 'sd 32768  :	LUT_out[11] = -37'sd 143687680;
		-19'sd 32768  :	LUT_out[11] = 37'sd 143687680;
		-19'sd 98304  :	LUT_out[11] = 37'sd 431063040;
		19 'sd 196608 :	LUT_out[11] = -37'sd 862126080;
		19 'sd 131072 :	LUT_out[11] = -37'sd 574750720;
		19 'sd 65536  :	LUT_out[11] = -37'sd 287375360;
		-19'sd 65536  :	LUT_out[11] = 37'sd 287375360;
		-19'sd 131072 :	LUT_out[11] = 37'sd 574750720;
		-19'sd 196608 :	LUT_out[11] = 37'sd 862126080;
		default     :	LUT_out[11] = 37'sd 0;
	endcase
end

// LUT_12 

always @ *
begin
	case(sum_level_1[12])
		19 'sd 0      :	LUT_out[12] = 37'sd 0;
		19 'sd 98304  :	LUT_out[12] = -37'sd 263159808;
		19 'sd 32768  :	LUT_out[12] = -37'sd 87719936;
		-19'sd 32768  :	LUT_out[12] = 37'sd 87719936;
		-19'sd 98304  :	LUT_out[12] = 37'sd 263159808;
		19 'sd 196608 :	LUT_out[12] = -37'sd 526319616;
		19 'sd 131072 :	LUT_out[12] = -37'sd 350879744;
		19 'sd 65536  :	LUT_out[12] = -37'sd 175439872;
		-19'sd 65536  :	LUT_out[12] = 37'sd 175439872;
		-19'sd 131072 :	LUT_out[12] = 37'sd 350879744;
		-19'sd 196608 :	LUT_out[12] = 37'sd 526319616;
		default     :	LUT_out[12] = 37'sd 0;
	endcase
end

// LUT_13 

always @ *
begin
	case(sum_level_1[13])
		19 'sd 0      :	LUT_out[13] = 37'sd 0;
		19 'sd 98304  :	LUT_out[13] = 37'sd 127205376;
		19 'sd 32768  :	LUT_out[13] = 37'sd 42401792;
		-19'sd 32768  :	LUT_out[13] = -37'sd 42401792;
		-19'sd 98304  :	LUT_out[13] = -37'sd 127205376;
		19 'sd 196608 :	LUT_out[13] = 37'sd 254410752;
		19 'sd 131072 :	LUT_out[13] = 37'sd 169607168;
		19 'sd 65536  :	LUT_out[13] = 37'sd 84803584;
		-19'sd 65536  :	LUT_out[13] = -37'sd 84803584;
		-19'sd 131072 :	LUT_out[13] = -37'sd 169607168;
		-19'sd 196608 :	LUT_out[13] = -37'sd 254410752;
		default     :	LUT_out[13] = 37'sd 0;
	endcase
end

// LUT_14 

always @ *
begin
	case(sum_level_1[14])
		19 'sd 0      :	LUT_out[14] = 37'sd 0;
		19 'sd 98304  :	LUT_out[14] = 37'sd 508821504;
		19 'sd 32768  :	LUT_out[14] = 37'sd 169607168;
		-19'sd 32768  :	LUT_out[14] = -37'sd 169607168;
		-19'sd 98304  :	LUT_out[14] = -37'sd 508821504;
		19 'sd 196608 :	LUT_out[14] = 37'sd 1017643008;
		19 'sd 131072 :	LUT_out[14] = 37'sd 678428672;
		19 'sd 65536  :	LUT_out[14] = 37'sd 339214336;
		-19'sd 65536  :	LUT_out[14] = -37'sd 339214336;
		-19'sd 131072 :	LUT_out[14] = -37'sd 678428672;
		-19'sd 196608 :	LUT_out[14] = -37'sd 1017643008;
		default     :	LUT_out[14] = 37'sd 0;
	endcase
end

// LUT_15 

always @ *
begin
	case(sum_level_1[15])
		19 'sd 0      :	LUT_out[15] = 37'sd 0;
		19 'sd 98304  :	LUT_out[15] = 37'sd 610172928;
		19 'sd 32768  :	LUT_out[15] = 37'sd 203390976;
		-19'sd 32768  :	LUT_out[15] = -37'sd 203390976;
		-19'sd 98304  :	LUT_out[15] = -37'sd 610172928;
		19 'sd 196608 :	LUT_out[15] = 37'sd 1220345856;
		19 'sd 131072 :	LUT_out[15] = 37'sd 813563904;
		19 'sd 65536  :	LUT_out[15] = 37'sd 406781952;
		-19'sd 65536  :	LUT_out[15] = -37'sd 406781952;
		-19'sd 131072 :	LUT_out[15] = -37'sd 813563904;
		-19'sd 196608 :	LUT_out[15] = -37'sd 1220345856;
		default     :	LUT_out[15] = 37'sd 0;
	endcase
end

// LUT_16 

always @ *
begin
	case(sum_level_1[16])
		19 'sd 0      :	LUT_out[16] = 37'sd 0;
		19 'sd 98304  :	LUT_out[16] = 37'sd 302088192;
		19 'sd 32768  :	LUT_out[16] = 37'sd 100696064;
		-19'sd 32768  :	LUT_out[16] = -37'sd 100696064;
		-19'sd 98304  :	LUT_out[16] = -37'sd 302088192;
		19 'sd 196608 :	LUT_out[16] = 37'sd 604176384;
		19 'sd 131072 :	LUT_out[16] = 37'sd 402784256;
		19 'sd 65536  :	LUT_out[16] = 37'sd 201392128;
		-19'sd 65536  :	LUT_out[16] = -37'sd 201392128;
		-19'sd 131072 :	LUT_out[16] = -37'sd 402784256;
		-19'sd 196608 :	LUT_out[16] = -37'sd 604176384;
		default     :	LUT_out[16] = 37'sd 0;
	endcase
end

// LUT_17 

always @ *
begin
	case(sum_level_1[17])
		19 'sd 0      :	LUT_out[17] = 37'sd 0;
		19 'sd 98304  :	LUT_out[17] = -37'sd 285081600;
		19 'sd 32768  :	LUT_out[17] = -37'sd 95027200;
		-19'sd 32768  :	LUT_out[17] = 37'sd 95027200;
		-19'sd 98304  :	LUT_out[17] = 37'sd 285081600;
		19 'sd 196608 :	LUT_out[17] = -37'sd 570163200;
		19 'sd 131072 :	LUT_out[17] = -37'sd 380108800;
		19 'sd 65536  :	LUT_out[17] = -37'sd 190054400;
		-19'sd 65536  :	LUT_out[17] = 37'sd 190054400;
		-19'sd 131072 :	LUT_out[17] = 37'sd 380108800;
		-19'sd 196608 :	LUT_out[17] = 37'sd 570163200;
		default     :	LUT_out[17] = 37'sd 0;
	endcase
end

// LUT_18 

always @ *
begin
	case(sum_level_1[18])
		19 'sd 0      :	LUT_out[18] = 37'sd 0;
		19 'sd 98304  :	LUT_out[18] = -37'sd 799604736;
		19 'sd 32768  :	LUT_out[18] = -37'sd 266534912;
		-19'sd 32768  :	LUT_out[18] = 37'sd 266534912;
		-19'sd 98304  :	LUT_out[18] = 37'sd 799604736;
		19 'sd 196608 :	LUT_out[18] = -37'sd 1599209472;
		19 'sd 131072 :	LUT_out[18] = -37'sd 1066139648;
		19 'sd 65536  :	LUT_out[18] = -37'sd 533069824;
		-19'sd 65536  :	LUT_out[18] = 37'sd 533069824;
		-19'sd 131072 :	LUT_out[18] = 37'sd 1066139648;
		-19'sd 196608 :	LUT_out[18] = 37'sd 1599209472;
		default     :	LUT_out[18] = 37'sd 0;
	endcase
end

// LUT_19 

always @ *
begin
	case(sum_level_1[19])
		19 'sd 0      :	LUT_out[19] = 37'sd 0;
		19 'sd 98304  :	LUT_out[19] = -37'sd 865566720;
		19 'sd 32768  :	LUT_out[19] = -37'sd 288522240;
		-19'sd 32768  :	LUT_out[19] = 37'sd 288522240;
		-19'sd 98304  :	LUT_out[19] = 37'sd 865566720;
		19 'sd 196608 :	LUT_out[19] = -37'sd 1731133440;
		19 'sd 131072 :	LUT_out[19] = -37'sd 1154088960;
		19 'sd 65536  :	LUT_out[19] = -37'sd 577044480;
		-19'sd 65536  :	LUT_out[19] = 37'sd 577044480;
		-19'sd 131072 :	LUT_out[19] = 37'sd 1154088960;
		-19'sd 196608 :	LUT_out[19] = 37'sd 1731133440;
		default     :	LUT_out[19] = 37'sd 0;
	endcase
end

// LUT_20 

always @ *
begin
	case(sum_level_1[20])
		19 'sd 0      :	LUT_out[20] = 37'sd 0;
		19 'sd 98304  :	LUT_out[20] = -37'sd 335118336;
		19 'sd 32768  :	LUT_out[20] = -37'sd 111706112;
		-19'sd 32768  :	LUT_out[20] = 37'sd 111706112;
		-19'sd 98304  :	LUT_out[20] = 37'sd 335118336;
		19 'sd 196608 :	LUT_out[20] = -37'sd 670236672;
		19 'sd 131072 :	LUT_out[20] = -37'sd 446824448;
		19 'sd 65536  :	LUT_out[20] = -37'sd 223412224;
		-19'sd 65536  :	LUT_out[20] = 37'sd 223412224;
		-19'sd 131072 :	LUT_out[20] = 37'sd 446824448;
		-19'sd 196608 :	LUT_out[20] = 37'sd 670236672;
		default     :	LUT_out[20] = 37'sd 0;
	endcase
end

// LUT_21 

always @ *
begin
	case(sum_level_1[21])
		19 'sd 0      :	LUT_out[21] = 37'sd 0;
		19 'sd 98304  :	LUT_out[21] = 37'sd 561709056;
		19 'sd 32768  :	LUT_out[21] = 37'sd 187236352;
		-19'sd 32768  :	LUT_out[21] = -37'sd 187236352;
		-19'sd 98304  :	LUT_out[21] = -37'sd 561709056;
		19 'sd 196608 :	LUT_out[21] = 37'sd 1123418112;
		19 'sd 131072 :	LUT_out[21] = 37'sd 748945408;
		19 'sd 65536  :	LUT_out[21] = 37'sd 374472704;
		-19'sd 65536  :	LUT_out[21] = -37'sd 374472704;
		-19'sd 131072 :	LUT_out[21] = -37'sd 748945408;
		-19'sd 196608 :	LUT_out[21] = -37'sd 1123418112;
		default     :	LUT_out[21] = 37'sd 0;
	endcase
end

// LUT_22 

always @ *
begin
	case(sum_level_1[22])
		19 'sd 0      :	LUT_out[22] = 37'sd 0;
		19 'sd 98304  :	LUT_out[22] = 37'sd 1288372224;
		19 'sd 32768  :	LUT_out[22] = 37'sd 429457408;
		-19'sd 32768  :	LUT_out[22] = -37'sd 429457408;
		-19'sd 98304  :	LUT_out[22] = -37'sd 1288372224;
		19 'sd 196608 :	LUT_out[22] = 37'sd 2576744448;
		19 'sd 131072 :	LUT_out[22] = 37'sd 1717829632;
		19 'sd 65536  :	LUT_out[22] = 37'sd 858914816;
		-19'sd 65536  :	LUT_out[22] = -37'sd 858914816;
		-19'sd 131072 :	LUT_out[22] = -37'sd 1717829632;
		-19'sd 196608 :	LUT_out[22] = -37'sd 2576744448;
		default     :	LUT_out[22] = 37'sd 0;
	endcase
end

// LUT_23 

always @ *
begin
	case(sum_level_1[23])
		19 'sd 0      :	LUT_out[23] = 37'sd 0;
		19 'sd 98304  :	LUT_out[23] = 37'sd 1290633216;
		19 'sd 32768  :	LUT_out[23] = 37'sd 430211072;
		-19'sd 32768  :	LUT_out[23] = -37'sd 430211072;
		-19'sd 98304  :	LUT_out[23] = -37'sd 1290633216;
		19 'sd 196608 :	LUT_out[23] = 37'sd 2581266432;
		19 'sd 131072 :	LUT_out[23] = 37'sd 1720844288;
		19 'sd 65536  :	LUT_out[23] = 37'sd 860422144;
		-19'sd 65536  :	LUT_out[23] = -37'sd 860422144;
		-19'sd 131072 :	LUT_out[23] = -37'sd 1720844288;
		-19'sd 196608 :	LUT_out[23] = -37'sd 2581266432;
		default     :	LUT_out[23] = 37'sd 0;
	endcase
end

// LUT_24 

always @ *
begin
	case(sum_level_1[24])
		19 'sd 0      :	LUT_out[24] = 37'sd 0;
		19 'sd 98304  :	LUT_out[24] = 37'sd 360185856;
		19 'sd 32768  :	LUT_out[24] = 37'sd 120061952;
		-19'sd 32768  :	LUT_out[24] = -37'sd 120061952;
		-19'sd 98304  :	LUT_out[24] = -37'sd 360185856;
		19 'sd 196608 :	LUT_out[24] = 37'sd 720371712;
		19 'sd 131072 :	LUT_out[24] = 37'sd 480247808;
		19 'sd 65536  :	LUT_out[24] = 37'sd 240123904;
		-19'sd 65536  :	LUT_out[24] = -37'sd 240123904;
		-19'sd 131072 :	LUT_out[24] = -37'sd 480247808;
		-19'sd 196608 :	LUT_out[24] = -37'sd 720371712;
		default     :	LUT_out[24] = 37'sd 0;
	endcase
end

// LUT_25 

always @ *
begin
	case(sum_level_1[25])
		19 'sd 0      :	LUT_out[25] = 37'sd 0;
		19 'sd 98304  :	LUT_out[25] = -37'sd 1139933184;
		19 'sd 32768  :	LUT_out[25] = -37'sd 379977728;
		-19'sd 32768  :	LUT_out[25] = 37'sd 379977728;
		-19'sd 98304  :	LUT_out[25] = 37'sd 1139933184;
		19 'sd 196608 :	LUT_out[25] = -37'sd 2279866368;
		19 'sd 131072 :	LUT_out[25] = -37'sd 1519910912;
		19 'sd 65536  :	LUT_out[25] = -37'sd 759955456;
		-19'sd 65536  :	LUT_out[25] = 37'sd 759955456;
		-19'sd 131072 :	LUT_out[25] = 37'sd 1519910912;
		-19'sd 196608 :	LUT_out[25] = 37'sd 2279866368;
		default     :	LUT_out[25] = 37'sd 0;
	endcase
end

// LUT_26 

always @ *
begin
	case(sum_level_1[26])
		19 'sd 0      :	LUT_out[26] = 37'sd 0;
		19 'sd 98304  :	LUT_out[26] = -37'sd 2348384256;
		19 'sd 32768  :	LUT_out[26] = -37'sd 782794752;
		-19'sd 32768  :	LUT_out[26] = 37'sd 782794752;
		-19'sd 98304  :	LUT_out[26] = 37'sd 2348384256;
		19 'sd 196608 :	LUT_out[26] = -37'sd 4696768512;
		19 'sd 131072 :	LUT_out[26] = -37'sd 3131179008;
		19 'sd 65536  :	LUT_out[26] = -37'sd 1565589504;
		-19'sd 65536  :	LUT_out[26] = 37'sd 1565589504;
		-19'sd 131072 :	LUT_out[26] = 37'sd 3131179008;
		-19'sd 196608 :	LUT_out[26] = 37'sd 4696768512;
		default     :	LUT_out[26] = 37'sd 0;
	endcase
end

// LUT_27 

always @ *
begin
	case(sum_level_1[27])
		19 'sd 0      :	LUT_out[27] = 37'sd 0;
		19 'sd 98304  :	LUT_out[27] = -37'sd 2286649344;
		19 'sd 32768  :	LUT_out[27] = -37'sd 762216448;
		-19'sd 32768  :	LUT_out[27] = 37'sd 762216448;
		-19'sd 98304  :	LUT_out[27] = 37'sd 2286649344;
		19 'sd 196608 :	LUT_out[27] = -37'sd 4573298688;
		19 'sd 131072 :	LUT_out[27] = -37'sd 3048865792;
		19 'sd 65536  :	LUT_out[27] = -37'sd 1524432896;
		-19'sd 65536  :	LUT_out[27] = 37'sd 1524432896;
		-19'sd 131072 :	LUT_out[27] = 37'sd 3048865792;
		-19'sd 196608 :	LUT_out[27] = 37'sd 4573298688;
		default     :	LUT_out[27] = 37'sd 0;
	endcase
end

// LUT_28 

always @ *
begin
	case(sum_level_1[28])
		19 'sd 0      :	LUT_out[28] = 37'sd 0;
		19 'sd 98304  :	LUT_out[28] = -37'sd 375816192;
		19 'sd 32768  :	LUT_out[28] = -37'sd 125272064;
		-19'sd 32768  :	LUT_out[28] = 37'sd 125272064;
		-19'sd 98304  :	LUT_out[28] = 37'sd 375816192;
		19 'sd 196608 :	LUT_out[28] = -37'sd 751632384;
		19 'sd 131072 :	LUT_out[28] = -37'sd 501088256;
		19 'sd 65536  :	LUT_out[28] = -37'sd 250544128;
		-19'sd 65536  :	LUT_out[28] = 37'sd 250544128;
		-19'sd 131072 :	LUT_out[28] = 37'sd 501088256;
		-19'sd 196608 :	LUT_out[28] = 37'sd 751632384;
		default     :	LUT_out[28] = 37'sd 0;
	endcase
end

// LUT_29 

always @ *
begin
	case(sum_level_1[29])
		19 'sd 0      :	LUT_out[29] = 37'sd 0;
		19 'sd 98304  :	LUT_out[29] = 37'sd 3178659840;
		19 'sd 32768  :	LUT_out[29] = 37'sd 1059553280;
		-19'sd 32768  :	LUT_out[29] = -37'sd 1059553280;
		-19'sd 98304  :	LUT_out[29] = -37'sd 3178659840;
		19 'sd 196608 :	LUT_out[29] = 37'sd 6357319680;
		19 'sd 131072 :	LUT_out[29] = 37'sd 4238213120;
		19 'sd 65536  :	LUT_out[29] = 37'sd 2119106560;
		-19'sd 65536  :	LUT_out[29] = -37'sd 2119106560;
		-19'sd 131072 :	LUT_out[29] = -37'sd 4238213120;
		-19'sd 196608 :	LUT_out[29] = -37'sd 6357319680;
		default     :	LUT_out[29] = 37'sd 0;
	endcase
end

// LUT_30 

always @ *
begin
	case(sum_level_1[30])
		19 'sd 0      :	LUT_out[30] = 37'sd 0;
		19 'sd 98304  :	LUT_out[30] = 37'sd 7359823872;
		19 'sd 32768  :	LUT_out[30] = 37'sd 2453274624;
		-19'sd 32768  :	LUT_out[30] = -37'sd 2453274624;
		-19'sd 98304  :	LUT_out[30] = -37'sd 7359823872;
		19 'sd 196608 :	LUT_out[30] = 37'sd 14719647744;
		19 'sd 131072 :	LUT_out[30] = 37'sd 9813098496;
		19 'sd 65536  :	LUT_out[30] = 37'sd 4906549248;
		-19'sd 65536  :	LUT_out[30] = -37'sd 4906549248;
		-19'sd 131072 :	LUT_out[30] = -37'sd 9813098496;
		-19'sd 196608 :	LUT_out[30] = -37'sd 14719647744;
		default     :	LUT_out[30] = 37'sd 0;
	endcase
end

// LUT_31 

always @ *
begin
	case(sum_level_1[31])
		19 'sd 0      :	LUT_out[31] = 37'sd 0;
		19 'sd 98304  :	LUT_out[31] = 37'sd 10719952896;
		19 'sd 32768  :	LUT_out[31] = 37'sd 3573317632;
		-19'sd 32768  :	LUT_out[31] = -37'sd 3573317632;
		-19'sd 98304  :	LUT_out[31] = -37'sd 10719952896;
		19 'sd 196608 :	LUT_out[31] = 37'sd 21439905792;
		19 'sd 131072 :	LUT_out[31] = 37'sd 14293270528;
		19 'sd 65536  :	LUT_out[31] = 37'sd 7146635264;
		-19'sd 65536  :	LUT_out[31] = -37'sd 7146635264;
		-19'sd 131072 :	LUT_out[31] = -37'sd 14293270528;
		-19'sd 196608 :	LUT_out[31] = -37'sd 21439905792;
		default     :	LUT_out[31] = 37'sd 0;
	endcase
end

// LUT_32 

always @ *
begin
	case(sum_level_1[32])
		19 'sd 0      :	LUT_out[32] = 37'sd 0;
		19 'sd 98304  :	LUT_out[32] = 37'sd 12004589568;
		19 'sd 32768  :	LUT_out[32] = 37'sd 4001529856;
		-19'sd 32768  :	LUT_out[32] = -37'sd 4001529856;
		-19'sd 98304  :	LUT_out[32] = -37'sd 12004589568;
		default     :	LUT_out[32] = 37'sd 0;
	endcase
end


endmodule