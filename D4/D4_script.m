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
for N_rx = 65:Nsps:201
        hsrrc_gs_rx = firrcos(N_rx-1, samp_rate/8, beta, samp_rate, 'rolloff', 'sqrt');
    for N_tx = 113: Nsps:201
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
for N_rx_gs = 65:Nsps:201
    hsrrc_gs_rx_sim = firrcos(N_rx_gs-1, samp_rate/8, beta, samp_rate, 'rolloff', 'sqrt');
    for N_tx_gs = 81:Nsps:201
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
plot(f*samp_rate, 20*log10(abs(H_srrc_prac_sim)), 'r', ...
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
h_tx_initial_shape = zeros(1,84);
h_tx_initial_shape(1:length(hsrrc_tx_gs)) = hsrrc_tx_gs; 
h_tx_reshape = reshape(h_tx_initial_shape, 4, [])';
h_tx_gs_scale_factor = sum(abs(h_tx_reshape))
h_tx_gs_scale_factor = max(sum(abs(h_tx_reshape))); % get max value


h_srrc_tx_gs_scld = hsrrc_tx_gs/h_tx_gs_scale_factor;
H_srrc_tx_gs_scld = freqz(h_srrc_tx_gs_scld, 1, 2*pi*f);
h_srrc_tx_gs_scld_verilog = round(h_srrc_tx_gs_scld*2^18); % coeff fits into 0s18 number




% make room for h_srrc_tx reshaping for pract
h_tx_initial_shape = zeros(1,116);
h_tx_initial_shape(1:length(h_srrc_wind_sim)) = h_srrc_wind_sim; 
h_tx_reshape = reshape(h_tx_initial_shape, 4, [])';
h_tx_pract_scale_factor = sum(abs(h_tx_reshape))
h_tx_pract_scale_factor = max(sum(abs(h_tx_reshape))); % get max value
% h_tx_pract_scale_factor = sum(abs(h_srrc_prac_sim))

h_srrc_tx_pract_scld = h_srrc_wind_sim/h_tx_pract_scale_factor;
H_srrc_tx_pract_scld = freqz(h_srrc_tx_pract_scld, 1, 2*pi*f);
h_srrc_tx_pract_scld_verilog = round(h_srrc_tx_pract_scld*2^18); % coeff fits into 0s18 number


h_tx_initial_shape_test = zeros(1,116);
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
plot(f*samp_rate, 20*log10(abs(H_srrc_tx_pract_scld)), 'r', ...
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



%% Interpolator
L = 2;
FS_new = samp_rate*L;
f_stop_upsam = f_stop/L;
f_trans_width = (1/L - f_stop*(1/L)) - f_stop/L
Atten = abs(20*log10(abs(H_srrc_tx_pract_scld(find(f==f_stop)))))

% M_lpf_ord = round((Atten-8)/(2.285*2*pi*(f_trans_width))) + 3
for M_lpf = 8:Nsps:100
    for beta_kaiser_lpf = 3.95:-0.01:1

% M_lpf_ord = 28;

% beta_lpf = 0.5842*(Atten - 21)^0.4 + 0.07886*(Atten -21);
    n_lpf = 0:M_lpf;

    win_lpf = kaiser(M_lpf+1, beta_kaiser_lpf );
    hd_lpf = 2*1/4*sinc(2*1/(4)*(n_lpf-M_lpf/2));
    
    h_lpf = hd_lpf .* win_lpf.';
    h_tx_prac_upsamp = upsample(h_srrc_tx_pract_scld, L);
    h_up_conv = conv(h_tx_prac_upsamp, h_lpf);
% H_lpf = freqz(h_up_conv, 1, 2*pi*f);
% figure(4)
% stem(n_lpf,h_lpf)
% title("h_{lpf}")

% freqz(h_up_conv, 1, 2*pi*f)
% H_upsam = freqz(h_tx_prac_upsamp, 1, 2*pi*f);
% figure(5)
% plot(f*FS_new, 20*log10(abs(H_lpf)))
% title("H_{lpf} Initial Up Sample by 2")

% UPSAMPLE BY 2 AGAIN
% FS_new2 = FS_new * L;
% f_stop_upsamp2 = f_stop_upsam/L;
% f_trans_width2 = (1/(L) - f_stop_upsamp2*(1\L) - f_stop_upsamp2/L);

% M_lpf_ord2 = round((Atten-8)/(2.285*2*pi*(f_trans_width2))) + 4
% M_lpf_ord2 = 28;

% n_lpf2 = 0:M_lpf_ord2;

    % win_lpf2 = kaiser(M_lpf_ord2+1, beta_lpf );
    % hd_lpf2 = 2*1/4*sinc(2*1/(4)*(n_lpf2-M_lpf_ord2/2));
    
    % h_lpf2 = hd_lpf2 .* win_lpf2.';
    h_tx_prac_upsamp2 = upsample(h_up_conv, L);
    h_up_conv2 = conv(h_tx_prac_upsamp2, h_lpf);
    H_tx_prac_upsamp2 = freqz(h_up_conv2, 1, 2*pi*f);
    % figure(6)
    % stem(n_lpf2,h_lpf2)
    % title("h_{lpf}")
    
    % figure(7)
    % plot(f*FS_new2, 20*log10(abs(H_lpf2)))
    % title("H_{lpf} Second Up Sample by 2")
    % 
    % L = 4;
    % h_tx_upsamp2 = upsample(h_srrc_tx_pract_scld, L);
    % 
    % freqz(h_tx_upsamp2, 1, 2*pi*f)
    
    % filter after carrier shift
    M_down = 2;
    % h_lpf3 = h_lpf2;
    h_rx_down_1 = downsample(conv(h_up_conv2, h_lpf), M_down);
    
    H_rx_down_1 = abs(freqz(h_rx_down_1, 1, 2*pi*f));
    
    % figure(8)
    % plot(f*FS_new, 20*log10(H_rx_down_1))
    
    % downsample by 2 again
    h_rx_down_2 = downsample(conv(h_rx_down_1,h_lpf), M_down);
    
    H_rx_down_2 = abs(freqz(h_rx_down_2, 1, 2*pi*f));
    
    % figure(9)
    % plot(f*samp_rate, 20*log10(H_rx_down_2));
    
    % convolve with matched filter
    h_rx_final = conv(h_rx_down_2, h_rx_scld);
    
    H_rx_final = abs(freqz(h_rx_final, 1, 2*pi*f));
    
    % figure(10)
    % plot(f*samp_rate, 20*log10(H_rx_final));
    
    
    % figure(11)
    % stem(h_rx_final)
    
    
    % % find idx of peak val
    % Peak_idx_final_test = (length(h_rx_final)-1)/2 + 1;
    % P_avg_sig_final_test = abs(h_rx_final(Peak_idx_final_test))^2;
    % P_avg_error_final_test = (sum(abs(h_rx_final(Peak_idx_final_test:Nsps:end)).^2)- P_avg_sig_final_test)*2;
    % 
    % % MER Calc
    % MER_final_test = 10*log10(P_avg_sig_final_test/P_avg_error_final_test);

    MER_final_test = MER_calc(h_rx_final, Nsps);
    if(MER_final_test >= 40)
        break
    end


    end
    if(MER_final_test >= 40)
        break
    end

end


figure(4)
plot(f*samp_rate, 20*log10(H_rx_final));


figure(5)
stem(h_rx_final)

figure(6)
plot(f, 20*log10(abs(freqz(h_lpf, 1, 2*pi*f))))


figure(7)
plot(f, 20*log10(abs(H_tx_prac_upsamp2)))

figure(8)
stem(h_lpf)
% calculate OB's
fs_idx_up = find(f==f_stop/4);
fOB1_start_idx_up = fs_idx_up + 1; % grab the next index
fOB1_stop_idx_up = find(f==fOB1_stop/4); % grab index of ob1 stop freq
fOB2_start_idx_up = fOB1_stop_idx_up + 1; % grab index of the next start
fOB2_stop_idx_up = find(f==fOB2_stop/4); % grab index of the ob2 stop freq



P_sig_chan_up = sum(abs(H_tx_prac_upsamp2(1:fs_idx_up)).^2)*2;
P_OB1_up = sum(abs(H_tx_prac_upsamp2(fOB1_start_idx_up:fOB1_stop_idx_up)).^2);
P_OB2_up = sum(abs(H_tx_prac_upsamp2(fOB2_start_idx_up:fOB2_stop_idx_up)).^2);

P_diff_OB1_up = 10*log10(P_sig_chan_up/P_OB1_up);
P_diff_OB2_up = 10*log10(P_sig_chan_up/P_OB2_up);

% plot just the upsampl and down samp of the lpf
% x_in = [1];
% x_in_up = upsample(x_in,L);
% x_in_up_lpf = conv(h_lpf, x_in_up)
% h_lpf_up = upsample(h_lpf, L);
% h_lpf_up_conv = conv(h_lpf_up, h_lpf);
% h_lpf_up_conv_up = upsample(h_lpf_up_conv,L);
% h_lpf_up_conv_up_down = downsample(h_lpf_up_conv_up,L);
% h_lpf_up_conv_up_down_conv = conv(h_lpf_up_conv_up_down, h_lpf);
% h_lpf_up_conv_up_down_conv_down = downsample(h_lpf_up_conv_up_down_conv, L);
% h_lpf_up_conv_up_down_conv_down_conv = conv(h_lpf_up_conv_up_down_conv_down, h_lpf);
h_lpf_up = upsample(h_lpf, L);
h_lpf_up_conv = conv(h_lpf_up, h_lpf);
h_lpf_up_conv_conv = conv(h_lpf_up_conv, h_lpf);
h_lpf_up_conv_conv_down = downsample(h_lpf_up_conv_conv,L);
h_lpf_up_conv_conv_down_conv = conv(h_lpf_up_conv_conv_down, h_lpf);
h_lpf_up_conv_conv_down_conv_down = downsample(h_lpf_up_conv_conv_down_conv,L);
% h_lpf_up_conv_down = downsample(h_lpf_up_conv, L);
% h_lpf_up_conv_down_conv = conv(h_lpf_up_conv, h_lpf);
% h_lpf_up_conv_down_conv_down = downsample(h_lpf_up_conv_down_conv, L);
% h_lpf_down = downsample(conv(h_lpf_up_conv_down_conv_down, h_lpf),2);


% try just the upsampled lpf and downsample lpf
h_up_lpf = upsample(h_lpf, L);
h_conv = conv(h_up_lpf,h_lpf);
h_conv_conv = conv(h_conv, h_lpf);
h_uplpf_downlpf = downsample(h_conv_conv, L);
h_uplpf_downlpf_conv = conv(h_uplpf_downlpf,h_lpf);
h_uplpf_downlpf_conv_down = downsample(h_uplpf_downlpf_conv,L);

figure(9)
stem(round(h_lpf_up_conv_conv_down_conv_down*2^17))

figure(10)
% stem(round(h_uplpf_downlpf*2^17))
stem(round(h_uplpf_downlpf_conv_down*2^17))


figure(11)
stem(round(h_lpf_up_conv_conv_down*2^17))

