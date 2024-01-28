function coeff2txt(b_n, name)

    if rem(length(b_n),2) == 1 % check if odd
        half_length = (length(b_n)-1)/2 + 1;
    else
        half_length = length(b_n)/2 + 1;
    end
    
    
    b = b_n(1 : half_length);

    fileName = fopen(name, 'wt');

    % Print to file
    for i = 1:half_length
        if i == half_length
            fprintf(fileName, "%d", b(i));
        else
      
            fprintf(fileName, "%d\n", b(i));
    
        end
    end

    fclose(fileName);

end
