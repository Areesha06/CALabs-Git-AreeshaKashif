`timescale 1ns / 1ps

module button_debounce (
    input  wire clk,
    input  wire btn_in,
    output reg  btn_out
);
    reg [19:0] cnt;
    reg        btn_sync;

    always @(posedge clk) begin
        btn_sync <= btn_in;
        if (btn_sync != btn_out)
            cnt <= cnt + 1;
        else
            cnt <= 0;

        if (cnt == 20'hFFFFF)
            btn_out <= btn_sync;
    end
endmodule