`timescale 1ns / 1ps

module led (
    input      [4:0]  fsm_state,
    input      [7:0]  alu_low_bits,
    input             alu_zero,
    output reg [15:0] leds
);

    always @(*) begin
        leds[15:11] = fsm_state;     // top 5 LEDs show FSM state
        leds[10]    = alu_zero;      // lights up when ALU result is zero
        leds[9:8]   = 2'b00;
        leds[7:0]   = alu_low_bits;  // bottom 8 LEDs show ALU result
    end

endmodule