`timescale 1ns / 1ps

module SevenSegController (
    input  wire clk,
    input  wire reset,
    input  wire [7:0]  value,
    output reg  [6:0]  seg,
    output reg  [3:0]  an
);

    // -----------------------------
    // Split into digits
    // -----------------------------
    reg [3:0] ones;
    reg [3:0] tens;

    always @(*) begin
        ones = value % 10;
        tens = (value / 10) % 10;
    end

    // -----------------------------
    // Refresh counter
    // -----------------------------
    reg [16:0] refresh_counter;
    reg digit_select;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            refresh_counter <= 0;
            digit_select    <= 0;
        end else begin
            if (refresh_counter == 17'd99999) begin
                refresh_counter <= 0;
                digit_select    <= ~digit_select;
            end else begin
                refresh_counter <= refresh_counter + 1;
            end
        end
    end

    // -----------------------------
    // Select digit
    // -----------------------------
    reg [3:0] current_digit;

    always @(*) begin
        if (digit_select == 0)
            current_digit = ones;
        else
            current_digit = (value >= 10) ? tens : 4'hF; // blank if single digit
    end

    // -----------------------------
    // Anode control (ACTIVE-LOW)
    // -----------------------------
    always @(*) begin
        if (digit_select == 0)
            an = 4'b1110; // rightmost digit ON
        else
            an = 4'b1101; // next digit ON
    end

    // -----------------------------
    // 7-segment decoder (ACTIVE-LOW)
    // -----------------------------
    always @(*) begin
        case (current_digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end
endmodule 