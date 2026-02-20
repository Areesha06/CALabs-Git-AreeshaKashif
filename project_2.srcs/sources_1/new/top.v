`timescale 1ns / 1ps
module top(
    input clk,
    input [3:0] switches,   // Basys3 switches
    output [15:0] LEDS       // LEDs display
);

    wire [31:0] A = 32'd4;
    wire [31:0] B = 32'd5;
    wire rst;
    debouncer db_inst (
        .clk(clk),
        .pb_in(switches[3]),  
        .pb_out(rst)
    );

    wire [2:0] ALUControl;
    fsm fsm_inst (
        .clk(clk),
        .rst(rst),
        .pb(switches[0]),       // switch 0 = button to cycle operations
        .ALUControl(ALUControl)
    );

    wire [31:0] ALUResult;
    wire Zero;
    alu alu_inst (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    leds led_inst (
        .clk(clk),
        .rst(rst),
        .ALUResult(ALUResult),
        .Zero(Zero),
        .LEDS(LEDS)
    );

endmodule
