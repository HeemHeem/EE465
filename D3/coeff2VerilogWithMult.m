function coeff2VerilogWithMult(b_n, bits, template_fileName, new_fileName)

    if rem(length(b_n),2) == 1 % check if odd
        half_length = (length(b_n)-1)/2 + 1;
    else
        half_length = length(b_n)/2 + 1;
    end
    
    
    b = b_n(1 : half_length);

    copyfile(template_fileName, new_fileName);

    fid = fopen(new_fileName, 'a+');
    fprintf(fid,"always @ *\n");
    fprintf(fid,"begin\n");
    % put coefficients into a verilog file
    for i = 1:half_length
        idx = i-1;
        if b(i) < 0 % check for negative
            fprintf(fid, "\tb[%d] = -%d'sd %d;\n", idx, bits, abs(b(i)));
        else
            fprintf(fid, "\tb[%d] = %d'sd %d;\n", idx, bits, b(i));
        end

    end
    fprintf(fid, "\tend\n");

    fprintf(fid, "endmodule")

    fclose(fid);

end