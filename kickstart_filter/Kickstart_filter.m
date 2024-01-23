%% 1.1 Part A: Sinusoidal Input
format longG
Nsps = 4;
Nsymb = 5; % Length of filter is 21 = Nsymb*Nsps + 1 where M = Nsymb*Nsps
M = 20;
beta = 0.25;
h = rcosdesign(beta,Nsymb, Nsps);
figure(1)
freqz(h)
%h_fr = abs(freqz(h));
h_freq_max = max(abs(freqz(h))); % linear value of frequency response

figure(2)
h_scaled = h/h_freq_max;
h_scaled_max = max(abs(freqz(h_scaled)))
freqz(h_scaled)
h_scaled_verilog = round(h_scaled * 2^18);

%% 1.2 Part B Managing Headroom Worst Case Input
worst_case_input = [1 1 1 -1 -1 -1 -1 1 1 1 1 1 1 1 -1 -1 -1 -1 1 1 1];
worst_case_output_vector = conv(worst_case_input, h);
worst_case_max_val = max(worst_case_output_vector);
h_scaled_worst_case = (h/worst_case_max_val)*(1-2^(-17)); %*2^17);
h_scaled_worst_case_verilog = round(h_scaled_worst_case*(2^18)); % fits in 0s18

worst_case_scaled_val = vpa(conv(worst_case_input, h_scaled_worst_case));
worst_case_scaled_max_val = max(worst_case_scaled_val); % check

%figure(3)







