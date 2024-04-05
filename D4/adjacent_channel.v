module adjacent_channel(
    input wire sys_clk, sam_clk_ena, sym_clk_ena, clock_12_5_ena, reset, adj_on_off, gauss_noise_on_off,
    input wire base_channel_on_off,
	input wire [1:0] gain_sel,
    input [3:0] in_delay_chain, out_delay_chain, NCO_in_delay_chain, NCO_out_delay_chain,
    input wire signed [17:0] sig_in, 
    output wire signed [17:0] sig_out //1s17


);
reg signed [35:0] NCO2_mult, sig_times_gain;
wire signed[17:0] awgn_out, sig_in_delay;
wire signed [17:0] I_tx_out, fcos_o;
wire [1:0] I_sym, Q_sym;

wire [21:0] q, LFSR_Counter;
wire signed [17:0] G1, G2, G3;
reg signed [17:0] adj_chan_val, base_chan, sum1,  noise, sum2, gain_out;



LFSR lfsr_adj(

	.clk(sys_clk),
	.sam_clk_ena(sam_clk_ena),
	.load_data(reset),
	.q(q),
	//.LFSR_2_BITS(LFSR_2_BITS),
	.I_sym(I_sym),
	.Q_sym(Q_sym),
	.LFSR_Counter(LFSR_Counter)

);


Baseband_Channel_TX I_channel_tx_adj(
	.sys_clk(sys_clk),
	.sam_clk_ena(sam_clk_ena),
	.sym_clk_ena(sym_clk_ena),
	.clock_12_5_ena(clock_12_5_ena),
	.reset(reset),
	.delay_chain(NCO_in_delay_chain), // NCO DELAY
	.mapper_in(I_sym),
	.sig_out(I_tx_out),
	.impulse_in(18'sd98304),
	.impulse_on_off(1'b0)
);


// NCO in delays

//NCO_2
NCO_2 nco2(
	.clk(sys_clk),
	.reset_n(~reset),
	.clken(1'b1),
	.fcos_o(fcos_o),
	.phi_inc_i(18'd83886)
);


// NCO2 multiplier
always @ *
	NCO2_mult = $signed(I_tx_out) * $signed(fcos_o); // 1s17 * 1s17 = 2s34


// switch 2 to decide to output channel or not
always @ *
	if(adj_on_off)
		adj_chan_val = $signed(NCO2_mult[34:17]); // 1s17

	else
		adj_chan_val = 18'sd0;

// NCO_2 delays
/***************************************Gain***********************/
assign G1 = 18'sd 48648;//96465; //4s14
assign G2 = 18'sd 65693; //130751; //4s14
assign G3 = 18'sd 79711;//158653; //4s14

always @ *
begin
	case(gain_sel)
	2'd0: gain_out = 18'sd0; //4s14
	2'd1: gain_out = G1; //4s14
	2'd2: gain_out = G2; //4s14
	2'd3: gain_out = G3; //4s14

	default: gain_out = G3;
	endcase
end


/***************************************Noise***********************/

awgn_generator awgn_gen(
	.clk(sys_clk),
	.clk_en(1'b1),
	.reset_n(~reset),
	.awgn_out(awgn_out) // 1s17
);

always @ *
	if(gauss_noise_on_off)
		noise = $signed(awgn_out); //1s17
	else
		noise = 18'sd0;
/***************************INPUT******************************/
// gains
// input delay
filter_delay #(.DELAY(10)) in_delay(
	.sys_clk(sys_clk),
	.reset(reset),
	.sam_clk_en(1'b1),
	.sig_in(sig_in),
	.sig_out(sig_in_delay),
	.delay_change(in_delay_chain)

);


always @ *
	if(base_channel_on_off)
		base_chan = $signed(sig_in_delay);
	else
		base_chan = 18'sd0;


// summations

// sum of NCO and sig in
always @ *
	sum1 = {base_chan[17],base_chan[17:1]} + {adj_chan_val[17], adj_chan_val[17:1]}; //2s16



//multiply
always @ *
	sig_times_gain = sum1 * gain_out; // 2s16*4s14 = 6s30


always @ *
	sum2 = sig_times_gain[31:14] + {noise[17], noise[17:1]}; // 2s16 sum1 


// output delay
filter_delay #(.DELAY(10)) out_delay(
	.sys_clk(sys_clk),
	.reset(reset),
	.sam_clk_en(1'b1),
	.sig_in({sum2[16:0], 1'b0}), //1s17
	.sig_out(sig_out),
	.delay_change(out_delay_chain)

);





endmodule