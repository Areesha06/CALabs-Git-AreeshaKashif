`timescale 1ns / 1ps
module fsm(
    input clk,
    input rst,
    input pb,               // debounced push button input
    output reg [3:0] ALUControl
);

    reg pb_last;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ALUControl <= 4'b0000;
            pb_last <= 0;
        end else begin
            pb_last <= pb;
            // detect rising edge of button
            if (pb & ~pb_last) begin
                if (ALUControl == 4'b0111)
                    ALUControl <= 4'b0000;
                else
                    ALUControl <= ALUControl + 1;
            end
        end
    end

endmodule
