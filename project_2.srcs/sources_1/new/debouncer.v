`timescale 1ns / 1ps
module debouncer(
    input clk,
    input pb_in,
    output reg pb_out
);
    reg [15:0] shift_reg;

    always @(posedge clk) begin
        shift_reg <= {shift_reg[14:0], pb_in};
        if (&shift_reg)       // all 16 bits high -> pressed
            pb_out <= 1;
        else if (~|shift_reg) // all 16 bits low -> released
            pb_out <= 0;
    end
endmodule
