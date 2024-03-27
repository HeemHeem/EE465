# EE 465 Modelsim compilation script
# Instructions: 1.  Set the variables below to values appropriate for your design.
#                   The rest of the script should work correctly without any modifications.
#               2.  In Modelsim, navigate to the location of this script.
#                   (File menu -> Change Directory) or use 'cd' commands.
#               3.  Run 'do compile.do' on the Modelsim console.
#               4.  Add signals to waveform viewer as desired.
#               5.  Save waveform set up file as 'wave.do' using 'Save format...' from the file menu.
#                   Place it in the same directory as the compile.do file (this file).
#               6.  After adding signals, you may need to rerun 'do compile.do' to get the values to show up.
#               7.  Use the waveform window to debug your design as desired.

# Variables to configure
set SIMULATION_LENGTH 4ms
set SOURCE_DIR "./"
set TB_DIR "./"
set TB_MODULE "tbench"

# End of variables to configure

onerror {resume}
transcript on

# set up compilation library
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

# compile source files
vlog -sv -work work ${SOURCE_DIR}/clocks.v
#vlog -sv -work work ${SOURCE_DIR}/LFSR.v
vlog -sv -work work ${SOURCE_DIR}/tbench.sv
#vlog -sv -work work ${SOURCE_DIR}/test_timesharing2.v
#vlog -sv -work work ${SOURCE_DIR}/tx_pract_with_Luts.v
#vlog -sv -work work ${SOURCE_DIR}/test_timesharing3.v
#vlog -sv -work work ${SOURCE_DIR}/test_timesharing5.v
#vlog -sv -work work ${SOURCE_DIR}/tx_pract_filt2.v
#vlog -sv -work work ${SOURCE_DIR}/test_timesharing6.v
#vlog -sv -work work ${SOURCE_DIR}/halfband_filter2.v
#vlog -sv -work work ${SOURCE_DIR}/halfband_filter2_tryna_fix.v
vlog -sv -work work ${SOURCE_DIR}/halfband_decim_polyphase_and_timesharing.v
vlog -sv -work work ${SOURCE_DIR}/halfband_interp_polyphase_and_timesharing.v

#vlog -sv -work work ${SOURCE_DIR}/test_polyphase_timesharing.v
#vlog -sv -work work ${SOURCE_DIR}/upsampler.v
#vlog -sv -work work ${SOURCE_DIR}/downsampler.v







# compile tb file
vlog -sv -work work ${TB_DIR}/${TB_MODULE}.sv

# initialize simulation
# add other libraries if necessary with -L lib_name
# if simulating megafunctions, add libraries specified by Quartus
vsim -voptargs="+acc" -t 1ns -L work ${TB_MODULE}

# open waveform viewer and populate with saved list of signals
do wave.do
#do polyphase_timeshare.do
# run simulation for specified amount of time
run ${SIMULATION_LENGTH}
