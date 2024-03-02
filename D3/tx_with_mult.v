module srrc_filter( input clk, reset,
							input [1:0] sw,
                    input signed [17:0] x_in, //1s17
                    output reg signed [17:0] y); //1s17);



// create array of vectors
integer  i;
reg signed [17:0] x[20:0]; // for 21 coefficients
reg signed [18:0] sum_level_1[10:0];
reg signed [17:0] sum_out[9:0];
reg signed [36:0] mult_out[10:0]; // 1s35 but changed to 2s35
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
always @ *
begin
    for(i=0; i <= 10; i=i+1)
    mult_out[i] <= sum_level_1[i] * b[i]; 
end

// sum up mutlipliers
always @ *
if (reset)
    for (i = 0; i <=9; i=i+1)
        sum_out[i] = 18'sd 0;
else
    begin
        sum_out[0] = mult_out[0][35:18] + mult_out[1][35:18];
        for(i = 0; i <=8 ; i=i+1)
            sum_out[i+1] <= sum_out[i] + mult_out[i+2][35:18]; 
    end
    

always @ (posedge clk or posedge reset)
    if(reset)
        y <= 0;
    else
        y <= sum_out[9];

 


always @ *
begin
	b[0] = -18'sd 309;
	b[1] = -18'sd 231;
	b[2] = 18'sd 6;
	b[3] = 18'sd 242;
	b[4] = 18'sd 315;
	b[5] = 18'sd 170;
	b[6] = -18'sd 97;
	b[7] = -18'sd 300;
	b[8] = -18'sd 295;
	b[9] = -18'sd 76;
	b[10] = 18'sd 206;
	b[11] = 18'sd 350;
	b[12] = 18'sd 243;
	b[13] = -18'sd 53;
	b[14] = -18'sd 332;
	b[15] = -18'sd 385;
	b[16] = -18'sd 152;
	b[17] = 18'sd 223;
	b[18] = 18'sd 474;
	b[19] = 18'sd 400;
	b[20] = 18'sd 15;
	b[21] = -18'sd 436;
	b[22] = -18'sd 629;
	b[23] = -18'sd 386;
	b[24] = 18'sd 178;
	b[25] = 18'sd 699;
	b[26] = 18'sd 795;
	b[27] = 18'sd 335;
	b[28] = -18'sd 435;
	b[29] = -18'sd 1015;
	b[30] = -18'sd 968;
	b[31] = -18'sd 236;
	b[32] = 18'sd 770;
	b[33] = 18'sd 1392;
	b[34] = 18'sd 1146;
	b[35] = 18'sd 78;
	b[36] = -18'sd 1196;
	b[37] = -18'sd 1837;
	b[38] = -18'sd 1323;
	b[39] = 18'sd 157;
	b[40] = 18'sd 1735;
	b[41] = 18'sd 2365;
	b[42] = 18'sd 1496;
	b[43] = -18'sd 491;
	b[44] = -18'sd 2419;
	b[45] = -18'sd 2997;
	b[46] = -18'sd 1661;
	b[47] = 18'sd 958;
	b[48] = 18'sd 3296;
	b[49] = 18'sd 3770;
	b[50] = 18'sd 1814;
	b[51] = -18'sd 1612;
	b[52] = -18'sd 4452;
	b[53] = -18'sd 4752;
	b[54] = -18'sd 1951;
	b[55] = 18'sd 2555;
	b[56] = 18'sd 6050;
	b[57] = 18'sd 6076;
	b[58] = 18'sd 2068;
	b[59] = -18'sd 3990;
	b[60] = -18'sd 8441;
	b[61] = -18'sd 8052;
	b[62] = -18'sd 2162;
	b[63] = 18'sd 6417;
	b[64] = 18'sd 12544;
	b[65] = 18'sd 11539;
	b[66] = 18'sd 2232;
	b[67] = -18'sd 11485;
	b[68] = -18'sd 21739;
	b[69] = -18'sd 20171;
	b[70] = -18'sd 2274;
	b[71] = 18'sd 29636;
	b[72] = 18'sd 66487;
	b[73] = 18'sd 95814;
	b[74] = 18'sd 106978;
	end
endmodule