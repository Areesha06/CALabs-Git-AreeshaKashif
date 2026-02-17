`timescale 1ns / 1ps

// ============================================================
//  MODULE: debouncher
//  Purpose: Remove button bounce using 16-bit saturating counter
//  - Counts while button pressed (max 65,535 clocks)
//  - When count[15] rises AND falls (edge detect) ? one-clock pulse
//  - Resets counter immediately when button released
// ============================================================
module debouncher (
    input  clk,
    input  pbin,      // Raw button input (noisy, async)
    output pbout      // Clean debounced pulse output
);
    
    reg [15:0] cnt = 0;   // 16-bit counter (saturates at bit 15)
    reg        q0  = 0;   // First FF for edge detection
    reg        q1  = 0;   // Second FF for edge detection

    always @(posedge clk) begin
        // When button released: reset counter
        if (!pbin)           
            cnt <= 0;
        
        // When button held: count up until bit 15 saturates
        else if (!cnt[15])   
            cnt <= cnt + 1;
        
        // Shift registers for edge detection (rising edge of cnt[15])
        q0 <= cnt[15];
        q1 <= q0;
    end
    
    // Output pulse: detect rising edge of cnt[15]
    // pbout = 1 for ONE clock when q0 goes from 0?1
    assign pbout = q0 & ~q1;

endmodule
