
`timescale 1ns / 1ps
module clock_divider(
    input clk,
    input rst,
    output reg enable
);

    reg [26:0] counter = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            enable <= 0;
        end
        else begin
            if (counter == 100_000_000 - 1) begin
                counter <= 0;
                enable <= 1;
            end
            else begin
                counter <= counter + 1;
                enable <= 0;
            end
        end
    end

endmodule
