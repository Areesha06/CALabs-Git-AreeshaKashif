`timescale 1ns / 1ps

module mux2 #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] in0,   // Input 0: PC + 4
    input  wire [WIDTH-1:0] in1,   // Input 1: branch target
    input  wire  sel,   // PCSrc control signal
    output wire [WIDTH-1:0] out
);

    assign out = sel ? in1 : in0;

endmodule