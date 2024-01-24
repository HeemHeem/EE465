function coeff2Verilog(b_n, bits)

    if rem(length(b_n),2) == 1 % check if odd
        half_length = (length(b_n)-1)/2 + 1;
    else
        half_length = length(b_n)/2 + 1;
    end
    
    
    b = b_n(1 : half_length);

    fileName = fopen("VC.txt", 'wt');
    fprintf(fileName,"always @ *\n");
    fprintf(fileName,"begin\n");
    % put coefficients into a verilog file
    for i = 1:half_length
        idx = i-1;
        if b(i) < 0
            fprintf(fileName, "\tb[%d] = -%d'sd %d;\n", idx, bits, b(i));
        else
            fprintf(fileName, "\tb[%d] = %d'sd %d;\n", idx, bits, b(i));
        end

    end
    fprintf(fileName, "end");

    fclose(fileName);

end