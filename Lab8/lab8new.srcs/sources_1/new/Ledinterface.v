

`timescale 1ns / 1ps

module LEDInterface (
    input  wire       clk,
    input  wire       reset,         // synchronous active-high reset
    input  wire       wr,            // write enable (from decoder: led_wr)
    input  wire [5:0] data_in,       // 6-bit value to display
    output reg  [5:0] led_out        // drives FPGA LED pins
);

    always @(posedge clk) begin
        if (reset)
            led_out <= 6'b000000;
        else if (wr)
            led_out <= data_in;
        // else: retain previous value (no change)
    end

endmodule