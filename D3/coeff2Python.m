function coeff2Python(b_n, fileName) %fractional_bits)

    if rem(length(b_n),2) == 1 % check if odd
        half_length = (length(b_n)-1)/2 + 1;
    else
        half_length = length(b_n)/2 + 1;
    end
    
    
    b = b_n(1 : half_length); %*2^fractional_bits;
    %fileName = fopen("VC.txt", 'wt');
    fid = fopen(fileName, "wt");
    % put coefficients into a verilog file
    for i = 1:half_length
        fprintf(fid, "%d\n", b(i));

    end

    fclose(fid);

end