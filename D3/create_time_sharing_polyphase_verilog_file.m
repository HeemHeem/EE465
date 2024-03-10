function create_time_sharing_polyphase_verilog_file(h, coeff_bits, counter_bits, template_fileName, new_fileName)

    copyfile(template_fileName, new_fileName);

    fid = fopen(new_fileName, 'a+');
    mux_inputs = 16;
    % lut_groups = (length(h)-1)/16;
    lut_groups = (length(h)-1)/mux_inputs;

    

    % for single coefficient
    fprintf(fid, "/********************** single coeff ***************/\n\n");
    fprintf(fid, "wire signed [17:0] h%d;\n\n", length(h)-1);
    if(h(end) < 0)
        fprintf(fid, "assign h%d = -18'sd %d;\n\n", length(h)-1, abs(h(end)));
    else
        fprintf(fid, "assign h%d = 18'sd %d;\n\n", length(h)-1, abs(h(end)));
    end

    fprintf(fid, 'always @ *\n');
    fprintf(fid, '\tmout%d = x[%d] * h%d;\n\n', lut_groups+1, length(h)-1, length(h)-1);

    % mulitplication  and accumulators and acc reg
    for lut = 0:lut_groups-1

        fprintf(fid, "/************************* m[%d]******************/\n\n", lut);
        fprintf(fid, "always @ *\n");
        fprintf(fid, "\tif(reset)\n");
        fprintf(fid, "\t\tm[%d] = 36'sd0;\n", lut);
        fprintf(fid, "\telse\n");
        fprintf(fid, "\t\tm[%d] = xm[%d] * h[%d];\n\n", lut, lut, lut);

        
        % acc
        fprintf(fid, "always @ (posedge clk or posedge reset)\n");
        % fprintf(fid, "always @ *\n");
        fprintf(fid, "\tif(reset)\n");
        % fprintf(fid, "\t\tm_acc[%d] <= m[%d];\n", lut, lut);
        fprintf(fid, "\t\tm_acc[%d] <= 36'sd0;\n", lut);
        fprintf(fid, "\telse if (counter == 2'd0)\n");
        % fprintf(fid, "\telse if (sam_clk_en)\n");
        fprintf(fid, "\t\tm_acc[%d] <= m[%d];\n", lut, lut);
        fprintf(fid, "\telse\n");
        fprintf(fid, "\t\tm_acc[%d] <= m_acc[%d] + m[%d];\n\n", lut, lut, lut);

        fprintf(fid, "reg signed [35:0] m%d_acc_delay[2:0];\n\n", lut);

        %acc delay
        fprintf(fid, "always @ (posedge clk)\n");
        fprintf(fid, "\t\tbegin\n");
        fprintf(fid, "\t\tm%d_acc_delay[0] <= m_acc[%d];\n", lut, lut);
        fprintf(fid, "\t\tm%d_acc_delay[1] <= m%d_acc_delay[0];\n", lut, lut);
        fprintf(fid, "\t\tm%d_acc_delay[2] <= m%d_acc_delay[1];\n", lut, lut);
        fprintf(fid, "\t\tend\n\n");
        
        %acc reg
        fprintf(fid, "always @ (posedge clk or posedge reset)\n");
        fprintf(fid, "\tif(reset)\n");
        % fprintf(fid, "\t\tm_acc_reg[%d] <= m_acc[%d];\n", lut, lut);
        % fprintf(fid, "\t\tm_acc_reg[%d] <= m%d_acc_delay[2];\n", lut, lut);
        fprintf(fid, "\t\tm_acc_reg[%d] <= 36'sd0;\n", lut);
        fprintf(fid, "\telse if (sam_clk_en)\n");
        % fprintf(fid, "\t\tm_acc_reg[%d] <= m_acc[%d];\n", lut, lut);
        fprintf(fid, "\t\tm_acc_reg[%d] <= m%d_acc_delay[2];\n", lut, lut);
        fprintf(fid, "\telse\n");
        fprintf(fid, "\t\tm_acc_reg[%d] <= m_acc_reg[%d];\n\n", lut, lut);


    end

    fprintf(fid, "/************************** LUTS ********************/\n\n");
    % case statement groups
    for lut = 0:lut_groups-1
        fprintf(fid, "always @ *\n");
        % fprintf(fid, "always @ (posedge clk)\n");
        fprintf(fid, "begin\n");
        fprintf(fid, "\tcase(counter)\n");
        cnt = 0;
        % generate case statement values
        for lut_val = (lut)*mux_inputs:(lut+1)*mux_inputs-1
            if(h(lut_val+1) < 0)
                fprintf(fid, "\t\t%d'd%d : h[%d] = -%d'sd %d;\n", counter_bits,cnt,lut, coeff_bits, abs(h(lut_val+1)));
            else
                fprintf(fid, "\t\t%d'd%d : h[%d] = %d'sd %d;\n", counter_bits, cnt,lut, coeff_bits, abs(h(lut_val+1)));
            end
            cnt = cnt + 1;
        end
        cnt = 0;
        if(h((lut)*mux_inputs+1) < 0)
            fprintf(fid, "\t\tdefault: h[%d] = -%d'sd %d;\n", lut, coeff_bits, abs(h(lut*mux_inputs+1)));
        else
            fprintf(fid, "\t\tdefault: h[%d] = %d'sd %d;\n", lut, coeff_bits, abs(h((lut*mux_inputs+1))));
        end
        fprintf(fid, "\tendcase\n");
        fprintf(fid, "end\n");
    end

    % case of x inputs
    for lut = 0:lut_groups-1
        fprintf(fid, "always @ *\n");
        % fprintf(fid, "always @ (posedge clk)\n");
        fprintf(fid, "begin\n");
        fprintf(fid, "\tcase(counter)\n");
        cnt = 0;
        % generate case statement values
        for lut_val = (lut)*mux_inputs:(lut+1)*mux_inputs-1
            fprintf(fid, "\t\t%d'd%d : xm[%d] = x[%d];\n",counter_bits, cnt, lut,lut_val);
            cnt = cnt + 1;
        end
        cnt = 0;
        fprintf(fid, "\t\tdefault: xm[%d] = x[%d];\n",lut,lut*mux_inputs);
        fprintf(fid, "\tendcase\n");
        fprintf(fid, "end\n");
    end




    fprintf(fid, "endmodule");
    fclose(fid);
end