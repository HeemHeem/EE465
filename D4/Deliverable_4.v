module Deliverable_4(
	input [17:0] PHYS_SW,
	input [3:0] PHYS_KEY,
	input CLOCK_50,
	//output wire [21:0] q, LFSR_Counter,
	output wire [1:0] I_sym, Q_sym, I_slice_out, symb_a, Q_slice_out, //LFSR_2_BITS
 	output wire sys_clk, sam_clk_ena, sym_clk_ena, sym_correct, sym_error, clock_12_5_ena,
	//output reg clear_accumulator,
	output wire [3:0] clk_phase,
	output wire signed [17:0] I_reference_level, I_decision_variable,  I_error, I_b, I_tx_out, I_NCO_out_tx,//errorless_decision_variable, error_by_system, // 1s17
	
	output wire [39:0] I_mapper_out_power, //4s36
	//output wire [37:0] accumulator, absolute_value, acc_counter,

	// accumulated_square_error

	output wire [29:0] I_accumulated_squared_error, // -4u34

	// accumulated_dc_error
	//output wire signed [35:0] acc_dc,
	output wire signed [35:0] I_accumulated_error, // -1s37
	output wire [21:0] error_count,
	
	
	// filters
	output reg signed [17:0] tx_out, //symbol_into_upsam, y_into_down_sam, y_into_delay 
	//output wire [1:0] time_share_counter

	input [13:0]ADC_DA,
	input [13:0]ADC_DB,

	output reg[13:0]DAC_DA,
	output reg [13:0]DAC_DB,
	// output	I2C_SCLK,
	// inout		I2C_SDAT,
	output	ADC_CLK_A,
	output	ADC_CLK_B,
	output	ADC_OEB_A,
	output	ADC_OEB_B,
	// input 	ADC_OTR_A,
	// input 	ADC_OTR_B,
	output	DAC_CLK_A,
	output	DAC_CLK_B,
	output	DAC_MODE,
	output	DAC_WRT_A,
	output	DAC_WRT_B
	// ,input 	OSC_SMA_ADC4,
	// input 	SMA_DAC4



);
wire signed [17:0] Q_tx_out, Q_NCO_out_tx;
wire [39:0] Q_mapper_out_power; //4s36
wire signed [39:0] Q_accumulated_squared_error; // -4u34
wire signed [35:0] Q_accumulated_error; // -1s37
wire [21:0] q, LFSR_Counter;
wire signed [17:0] channel_out, channel_out_delay, I_NCO_out_rx, Q_NCO_out_rx, I_mapper_out, Q_mapper_out; //1s17
wire signed [17:0] Q_error; //1s17
wire [37:0] accumulator, absolute_value, acc_counter;
wire signed [35:0] acc_dc;
wire [63:0] isi_in;
wire [49:0] acc_error;
wire [35:0] sqr_error;
wire [17:0] hb_interp1_out, hb_interp2_out, hb_interp2_out_delay, hb_decim1_out, hb_decim2_out, hb_decim1_down, hb_decim2_down;

reg signed [17:0] channel_out_scld, I_NCO_out_tx_scld, Q_NCO_out_tx_scld; 
wire signed [17:0] Q_decision_variable, Q_b, Q_reference_level;
reg clear_accumulator;
/************************
			Set up DACs
		*/
		assign DAC_CLK_A = sys_clk;
		assign DAC_CLK_B = sys_clk;
		
		
		assign DAC_MODE = 1'b1; //treat DACs seperately
		
		assign DAC_WRT_A = ~sys_clk;
		assign DAC_WRT_B = ~sys_clk;
		
	always@ (posedge sys_clk)// convert 1s13 format to 0u14
							//format and send it to DAC A
	DAC_DA = {~channel_out_scld[17],
					channel_out_scld[16:4]};	
			
	always@ (posedge sys_clk) // DAC B is not used in this
					// lab so makes it the same as DAC A
				
		DAC_DB = {~channel_out_scld[17],
					channel_out_scld[16:4]};	
		/*  End DAC setup
		************************/

/********************
*	set up ADCs, which are not used in this lab 
*/
(* noprune *) reg [13:0] registered_ADC_A;
(* noprune *) reg [13:0] registered_ADC_B;

assign ADC_CLK_A = sys_clk;
		assign ADC_CLK_B = sys_clk;
		
		assign ADC_OEB_A = 1'b1;
		assign ADC_OEB_B = 1'b1;

		
		always@ (posedge sys_clk)
			registered_ADC_A <= ADC_DA;
			
		always@ (posedge sys_clk)
			registered_ADC_B <= ADC_DB;
			
		/*  End ADC setup
		************************/	



MER isi_probes(
.probe(isi_in),
.source(isi_in)
);


reg [10:0] counter_imp;
reg [17:0] mux_out, periodic_impulse;

// impulse ciruit
// counter
always @ (posedge sys_clk)
	if(sam_clk_ena)
	//if(clock_12_5_ena)
		counter_imp <= counter_imp + 11'd1;
		
	else
		counter_imp <= counter_imp;
//mux_select
always @ *
	if(~|counter_imp)
		mux_out <= 18'sd98304;
		//mux_out <= 18'sd131071;
	else
		mux_out <= 18'sb0;




always @ (posedge sys_clk)
	periodic_impulse <= mux_out;

//

clocks test_clocks(

	.clock_50(CLOCK_50),
	.sys_clk(sys_clk),
	.sam_clk_ena(sam_clk_ena),
	.sym_clk_ena(sym_clk_ena),
	.clk_phase(clk_phase),
	.clock_12_5_ena(clock_12_5_ena)

);


LFSR lfsr(

	.clk(sys_clk),
	.sam_clk_ena(sam_clk_ena),
	.load_data(PHYS_SW[17]),
	.q(q),
	//.LFSR_2_BITS(LFSR_2_BITS),
	.I_sym(I_sym),
	.Q_sym(Q_sym),
	.LFSR_Counter(LFSR_Counter)

);

/************************* CLEAR ACCUMULATOR SIGNAL *******************************/
always @ (posedge sys_clk)
	if(LFSR_Counter == 22'h3fffff)
	//if(q == 22'h0fffff)
		clear_accumulator = 1'b1;
	else
		clear_accumulator = 1'b0;

//input_mapper in_map(
//
//	.mapper_in(LFSR_2_BITS),
//	.mapper_out(symbol_into_upsam) // decision variable output for now.
//);

Baseband_Channel_TX I_channel_tx(
	.sys_clk(sys_clk),
	.sam_clk_ena(sam_clk_ena),
	.sym_clk_ena(sym_clk_ena),
	.clock_12_5_ena(clock_12_5_ena),
	.reset(PHYS_SW[17]),
	.delay_chain(isi_in[3:0]),
	.mapper_in(I_sym),
	.sig_out(I_tx_out),
	.impulse_in(mux_out),
	.impulse_on_off(PHYS_SW[16])
);


Baseband_Channel_TX Q_channel_tx(
	.sys_clk(sys_clk),
	.sam_clk_ena(sam_clk_ena),
	.sym_clk_ena(sym_clk_ena),
	.clock_12_5_ena(clock_12_5_ena),
	.reset(PHYS_SW[17]),
	.delay_chain(isi_in[3:0]),
	.mapper_in(Q_sym),
	.sig_out(Q_tx_out),
	.impulse_in(mux_out),
	.impulse_on_off(PHYS_SW[16])
);





// NCO_1 here
NCO_1 nco1_tx(
	.clk(sys_clk),
	.reset(PHYS_SW[17]),
	.I_sig_in(I_tx_out),
	.Q_sig_in(Q_tx_out),
	.NCO_cos(I_NCO_out_tx),
	.NCO_sin(Q_NCO_out_tx)
);

//always @ *
//	I_NCO_out_tx_scld = I_NCO_out_tx <<<1;
//
//always @ *
//	Q_NCO_out_tx_scld = Q_NCO_out_tx <<<1;

always @ *
	tx_out = I_NCO_out_tx + Q_NCO_out_tx;


adjacent_channel adj_chan(
	.sys_clk(sys_clk),
	.sam_clk_ena(sam_clk_ena),
	.sym_clk_ena(sym_clk_ena),
	.clock_12_5_ena(clock_12_5_ena),
	.reset(PHYS_SW[17]),
	.adj_on_off(PHYS_SW[2]),
	.gauss_noise_on_off(PHYS_SW[4]),
	.in_delay_chain(isi_in[7:4]),
	.out_delay_chain(isi_in[11:8]),
	.NCO_in_delay_chain(isi_in[15:12]),
	.NCO_out_delay_chain(isi_in[19:16]),
	.sig_in(tx_out), // NCO out
	.sig_out(channel_out)

);

always @ *
	channel_out_scld = channel_out<<<2;


filter_delay #(.DELAY(10)) NCO_rx_in_delay(
	.sys_clk(sys_clk),
	.reset(PHYS_SW[17]),
	.sam_clk_en(1'b1),
	.sig_in(channel_out),
	.sig_out(channel_out_delay),
	.delay_change(isi_in[23:20])

);

// NCO1 rx
NCO_1 nco1_rx(
	.clk(sys_clk),
	.reset(PHYS_SW[17]),
	.I_sig_in(channel_out_delay),
	.Q_sig_in(channel_out_delay),
	.NCO_cos(I_NCO_out_rx),
	.NCO_sin(Q_NCO_out_rx)
);


RF_Channel_RX I_channel_rx(
	.sys_clk(sys_clk),
	.sam_clk_ena(sam_clk_ena),
	.sym_clk_ena(sym_clk_ena),
	.clock_12_5_ena(clock_12_5_ena),
	.reset(PHYS_SW[17]),
	.sig_in(I_NCO_out_rx),
	.delay_chain1(isi_in[27:24]),
	.delay_chain2(isi_in[31:28]),
	.delay_chain3(isi_in[35:32]),
	.decision_variable(I_decision_variable)	
);

RF_Channel_RX Q_channel_rx(
	.sys_clk(sys_clk),
	.sam_clk_ena(sam_clk_ena),
	.sym_clk_ena(sym_clk_ena),
	.clock_12_5_ena(clock_12_5_ena),
	.reset(PHYS_SW[17]),
	.sig_in(Q_NCO_out_rx),
	.delay_chain1(isi_in[27:24]),
	.delay_chain2(isi_in[31:28]),
	.delay_chain3(isi_in[35:32]),
	.decision_variable(Q_decision_variable)	
);


reference_level_and_error I_ref_and_err(
	.sys_clk(sys_clk),
	.sam_clk_ena(sam_clk_ena),
	.sym_clk_ena(sym_clk_ena),
	.clock_12_5_ena(clock_12_5_ena),
	.reset(PHYS_SW[17]),
	.reference_level(I_reference_level),
	.decision_variable(I_decision_variable),
	.slice_out(I_slice_out),
	.b(I_b),
	.mapper_out(I_mapper_out),
	.error(I_error)	
);

reference_level_and_error Q_ref_and_err(
	.sys_clk(sys_clk),
	.sam_clk_ena(sam_clk_ena),
	.sym_clk_ena(sym_clk_ena),
	.clock_12_5_ena(clock_12_5_ena),
	.reset(PHYS_SW[17]),
	.reference_level(Q_reference_level),
	.decision_variable(Q_decision_variable),
	.slice_out(Q_slice_out),
	.b(Q_b),
	.mapper_out(Q_mapper_out),
	.error(Q_error)	
);




symbol_comparison I_sym_comp(
	.sys_clk(sys_clk),
	.sam_clk_ena(sam_clk_ena),
	.sym_clk_ena(sym_clk_ena),
	.clock_12_5_ena(clock_12_5_ena),
	.reset(PHYS_SW[17]),
	.symb_in(I_sym),
	.slice_in(I_slice_out),
	.delay_chain(isi_in[39:36]),
	.sym_correct(sym_correct),
	.sym_error(sym_error)
);


MER_circuit I_MER(
	.sys_clk(sys_clk),
	.sam_clk_ena(sam_clk_ena),
	.sym_clk_ena(sym_clk_ena),
	.clock_12_5_ena(clock_12_5_ena),
	.reset(PHYS_SW[17]),
	.clear_accumulator(clear_accumulator),
	.decision_variable(I_decision_variable),
	.error(I_error),
	.mapper_out_power(I_mapper_out_power),
	.accumulated_squared_error(I_accumulated_squared_error),
	.accumulated_error(I_accumulated_error),
	.reference_level(I_reference_level)
);




MER_circuit Q_MER(
	.sys_clk(sys_clk),
	.sam_clk_ena(sam_clk_ena),
	.sym_clk_ena(sym_clk_ena),
	.clock_12_5_ena(clock_12_5_ena),
	.reset(PHYS_SW[17]),
	.clear_accumulator(clear_accumulator),
	.decision_variable(Q_decision_variable),
	.error(Q_error),
	.mapper_out_power(Q_mapper_out_power),
	.accumulated_squared_error(Q_accumulated_squared_error),
	.accumulated_error(Q_accumulated_error),
	.reference_level(Q_reference_level)
);


BER ber(

	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_ena),
	.sym_clk_en(sym_clk_ena),
	.KEY(PHYS_KEY[0]),
	.slicer_in_I(I_slice_out),
	.slicer_in_Q(Q_slice_out),
	.error_count(error_count)

);













// upsampler upsam(
// 	.sys_clk(sys_clk),
// 	.sym_clk_en(sym_clk_ena),
// 	.sam_clk_en(sam_clk_ena),
// 	.reset(PHYS_SW[0]),
// 	.symb_in(symbol_into_upsam),
// 	.sig_out(symbol_into_filter)

// );

// tx_pract_filter2 pract(

// 	.clk(sys_clk),
// 	.reset(PHYS_SW[0]),
// 	.sym_clk_en(sym_clk_ena),
// 	.sam_clk_en(sam_clk_ena),
// 	.x_in(symbol_into_filter),
// 	.y(tx_out)

// );

//  //halfband interpolator
// halfband_filter_interp interp1(
// 	.clk(sys_clk),
// 	.reset(PHYS_SW[0]),
// 	.sym_clk_en(sym_clk_ena),
// 	.sam_clk_en(sam_clk_ena),
// 	.bit_rate_en(clock_12_5_ena),
// 	//.x_in(periodic_impulse),
// 	.x_in(tx_out),
// 	.y(hb_interp1_out)


// );

// halfband_filter_interp2 interp2(
// 	.clk(sys_clk),
// 	.reset(PHYS_SW[0]),
// 	.sym_clk_en(sym_clk_ena),
// 	.sam_clk_en(sam_clk_ena),
// 	.bit_rate_en(clock_12_5_ena),
// 	.x_in(hb_interp1_out),
// 	//.x_in(p_delay),
// 	.y(hb_interp2_out)
// 	//.y2(y2),
// 	//.y1(y1),
// 	//.counter(count)


// );


// filter_delay #(.DELAY(10)) hb1_interp_delay(
// 	.sys_clk(sys_clk),
// 	.reset(PHYS_SW[0]),
// 	.sam_clk_en(1'b1),
// 	.sig_in(hb_interp2_out),
// 	.sig_out(hb_interp2_out_delay),
// 	.delay_change(isi_in[19:16])

// );


// halfband_filter_decim_poly decim1(
// 	.clk(sys_clk),
// 	.reset(PHYS_SW[0]),
// 	.sym_clk_en(sym_clk_ena),
// 	.sam_clk_en(sam_clk_ena),
// 	.bit_rate_en(clock_12_5_ena),
// 	.x_in(hb_interp2_out_delay),
// 	.y(hb_decim1_out)
// 	//.y2(y2)


// );


// filter_delay #(.DELAY(10)) hb1_decim_delay(
// 	.sys_clk(sys_clk),
// 	.reset(PHYS_SW[0]),
// 	.sam_clk_en(clock_12_5_ena),
// 	.sig_in(hb_decim1_out),
// 	.sig_out(hb_decim1_down),
// 	.delay_change(isi_in[11:8])

// );




// halfband_filter_decim decim2(
// 	.clk(sys_clk),
// 	.reset(PHYS_SW[0]),
// 	.sym_clk_en(sym_clk_ena),
// 	.sam_clk_en(sam_clk_ena),
// 	.bit_rate_en(clock_12_5_ena),
// 	.x_in(hb_decim1_down),
// 	.y(hb_decim2_out)


// );


// filter_delay #(.DELAY(10)) hb2_decim_delay(
// 	.sys_clk(sys_clk),
// 	.reset(PHYS_SW[0]),
// 	.sam_clk_en(sam_clk_ena),
// 	.sig_in(hb_decim2_out),
// 	.sig_out(hb_decim2_down),
// 	.delay_change(isi_in[15:12])

// );
// //tx_gs_filter2 gs(
// //
// //	.clk(sys_clk),
// //	.reset(~load_data),
// //	.sym_clk_en(sym_clk_ena),
// //	.sam_clk_en(sam_clk_ena),
// //	.x_in(symbol_into_filter),
// //	.y(tx_out)
// //
// //);

// rx_gs_filter filt2(

// 	.clk(sys_clk),
// 	.reset(PHYS_SW[0]),
// 	.sym_clk_en(sym_clk_ena),
// 	.sam_clk_en(sam_clk_ena),
// 	.x_in(hb_decim2_down),
// 	.y(y_into_delay)
// 	//.y(decision_variable)
// );


// //test_timesharing5 filt2(
// //
// //	.clk(sys_clk),
// //	.reset(~load_data),
// //	.sym_clk_en(sym_clk_ena),
// //	.sam_clk_en(sam_clk_ena),
// //	.x_in(tx_out),
// //	.y(y_into_delay),
// //	.counter(time_share_counter)
// //	//.y(decision_variable)
// //);


// filter_delay #(.DELAY(10)) filt_delay(
// 	.sys_clk(sys_clk),
// 	.reset(PHYS_SW[0]),
// 	.sam_clk_en(sam_clk_ena),
// 	.sig_in(y_into_delay),
// 	.sig_out(y_into_down_sam),
// 	.delay_change(isi_in[3:0])

// );


// downsampler downsam(

// 	.sys_clk(sys_clk),
// 	.sym_clk_en(sym_clk_ena),
// 	.sam_clk_en(sam_clk_ena),
// 	.reset(PHYS_SW[0]),
// 	.sig_in(y_into_down_sam),
// 	.sym_out(decision_variable)

// );

// //DUT_for_MER_measurement SUT(
// //
// //	.clk(sys_clk),
// //	.clk_en(sym_clk_ena),
// //	.reset(load_data),
// //	 //.isi_power(18'sd9268), //20dB
// //	// .isi_power(18'sd293), //50 dB
// //	//.isi_power(18'sd165), //55dB
// //	.isi_power(isi_in),
// //	.in_data(symbol_into_filter),
// //	.decision_variable(decision_variable),
// //	.errorless_decision_variable(errorless_decision_variable),
// //	.error(error_by_system)
// //
// //);




// magnitude_estimate mag_est(

// 	.clk(sys_clk),
// 	.sym_clk_ena(sym_clk_ena),
// 	.clear_accumulator(clear_accumulator),
// 	.decision_variable(decision_variable),
// 	.reference_level(reference_level),
// 	.mapper_out_power(mapper_out_power),
// 	.accumulator(accumulator),
// 	//.b(b),
// 	.absolute_value(absolute_value),
// 	.acc_counter(acc_counter)

// );

// slicer slice(
// 	.reference_level(reference_level),
// 	.decision_variable(decision_variable),
// 	.slice_out(slice_out)

// );


// delay dl(
// 	.sym_clk_en(sym_clk_ena),
// 	.sam_clk_en(sam_clk_ena),
// 	.sig_in(LFSR_2_BITS),
// 	.symb_a(symb_a),
// 	.sys_clk(sys_clk),
// 	.delay_change(isi_in[7:4])
// );

// comparator comp(
// 	.sym_clk_ena(sym_clk_ena),
// 	.symb_a(symb_a),
// 	.symb_b(slice_out),
// 	.sym_correct(sym_correct),
// 	.sym_error(sym_error),
// 	.clk(sys_clk)
// );


// output_mapper out_map(
// 	.reference_level(reference_level),
// 	.slice_in(slice_out),
// 	.mapper_out(mapper_out),
// 	.b(b)
// );

// decision_error	dec_err(
// 	.clk(sys_clk),
// 	.sym_clk_ena(sym_clk_ena),
// 	.decision_variable(decision_variable),
// 	.mapper_out(mapper_out),
// 	.error(error)
// );

// average_accumulated_squared_error acc_sq_err(
// 	.clk(sys_clk),
// 	.clear_accumulator(clear_accumulator),
// 	.sym_clk_ena(sym_clk_ena),
// 	.error(error),
// 	.acc_error(acc_error),
// 	.sqr_error(sqr_error),
// 	.accumulated_squared_error(accumulated_squared_error)
// );

// accumulated_dc_error acc_dc_error(
// 	.clk(sys_clk),
// 	.sym_clk_ena(sym_clk_ena),
// 	.clear_accumulator(clear_accumulator),
// 	.error(error),
// 	.acc(acc_dc),
// 	.accumulated_error(accumulated_error)
// );







endmodule
