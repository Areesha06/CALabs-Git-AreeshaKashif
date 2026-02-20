`timescale 1ns / 1ps
module switches(
    input clk,
    input rst,
    input [15:0] switches,       // physical FPGA switches
    output reg [2:0] ALUControl, // 3-bit operation select
    output reg rst_out           // on/off or reset
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ALUControl <= 3'b000;
            rst_out <= 0;
        end else begin
            ALUControl <= switches[2:0];   // switches 0-2 for operation
            rst_out <= switches[3];         // switch 3 for on/off or reset
        end
    end

endmodule
