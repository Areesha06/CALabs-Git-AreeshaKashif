`timescale 1ns / 1ps

// ============================================================
//  MODULE: fsm_control
//  Purpose: 3-state Moore FSM controlling countdown process
//  States: IDLE (waiting) -> LOAD (capture switch) -> COUNT (decrement)
// ============================================================
module fsm_control (
    input      clk,
    input      rst,           // Global reset (BTNC)
    input      rst_btn,       // Mid-count reset (BTNU, debounced)
    input      sw_nonzero,    // Trigger: any switch is ON
    input      count_zero,    // Trigger: counter reached zero
    output reg counter_load,  // Signal: load switch value into counter
    output reg counter_en,    // Signal: enable counter decrement
    output reg [1:0] fsm_state = 2'b00
);
    
    // Define state encodings for readability
    localparam [1:0] IDLE=2'b00, LOAD=2'b01, COUNT=2'b10;

    initial begin
        counter_load = 1'b0;
        counter_en   = 1'b0;
    end

    reg [1:0] next_state;

    // ========================
    // Next-state logic (combinational)
    // Determines which state to go to based on current state and inputs
    // ========================
    always @(*) begin
        case (fsm_state)
            // IDLE: Wait for user to set a switch
            IDLE:    next_state = sw_nonzero ? LOAD  : IDLE;
            
            // LOAD: Always transition to COUNT after capturing switch value
            LOAD:    next_state = COUNT;
            
            // COUNT: Stay counting until counter hits zero, then return to IDLE
            COUNT:   next_state = count_zero ? IDLE  : COUNT;
            
            default: next_state = IDLE;
        endcase
    end

    // ========================
    // State register (synchronous)
    // Updates state on every clock edge
    // Both global reset and mid-count reset return to IDLE
    // ========================
    always @(posedge clk) begin
        if (rst || rst_btn) 
            fsm_state <= IDLE;
        else                
            fsm_state <= next_state;
    end

    // ========================
    // Output logic (combinational)
    // Asserts control signals based on NEXT state
    // This ensures signals are ready when state registers update
    // ========================
    always @(*) begin
        counter_load = 1'b0;
        counter_en   = 1'b0;
        if (!(rst || rst_btn)) begin
            case (next_state)
                // In LOAD state: capture the switch value
                LOAD:  counter_load = 1'b1;
                
                // In COUNT state: enable decrement (unless already at zero)
                COUNT: counter_en   = ~count_zero;
                
                default: ;
            endcase
        end
    end

endmodule
