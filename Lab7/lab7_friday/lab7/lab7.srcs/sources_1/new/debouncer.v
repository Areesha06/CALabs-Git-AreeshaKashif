`timescale 1ns / 1ps

module debouncer (
    input  clk,
    input  noisy,
    output clean
);

    reg [2:0] shift;

    // Shift input through 3 flip flops to filter glitches
    always @(posedge clk) begin
        shift <= {shift[1:0], noisy};
    end

    // Only output 1 when all 3 bits agree
    assign clean = (shift == 3'b111) ? 1'b1 : 1'b0;

endmodule