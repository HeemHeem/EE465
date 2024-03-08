module rx_gs_filter #(
    parameter COEFF_LEN = 81,
    parameter HALF_COEFF_LEN = (COEFF_LEN-1)/2
)
( input clk, reset, sym_clk_en, sam_clk_en,
							input [1:0] sw,
                    input signed [17:0] x_in, //1s17
                    output reg signed [17:0] y); //1s17);



// create array of vectors
integer  i;
reg signed [17:0] x[COEFF_LEN-1:0]; // for 21 coefficients
reg signed [35:0] sum_level_1[2:0];
reg signed [35:0] sum_level_2[1:0];
// reg signed [17:0] sum_out[HALF_COEFF_LEN-1:0];
// reg signed [36:0] mult_out[HALF_COEFF_LEN:0]; // 1s35 but changed to 2s35
// reg signed [17:0] b[HALF_COEFF_LEN:0]; // coefficients
reg signed [17:0] hm0, hm1, hm2, hm3, hm4, hm5, hm6, hm7, hm8, hm9, hm10, hm11, hm12, hm13, hm14, hm15, hm16, hm17, hm18, hm19;
reg signed [17:0] xm0, xm1, xm2, xm3, xm4, xm5, xm6, xm7, xm8, xm9, xm10, xm11, xm12, xm13, xm14, xm15, xm16, xm17, xm18, xm19; // hm's- 0s18, xm's 1s17
reg signed [35:0] m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16, m17, m18, m19, m20; // 1s35s
reg signed [35:0] m0_acc, m1_acc, m2_acc, m3_acc, m4_acc; // 1s35
reg signed [35:0] y_temp; // 1s35
reg [1:0] counter;


always @ (posedge clk or posedge reset)
    if(reset)
        x[0] <= 18'sd0;
    else if (sam_clk_en)
        x[0] <= x_in;
	else
		x[0] <= x[0];

always @ (posedge clk or posedge reset)
    if(reset) 
    begin
        for(i=1; i<COEFF_LEN; i=i+1)
            x[i] <= 18'sd0;
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


// multiply by coefficients
always @ *
begin
    for(i=0; i <= HALF_COEFF_LEN; i=i+1)
    mult_out[i] <= sum_level_1[i] * b[i]; 
end

// sum up mutlipliers
always @ *
if (reset)
    for (i = 0; i <=HALF_COEFF_LEN-1; i=i+1)
        sum_out[i] = 18'sd 0;
else
    begin
        sum_out[0] = mult_out[0][35:18] + mult_out[1][35:18];
        for(i = 0; i <= HALF_COEFF_LEN-2 ; i=i+1)
            sum_out[i+1] <= sum_out[i] + mult_out[i+2][35:18]; 
    end
    

always @ (posedge clk or posedge reset)
    if(reset)
        y <= 0;
    else if(sam_clk_en)
        y <= sum_out[HALF_COEFF_LEN-1];
	else
		y <= y;

 


always @ (posedge clk or posedge reset)
	if(reset)
		m[0] = 36'sd0;
	else
		m[0] = xm0 * hm0;

always @ (posedge clk or posedge reset)
	if(reset)
		m[1] = 36'sd0;
	else
		m[1] = xm1 * hm1;

always @ (posedge clk or posedge reset)
	if(reset)
		m[2] = 36'sd0;
	else
		m[2] = xm2 * hm2;

always @ (posedge clk or posedge reset)
	if(reset)
		m[3] = 36'sd0;
	else
		m[3] = xm3 * hm3;

always @ (posedge clk or posedge reset)
	if(reset)
		m[4] = 36'sd0;
	else
		m[4] = xm4 * hm4;

always @ (posedge clk or posedge reset)
	if(reset)
		m[5] = 36'sd0;
	else
		m[5] = xm5 * hm5;

always @ (posedge clk or posedge reset)
	if(reset)
		m[6] = 36'sd0;
	else
		m[6] = xm6 * hm6;

always @ (posedge clk or posedge reset)
	if(reset)
		m[7] = 36'sd0;
	else
		m[7] = xm7 * hm7;

always @ (posedge clk or posedge reset)
	if(reset)
		m[8] = 36'sd0;
	else
		m[8] = xm8 * hm8;

always @ (posedge clk or posedge reset)
	if(reset)
		m[9] = 36'sd0;
	else
		m[9] = xm9 * hm9;

always @ (posedge clk or posedge reset)
	if(reset)
		m[10] = 36'sd0;
	else
		m[10] = xm10 * hm10;

always @ (posedge clk or posedge reset)
	if(reset)
		m[11] = 36'sd0;
	else
		m[11] = xm11 * hm11;

always @ (posedge clk or posedge reset)
	if(reset)
		m[12] = 36'sd0;
	else
		m[12] = xm12 * hm12;

always @ (posedge clk or posedge reset)
	if(reset)
		m[13] = 36'sd0;
	else
		m[13] = xm13 * hm13;

always @ (posedge clk or posedge reset)
	if(reset)
		m[14] = 36'sd0;
	else
		m[14] = xm14 * hm14;

always @ (posedge clk or posedge reset)
	if(reset)
		m[15] = 36'sd0;
	else
		m[15] = xm15 * hm15;

always @ (posedge clk or posedge reset)
	if(reset)
		m[16] = 36'sd0;
	else
		m[16] = xm16 * hm16;

always @ (posedge clk or posedge reset)
	if(reset)
		m[17] = 36'sd0;
	else
		m[17] = xm17 * hm17;

always @ (posedge clk or posedge reset)
	if(reset)
		m[18] = 36'sd0;
	else
		m[18] = xm18 * hm18;

always @ (posedge clk or posedge reset)
	if(reset)
		m[19] = 36'sd0;
	else
		m[19] = xm19 * hm19;

wire signed [17:0] h80;

assign h80 = 18'sd 166;

always @ *
	m_out_21 = x[80] * h80;

always @ *
begin
	case(counter)
		2'd0 : hm0 = 18'sd 166;
		2'd1 : hm0 = 18'sd 194;
		2'd2 : hm0 = 18'sd 61;
		2'd3 : hm0 = -18'sd 149;
		default: hm0 = 18'sd 166;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm1 = -18'sd 275;
		2'd1 : hm1 = -18'sd 198;
		2'd2 : hm1 = 18'sd 62;
		2'd3 : hm1 = 18'sd 332;
		default: hm1 = -18'sd 665;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm2 = 18'sd 398;
		2'd1 : hm2 = 18'sd 163;
		2'd2 : hm2 = -18'sd 256;
		2'd3 : hm2 = -18'sd 575;
		default: hm2 = 18'sd 398;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm3 = -18'sd 529;
		2'd1 : hm3 = -18'sd 73;
		2'd2 : hm3 = 18'sd 540;
		2'd3 : hm3 = 18'sd 889;
		default: hm3 = -18'sd 245;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm4 = 18'sd 662;
		2'd1 : hm4 = -18'sd 96;
		2'd2 : hm4 = -18'sd 946;
		2'd3 : hm4 = -18'sd 1295;
		default: hm4 = 18'sd 662;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm5 = -18'sd 791;
		2'd1 : hm5 = 18'sd 382;
		2'd2 : hm5 = 18'sd 1529;
		2'd3 : hm5 = 18'sd 1833;
		default: hm5 = -18'sd 1099;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm6 = 18'sd 908;
		2'd1 : hm6 = -18'sd 857;
		2'd2 : hm6 = -18'sd 2403;
		2'd3 : hm6 = -18'sd 2601;
		default: hm6 = 18'sd 908;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm7 = -18'sd 1007;
		2'd1 : hm7 = 18'sd 1688;
		2'd2 : hm7 = 18'sd 3871;
		2'd3 : hm7 = 18'sd 3878;
		default: hm7 = -18'sd 249;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm8 = 18'sd 1082;
		2'd1 : hm8 = -18'sd 3425;
		2'd2 : hm8 = -18'sd 7056;
		2'd3 : hm8 = -18'sd 6870;
		default: hm8 = 18'sd 1082;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm9 = -18'sd 1129;
		2'd1 : hm9 = 18'sd 9550;
		2'd2 : hm9 = 18'sd 22113;
		2'd3 : hm9 = 18'sd 32208;
		default: hm9 = -18'sd 1593;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm10 = 18'sd 36068;
		2'd1 : hm10 = 18'sd 32208;
		2'd2 : hm10 = 18'sd 22113;
		2'd3 : hm10 = 18'sd 9550;
		default: hm10 = 18'sd 36068;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm11 = -18'sd 1129;
		2'd1 : hm11 = -18'sd 6870;
		2'd2 : hm11 = -18'sd 7056;
		2'd3 : hm11 = -18'sd 3425;
		default: hm11 = -18'sd 1023;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm12 = 18'sd 1082;
		2'd1 : hm12 = 18'sd 3878;
		2'd2 : hm12 = 18'sd 3871;
		2'd3 : hm12 = 18'sd 1688;
		default: hm12 = 18'sd 1082;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm13 = -18'sd 1007;
		2'd1 : hm13 = -18'sd 2601;
		2'd2 : hm13 = -18'sd 2403;
		2'd3 : hm13 = -18'sd 857;
		default: hm13 = -18'sd 2115;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm14 = 18'sd 908;
		2'd1 : hm14 = 18'sd 1833;
		2'd2 : hm14 = 18'sd 1529;
		2'd3 : hm14 = 18'sd 382;
		default: hm14 = 18'sd 908;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm15 = -18'sd 791;
		2'd1 : hm15 = -18'sd 1295;
		2'd2 : hm15 = -18'sd 946;
		2'd3 : hm15 = -18'sd 96;
		default: hm15 = -18'sd 2161;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm16 = 18'sd 662;
		2'd1 : hm16 = 18'sd 889;
		2'd2 : hm16 = 18'sd 540;
		2'd3 : hm16 = -18'sd 73;
		default: hm16 = 18'sd 662;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm17 = -18'sd 529;
		2'd1 : hm17 = -18'sd 575;
		2'd2 : hm17 = -18'sd 256;
		2'd3 : hm17 = 18'sd 163;
		default: hm17 = -18'sd 2649;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm18 = 18'sd 398;
		2'd1 : hm18 = 18'sd 332;
		2'd2 : hm18 = 18'sd 62;
		2'd3 : hm18 = -18'sd 198;
		default: hm18 = 18'sd 398;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : hm19 = -18'sd 275;
		2'd1 : hm19 = -18'sd 149;
		2'd2 : hm19 = 18'sd 61;
		2'd3 : hm19 = 18'sd 194;
		default: hm19 = -18'sd 3783;
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm0 = x[0];
		2'd1 : xm0 = x[1];
		2'd2 : xm0 = x[2];
		2'd3 : xm0 = x[3];
		default: xm0 = x[0];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm1 = x[4];
		2'd1 : xm1 = x[5];
		2'd2 : xm1 = x[6];
		2'd3 : xm1 = x[7];
		default: xm1 = x[4];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm2 = x[8];
		2'd1 : xm2 = x[9];
		2'd2 : xm2 = x[10];
		2'd3 : xm2 = x[11];
		default: xm2 = x[8];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm3 = x[12];
		2'd1 : xm3 = x[13];
		2'd2 : xm3 = x[14];
		2'd3 : xm3 = x[15];
		default: xm3 = x[12];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm4 = x[16];
		2'd1 : xm4 = x[17];
		2'd2 : xm4 = x[18];
		2'd3 : xm4 = x[19];
		default: xm4 = x[16];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm5 = x[20];
		2'd1 : xm5 = x[21];
		2'd2 : xm5 = x[22];
		2'd3 : xm5 = x[23];
		default: xm5 = x[20];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm6 = x[24];
		2'd1 : xm6 = x[25];
		2'd2 : xm6 = x[26];
		2'd3 : xm6 = x[27];
		default: xm6 = x[24];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm7 = x[28];
		2'd1 : xm7 = x[29];
		2'd2 : xm7 = x[30];
		2'd3 : xm7 = x[31];
		default: xm7 = x[28];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm8 = x[32];
		2'd1 : xm8 = x[33];
		2'd2 : xm8 = x[34];
		2'd3 : xm8 = x[35];
		default: xm8 = x[32];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm9 = x[36];
		2'd1 : xm9 = x[37];
		2'd2 : xm9 = x[38];
		2'd3 : xm9 = x[39];
		default: xm9 = x[36];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm10 = x[40];
		2'd1 : xm10 = x[41];
		2'd2 : xm10 = x[42];
		2'd3 : xm10 = x[43];
		default: xm10 = x[40];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm11 = x[44];
		2'd1 : xm11 = x[45];
		2'd2 : xm11 = x[46];
		2'd3 : xm11 = x[47];
		default: xm11 = x[44];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm12 = x[48];
		2'd1 : xm12 = x[49];
		2'd2 : xm12 = x[50];
		2'd3 : xm12 = x[51];
		default: xm12 = x[48];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm13 = x[52];
		2'd1 : xm13 = x[53];
		2'd2 : xm13 = x[54];
		2'd3 : xm13 = x[55];
		default: xm13 = x[52];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm14 = x[56];
		2'd1 : xm14 = x[57];
		2'd2 : xm14 = x[58];
		2'd3 : xm14 = x[59];
		default: xm14 = x[56];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm15 = x[60];
		2'd1 : xm15 = x[61];
		2'd2 : xm15 = x[62];
		2'd3 : xm15 = x[63];
		default: xm15 = x[60];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm16 = x[64];
		2'd1 : xm16 = x[65];
		2'd2 : xm16 = x[66];
		2'd3 : xm16 = x[67];
		default: xm16 = x[64];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm17 = x[68];
		2'd1 : xm17 = x[69];
		2'd2 : xm17 = x[70];
		2'd3 : xm17 = x[71];
		default: xm17 = x[68];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm18 = x[72];
		2'd1 : xm18 = x[73];
		2'd2 : xm18 = x[74];
		2'd3 : xm18 = x[75];
		default: xm18 = x[72];
	endcase
end
always @ *
begin
	case(counter)
		2'd0 : xm19 = x[76];
		2'd1 : xm19 = x[77];
		2'd2 : xm19 = x[78];
		2'd3 : xm19 = x[79];
		default: xm19 = x[76];
	endcase
end
endmodule