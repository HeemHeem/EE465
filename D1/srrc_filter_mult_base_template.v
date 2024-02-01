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

 


