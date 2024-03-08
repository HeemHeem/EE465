function create_time_sharing_polyphase_verilog_file(h, coeff_bits, counter_bits, template_fileName, new_fileName)

    copyfile(template_fileName, new_fileName);

    fid = fopen(new_fileName, 'a+');
    mux_inputs = 4;
    % lut_groups = (length(h)-1)/16;
    lut_groups = (length(h)-1)/mux_inputs;

    % mulitplication
    for lut = 0:lut_groups-1
        fprintf(fid, "always @ (posedge clk or posedge reset)\n");
        fprintf(fid, "\tif(reset)\n");
        fprintf(fid, "\t\tm[%d] = 36'sd0;\n", lut);
        fprintf(fid, "\telse\n");
        fprintf(fid, "\t\tm[%d] = xm%d * hm%d;\n\n", lut, lut, lut);
    end

    % for single coefficient
    fprintf(fid, "wire signed [17:0] h%d;\n\n", length(h)-1);
    if(h(end) < 0)
        fprintf(fid, "assign h%d = -18'sd %d;\n\n", length(h)-1, abs(h(end)));
    else
        fprintf(fid, "assign h%d = 18'sd %d;\n\n", length(h)-1, abs(h(end)));
    end

    fprintf(fid, 'always @ *\n');
    fprintf(fid, '\tm_out_%d = x[%d] * h%d;\n\n', lut_groups+1, length(h)-1, length(h)-1);
    % case statement groups
    for lut = 0:lut_groups-1
        fprintf(fid, "always @ *\n");
        fprintf(fid, "begin\n");
        fprintf(fid, "\tcase(counter)\n");
        cnt = 0;
        % generate case statement values
        for lut_val = (lut)*mux_inputs:(lut+1)*mux_inputs-1
            if(h(lut_val+1) < 0)
                fprintf(fid, "\t\t%d'd%d : hm%d = -%d'sd %d;\n", counter_bits,cnt,lut, coeff_bits, abs(h(lut_val+1)));
            else
                fprintf(fid, "\t\t%d'd%d : hm%d = %d'sd %d;\n", counter_bits, cnt,lut, coeff_bits, abs(h(lut_val+1)));
            end
            cnt = cnt + 1;
        end
        cnt = 0;
        if(h((lut)*mux_inputs+1) < 0)
            fprintf(fid, "\t\tdefault: hm%d = -%d'sd %d;\n", lut, coeff_bits, abs(h((lut))*mux_inputs+1));
        else
            fprintf(fid, "\t\tdefault: hm%d = %d'sd %d;\n", lut, coeff_bits, abs(h((lut)*mux_inputs+1)));
        end
        fprintf(fid, "\tendcase\n");
        fprintf(fid, "end\n");
    end

    % case of x inputs
    for lut = 0:lut_groups-1
        fprintf(fid, "always @ *\n");
        fprintf(fid, "begin\n");
        fprintf(fid, "\tcase(counter)\n");
        cnt = 0;
        % generate case statement values
        for lut_val = (lut)*mux_inputs:(lut+1)*mux_inputs-1
            fprintf(fid, "\t\t%d'd%d : xm%d = x[%d];\n",counter_bits, cnt, lut,lut_val);
            cnt = cnt + 1;
        end
        cnt = 0;
        fprintf(fid, "\t\tdefault: xm%d = x[%d];\n",lut,lut*mux_inputs);
        fprintf(fid, "\tendcase\n");
        fprintf(fid, "end\n");
    end




    fprintf(fid, "endmodule");
    fclose(fid);
end