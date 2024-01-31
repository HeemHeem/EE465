
# import numpy as np
# parameters
# symbols = [0, 1 , 0.6666666666666666, -0.6666666666666666, -1]
# symbols = [0, 3, 1, -1, -3]
# symbols = [0, 2, 1, -1, -2]
# symbols = [0, 1, 1/3, -1/3, -1]
symbols = [0,3/4, 1/4, -1/4, -3/4]
# print(symbols)

def LUT_inputs (symb_list:list)-> list:
    """Generate a combination of possible inputs to the LUT based on symbols.

    Args:
        symb (list): list of numbers

    Returns:
        list: list of possible inputs to LUT for a 2 input adder
    """
    # set output list as initial list and then append
    lut_in = symb_list.copy()
    
    for symbol in symb_list:
        for sym in symb_list:
            sum2inputs = symbol + sym
            # print(f"{symbol} + {sym} = {sum2inputs}")
            if sum2inputs not in lut_in:
                lut_in.append(sum2inputs)
    return lut_in




def convert_to_verilog(in_val: list, fract_bits: int) -> list:
    """Convert to verilog format based on number of fractional bits

    Args:
        in_val (list): list of decimal numbers
        fract_bits (_type_): number of fractional bits

    Returns:
        list: list of numbers in verilog format
    """
    return [int(round(num * 2 ** fract_bits)) for num in in_val]




def get_coeff_from_txt(txt_file: str) -> list:
    """Return a list of verilog coefficients from text file

    Args:
        txt_file (str): name of coefficient txt file

    Returns:
        list: a list of verilog coefficients as integers
    """
    coeff_list = []
    with open(txt_file) as f:
        for line in f:
            line = line.strip()

            # print(line)
            
            coeff_list.append(int(line))
    # print(coeff_list)
    return coeff_list



        

def LUT_outputs(symb_list: list, coeff_list_verilog:list, frac_bits: int) -> dict:
    """Generate a dictionary of lists for the possible verilog LUT outputs based on filter coefficients
        also scale down by a factor due to python not handling fractions well. so scale down by the input scaling
        Reminder, the middle coefficient only needs the initial inputs, not the combo

    Args:
        symb_list (list): list of input symbols in decimal format
        coeff_list_verilog: list of coefficients in verilog format
        frac_bits: integer number of fractional bits
    
    Returns:
        dict: a dictionary of lists for each LUT
    """
    # generate lut inputs
    symb_list_verilog = convert_to_verilog(symb_list, frac_bits)
    lut_in = LUT_inputs(symb_list_verilog)
    # print(lut_in)
    
    # generate key names
    LUT_dict = {}
    for num in range(0,len(coeff_list_verilog)):
        LUT_Num = f"LUT_{num}"
        tmp = [] # calculate lut values
        
        # for last coefficient -  it only requires the initial input values
        if num == len(coeff_list_verilog)-1:
            for inpt in symb_list_verilog:
                mult = coeff_list_verilog[num] * inpt
                # print(f'{inpt} * {coeff_list_verilog[num]} = {mult}')

                tmp.append(mult)
        else:
                
            for val in lut_in:
                mult = coeff_list_verilog[num] * val
                if mult not in tmp:
                    # print(f'{val} * {coeff_list_verilog[num]} = {mult}')

                    tmp.append(mult)
        
        # for idx in range(0,len(tmp)):
        #     tmp[idx] = round(tmp[idx]/scale_factor)
        LUT_dict[LUT_Num] = tmp
        
    # print(LUT_dict)
                    
    return LUT_dict

# TODO: write to verilog file with the list of coefficients needed. Also need to fix last LUT as it only requires the initial input values and no the combination
# print(LUT_inputs(symbols))

def generate_lut_case_statement(lut_num: int, lut_inpt_list: list, LUT_dict: dict, lut_file, num_add_bits: int, num_lt_bits: int) -> None:
    """ Write case statement for LUT outputs to file object

    Args:
        lut_num (int): the LUT number
        lut_inpt_list (list): list of inputs for the LUT
        LUT_dict (dict): LUT output dictionary
        lut_file (TextIOWrapper): file object to be written to
        num_add_bits (int): number of adder bits
        num_lt_bits (int): number of bits needed for LUT
    """
    lut_file.write(f"\tcase(sum_level_1[{lut_num}])\n")
    
    # loop through adder output vals and map to coefficient
    for val in range(0,len(lut_inpt_list)):
        #check negative input value
        print(val)
        print(str(lut_inpt_list) + "input list")
        if lut_inpt_list[val] < 0:
            lut_file.write(f"\t\t-{num_add_bits}'sd {abs(lut_inpt_list[val]):<6} :")
            #check negative coeff output

            if LUT_dict[f'LUT_{lut_num}'][val] < 0:

                lut_file.write(f"\tLUT_out{str([lut_num]):<4} = -{num_lt_bits}'sd {abs(LUT_dict[f'LUT_{lut_num}'][val])};\n")
            else:
                lut_file.write(f"\tLUT_out{str([lut_num]):<4} = {num_lt_bits}'sd {LUT_dict[f'LUT_{lut_num}'][val]};\n")
                
        # for postive values    
        else:
            lut_file.write(f"\t\t{num_add_bits} 'sd {lut_inpt_list[val]:<6} :")
            #check negative coeff output
            if LUT_dict[f'LUT_{lut_num}'][val] < 0:
                lut_file.write(f"\tLUT_out{str([lut_num]):<4} = -{num_lt_bits}'sd {abs(LUT_dict[f'LUT_{lut_num}'][val])};\n")
            else:
                lut_file.write(f"\tLUT_out{str([lut_num]):<4} = {num_lt_bits}'sd {LUT_dict[f'LUT_{lut_num}'][val]};\n")
    lut_file.write(f"\t\tdefault{':':>6}\tLUT_out{str([lut_num]):<4} = {num_lt_bits}'sd 0;\n")
    lut_file.write(f"\tendcase\n")
    lut_file.write(f"end\n\n")




def generate_filter_script(base_file_name: str, new_file_name:str, num_LUT_bits: int, num_adder_bits: int, symb_list:list,coeff_list: list, 
                           num_symb_frac_bits:int) -> None:
    """Generate new verilog filter file with LUTs instead of multipliers from a verilog base template

    Args:
        base_file_name (str): base template verilog file name
        new_file_name (str): new verilog filter file name
        num_LUT_bits (int): number of bits needed for LUT outputs
        num_adder_bits (int): number of bits needed for adder output that will be going into LUT
        symb_list (list): initial symbols in decimal format
        coeff_list (list): coefficient list in verilog format
        num_symb_frac_bits (int): number of fractional bits needed to represent input symbols in verilog format
     
    """
    
    # get LUT parameters
    initial_symb_verilog = convert_to_verilog(symb_list, num_symb_frac_bits)
    initial_symb_verilog_scaled = []

    # print(str(initial_symb_verilog) + " initial_symb_verilog")
    
    # scale down initial symbols
    for val in initial_symb_verilog:    
        initial_symb_verilog_scaled.append(round(val))
        
    
    LUT_input_verilog = LUT_inputs(initial_symb_verilog)
    LUT_input_verilog_scaled = []

    for val in LUT_input_verilog:    
        LUT_input_verilog_scaled.append(round(val))
    
    # print(str(LUT_input_verilog) + "LUT_input_verilog")
    
    #t get LUT output dictionary
    LUT = LUT_outputs(symb_list, coeff_list, num_symb_frac_bits)
    
    # copy contents of base file into new file
    with open(base_file_name, 'r') as base_file, open(new_file_name, 'w') as new_file:
        for line in base_file:
            new_file.write(line)
            
    # write Lut outputs to new file
    with open(new_file_name, "a") as lut_file:
        
        # loop through dictionary and write coefficient outputs to LUT outputs
        for lut_num in range(0, len(LUT)):
            lut_file.write(f"// LUT_{lut_num} \n")
            lut_file.write("\nalways @ *\n")
            lut_file.write("begin\n")
            
            # for the middle coefficient
            if lut_num == len(LUT) - 1:
                generate_lut_case_statement(lut_num, initial_symb_verilog_scaled, LUT, lut_file, num_adder_bits, num_LUT_bits)

            else:
                generate_lut_case_statement(lut_num, LUT_input_verilog, LUT, lut_file, num_adder_bits, num_LUT_bits)
        lut_file.write("\nendmodule")
                
            


# generate case statement to check range?
                                            
                        
                                                
                    
                    
            
            
            
            
        
        
                    


in_val_verilog = convert_to_verilog(symbols, 17)
# in_val_verilog = symbols
print(in_val_verilog)


# print(type(0x5F))
lut_inpt_verilog = LUT_inputs(in_val_verilog)
# lut_inpt_verilog = LUT_inputs(hex_val)
print(lut_inpt_verilog)
# hex_val = []
# for i in lut_inpt_verilog:
#     hex_val.append(hex(i))
# print(hex_val)
coeff_list = get_coeff_from_txt("lut_coefficient.txt")
print(coeff_list)

LUTs = LUT_outputs(symbols, coeff_list, 3, 16)
# # print(LUTs["LUT_0"])
# print(LUTs)


generate_filter_script("srrc_filter_base_template.v", "srrc_filter_Luts.v", 37, 19, symbols, coeff_list, 17)
            