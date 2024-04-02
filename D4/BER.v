module BER(
    input sys_clk, sam_clk_en, sym_clk_en, KEY,
    input [1:0] slicer_in_I, slicer_in_Q,

    output [21:0] error_count // 22 bits instead of 21 because we are using both I and Q


);

reg detect_errors, p_to_s, initialize, initialize_position, d0, error, error_ena, roll_over;
reg [21:0] q;
reg [19:0] counter;

// counter logic
always @ (posedge sys_clk)
    if(reset)
        counter <= 20'd0;
    else if(sym_clk_en)
        counter <= counter + 20'd1;
    else
        counter  <= counter;



// roll over detector
always @ *
    if(counter == 20'hfffff)
        roll_over = 1'b1;
    else
        roll_over = 1'b0;

// error enable
always @ *
    error_ena = error && sam_clk_en;

// error counter
always @ (posedge sys_clk)
    if(roll_over)
        error_count <= 22'd0; // clear
    
    else if(error_ena)
        error_count <= error_count + 22'd1;
    else
        error_counter <= error_count;


// error
always @ *
    error = p_to_s ^ d0;


// LFSR d0 input
always @ *
    begin
    case(initialize_position)
        1'b0: d0 = detect_errors;
        1'b1: d0 = p_to_s;
    endcase
end


// initialize
always @ (posedge clk)
    if(~KEY)
        initialize <= 1'b1;
    else
        initialize <= 1'b0;


// initialize position


//Parallel to serial circuit
parallel_to_serial p2s(
    .clk(sys_clk),
    .reset(reset),
    .sam_clk_en(sam_clk_en),
    .from_slice_I(slicer_in_I),
    .from_slicer_Q(slicer_in_q),
    .p_to_s(p_to_s)

);

LFSR_BER lfsr_ber(
    .clk(sys_clk)
    .sam_clk_ena(sam_clk_en),
    .d0(d0),
    .load_data(initialize),
    .q(q),
    // .I_sym(),
    // .Q_sym(),
    // .LFSR_Counter(),
    .feedback(detect_errors)
);





endmodule