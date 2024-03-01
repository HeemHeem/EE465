module rx_gs_filter( input clk, reset, sym_clk_en, sam_clk_en,
							input [1:0] sw,
                    input signed [17:0] x_in, //1s17
                    output reg signed [17:0] y); //1s17);



// create array of vectors
integer  i;
reg signed [17:0] x[80:0]; // for 81 coefficients
reg signed [18:0] sum_level_1[10:0]; // 2s18
reg signed [17:0] sum_out[39:0];
reg signed [36:0] mult_out[40:0]; // 1s35 but changed to 2s35
reg signed [17:0] b[40:0]; // coefficients

always @ (posedge clk or posedge reset)
    if(reset)
        x[0] <= 0;
    else
        x[0] <= x_in;

always @ (posedge clk or posedge reset)
    if(reset) 
    begin
        for(i=1; i<81; i=i+1)
            x[i] <= 0;
    end
    else if (sam_clk_en)
    begin
        for(i=1; i<81; i=i+1)
            x[i] <= x[i-1];
    end
	else
    begin
        for(i=1; i<81; i=i+1)
            x[i] <= x[i];
    end
// add values the require the same coefficients
always @ *
begin
    for(i=0; i<=39; i= i+1)
    sum_level_1[i] <= {x[i][17], x[i]} + {x[80-i][17], x[80-i]}; // sign extend to see whats up 2s17
end

// center value
always @ *
    sum_level_1[40] <= {x[40][17], x[40]};


// multiply by coefficients
always @ *
begin
    for(i=0; i <= 40; i=i+1)
    mult_out[i] <= sum_level_1[i] * b[i]; 
end

// sum up mutlipliers
always @ *
if (reset)
    for (i = 0; i <=39; i=i+1)
        sum_out[i] = 18'sd 0;
else
    begin
        sum_out[0] = mult_out[0][35:18] + mult_out[1][35:18];
        for(i = 0; i <=38 ; i=i+1)
            sum_out[i+1] <= sum_out[i] + mult_out[i+2][35:18]; 
    end
    

always @ (posedge clk or posedge reset)
    if(reset)
        y <= 0;
    else if(sam_clk_en)
        y <= sum_out[39];
	else
		y <= y;

 


always @ *
begin
	b[0] = 18'sd 166;
	b[1] = 18'sd 194;
	b[2] = 18'sd 61;
	b[3] = -18'sd 149;
	b[4] = -18'sd 275;
	b[5] = -18'sd 198;
	b[6] = 18'sd 62;
	b[7] = 18'sd 332;
	b[8] = 18'sd 398;
	b[9] = 18'sd 163;
	b[10] = -18'sd 256;
	b[11] = -18'sd 575;
	b[12] = -18'sd 529;
	b[13] = -18'sd 73;
	b[14] = 18'sd 540;
	b[15] = 18'sd 889;
	b[16] = 18'sd 662;
	b[17] = -18'sd 96;
	b[18] = -18'sd 946;
	b[19] = -18'sd 1295;
	b[20] = -18'sd 791;
	b[21] = 18'sd 382;
	b[22] = 18'sd 1529;
	b[23] = 18'sd 1833;
	b[24] = 18'sd 908;
	b[25] = -18'sd 857;
	b[26] = -18'sd 2403;
	b[27] = -18'sd 2601;
	b[28] = -18'sd 1007;
	b[29] = 18'sd 1688;
	b[30] = 18'sd 3871;
	b[31] = 18'sd 3878;
	b[32] = 18'sd 1082;
	b[33] = -18'sd 3425;
	b[34] = -18'sd 7056;
	b[35] = -18'sd 6870;
	b[36] = -18'sd 1129;
	b[37] = 18'sd 9550;
	b[38] = 18'sd 22113;
	b[39] = 18'sd 32208;
	b[40] = 18'sd 36068;
	end
endmodule