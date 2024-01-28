
# import numpy as np
# parameters
# symbols = [0, 1 , 0.6666666666666666, -0.6666666666666666, -1]
symbols = [0, 3, 1, -1, -3]
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
    """Return a list of verilog coefficients from textfile

    Args:
        txt_file (str): name of coefficient txt file

    Returns:
        list: a list of verilog coefficients as integers
    """
    coeff_list = []
    with open(txt_file) as f:
        for line in f:
            line = line.strip()
            coeff_list.append(int(line))
    return coeff_list
        

def LUT_outputs(lut_inputs_verilog: list, coeff_list_verilog:list, scale_factor: int) -> dict:
    """Generate a dictionary of lists for the possible verilog LUT outputs based on filter coefficients
        also scale down by a factor due to python not handling fractions well. so scale down by the input scaling

    Args:
        lut_inputs (list): list of input values in verilog format
        coeff_list_verilog: list of coefficients in verilog format
        scale_factor: scale down by this factor since python doesn't handle fractions well
    
    Returns:
        dict: a dictionary of lists for each LUT
    """
    # generate key names
    LUT_dict = {}
    for num in range(0,len(coeff_list_verilog)):
        LUT_Num = f"LUT_{num}"
        # LUT_dict[LUT_Num] = []
        # calculate lut values
        tmp = []
        for inpt in lut_inputs_verilog:
            mult = coeff_list_verilog[num] * inpt
            if mult not in tmp:
                tmp.append(mult)
        
        for idx in range(0,len(tmp)):
            tmp[idx] = round(tmp[idx]/scale_factor)
        LUT_dict[LUT_Num] = tmp
        
    
                    
    return LUT_dict

# TODO: write to verilog file with the list of coefficients needed. Also need to fix last LUT as it only requires the initial input values and no the combination
# print(LUT_inputs(symbols))


in_val_verilog = convert_to_verilog(symbols, 16)
print(in_val_verilog)

lut_inpt_verilog = LUT_inputs(in_val_verilog)
print(lut_inpt_verilog)

coeff_list = get_coeff_from_txt("coeff_tx.txt")
print(coeff_list)

LUTs = LUT_outputs(lut_inpt_verilog, coeff_list, 3)
# print(LUTs["LUT_0"])
print(LUTs)


            