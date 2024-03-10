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




fs_idx = find(f==f_stop);
fOB1_start_idx = fs_idx + 1; % grab the next index
fOB1_stop_idx = find(f==fOB1_stop); % grab index of ob1 stop freq
fOB2_start_idx = fOB1_stop_idx + 1; % grab index of the next start
fOB2_stop_idx = find(f==fOB2_stop); % grab index of the ob2 stop freq




%% Pulse Shaping Filter Gold Standard

%first get the order of the filter
ford = fb(2:end-1);
aord = [1 1/sqrt(2) 0];
%M_test = firpmord(ford, aord, dev)
%M = 128;
M=132;
%M_rx= 200;
M_rx = 280;
Nsymb_rx = M_rx/Nsps
Nsymb = M/Nsps
% plot the filter
hsrrc_gs_rx = rcosdesign(beta, Nsymb, Nsps,"sqrt");
%h_srrc_rx_sf = max(abs(freqz(hsrrc_gs_rx,1,2*pi*f)));
%hsrrc_gs_rx_scld = hsrrc_gs_rx/h_srrc_rx_sf;
%hsrrc_gs_rx = firpm(M_rx, fb, a, wght);
%hsrrc_gs_tx = firpm(M, fb, a, wght);
hsrrc_gs_tx = rcosdesign(beta, Nsymb, Nsps,"sqrt");
%figure(1)
%freqz(hsrrc_gs_tx,1, 2*pi*f)
Hsrrc_gs_tx = freqz(hsrrc_gs_tx, 1, 2*pi*f);
%Hsrrc_gs_rx = freqz(hsrrc_gs_rx(41:end-40), 1, 2*pi*f);
Hsrrc_gs_rx = freqz(hsrrc_gs_rx, 1, 2*pi*f);

%% MER of GS

% convolve filters to get rc
%h_rc_gs = conv(hsrrc_gs_tx, hsrrc_gs_rx(41:end-40));
h_rc_gs = conv(hsrrc_gs_tx, hsrrc_gs_rx);
H_rc_gs_to_verilog = round(h_rc_gs*2^17);
% find idx of peak val
Peak_idx_gs = (length(h_rc_gs)-1)/2 + 1; 
P_avg_sig_gs = abs(h_rc_gs(Peak_idx_gs))^2;
P_avg_error_gs = sum(abs(h_rc_gs(1:Nsps:end)).^2)- P_avg_sig_gs;

% mer calc
MER_gs = 10*log10(P_avg_sig_gs/P_avg_error_gs)


%% MER of Pract PS with GS MF to meet spec
x_N_rx_best = 0;
x_N_tx_best = 0;
x_beta_kaiser_best = 0;
x_beta_pract_best = 0;
x_samp_divider_best =0;

P_diff_OB1 = 0;
P_diff_OB2 = 0;
MER_pract = 0;

N_start = 101; % length start
MER_pract = 30;
% loop through parameters to find best MER and OB1 to match
% for N_rx = 81:Nsps:201 
for N_rx = 81:Nsps:201
        hsrrc_gs_rx = firrcos(N_rx-1, samp_rate/8, beta, samp_rate, 'rolloff', 'sqrt');
    for N_tx = 105: Nsps:201
        for samp_rate_divider = 7:0.1:8
            for beta_pract = 0.08:0.001:0.15
                h_srrc_trunc = firrcos(N_tx-1, samp_rate/samp_rate_divider, beta_pract, samp_rate, 'rolloff', 'sqrt');
                for beta_kaiser = 5:-1:1
                    
                    wn_kaiser = kaiser(N_tx, beta_kaiser);
                    h_srrc_wind = h_srrc_trunc .* wn_kaiser .'; % apply window'
                    
                    % convolve filters together
                    h_rc_pract = conv(h_srrc_wind, hsrrc_gs_rx);
                    H_srrc_practical = freqz(h_srrc_wind, 1, 2*pi*f);
    
                    % find idx of peak val
                    Peak_idx_pract = (length(h_rc_pract)-1)/2 + 1;
                    P_avg_sig_pract = abs(h_rc_pract(Peak_idx_pract))^2;
                    P_avg_error_pract = sum(abs(h_rc_pract(1:Nsps:end)).^2)- P_avg_sig_pract;
                    
                    % MER Calc  
                    MER_pract = 10*log10(P_avg_sig_pract/P_avg_error_pract);
    
                    % Channel Power Calc
                    P_sig_chan = sum(abs(H_srrc_practical(1:fs_idx)).^2)*2;
                    P_OB1 = sum(abs(H_srrc_practical(fOB1_start_idx:fOB1_stop_idx)).^2);
                    P_OB2 = sum(abs(H_srrc_practical(fOB2_start_idx:fOB2_stop_idx)).^2);
    
                    P_diff_OB1 = 10*log10(P_sig_chan/P_OB1);
                    P_diff_OB2 = 10*log10(P_sig_chan/P_OB2);
    
                    x_N_tx_best = N_tx;
                    x_N_rx_best = N_rx;
                    x_beta_kaiser_best = beta_kaiser;
                    x_beta_pract_best = beta_pract;
                    %x_samp_divider_best = samp_rate_divider;
                    if (P_diff_OB1 > 58 && MER_pract > 40)
    
                        break
                    end
                end
                if(P_diff_OB1 > 58)
                    break
                end
            end
        % just to break out of the loop
        if(P_diff_OB1 > 58)
            break
        end
        end
        if(P_diff_OB1 > 58)
            break
        end
    end
    if(MER_pract > 40)
        break
    end
end


%% MER GS
hsrrc_gs_rx_sim = firrcos(x_N_rx_best-1, samp_rate/8, beta, samp_rate, 'rolloff', 'sqrt');
Hsrrc_gs_rx_sim = freqz(hsrrc_gs_rx_sim, 1, 2*pi*f);

x_N_tx_gs_best = 0;
x_samp_divider_best_gs = 0;
x_beta_pract_best_gs = 0;
% for N_rx_gs = 81:Nsps:201
for N_rx_gs = 81:Nsps:201
    hsrrc_gs_rx_sim = firrcos(N_rx_gs-1, samp_rate/8, beta, samp_rate, 'rolloff', 'sqrt');
    for N_tx_gs = 65:Nsps:201
    %for samp_tx_divider = 7:0.1:8
        %for beta_tx = 0.11:0.01:0.15
            hsrrc_tx_gs =firrcos(N_tx_gs-1, samp_rate/8, beta, samp_rate, 'rolloff', 'sqrt');
            Hsrrc_tx_gs = freqz(hsrrc_tx_gs, 1, 2*pi*f);
            
            h_rc_gs = conv(hsrrc_tx_gs, hsrrc_gs_rx_sim);
    
            % find idx of peak val
            Peak_idx_gs = (length(h_rc_gs)-1)/2 + 1; 
            P_avg_sig_gs = abs(h_rc_gs(Peak_idx_gs))^2;
            P_avg_error_gs = sum(abs(h_rc_gs(1:Nsps:end)).^2)- P_avg_sig_gs;
            
            % mer calc
            MER_gs = 10*log10(P_avg_sig_gs/P_avg_error_gs);

            if(MER_gs > 50)
                x_N_tx_gs_best = N_tx_gs;
                %x_samp_divider_best_gs = samp_tx_divider;
                %x_beta_pract_best_gs = beta_tx;
                break
            end

        %end
        % if(MER_gs >50)
        %     break
        % end

    end
    if(MER_gs >50)
        break
    end

end



%% Plots
h_srrc_prac_sim = firrcos(x_N_tx_best-1, samp_rate/8, x_beta_pract_best, samp_rate, 'rolloff', 'sqrt');
wn_kaiser_sim = kaiser(x_N_tx_best, x_beta_kaiser_best);
h_srrc_wind_sim = h_srrc_prac_sim .* wn_kaiser_sim .';
H_srrc_prac_sim = freqz(h_srrc_wind_sim, 1, 2*pi*f);


figure(1)
plot(f*samp_rate, 20*log10(abs(H_srrc_prac_sim)), 'r',...
    f*samp_rate, 20*log10(abs(Hsrrc_gs_rx_sim)), 'b',...
    f*samp_rate, 20*log10(abs(Hsrrc_tx_gs)), 'g')
xline(875000);
xline(1095000);
xline(2625000);
xline(781250);
ylabel("20log10(H)");
xlabel("frequency in Hz");
legend('Tx_{pract}', 'Rx', 'Tx')
hold off


% convolve filters together
h_rc_pract_test = conv(h_srrc_wind_sim, hsrrc_gs_rx_sim);
% find idx of peak val
Peak_idx_pract_test = (length(h_rc_pract_test)-1)/2 + 1;
P_avg_sig_pract_test = abs(h_rc_pract(Peak_idx_pract_test))^2;
P_avg_error_pract_test = sum(abs(h_rc_pract_test(1:Nsps:end)).^2)- P_avg_sig_pract_test;

% MER Calc
MER_pract_test = 10*log10(P_avg_sig_pract_test/P_avg_error_pract_test);




% make room for h_srrc_tx reshaping for gs
h_tx_initial_shape = zeros(1,68);
h_tx_initial_shape(1:length(hsrrc_tx_gs)) = hsrrc_tx_gs; 
h_tx_reshape = reshape(h_tx_initial_shape, 4, [])';
h_tx_gs_scale_factor = sum(abs(h_tx_reshape))
h_tx_gs_scale_factor = max(sum(abs(h_tx_reshape))); % get max value


h_srrc_tx_gs_scld = hsrrc_tx_gs/h_tx_gs_scale_factor;
H_srrc_tx_gs_scld = freqz(h_srrc_tx_gs_scld, 1, 2*pi*f);
h_srrc_tx_gs_scld_verilog = round(h_srrc_tx_gs_scld*2^18); % coeff fits into 0s18 number




% make room for h_srrc_tx reshaping for pract
h_tx_initial_shape = zeros(1,108);
h_tx_initial_shape(1:length(h_srrc_wind_sim)) = h_srrc_wind_sim; 
h_tx_reshape = reshape(h_tx_initial_shape, 4, [])';
h_tx_pract_scale_factor = sum(abs(h_tx_reshape))
h_tx_pract_scale_factor = max(sum(abs(h_tx_reshape))); % get max value
% h_tx_pract_scale_factor = sum(abs(h_srrc_prac_sim))

h_srrc_tx_pract_scld = h_srrc_wind_sim/h_tx_pract_scale_factor;
h_srrc_tx_pract_scld_verilog = round(h_srrc_tx_pract_scld*2^18); % coeff fits into 0s18 number


h_tx_initial_shape_test = zeros(1,108);
h_tx_initial_shape_test(1:length(h_srrc_prac_sim)) = h_srrc_tx_pract_scld; 
h_tx_reshape_test = reshape(h_tx_initial_shape_test, 4, [])';
h_tx_pract_scale_factor_test = sum(abs(h_tx_reshape_test))
h_tx_pract_scale_factor_test = max(sum(abs(h_tx_reshape_test))); % get max value


h_srrc_tx_pract_scld_test = h_srrc_tx_pract_scld/h_tx_pract_scale_factor_test;
h_srrc_tx_pract_scld_verilog_test = round(h_srrc_tx_pract_scld_test*2^18); % coeff fits into 0s18 number


% scaling of rx
h_rx_scld = hsrrc_gs_rx_sim/sum(abs(hsrrc_gs_rx_sim));
h_rx_scld_verilog = round(h_rx_scld * 2^18); % coeff fits into 0s18



figure(2)
plot(f*samp_rate, 20*log10(abs(H_srrc_tx_gs_scld)), 'r',...
    f*samp_rate, 20*log10(abs(Hsrrc_gs_rx_sim)), 'b',...
    f*samp_rate, 20*log10(abs(Hsrrc_tx_gs)), 'g')
xline(875000);
xline(1095000);
xline(2625000);
xline(781250);
ylabel("20log10(H)");
xlabel("frequency in Hz");
legend('Tx_{pract}', 'Rx', 'Tx')
hold off


h_prc_rx_cov = conv(h_srrc_tx_pract_scld, h_rx_scld);
figure(3)
% plot(length(h_prc_rx_cov), h_prc_rx_cov)
stem(h_prc_rx_cov)



Peak_idx_gs = (length(h_prc_rx_cov)-1)/2 + 1; 
P_avg_sig_gs = abs(h_prc_rx_cov(Peak_idx_gs))^2;
P_avg_error_gs = sum(abs(h_prc_rx_cov(1:Nsps:end)).^2)- P_avg_sig_gs;

% mer calc
MER_cov = 10*log10(P_avg_sig_gs/P_avg_error_gs);




