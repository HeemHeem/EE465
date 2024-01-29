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
		19 'd393216 :	LUT_out[0]  = 37'd119406592;
		19 'd131072 :	LUT_out[0]  = 37'd39802197;
		-19'd131072 :	LUT_out[0]  = -37'd39802197;
		-19'd393216 :	LUT_out[0]  = -37'd119406592;
		19 'd786432 :	LUT_out[0]  = 37'd238813184;
		19 'd524288 :	LUT_out[0]  = 37'd159208789;
		19 'd262144 :	LUT_out[0]  = 37'd79604395;
		-19'd262144 :	LUT_out[0]  = -37'd79604395;
		-19'd524288 :	LUT_out[0]  = -37'd159208789;
		-19'd786432 :	LUT_out[0]  = -37'd238813184;
		default     :	LUT_out[0]  = 37'd0;
	endcase
end

// LUT_1 

always @ *
begin
	case(sum_level_1[1])
		19 'd0      :	LUT_out[1]  = 37'd0;
		19 'd393216 :	LUT_out[1]  = 37'd280100864;
		19 'd131072 :	LUT_out[1]  = 37'd93366955;
		-19'd131072 :	LUT_out[1]  = -37'd93366955;
		-19'd393216 :	LUT_out[1]  = -37'd280100864;
		19 'd786432 :	LUT_out[1]  = 37'd560201728;
		19 'd524288 :	LUT_out[1]  = 37'd373467819;
		19 'd262144 :	LUT_out[1]  = 37'd186733909;
		-19'd262144 :	LUT_out[1]  = -37'd186733909;
		-19'd524288 :	LUT_out[1]  = -37'd373467819;
		-19'd786432 :	LUT_out[1]  = -37'd560201728;
		default     :	LUT_out[1]  = 37'd0;
	endcase
end

// LUT_2 

always @ *
begin
	case(sum_level_1[2])
		19 'd0      :	LUT_out[2]  = 37'd0;
		19 'd393216 :	LUT_out[2]  = 37'd227016704;
		19 'd131072 :	LUT_out[2]  = 37'd75672235;
		-19'd131072 :	LUT_out[2]  = -37'd75672235;
		-19'd393216 :	LUT_out[2]  = -37'd227016704;
		19 'd786432 :	LUT_out[2]  = 37'd454033408;
		19 'd524288 :	LUT_out[2]  = 37'd302688939;
		19 'd262144 :	LUT_out[2]  = 37'd151344469;
		-19'd262144 :	LUT_out[2]  = -37'd151344469;
		-19'd524288 :	LUT_out[2]  = -37'd302688939;
		-19'd786432 :	LUT_out[2]  = -37'd454033408;
		default     :	LUT_out[2]  = 37'd0;
	endcase
end

// LUT_3 

always @ *
begin
	case(sum_level_1[3])
		19 'd0      :	LUT_out[3]  = 37'd0;
		19 'd393216 :	LUT_out[3]  = -37'd312475648;
		19 'd131072 :	LUT_out[3]  = -37'd104158549;
		-19'd131072 :	LUT_out[3]  = 37'd104158549;
		-19'd393216 :	LUT_out[3]  = 37'd312475648;
		19 'd786432 :	LUT_out[3]  = -37'd624951296;
		19 'd524288 :	LUT_out[3]  = -37'd416634197;
		19 'd262144 :	LUT_out[3]  = -37'd208317099;
		-19'd262144 :	LUT_out[3]  = 37'd208317099;
		-19'd524288 :	LUT_out[3]  = 37'd416634197;
		-19'd786432 :	LUT_out[3]  = 37'd624951296;
		default     :	LUT_out[3]  = 37'd0;
	endcase
end

// LUT_4 

always @ *
begin
	case(sum_level_1[4])
		19 'd0      :	LUT_out[4]  = 37'd0;
		19 'd393216 :	LUT_out[4]  = -37'd1211891712;
		19 'd131072 :	LUT_out[4]  = -37'd403963904;
		-19'd131072 :	LUT_out[4]  = 37'd403963904;
		-19'd393216 :	LUT_out[4]  = 37'd1211891712;
		19 'd786432 :	LUT_out[4]  = -37'd2423783424;
		19 'd524288 :	LUT_out[4]  = -37'd1615855616;
		19 'd262144 :	LUT_out[4]  = -37'd807927808;
		-19'd262144 :	LUT_out[4]  = 37'd807927808;
		-19'd524288 :	LUT_out[4]  = 37'd1615855616;
		-19'd786432 :	LUT_out[4]  = 37'd2423783424;
		default     :	LUT_out[4]  = 37'd0;
	endcase
end

// LUT_5 

always @ *
begin
	case(sum_level_1[5])
		19 'd0      :	LUT_out[5]  = 37'd0;
		19 'd393216 :	LUT_out[5]  = -37'd1690566656;
		19 'd131072 :	LUT_out[5]  = -37'd563522219;
		-19'd131072 :	LUT_out[5]  = 37'd563522219;
		-19'd393216 :	LUT_out[5]  = 37'd1690566656;
		19 'd786432 :	LUT_out[5]  = -37'd3381133312;
		19 'd524288 :	LUT_out[5]  = -37'd2254088875;
		19 'd262144 :	LUT_out[5]  = -37'd1127044437;
		-19'd262144 :	LUT_out[5]  = 37'd1127044437;
		-19'd524288 :	LUT_out[5]  = 37'd2254088875;
		-19'd786432 :	LUT_out[5]  = 37'd3381133312;
		default     :	LUT_out[5]  = 37'd0;
	endcase
end

// LUT_6 

always @ *
begin
	case(sum_level_1[6])
		19 'd0      :	LUT_out[6]  = 37'd0;
		19 'd393216 :	LUT_out[6]  = -37'd628097024;
		19 'd131072 :	LUT_out[6]  = -37'd209365675;
		-19'd131072 :	LUT_out[6]  = 37'd209365675;
		-19'd393216 :	LUT_out[6]  = 37'd628097024;
		19 'd786432 :	LUT_out[6]  = -37'd1256194048;
		19 'd524288 :	LUT_out[6]  = -37'd837462699;
		19 'd262144 :	LUT_out[6]  = -37'd418731349;
		-19'd262144 :	LUT_out[6]  = 37'd418731349;
		-19'd524288 :	LUT_out[6]  = 37'd837462699;
		-19'd786432 :	LUT_out[6]  = 37'd1256194048;
		default     :	LUT_out[6]  = 37'd0;
	endcase
end

// LUT_7 

always @ *
begin
	case(sum_level_1[7])
		19 'd0      :	LUT_out[7]  = 37'd0;
		19 'd393216 :	LUT_out[7]  = 37'd2581856256;
		19 'd131072 :	LUT_out[7]  = 37'd860618752;
		-19'd131072 :	LUT_out[7]  = -37'd860618752;
		-19'd393216 :	LUT_out[7]  = -37'd2581856256;
		19 'd786432 :	LUT_out[7]  = 37'd5163712512;
		19 'd524288 :	LUT_out[7]  = 37'd3442475008;
		19 'd262144 :	LUT_out[7]  = 37'd1721237504;
		-19'd262144 :	LUT_out[7]  = -37'd1721237504;
		-19'd524288 :	LUT_out[7]  = -37'd3442475008;
		-19'd786432 :	LUT_out[7]  = -37'd5163712512;
		default     :	LUT_out[7]  = 37'd0;
	endcase
end

// LUT_8 

always @ *
begin
	case(sum_level_1[8])
		19 'd0      :	LUT_out[8]  = 37'd0;
		19 'd393216 :	LUT_out[8]  = 37'd7258636288;
		19 'd131072 :	LUT_out[8]  = 37'd2419545429;
		-19'd131072 :	LUT_out[8]  = -37'd2419545429;
		-19'd393216 :	LUT_out[8]  = -37'd7258636288;
		19 'd786432 :	LUT_out[8]  = 37'd14517272576;
		19 'd524288 :	LUT_out[8]  = 37'd9678181717;
		19 'd262144 :	LUT_out[8]  = 37'd4839090859;
		-19'd262144 :	LUT_out[8]  = -37'd4839090859;
		-19'd524288 :	LUT_out[8]  = -37'd9678181717;
		-19'd786432 :	LUT_out[8]  = -37'd14517272576;
		default     :	LUT_out[8]  = 37'd0;
	endcase
end

// LUT_9 

always @ *
begin
	case(sum_level_1[9])
		19 'd0      :	LUT_out[9]  = 37'd0;
		19 'd393216 :	LUT_out[9]  = 37'd11493441536;
		19 'd131072 :	LUT_out[9]  = 37'd3831147179;
		-19'd131072 :	LUT_out[9]  = -37'd3831147179;
		-19'd393216 :	LUT_out[9]  = -37'd11493441536;
		19 'd786432 :	LUT_out[9]  = 37'd22986883072;
		19 'd524288 :	LUT_out[9]  = 37'd15324588715;
		19 'd262144 :	LUT_out[9]  = 37'd7662294357;
		-19'd262144 :	LUT_out[9]  = -37'd7662294357;
		-19'd524288 :	LUT_out[9]  = -37'd15324588715;
		-19'd786432 :	LUT_out[9]  = -37'd22986883072;
		default     :	LUT_out[9]  = 37'd0;
	endcase
end

// LUT_10 

always @ *
begin
	case(sum_level_1[10])
		19 'd0      :	LUT_out[10] = 37'd0;
		19 'd131072 :	LUT_out[10] = 37'd13204848640;
		19 'd43691  :	LUT_out[10] = 37'd4401616213;
		-19'd43691  :	LUT_out[10] = -37'd4401616213;
		-19'd131072 :	LUT_out[10] = -37'd13204848640;
		default     :	LUT_out[10] = 37'd0;
	endcase
end


endmodule