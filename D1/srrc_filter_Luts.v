module srrc_filter( input clk, reset,
							input [1:0] sw,
                    input signed [17:0] x_in, //1s17
                    output reg signed [17:0] y); //1s17);



// create array of vectors
integer  i;
reg signed [17:0] x[20:0]; // for 21 coefficients
reg signed [18:0] sum_level_1[10:0];
reg signed [17:0] sum_out[9:0];
reg signed [36:0] LUT_out[10:0]; // 1s35 but changed to 2s35
reg signed [17:0] b[10:0]; // coefficients

always @ (posedge clk or posedge reset)
    if(reset)
        x[0] <= 0;
    else
        x[0] <= x_in;

always @ (posedge clk or posedge reset)
    if(reset) 
    begin
        for(i=1; i<21; i=i+1)
            x[i] <= 0;
    end
    else
    begin
        for(i=1; i<21; i=i+1)
            x[i] <= x[i-1];
    end


// add values the require the same coefficients
always @ *
begin
    for(i=0; i<=9; i= i+1)
    sum_level_1[i] <= {x[i][17], x[i]} + {x[20-i][17], x[20-i]}; // sign extend to see whats up 2s17
end

// center value
always @ *
    sum_level_1[10] <= {x[10][17], x[10]};


// multiply by coefficients
// always @ *
// begin
//     for(i=0; i <= 10; i=i+1)
//     mult_out[i] <= sum_level_1[i] * b[i]; 
// end

// sum up mutlipliers
always @ *
if (reset)
    for (i = 0; i <=9; i=i+1)
        sum_out[i] = 18'sd 0;
else
    begin
        sum_out[0] = LUT_out[0][35:18] + LUT_out[1][35:18];
        for(i = 0; i <=8 ; i=i+1)
            sum_out[i+1] <= sum_out[i] + LUT_out[i+2][35:18]; 
    end
    

always @ (posedge clk or posedge reset)
    if(reset)
        y <= 0;
    else
        y <= sum_out[9];

 


// LUT_0 

always @ *
begin
	case(sum_level_1[0])
		19 'sd 0      :	LUT_out[0]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[0]  = 37'sd 31358976;
		19 'sd 32768  :	LUT_out[0]  = 37'sd 10452992;
		-19'sd 32768  :	LUT_out[0]  = -37'sd 10452992;
		-19'sd 98304  :	LUT_out[0]  = -37'sd 31358976;
		19 'sd 196608 :	LUT_out[0]  = 37'sd 62717952;
		19 'sd 131072 :	LUT_out[0]  = 37'sd 41811968;
		19 'sd 65536  :	LUT_out[0]  = 37'sd 20905984;
		-19'sd 65536  :	LUT_out[0]  = -37'sd 20905984;
		-19'sd 131072 :	LUT_out[0]  = -37'sd 41811968;
		-19'sd 196608 :	LUT_out[0]  = -37'sd 62717952;
		default     :	LUT_out[0]  = 37'sd 0;
	endcase
end

// LUT_1 

always @ *
begin
	case(sum_level_1[1])
		19 'sd 0      :	LUT_out[1]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[1]  = 37'sd 163184640;
		19 'sd 32768  :	LUT_out[1]  = 37'sd 54394880;
		-19'sd 32768  :	LUT_out[1]  = -37'sd 54394880;
		-19'sd 98304  :	LUT_out[1]  = -37'sd 163184640;
		19 'sd 196608 :	LUT_out[1]  = 37'sd 326369280;
		19 'sd 131072 :	LUT_out[1]  = 37'sd 217579520;
		19 'sd 65536  :	LUT_out[1]  = 37'sd 108789760;
		-19'sd 65536  :	LUT_out[1]  = -37'sd 108789760;
		-19'sd 131072 :	LUT_out[1]  = -37'sd 217579520;
		-19'sd 196608 :	LUT_out[1]  = -37'sd 326369280;
		default     :	LUT_out[1]  = 37'sd 0;
	endcase
end

// LUT_2 

always @ *
begin
	case(sum_level_1[2])
		19 'sd 0      :	LUT_out[2]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[2]  = 37'sd 221872128;
		19 'sd 32768  :	LUT_out[2]  = 37'sd 73957376;
		-19'sd 32768  :	LUT_out[2]  = -37'sd 73957376;
		-19'sd 98304  :	LUT_out[2]  = -37'sd 221872128;
		19 'sd 196608 :	LUT_out[2]  = 37'sd 443744256;
		19 'sd 131072 :	LUT_out[2]  = 37'sd 295829504;
		19 'sd 65536  :	LUT_out[2]  = 37'sd 147914752;
		-19'sd 65536  :	LUT_out[2]  = -37'sd 147914752;
		-19'sd 131072 :	LUT_out[2]  = -37'sd 295829504;
		-19'sd 196608 :	LUT_out[2]  = -37'sd 443744256;
		default     :	LUT_out[2]  = 37'sd 0;
	endcase
end

// LUT_3 

always @ *
begin
	case(sum_level_1[3])
		19 'sd 0      :	LUT_out[3]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[3]  = 37'sd 26148864;
		19 'sd 32768  :	LUT_out[3]  = 37'sd 8716288;
		-19'sd 32768  :	LUT_out[3]  = -37'sd 8716288;
		-19'sd 98304  :	LUT_out[3]  = -37'sd 26148864;
		19 'sd 196608 :	LUT_out[3]  = 37'sd 52297728;
		19 'sd 131072 :	LUT_out[3]  = 37'sd 34865152;
		19 'sd 65536  :	LUT_out[3]  = 37'sd 17432576;
		-19'sd 65536  :	LUT_out[3]  = -37'sd 17432576;
		-19'sd 131072 :	LUT_out[3]  = -37'sd 34865152;
		-19'sd 196608 :	LUT_out[3]  = -37'sd 52297728;
		default     :	LUT_out[3]  = 37'sd 0;
	endcase
end

// LUT_4 

always @ *
begin
	case(sum_level_1[4])
		19 'sd 0      :	LUT_out[4]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[4]  = -37'sd 426737664;
		19 'sd 32768  :	LUT_out[4]  = -37'sd 142245888;
		-19'sd 32768  :	LUT_out[4]  = 37'sd 142245888;
		-19'sd 98304  :	LUT_out[4]  = 37'sd 426737664;
		19 'sd 196608 :	LUT_out[4]  = -37'sd 853475328;
		19 'sd 131072 :	LUT_out[4]  = -37'sd 568983552;
		19 'sd 65536  :	LUT_out[4]  = -37'sd 284491776;
		-19'sd 65536  :	LUT_out[4]  = 37'sd 284491776;
		-19'sd 131072 :	LUT_out[4]  = 37'sd 568983552;
		-19'sd 196608 :	LUT_out[4]  = 37'sd 853475328;
		default     :	LUT_out[4]  = 37'sd 0;
	endcase
end

// LUT_5 

always @ *
begin
	case(sum_level_1[5])
		19 'sd 0      :	LUT_out[5]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[5]  = -37'sd 798621696;
		19 'sd 32768  :	LUT_out[5]  = -37'sd 266207232;
		-19'sd 32768  :	LUT_out[5]  = 37'sd 266207232;
		-19'sd 98304  :	LUT_out[5]  = 37'sd 798621696;
		19 'sd 196608 :	LUT_out[5]  = -37'sd 1597243392;
		19 'sd 131072 :	LUT_out[5]  = -37'sd 1064828928;
		19 'sd 65536  :	LUT_out[5]  = -37'sd 532414464;
		-19'sd 65536  :	LUT_out[5]  = 37'sd 532414464;
		-19'sd 131072 :	LUT_out[5]  = 37'sd 1064828928;
		-19'sd 196608 :	LUT_out[5]  = 37'sd 1597243392;
		default     :	LUT_out[5]  = 37'sd 0;
	endcase
end

// LUT_6 

always @ *
begin
	case(sum_level_1[6])
		19 'sd 0      :	LUT_out[6]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[6]  = -37'sd 533987328;
		19 'sd 32768  :	LUT_out[6]  = -37'sd 177995776;
		-19'sd 32768  :	LUT_out[6]  = 37'sd 177995776;
		-19'sd 98304  :	LUT_out[6]  = 37'sd 533987328;
		19 'sd 196608 :	LUT_out[6]  = -37'sd 1067974656;
		19 'sd 131072 :	LUT_out[6]  = -37'sd 711983104;
		19 'sd 65536  :	LUT_out[6]  = -37'sd 355991552;
		-19'sd 65536  :	LUT_out[6]  = 37'sd 355991552;
		-19'sd 131072 :	LUT_out[6]  = 37'sd 711983104;
		-19'sd 196608 :	LUT_out[6]  = 37'sd 1067974656;
		default     :	LUT_out[6]  = 37'sd 0;
	endcase
end

// LUT_7 

always @ *
begin
	case(sum_level_1[7])
		19 'sd 0      :	LUT_out[7]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[7]  = 37'sd 720863232;
		19 'sd 32768  :	LUT_out[7]  = 37'sd 240287744;
		-19'sd 32768  :	LUT_out[7]  = -37'sd 240287744;
		-19'sd 98304  :	LUT_out[7]  = -37'sd 720863232;
		19 'sd 196608 :	LUT_out[7]  = 37'sd 1441726464;
		19 'sd 131072 :	LUT_out[7]  = 37'sd 961150976;
		19 'sd 65536  :	LUT_out[7]  = 37'sd 480575488;
		-19'sd 65536  :	LUT_out[7]  = -37'sd 480575488;
		-19'sd 131072 :	LUT_out[7]  = -37'sd 961150976;
		-19'sd 196608 :	LUT_out[7]  = -37'sd 1441726464;
		default     :	LUT_out[7]  = 37'sd 0;
	endcase
end

// LUT_8 

always @ *
begin
	case(sum_level_1[8])
		19 'sd 0      :	LUT_out[8]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[8]  = 37'sd 2712797184;
		19 'sd 32768  :	LUT_out[8]  = 37'sd 904265728;
		-19'sd 32768  :	LUT_out[8]  = -37'sd 904265728;
		-19'sd 98304  :	LUT_out[8]  = -37'sd 2712797184;
		19 'sd 196608 :	LUT_out[8]  = 37'sd 5425594368;
		19 'sd 131072 :	LUT_out[8]  = 37'sd 3617062912;
		19 'sd 65536  :	LUT_out[8]  = 37'sd 1808531456;
		-19'sd 65536  :	LUT_out[8]  = -37'sd 1808531456;
		-19'sd 131072 :	LUT_out[8]  = -37'sd 3617062912;
		-19'sd 196608 :	LUT_out[8]  = -37'sd 5425594368;
		default     :	LUT_out[8]  = 37'sd 0;
	endcase
end

// LUT_9 

always @ *
begin
	case(sum_level_1[9])
		19 'sd 0      :	LUT_out[9]  = 37'sd 0;
		19 'sd 98304  :	LUT_out[9]  = 37'sd 4578312192;
		19 'sd 32768  :	LUT_out[9]  = 37'sd 1526104064;
		-19'sd 32768  :	LUT_out[9]  = -37'sd 1526104064;
		-19'sd 98304  :	LUT_out[9]  = -37'sd 4578312192;
		19 'sd 196608 :	LUT_out[9]  = 37'sd 9156624384;
		19 'sd 131072 :	LUT_out[9]  = 37'sd 6104416256;
		19 'sd 65536  :	LUT_out[9]  = 37'sd 3052208128;
		-19'sd 65536  :	LUT_out[9]  = -37'sd 3052208128;
		-19'sd 131072 :	LUT_out[9]  = -37'sd 6104416256;
		-19'sd 196608 :	LUT_out[9]  = -37'sd 9156624384;
		default     :	LUT_out[9]  = 37'sd 0;
	endcase
end

// LUT_10 

always @ *
begin
	case(sum_level_1[10])
		19 'sd 0      :	LUT_out[10] = 37'sd 0;
		19 'sd 98304  :	LUT_out[10] = 37'sd 5342134272;
		19 'sd 32768  :	LUT_out[10] = 37'sd 1780711424;
		-19'sd 32768  :	LUT_out[10] = -37'sd 1780711424;
		-19'sd 98304  :	LUT_out[10] = -37'sd 5342134272;
		default     :	LUT_out[10] = 37'sd 0;
	endcase
end


endmodule