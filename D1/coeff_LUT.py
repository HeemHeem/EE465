
# parameters
symbols = [0, 1, 1/3, -1/3, -1]
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
            if sum2inputs not in lut_in:
                lut_in.append(sum2inputs)
    return lut_in

def LUT_outputs(lut_inputs: list, coeff_txt: str):
    """Generate a dictionary of list for the possible verilog outputs

    Args:
        lut_inputs (list): _description_
        coeff_txt (str): _description_
    """

print(LUT_inputs(symbols))


            