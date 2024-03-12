%% Parameters
clear all
Nsps = 4; % num samp per symb
beta = 0.12; % rolloff
FOB1_BW = 220000; % 220 kHz bandwidth
FOB2_BW = 1530000;% 1.53 MHz
stop_atten = 70; % stop band attenuation
OB1 = 58; % OB1 attenuation
OB2 = 60; % OB2 attenuation
BW_baseband = 875000; % 0.875 MHz or 875 KHz
samp_rate = 6.25 * 10^6; % sampling rate of 6.25 Msamples/second
f_cutoff = 1/2/Nsps; % cutoff frequency - 6dB downpoint for rc and 3dB for srrc
f_pass = (1-beta)*f_cutoff; % passband freq
f_stop = (1+beta)*f_cutoff; % stopband freq
fOB1_stop = f_stop + FOB1_BW/samp_rate;
fOB2_stop = fOB1_stop + FOB2_BW/samp_rate; 
fb = [0 f_pass f_cutoff f_cutoff f_stop 0.5]*2; % frequency bands - multiply by 2 to get cyc/samp - weird matlab
a = [1 1 1/sqrt(2) 1/sqrt(2) 0 0];
sb = 10^(-stop_atten/20); % stop band freq
dev = [sb 0.02 sb]; % only used as an initial
wght = [2.4535 1 1];
%df = 1/20000; % frequency increment in cycles/samp
df = 0.00001;
f = [0:df:0.5-df/2]; % cycles/sample; 0 to almost 1/2

%% Pulse Shaping Filter Gold Standard

%first get the order of the filter
ford = fb(2:end-1);
aord = [1 1/sqrt(2) 0];
M_test = firpmord(ford, aord, dev)
%M = 128;
M=128;
%M_rx= 200;
M_rx = 280;
Nsymb_rx = M_rx/Nsps
Nsymb = M/Nsps
% plot the filter
%hsrrc_gs_rx = rcosdesign(beta, Nsymb_rx, Nsps,"sqrt");
%h_srrc_rx_sf = max(abs(freqz(hsrrc_gs_rx,1,2*pi*f)));
%hsrrc_gs_rx_scld = hsrrc_gs_rx/h_srrc_rx_sf;
hsrrc_gs_rx = firpm(M_rx, fb, a, wght);
hsrrc_gs_tx = firpm(M, fb, a, wght);
%hsrrc_gs_tx = rcosdesign(beta, Nsymb, Nsps,"sqrt");
Hsrrc_gs_tx = freqz(hsrrc_gs_tx, 1, 2*pi*f);
Hsrrc_gs_rx = freqz(hsrrc_gs_rx(41:end-40), 1, 2*pi*f);



%% MER of GS

% convolve filters to get rc
h_rc_gs = conv(hsrrc_gs_tx, hsrrc_gs_rx(41:end-40));
H_rc_gs_to_verilog = round(h_rc_gs*2^17);
% find idx of peak val
Peak_idx_gs = (length(h_rc_gs)-1)/2 + 1; 
P_avg_sig_gs = abs(h_rc_gs(Peak_idx_gs))^2;
P_avg_error_gs = sum(abs(h_rc_gs(1:Nsps:end)).^2)- P_avg_sig_gs;

% mer calc
MER_gs = 10*log10(P_avg_sig_gs/P_avg_error_gs)

%% MER of Practical to GS
h_srrc_trunc = hsrrc_gs_tx(5:end-4);
h_srrc_rx_trunc = hsrrc_gs_rx(41:end-40); % originally 77 and 76
N_pract = numel(h_srrc_trunc);
M_pract = N_pract -1;
Nsymb_pract = M_pract/Nsps;
h_srrc_pract = rcosdesign(beta, Nsymb_pract, Nsps, "sqrt" );
%h_srrc_trunc = firrcos(N_pract-1, samp_rate/8, beta, samp_rate, 'rolloff', 'sqrt');

% kaiser window
if(stop_atten > 50)
    beta_kaiser = 0.1102*(stop_atten-8.7);
else
    beta_kaiser = 0.5842*(stop_atten-21)^0.4 + 0.07886*(stop_atten-21);
end

wn_kaiser = kaiser(N_pract,1);

%h_srrc_wind = h_srrc_pract .* wn_kaiser.'; %'

H_srrc_practical = freqz(h_srrc_trunc, 1, 2*pi*f);
%H_srrc_practical = freqz(h_srrc_trunc,1,2*pi*f);

% convolve filters to get rc
%h_rc_pract = conv(h_srrc_wind, hsrrc_gs_rx);
h_rc_pract = conv(h_srrc_trunc, h_srrc_rx_trunc);

% find idx of peak val
Peak_idx_pract = (length(h_rc_pract)-1)/2 + 1;
P_avg_sig_pract = abs(h_rc_pract(Peak_idx_pract))^2;
P_avg_error_pract = sum(abs(h_rc_pract(1:Nsps:end)).^2)- P_avg_sig_pract;

MER_pract = 10*log10(P_avg_sig_pract/P_avg_error_pract)



figure(1)
hold on
plot(f*samp_rate, 20*log10(abs(Hsrrc_gs_tx)),"r",...
    f*samp_rate, 20*log10(abs(Hsrrc_gs_rx)),"b",...
    f*samp_rate, 20*log10(abs(H_srrc_practical)),"k");
xline(875000);
xline(1095000);
xline(2625000);
ylabel("20log10(H)");
xlabel("frequency in Hz");
legend('Tx', 'Rx', 'Tx_{pract}')
hold off


% figure(2)
% hold on
% plot(f*samp_rate, 20*log10(abs(H_srrc_practical)),"r")
% xline(875000);
% xline(1095000);
% xline(2625000);
% ylabel("20log10(H)");
% xlabel("frequency in Hz");
% hold off

fs_idx = find(f==f_stop);
fOB1_start_idx = fs_idx + 1; % grab the next index
fOB1_stop_idx = find(f==fOB1_stop); % grab index of ob1 stop freq
fOB2_start_idx = fOB1_stop_idx + 1; % grab index of the next start
fOB2_stop_idx = find(f==fOB2_stop); % grab index of the ob2 stop freq

P_sig_chan = sum(abs(H_srrc_practical(1:fs_idx)).^2);
P_OB1 = sum(abs(H_srrc_practical(fOB1_start_idx:fOB1_stop_idx)).^2);
P_OB2 = sum(abs(H_srrc_practical(fOB2_start_idx:fOB2_stop_idx)).^2);

P_diff_OB1 = 10*log10(P_sig_chan/P_OB1)
P_diff_OB2 = 10*log10(P_sig_chan/P_OB2)