`timescale 1ns / 1ps
module leds(
    input clk,
    input rst,
    input [31:0] ALUResult,
    input Zero,
    output reg [15:0] LEDS
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            LEDS <= 16'b0;
        else begin
            LEDS[14:0] <= ALUResult[14:0];  // lower 15 bits to LEDs
            LEDS[15]   <= Zero;              // MSB LED shows Zero flag
        end
    end

endmodule
