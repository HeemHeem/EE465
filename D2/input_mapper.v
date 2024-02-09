`define DATA_LENGTH 18

module input_mapper #(
    parameter       DATA_WIDTH = 18 // data length of the output
)(
    input [1:0] mapper_in,
    output reg signed [17:0] mapper_out // 1s17

);


always @ *
    case(mapper_in)
    
        2'b00: mapper_out = -`DATA_LENGTH'sd 98304; // -0.75 (-3a)
        2'b01: mapper_out = -`DATA_LENGTH'sd 32768; // -0.25 (-a)
        2'b10: mapper_out = `DATA_LENGTH'sd 32768; // 0.25 (a)
        2'b11: mapper_out = `DATA_LENGTH'sd 98304; // 0.75 (3a)

        default: mapper_out = `DATA_LENGTH'sd 0;
    endcase

endmodule