`timescale 1ns / 1ps
module decrement_counter (
    input clk,
    input rst,                // Global reset
    input rst_btn,            // Mid-count reset
    input load,               // Load enable (from FSM)
    input en,                 // Decrement enable (from FSM)
    input [15:0] sw_val,      // Switch input (bit position = value)
    output reg [15:0] count = 16'h0000,      // Current count value
    output reg count_zero = 1'b1              // Flag: reached zero
);

    always @(posedge clk) begin
        // PRIORITY 1: Reset overrides everything
        if (rst || rst_btn) begin
            count <= 16'h0000;
            count_zero <= 1'b1;
        end 
        // PRIORITY 2: Load takes precedence over decrement
        // Priority encoder: first set bit determines load value
        else if (load) begin
            case (1'b1)
                sw_val[0]:  count <= 4'd0;    // Only bit 0 set ? load 0
                sw_val[1]:  count <= 4'd1;    // Only bit 1 set ? load 1
                sw_val[2]:  count <= 4'd2;    // Only bit 2 set ? load 2
                sw_val[3]:  count <= 4'd3;    // Only bit 3 set ? load 3
                sw_val[4]:  count <= 4'd4;    // Only bit 4 set ? load 4
                sw_val[5]:  count <= 4'd5;    // Only bit 5 set ? load 5
                sw_val[6]:  count <= 4'd6;    // Only bit 6 set ? load 6
                sw_val[7]:  count <= 4'd7;    // Only bit 7 set ? load 7
                sw_val[8]:  count <= 4'd8;    // Only bit 8 set ? load 8
                sw_val[9]:  count <= 4'd9;    // Only bit 9 set ? load 9
                sw_val[10]: count <= 4'd10;   // Only bit 10 set ? load 10
                sw_val[11]: count <= 4'd11;   // Only bit 11 set ? load 11
                sw_val[12]: count <= 4'd12;   // Only bit 12 set ? load 12
                sw_val[13]: count <= 4'd13;   // Only bit 13 set ? load 13
                sw_val[14]: count <= 4'd14;   // Only bit 14 set ? load 14
                sw_val[15]: count <= 4'd15;   // Only bit 15 set (R2) ? load 15
                default:    count <= 16'h0000;
            endcase
            count_zero <= (sw_val == 16'h0000);  // Check if any switch is ON
        end 
        // PRIORITY 3: Decrement when enabled and not already zero
        else if (en && !count_zero) begin
            count <= count - 1'b1;               // Decrement by 1
            count_zero <= (count == 16'h0001);   // Register when next value will be 0
        end
    end

endmodule