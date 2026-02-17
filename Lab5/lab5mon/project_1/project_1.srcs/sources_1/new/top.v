`timescale 1ns / 1ps

// ============================================================
//  MODULE: lab5_top
//  Purpose: Top-level integration of all 5 modules
//  Signal flow:
//    SW[15:0] ? switches ? FSM & counter
//    BTNC ? debouncer ? FSM & counter
//    FSM ? counter (load, en signals)
//    Counter ? 7-seg display
// ============================================================
module lab5_top (
    input        clk,           // 100 MHz oscillator (W5)
    input        rst,           // Global reset button BTNC (U18)
    input        rst_btn_raw,   // Debounce-input reset button BTNU (T18)
    input [15:0] sw,            // Physical slide switches (SW[15:0])
    output [6:0] seg,           // 7-segment cathodes active-LOW (W7-U7)
    output [3:0] an,            // 7-segment anodes active-LOW (U2-W4)
    output       dp             // Decimal point (always OFF, V7)
);

    // ========================
    // Internal wires
    // ========================
    wire        rst_btn;        // Debounced reset pulse from BTNU
    wire [31:0] sw_read_data;   // 32-bit output from switches module
    wire [15:0] sw_val;         // Extracted 16-bit switch value
    wire        sw_nonzero;     // Flag: any switch is ON
    wire        counter_load;   // FSM output: load counter now
    wire        counter_en;     // FSM output: enable decrement now
    wire [15:0] count;          // Counter value to display
    wire        count_zero;     // Counter flag: reached zero

    // ----------------------------------------------------------
    // INSTANCE 1: Debouncher
    // Cleans up BTNU input and produces one-clock pulse
    // ----------------------------------------------------------
    debouncher u_debounce (
        .clk   (clk),
        .pbin  (rst_btn_raw),
        .pbout (rst_btn)
    );

    // ----------------------------------------------------------
    // INSTANCE 2: Switches interface
    // Reads all 16 slide switches via memory-mapped interface
    // memAddress = {28'h0, 2'b10} selects full 16-bit mode
    // ----------------------------------------------------------
    switches u_switches (
        .clk        (clk),
        .rst        (rst),
        .btns       (16'h0000),
        .writeData  (32'h00000000),
        .writeEnable(1'b0),
        .readEnable (1'b1),
        .memAddress ({28'h0, 2'b10}),  // Address mode 2 = full 16-bit read
        .switches   (sw),
        .readData   (sw_read_data)
    );

    // Extract 16-bit value and detect if any switch is ON
    assign sw_val     = sw_read_data[15:0];
    assign sw_nonzero = (sw_val != 16'h0000);

    // ----------------------------------------------------------
    // INSTANCE 3: FSM Controller
    // 3-state machine managing countdown sequence
    // ----------------------------------------------------------
    fsm_control u_fsm (
        .clk         (clk),
        .rst         (rst),
        .rst_btn     (rst_btn),
        .sw_nonzero  (sw_nonzero),
        .count_zero  (count_zero),
        .counter_load(counter_load),
        .counter_en  (counter_en)
    );

    // ----------------------------------------------------------
    // INSTANCE 4: Decrement Counter with Priority Encoder
    // Loads switch BIT POSITION (0-15) as countdown value
    // Example: SW[15] (R2) only ? load 15
    //          SW[7] only ? load 7
    //          SW[0] only ? load 0
    // ----------------------------------------------------------
    decrement_counter u_counter (
        .clk       (clk),
        .rst       (rst),
        .rst_btn   (rst_btn),
        .load      (counter_load),
        .en        (counter_en),
        .sw_val    (sw_val),
        .count     (count),
        .count_zero(count_zero)
    );

    // ----------------------------------------------------------
    // INSTANCE 5: Seven-Segment Display
    // Multiplexes 4 digits and converts count to hex display
    // ----------------------------------------------------------
    seven_seg_display u_7seg (
        .clk  (clk),
        .rst  (rst),
        .value(count),
        .seg  (seg),
        .an   (an),
        .dp   (dp)
    );

endmodule