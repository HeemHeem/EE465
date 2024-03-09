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
reg signed [17:0] hm0, hm1, hm2, hm3, hm4, xm0, xm1, xm2, xm3, xm4; // hm's- 0s18, xm's 1s17
reg signed [35:0] m0, m1, m2, m3, m4, m5; // 1s35
reg signed [35:0] m0_acc, m1_acc, m2_acc, m3_acc, m4_acc; // 1s35
reg signed [35:0] y_temp; // 1s35
reg [3:0] counter;

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
// counter
always  @ (posedge clk or posedge reset)
    if(reset)
        counter <= 4'd0;
    else if (sym_clk_en)
        counter  <= 4'd0;
    else
        counter <= counter + 4'd1;

// multipliers


// m0
always @ (posedge clk or posedge reset)
    if (reset)
        m0 <= 36'sd0;
    else
        m0 <= xm0 * hm0;

// m0 acc
always @ (posedge clk or posedge reset)
    if (reset)
        m0 <= m0;
    else if (sym_clk_en)
        m0 <= m0;
    else
        m0_acc <= m0_acc + m0;


// m1
always @ (posedge clk or posedge reset)
    if (reset)
        m1 <= 36'sd0;
    else
        m1 <= xm1 * hm1;

// m1 acc
always @ (posedge clk or posedge reset)
    if (reset)
        m1_acc <= m1;
    else if (sym_clk_en)
        m1_acc <= m1;
    else
        m1_acc <= m1_acc + m1;



// m2
always @ (posedge clk or posedge reset)
    if (reset)
        m2 <= 36'sd0;
    else
        m2 <= xm2 * hm2;

// m2 acc
always @ (posedge clk or posedge reset)
    if (reset)
        m2_acc <= m2;
    else if (sym_clk_en)
        m2_acc <= m2;
    else
        m2_acc <= m2_acc + m2;



// m3
always @ (posedge clk or posedge reset)
    if (reset)
        m3 <= 36'sd0;
    else
        m3 <= xm3 * hm3;

// m3 acc
always @ (posedge clk or posedge reset)
    if (reset)
        m3_acc <= m3;

    else if (sym_clk_en)
        m3_acc <= m3;
    else
        m3_acc <= m3_acc + m3;


// m4
always @ (posedge clk or posedge reset)
    if (reset)
        m4 <= 36'sd0;
    else
        m4 <= xm4 * hm4;

// m4 acc
always @ (posedge clk or posedge reset)
    if (reset)
        m4_acc <= m4;

    else if (sym_clk_en)
        m4_acc <= m4;
    else
        m4_acc <= m4_acc + m4;



// m5
 
wire signed [17:0] h80;

assign h80 = 18'sd 166;

always @ *
    if(reset)
        m5 <= 36'sd0;
    else
	    m5 <= x[80] * h80;


// sum level 1
always @ (posedge clk or posedge reset)
    if (reset) begin
        sum_level_1[0] <= 36'sd0;
        sum_level_1[1] <= 36'sd0;
    end

    else if (sym_clk_en) begin
        sum_level_1[0] <= m0_acc + m1_acc;
        sum_level_1[1] <= m2_acc + m3_acc;
        sum_level_1[2] <= m4_acc;
    end

    else begin
        sum_level_1[0] <= sum_level_1[0];
        sum_level_1[1] <= sum_level_1[1];
        sum_level_1[2] <= sum_level_1[2];
    end
// sum level 2
always @ *
    if (reset) begin
        sum_level_2[0] <= 36'sd0;
        sum_level_2[1] <= 36'sd0;
    end
    else begin
        sum_level_2[0] <= sum_level_1[0] + sum_level_1[1];
        sum_level_2[1] <= sum_level_1[2] + m5;
    end


// y_temp
always @ *
    y_temp = sum_level_2[0] + sum_level_2[1]; // 1s35 + 1s35 = 1s35

// y
always @ (posedge clk or posedge reset)
    if(reset)
        y <= 18'sd0;
    else if(sam_clk_en)
        y <= y_temp[35:18]; // 1s17
    else
        y <= y;



always @ *
begin
	case(counter)
		4'd0 : hm0 = 18'sd 166;
		4'd1 : hm0 = 18'sd 194;
		4'd2 : hm0 = 18'sd 61;
		4'd3 : hm0 = -18'sd 149;
		4'd4 : hm0 = -18'sd 275;
		4'd5 : hm0 = -18'sd 198;
		4'd6 : hm0 = 18'sd 62;
		4'd7 : hm0 = 18'sd 332;
		4'd8 : hm0 = 18'sd 398;
		4'd9 : hm0 = 18'sd 163;
		4'd10 : hm0 = -18'sd 256;
		4'd11 : hm0 = -18'sd 575;
		4'd12 : hm0 = -18'sd 529;
		4'd13 : hm0 = -18'sd 73;
		4'd14 : hm0 = 18'sd 540;
		4'd15 : hm0 = 18'sd 889;
		default: hm0 = 18'sd 166;
	endcase
end
always @ *
begin
	case(counter)
		4'd0 : hm1 = 18'sd 662;
		4'd1 : hm1 = -18'sd 96;
		4'd2 : hm1 = -18'sd 946;
		4'd3 : hm1 = -18'sd 1295;
		4'd4 : hm1 = -18'sd 791;
		4'd5 : hm1 = 18'sd 382;
		4'd6 : hm1 = 18'sd 1529;
		4'd7 : hm1 = 18'sd 1833;
		4'd8 : hm1 = 18'sd 908;
		4'd9 : hm1 = -18'sd 857;
		4'd10 : hm1 = -18'sd 2403;
		4'd11 : hm1 = -18'sd 2601;
		4'd12 : hm1 = -18'sd 1007;
		4'd13 : hm1 = 18'sd 1688;
		4'd14 : hm1 = 18'sd 3871;
		4'd15 : hm1 = 18'sd 3878;
		default: hm1 = 18'sd 662;
	endcase
end
always @ *
begin
	case(counter)
		4'd0 : hm2 = 18'sd 1082;
		4'd1 : hm2 = -18'sd 3425;
		4'd2 : hm2 = -18'sd 7056;
		4'd3 : hm2 = -18'sd 6870;
		4'd4 : hm2 = -18'sd 1129;
		4'd5 : hm2 = 18'sd 9550;
		4'd6 : hm2 = 18'sd 22113;
		4'd7 : hm2 = 18'sd 32208;
		4'd8 : hm2 = 18'sd 36068;
		4'd9 : hm2 = 18'sd 32208;
		4'd10 : hm2 = 18'sd 22113;
		4'd11 : hm2 = 18'sd 9550;
		4'd12 : hm2 = -18'sd 1129;
		4'd13 : hm2 = -18'sd 6870;
		4'd14 : hm2 = -18'sd 7056;
		4'd15 : hm2 = -18'sd 3425;
		default: hm2 = 18'sd 1082;
	endcase
end
always @ *
begin
	case(counter)
		4'd0 : hm3 = 18'sd 1082;
		4'd1 : hm3 = 18'sd 3878;
		4'd2 : hm3 = 18'sd 3871;
		4'd3 : hm3 = 18'sd 1688;
		4'd4 : hm3 = -18'sd 1007;
		4'd5 : hm3 = -18'sd 2601;
		4'd6 : hm3 = -18'sd 2403;
		4'd7 : hm3 = -18'sd 857;
		4'd8 : hm3 = 18'sd 908;
		4'd9 : hm3 = 18'sd 1833;
		4'd10 : hm3 = 18'sd 1529;
		4'd11 : hm3 = 18'sd 382;
		4'd12 : hm3 = -18'sd 791;
		4'd13 : hm3 = -18'sd 1295;
		4'd14 : hm3 = -18'sd 946;
		4'd15 : hm3 = -18'sd 96;
		default: hm3 = 18'sd 1082;
	endcase
end
always @ *
begin
	case(counter)
		4'd0 : hm4 = 18'sd 662;
		4'd1 : hm4 = 18'sd 889;
		4'd2 : hm4 = 18'sd 540;
		4'd3 : hm4 = -18'sd 73;
		4'd4 : hm4 = -18'sd 529;
		4'd5 : hm4 = -18'sd 575;
		4'd6 : hm4 = -18'sd 256;
		4'd7 : hm4 = 18'sd 163;
		4'd8 : hm4 = 18'sd 398;
		4'd9 : hm4 = 18'sd 332;
		4'd10 : hm4 = 18'sd 62;
		4'd11 : hm4 = -18'sd 198;
		4'd12 : hm4 = -18'sd 275;
		4'd13 : hm4 = -18'sd 149;
		4'd14 : hm4 = 18'sd 61;
		4'd15 : hm4 = 18'sd 194;
		default: hm4 = 18'sd 662;
	endcase
end
always @ *
begin
	case(counter)
		4'd0 : xm0 = x[0];
		4'd1 : xm0 = x[1];
		4'd2 : xm0 = x[2];
		4'd3 : xm0 = x[3];
		4'd4 : xm0 = x[4];
		4'd5 : xm0 = x[5];
		4'd6 : xm0 = x[6];
		4'd7 : xm0 = x[7];
		4'd8 : xm0 = x[8];
		4'd9 : xm0 = x[9];
		4'd10 : xm0 = x[10];
		4'd11 : xm0 = x[11];
		4'd12 : xm0 = x[12];
		4'd13 : xm0 = x[13];
		4'd14 : xm0 = x[14];
		4'd15 : xm0 = x[15];
		default: xm0 = x[0];
	endcase
end
always @ *
begin
	case(counter)
		4'd0 : xm1 = x[16];
		4'd1 : xm1 = x[17];
		4'd2 : xm1 = x[18];
		4'd3 : xm1 = x[19];
		4'd4 : xm1 = x[20];
		4'd5 : xm1 = x[21];
		4'd6 : xm1 = x[22];
		4'd7 : xm1 = x[23];
		4'd8 : xm1 = x[24];
		4'd9 : xm1 = x[25];
		4'd10 : xm1 = x[26];
		4'd11 : xm1 = x[27];
		4'd12 : xm1 = x[28];
		4'd13 : xm1 = x[29];
		4'd14 : xm1 = x[30];
		4'd15 : xm1 = x[31];
		default: xm1 = x[16];
	endcase
end
always @ *
begin
	case(counter)
		4'd0 : xm2 = x[32];
		4'd1 : xm2 = x[33];
		4'd2 : xm2 = x[34];
		4'd3 : xm2 = x[35];
		4'd4 : xm2 = x[36];
		4'd5 : xm2 = x[37];
		4'd6 : xm2 = x[38];
		4'd7 : xm2 = x[39];
		4'd8 : xm2 = x[40];
		4'd9 : xm2 = x[41];
		4'd10 : xm2 = x[42];
		4'd11 : xm2 = x[43];
		4'd12 : xm2 = x[44];
		4'd13 : xm2 = x[45];
		4'd14 : xm2 = x[46];
		4'd15 : xm2 = x[47];
		default: xm2 = x[32];
	endcase
end
always @ *
begin
	case(counter)
		4'd0 : xm3 = x[48];
		4'd1 : xm3 = x[49];
		4'd2 : xm3 = x[50];
		4'd3 : xm3 = x[51];
		4'd4 : xm3 = x[52];
		4'd5 : xm3 = x[53];
		4'd6 : xm3 = x[54];
		4'd7 : xm3 = x[55];
		4'd8 : xm3 = x[56];
		4'd9 : xm3 = x[57];
		4'd10 : xm3 = x[58];
		4'd11 : xm3 = x[59];
		4'd12 : xm3 = x[60];
		4'd13 : xm3 = x[61];
		4'd14 : xm3 = x[62];
		4'd15 : xm3 = x[63];
		default: xm3 = x[48];
	endcase
end
always @ *
begin
	case(counter)
		4'd0 : xm4 = x[64];
		4'd1 : xm4 = x[65];
		4'd2 : xm4 = x[66];
		4'd3 : xm4 = x[67];
		4'd4 : xm4 = x[68];
		4'd5 : xm4 = x[69];
		4'd6 : xm4 = x[70];
		4'd7 : xm4 = x[71];
		4'd8 : xm4 = x[72];
		4'd9 : xm4 = x[73];
		4'd10 : xm4 = x[74];
		4'd11 : xm4 = x[75];
		4'd12 : xm4 = x[76];
		4'd13 : xm4 = x[77];
		4'd14 : xm4 = x[78];
		4'd15 : xm4 = x[79];
		default: xm4 = x[64];
	endcase
end

endmodule