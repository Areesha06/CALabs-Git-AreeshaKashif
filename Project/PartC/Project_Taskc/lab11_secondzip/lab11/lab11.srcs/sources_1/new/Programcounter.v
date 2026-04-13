`timescale 1ns / 1ps

module ProgramCounter (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] pc_next,   // Next PC value (from mux2)
    output reg  [31:0] pc         // Current PC value
);
    initial pc = 32'b0; 
    always @(posedge clk) begin
        if (reset)
            pc <= 32'b0;
        else
            pc <= pc_next;
    end

endmodule