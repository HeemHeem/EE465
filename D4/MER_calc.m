function MER = MER_calc(hd, Nsps)
    
    Peak_idx = (length(hd)+1)/2; % center value
    P_avg_sig = abs(hd(Peak_idx))^2;
    P_avg_error =2*(sum(abs(hd(Peak_idx:Nsps:end)).^2) - P_avg_sig);

    MER = 10*log10(P_avg_sig/P_avg_error);

end
