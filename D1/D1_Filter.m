%% Parameters
clear all

%%%%%%%%%%%%%%%%%%%%%% SRRC %%%%%%%%%%%%%%%%%%%%
A = 40; % 40 dB attenuation

Nsps = 4; % 4 samples per symbol

M_srrc = 20; % order of 20, Length of 21

N_srrc = 21; % length of 21

Nsymb_srrc = 5; % number of symbols

beta_tx = 0.25; % tx shaping factor

beta_rx = 0.25; % rx shaping factor

%%%%%%%%%%%%%%%%%%%% RC %%%%%%%%%%%%%%%%%%%%%%%%%

M_rc = 40; % order of 40, Length of 41 

Nsymb_rc = 10; % number of symbols

N_rc = 41; % length of RC

%%%%%%%%%%%%%%%%% Sampling Vectors %%%%%%%%%%%%%%%%%
Fs = 25*10^6; % 25MHz sampling

f_c = 1/2/Nsps; % 6dB downpoint for rc and 3db for srrc

df = 1/2000; % frequency increment in cycles/samp

f = [0:df:0.5-df/2]; % cycles/sample; 0 to almost 1/2

%% IDEAL
% magnitude response for RC and SCCR filters

Hrc_f = zeros(1,length(f)); % reserve space for magnitude response of rc filter

Hsrrc_f = zeros(1,length(f)); % reserve space for magnitude response of srrc filter

f1 = find(f < f_c*(1-beta_tx)); % indices where H_f = 1

f2 = find( (f_c*(1-beta_tx)<= f) & ( f <= f_c*(1+beta_tx))); % indices where
% H_f is in transition

f3 = find(f > f_c*(1+beta_tx)); % indices where H_f = 0

%%%%% Hrc_f filter equations
Hrc_f(f1) = ones(1,length(f1));
Hrc_f(f2) = 0.5+0.5*cos(pi*(f2-f2(1))/(length(f2)-1));
Hrc_f(f3) = 0;
%%%%
Hsrrc_f = sqrt(Hrc_f);

% plots
figure(1);
plot(f,(Hrc_f),'r', ...
f,(Hsrrc_f),'--b','LineWidth',2);
xlabel('frequency in cycles/sample')
ylabel('|H_{rc}(e^{2\pif})| and |H_{srrc}(e^{2\pif})|')
legend("RC", "SRRC")
grid



%%%%%%%%%%%%%%% IMPULSE RESPONSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% find and plot the impulse response
% impulse response of rc filter
h_rc = rcosdesign(beta_tx, Nsymb_rc, Nsps, "normal");

% impulse response of srrc filter
h_srrc = rcosdesign(beta_tx, Nsymb_srrc, Nsps, "sqrt");

% PLOTS
figure(2)
plot(0:N_rc-1,h_rc,'r*', 0:N_srrc-1,h_srrc,'bd', 'MarkerSize',8);
ylabel('h_{rc}[n] and h_{srrc}[n]');
xlabel('n');
legend('RC', 'SRRC')
grid;
% Find and plot the frequency repsonses of the
% finite length RC and SRRC filters
H_hat_rc = freqz(h_rc,1,2*pi*f);
H_hat_srrc = freqz(h_srrc,1,2*pi*f);

figure(3)
plot(f,20*log10(abs(H_hat_rc)),'r', ...
f,20*log10(abs(H_hat_srrc)),'--b','LineWidth',2);
ylabel('H_{hat}(\Omega) for RC and SRRC');
xlabel('frequency in cycles/sample')
legend('RC', 'SRRC')
grid;


%% Tx

%%% kaiser window
if(A > 50)
    beta_kaiser = 0.1102*(A-8.7);
else
    beta_kaiser = 0.5842*(A-21)^0.4 + 0.07886*(A-21);
end

wn_kaiser = kaiser(M_srrc+1,beta_kaiser);

h_srrc = rcosdesign(beta_tx, Nsymb_srrc, Nsps, "sqrt");

h_srrc_tx = h_srrc .* wn_kaiser.';


% calculate the scaling factor knowing that the input is going to be
% upsampled, so turn the coefficients into an nx4 (row x column) matrix
% then sum each column and use max value to scale.


% make room for h_srrc_tx reshaping
h_tx_initial_shape = zeros(1,24)
h_tx_initial_shape(1:length(h_srrc_tx)) = h_srrc_tx 
h_tx_reshape = reshape(h_tx_initial_shape, 4, [])' 
% h_tx_scale_factor = max(sum(abs(h_tx_reshape))); % get max value
h_tx_scale_factor = sum(abs(h_srrc_tx));

h_srrc_tx_scld = h_srrc_tx/h_tx_scale_factor
h_srrc_tx_scld_verilog = round(h_srrc_tx_scld*2^17); % coeff fits into 1s17 number

% h_srrc_tx_upsampled = upsample(h_srrc_tx_scld,4);
% figure(10)
% freqz(h_srrc_tx_upsampled,1, 2*pi*f)

% freq response
H_srrc_tx = freqz(h_srrc_tx_scld, 1, 2*pi*f); % need to ask about freqz as it may not be helpful
H_srrc_tx_not_scaled = freqz(h_srrc_tx, 1, 2*pi*f);

%% Rx

% rx is just h_srrc
h_srrc_rx = rcosdesign(beta_rx, Nsymb_srrc, Nsps, "sqrt");
h_srrc_rx_scld = h_srrc_rx/sum(abs(h_srrc_rx));
h_srrc_rx_scld_verilog = round(h_srrc_rx_scld * 2^18); %0s18 number
H_srrc_rx = freqz(h_srrc_rx_scld, 1, 2*pi*f);

figure(4)
plot(f,20*log10(abs(H_srrc_tx)),'r', ...
f,20*log10(abs(H_srrc_rx)),'--b','LineWidth',2);
ylabel('H_{hat}(\Omega) for SRRC TX and RX');
xlabel('frequency in cycles/sample')
legend('TX', 'RX')
grid;

%% MER

% convolve filters to get rc
h_rc_practical = conv(h_srrc_tx_scld, h_srrc_rx_scld);
H_rc_practical_to_verilog = h_rc_practical*2^17;
% find idx of peak val
Peak_idx = (length(h_rc_practical)-1)/2 + 1; 
P_avg_sig = abs(h_rc_practical(Peak_idx))^2;
P_avg_error = sum(abs(h_rc_practical(1:Nsps:end)).^2) - P_avg_sig;


% mer calc
MER = 10*log10(P_avg_sig/P_avg_error)

figure(5)
plot(0:N_rc-1,h_rc_practical,'r*', 'MarkerSize',8);
ylabel('h_{rc-real}[n]');
xlabel('n');
legend('Practical')
grid;















