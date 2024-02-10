module output_mapper(
    input wire signed [17:0] reference_level,
    input wire [1:0] slice_in,
    output reg signed [17:0] mapper_out
);

reg signed [17:0] b;

always  @ *
    b = reference_level >> 1; // b value. Divide reference by 2

always @ *
    case(slice_in)

    2'b00: mapper_out = -reference_level - b; // -3b
    2'b01: mapper_out = -reference_level + b;// -b
    2'b11: mapper_out = reference_level - b; // b
    2'b10: mapper_out = reference_level + b; // 3b

    default: mapper_out = reference_level;
    endcase






endmodule
