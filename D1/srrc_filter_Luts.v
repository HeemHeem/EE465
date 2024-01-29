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
		19 'd0      :	LUT_out[0]  = 37'd0;
		19 'd98304  :	LUT_out[0]  = 37'd29851648;
		19 'd32768  :	LUT_out[0]  = 37'd9950549;
		-19'd32768  :	LUT_out[0]  = -37'd9950549;
		-19'd98304  :	LUT_out[0]  = -37'd29851648;
		19 'd196608 :	LUT_out[0]  = 37'd59703296;
		19 'd131072 :	LUT_out[0]  = 37'd39802197;
		19 'd65536  :	LUT_out[0]  = 37'd19901099;
		-19'd65536  :	LUT_out[0]  = -37'd19901099;
		-19'd131072 :	LUT_out[0]  = -37'd39802197;
		-19'd196608 :	LUT_out[0]  = -37'd59703296;
		default     :	LUT_out[0]  = 37'd0;
	endcase
end

// LUT_1 

always @ *
begin
	case(sum_level_1[1])
		19 'd0      :	LUT_out[1]  = 37'd0;
		19 'd98304  :	LUT_out[1]  = 37'd70025216;
		19 'd32768  :	LUT_out[1]  = 37'd23341739;
		-19'd32768  :	LUT_out[1]  = -37'd23341739;
		-19'd98304  :	LUT_out[1]  = -37'd70025216;
		19 'd196608 :	LUT_out[1]  = 37'd140050432;
		19 'd131072 :	LUT_out[1]  = 37'd93366955;
		19 'd65536  :	LUT_out[1]  = 37'd46683477;
		-19'd65536  :	LUT_out[1]  = -37'd46683477;
		-19'd131072 :	LUT_out[1]  = -37'd93366955;
		-19'd196608 :	LUT_out[1]  = -37'd140050432;
		default     :	LUT_out[1]  = 37'd0;
	endcase
end

// LUT_2 

always @ *
begin
	case(sum_level_1[2])
		19 'd0      :	LUT_out[2]  = 37'd0;
		19 'd98304  :	LUT_out[2]  = 37'd56754176;
		19 'd32768  :	LUT_out[2]  = 37'd18918059;
		-19'd32768  :	LUT_out[2]  = -37'd18918059;
		-19'd98304  :	LUT_out[2]  = -37'd56754176;
		19 'd196608 :	LUT_out[2]  = 37'd113508352;
		19 'd131072 :	LUT_out[2]  = 37'd75672235;
		19 'd65536  :	LUT_out[2]  = 37'd37836117;
		-19'd65536  :	LUT_out[2]  = -37'd37836117;
		-19'd131072 :	LUT_out[2]  = -37'd75672235;
		-19'd196608 :	LUT_out[2]  = -37'd113508352;
		default     :	LUT_out[2]  = 37'd0;
	endcase
end

// LUT_3 

always @ *
begin
	case(sum_level_1[3])
		19 'd0      :	LUT_out[3]  = 37'd0;
		19 'd98304  :	LUT_out[3]  = -37'd78118912;
		19 'd32768  :	LUT_out[3]  = -37'd26039637;
		-19'd32768  :	LUT_out[3]  = 37'd26039637;
		-19'd98304  :	LUT_out[3]  = 37'd78118912;
		19 'd196608 :	LUT_out[3]  = -37'd156237824;
		19 'd131072 :	LUT_out[3]  = -37'd104158549;
		19 'd65536  :	LUT_out[3]  = -37'd52079275;
		-19'd65536  :	LUT_out[3]  = 37'd52079275;
		-19'd131072 :	LUT_out[3]  = 37'd104158549;
		-19'd196608 :	LUT_out[3]  = 37'd156237824;
		default     :	LUT_out[3]  = 37'd0;
	endcase
end

// LUT_4 

always @ *
begin
	case(sum_level_1[4])
		19 'd0      :	LUT_out[4]  = 37'd0;
		19 'd98304  :	LUT_out[4]  = -37'd302972928;
		19 'd32768  :	LUT_out[4]  = -37'd100990976;
		-19'd32768  :	LUT_out[4]  = 37'd100990976;
		-19'd98304  :	LUT_out[4]  = 37'd302972928;
		19 'd196608 :	LUT_out[4]  = -37'd605945856;
		19 'd131072 :	LUT_out[4]  = -37'd403963904;
		19 'd65536  :	LUT_out[4]  = -37'd201981952;
		-19'd65536  :	LUT_out[4]  = 37'd201981952;
		-19'd131072 :	LUT_out[4]  = 37'd403963904;
		-19'd196608 :	LUT_out[4]  = 37'd605945856;
		default     :	LUT_out[4]  = 37'd0;
	endcase
end

// LUT_5 

always @ *
begin
	case(sum_level_1[5])
		19 'd0      :	LUT_out[5]  = 37'd0;
		19 'd98304  :	LUT_out[5]  = -37'd422641664;
		19 'd32768  :	LUT_out[5]  = -37'd140880555;
		-19'd32768  :	LUT_out[5]  = 37'd140880555;
		-19'd98304  :	LUT_out[5]  = 37'd422641664;
		19 'd196608 :	LUT_out[5]  = -37'd845283328;
		19 'd131072 :	LUT_out[5]  = -37'd563522219;
		19 'd65536  :	LUT_out[5]  = -37'd281761109;
		-19'd65536  :	LUT_out[5]  = 37'd281761109;
		-19'd131072 :	LUT_out[5]  = 37'd563522219;
		-19'd196608 :	LUT_out[5]  = 37'd845283328;
		default     :	LUT_out[5]  = 37'd0;
	endcase
end

// LUT_6 

always @ *
begin
	case(sum_level_1[6])
		19 'd0      :	LUT_out[6]  = 37'd0;
		19 'd98304  :	LUT_out[6]  = -37'd157024256;
		19 'd32768  :	LUT_out[6]  = -37'd52341419;
		-19'd32768  :	LUT_out[6]  = 37'd52341419;
		-19'd98304  :	LUT_out[6]  = 37'd157024256;
		19 'd196608 :	LUT_out[6]  = -37'd314048512;
		19 'd131072 :	LUT_out[6]  = -37'd209365675;
		19 'd65536  :	LUT_out[6]  = -37'd104682837;
		-19'd65536  :	LUT_out[6]  = 37'd104682837;
		-19'd131072 :	LUT_out[6]  = 37'd209365675;
		-19'd196608 :	LUT_out[6]  = 37'd314048512;
		default     :	LUT_out[6]  = 37'd0;
	endcase
end

// LUT_7 

always @ *
begin
	case(sum_level_1[7])
		19 'd0      :	LUT_out[7]  = 37'd0;
		19 'd98304  :	LUT_out[7]  = 37'd645464064;
		19 'd32768  :	LUT_out[7]  = 37'd215154688;
		-19'd32768  :	LUT_out[7]  = -37'd215154688;
		-19'd98304  :	LUT_out[7]  = -37'd645464064;
		19 'd196608 :	LUT_out[7]  = 37'd1290928128;
		19 'd131072 :	LUT_out[7]  = 37'd860618752;
		19 'd65536  :	LUT_out[7]  = 37'd430309376;
		-19'd65536  :	LUT_out[7]  = -37'd430309376;
		-19'd131072 :	LUT_out[7]  = -37'd860618752;
		-19'd196608 :	LUT_out[7]  = -37'd1290928128;
		default     :	LUT_out[7]  = 37'd0;
	endcase
end

// LUT_8 

always @ *
begin
	case(sum_level_1[8])
		19 'd0      :	LUT_out[8]  = 37'd0;
		19 'd98304  :	LUT_out[8]  = 37'd1814659072;
		19 'd32768  :	LUT_out[8]  = 37'd604886357;
		-19'd32768  :	LUT_out[8]  = -37'd604886357;
		-19'd98304  :	LUT_out[8]  = -37'd1814659072;
		19 'd196608 :	LUT_out[8]  = 37'd3629318144;
		19 'd131072 :	LUT_out[8]  = 37'd2419545429;
		19 'd65536  :	LUT_out[8]  = 37'd1209772715;
		-19'd65536  :	LUT_out[8]  = -37'd1209772715;
		-19'd131072 :	LUT_out[8]  = -37'd2419545429;
		-19'd196608 :	LUT_out[8]  = -37'd3629318144;
		default     :	LUT_out[8]  = 37'd0;
	endcase
end

// LUT_9 

always @ *
begin
	case(sum_level_1[9])
		19 'd0      :	LUT_out[9]  = 37'd0;
		19 'd98304  :	LUT_out[9]  = 37'd2873360384;
		19 'd32768  :	LUT_out[9]  = 37'd957786795;
		-19'd32768  :	LUT_out[9]  = -37'd957786795;
		-19'd98304  :	LUT_out[9]  = -37'd2873360384;
		19 'd196608 :	LUT_out[9]  = 37'd5746720768;
		19 'd131072 :	LUT_out[9]  = 37'd3831147179;
		19 'd65536  :	LUT_out[9]  = 37'd1915573589;
		-19'd65536  :	LUT_out[9]  = -37'd1915573589;
		-19'd131072 :	LUT_out[9]  = -37'd3831147179;
		-19'd196608 :	LUT_out[9]  = -37'd5746720768;
		default     :	LUT_out[9]  = 37'd0;
	endcase
end

// LUT_10 

always @ *
begin
	case(sum_level_1[10])
		19 'd0      :	LUT_out[10] = 37'd0;
		19 'd32768  :	LUT_out[10] = 37'd3301212160;
		19 'd10923  :	LUT_out[10] = 37'd1100404053;
		-19'd10923  :	LUT_out[10] = -37'd1100404053;
		-19'd32768  :	LUT_out[10] = -37'd3301212160;
		default     :	LUT_out[10] = 37'd0;
	endcase
end


endmodule