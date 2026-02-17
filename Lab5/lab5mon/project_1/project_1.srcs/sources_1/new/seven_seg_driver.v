`timescale 1ns / 1ps

// ============================================================
//  MODULE: seven_seg_display
//  Purpose: 4-digit 7-segment display with hex output
//  - Multiplexes between 4 digits at ~1 kHz refresh
//  - Converts 4-bit hex nibble to 7-segment cathode pattern
//  - All segments active-LOW (1 = OFF, 0 = ON)
// ============================================================
module seven_seg_display (
    input          clk,
    input          rst,
    input  [15:0]  value,      // 16-bit number to display (4 hex digits)
    output reg [6:0] seg = 7'b1111111,    // Segment outputs (active-LOW)
    output reg [3:0] an  = 4'b1111,       // Anode select (active-LOW)
    output           dp                   // Decimal point (always OFF)
);
    
    assign dp = 1'b1;  // Decimal point always disabled
    
    reg [17:0] div = 0;   // Frequency divider for multiplexing
    reg [1:0]  sel = 0;   // Digit selector (0=rightmost, 3=leftmost)
    reg [3:0]  nib = 0;   // Current 4-bit hex digit being displayed

    // ========================
    // Frequency divider for multiplexing
    // Counts to 262,143 to create ~381 Hz refresh per digit
    // 4 digits × 381 Hz ? 1.5 kHz overall refresh
    // ========================
    always @(posedge clk) begin
        if (rst) begin
            div <= 0; 
            sel <= 0;
        end else begin
            div <= div + 1;
            if (div == 0) sel <= sel + 1;  // Advance digit every 262k clocks
        end
    end

    // ========================
    // Digit/nibble selection logic
    // Selects which 4 bits of value[15:0] to display
    // Also drives anode output (active-LOW: 0=ON, 1=OFF)
    // ========================
    always @(posedge clk) begin
        case (sel)
            2'd0: begin nib <= value[3:0];    an <= 4'b1110; end   // Digit 0 (ones)
            2'd1: begin nib <= value[7:4];    an <= 4'b1101; end   // Digit 1 (sixteens)
            2'd2: begin nib <= value[11:8];   an <= 4'b1011; end   // Digit 2 (256s)
            2'd3: begin nib <= value[15:12];  an <= 4'b0111; end   // Digit 3 (4096s)
        endcase
    end

    // ========================
    // Hex-to-7-segment decoder
    // Converts 4-bit value to segment pattern (active-LOW)
    // Segments: {g,f,e,d,c,b,a}
    //           a=top, b=top-right, c=bottom-right, d=bottom,
    //           e=bottom-left, f=top-left, g=middle
    // ========================
    always @(posedge clk) begin
        if (rst) 
            seg <= 7'b1111111;  // All segments OFF
        else 
            case (nib)
                4'h0: seg <= 7'b1000000;  // 0
                4'h1: seg <= 7'b1111001;  // 1
                4'h2: seg <= 7'b0100100;  // 2
                4'h3: seg <= 7'b0110000;  // 3
                4'h4: seg <= 7'b0011001;  // 4
                4'h5: seg <= 7'b0010010;  // 5
                4'h6: seg <= 7'b0000010;  // 6
                4'h7: seg <= 7'b1111000;  // 7
                4'h8: seg <= 7'b0000000;  // 8
                4'h9: seg <= 7'b0010000;  // 9
                4'hA: seg <= 7'b0001000;  // A
                4'hB: seg <= 7'b0000011;  // B
                4'hC: seg <= 7'b1000110;  // C
                4'hD: seg <= 7'b0100001;  // D
                4'hE: seg <= 7'b0000110;  // E
                4'hF: seg <= 7'b0001110;  // F
                default: seg <= 7'b1111111;
            endcase
    end

endmodule

