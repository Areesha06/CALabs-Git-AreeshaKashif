`timescale 1ns / 1ps

// ============================================================
//  Simple Testbench - Lab 5 FSM with Priority Encoder
//  Tests: reset, idle, countdown (bit position = value)
// ============================================================
module tb_fsm;
    reg        clk         = 0;
    reg        rst         = 0;
    reg        rst_btn_raw = 0;
    reg [15:0] sw          = 0;
    wire [6:0] seg;
    wire [3:0] an;
    wire       dp;
    
    always #5 clk = ~clk;   // 100 MHz
    
    // Instantiate top module
    lab5_top uut (
        .clk        (clk),
        .rst        (rst),
        .rst_btn_raw(rst_btn_raw),
        .sw         (sw),
        .seg        (seg),
        .an         (an),
        .dp         (dp)
    );
    
    // Internal probes
    wire [1:0]  state = uut.u_fsm.fsm_state;
    wire [15:0] count = uut.u_counter.count;
    wire        load  = uut.u_fsm.counter_load;
    wire        en    = uut.u_fsm.counter_en;
    
    initial begin
        $dumpfile("tb_fsm.vcd");
        $dumpvars(0, tb_fsm);
    end
    
    // Print every clock edge
    initial begin
        $display("  Time | state | count | load | en");
        $display("  -----|-------|-------|------|----");
        forever begin
            @(posedge clk); #1;
            $display("  %0t  |  %2b   | %04h  |  %b   |  %b",
                     $time, state, count, load, en);
        end
    end
    
    initial begin
        $display("=== Lab 5 FSM Testbench (Priority Encoder) ===\n");
        
        // -------------------------------------------------
        // TEST 1: Global reset -> state=IDLE, count=0
        // -------------------------------------------------
        $display("[TEST 1] Global reset");
        rst = 1;
        repeat(4) @(posedge clk); #1;
        rst = 0;
        @(posedge clk); #1;
        $display("  >> state=%b  count=%04h  (expect: state=00, count=0000)\n",
                 state, count);
        
        // -------------------------------------------------
        // TEST 2: sw=0 -> FSM stays in IDLE
        // -------------------------------------------------
        $display("[TEST 2] sw=0 stays IDLE");
        sw = 16'h0000;
        repeat(4) @(posedge clk); #1;
        $display("  >> state=%b  count=%04h  (expect: state=00, count=0000)\n",
                 state, count);
        
        // -------------------------------------------------
        // TEST 3: SW[5] only (bit 5 = load value 5)
        //         FSM should: IDLE->LOAD->COUNT 5,4,3,2,1,0 -> IDLE
        //         PRIORITY ENCODER: only bit 5 set ? loads 5
        // -------------------------------------------------
        $display("[TEST 3] SW[5] only (bit position 5 = value 5)");
        $display("         Setting sw = 16'h0020 (only bit 5)");
        sw = 16'h0020;           // Only bit 5 set ? priority encoder loads 5
        @(posedge clk);          // FSM sees sw!=0, goes to LOAD, counter loads 5
        sw = 16'h0000;           // clear sw immediately so it won't reload
        repeat(10) @(posedge clk); #1;  // wait for 5 decrements + return to IDLE
        $display("  >> state=%b  count=%04h  (expect: state=00, count=0000)\n",
                 state, count);
        
        // -------------------------------------------------
        // TEST 4: SW[8] only (bit 8 = load value 8), then reset button mid-count
        //         FSM should jump back to IDLE immediately
        // -------------------------------------------------
        $display("[TEST 4] SW[8] only (bit 8 = value 8), reset button mid-count");
        $display("         Setting sw = 16'h0100 (only bit 8)");
        sw = 16'h0100;           // Only bit 8 set ? priority encoder loads 8
        @(posedge clk);          // LOAD: counter loads 8
        sw = 16'h0000;           // clear sw
        repeat(3) @(posedge clk); #1; // let it count down 3 steps (count should be 5)
        $display("  >> mid-count: state=%b  count=%04h  (expect: state=10, count should be 5ish)",
                 state, count);
        
        // Hold button 30 cycles to satisfy debouncer
        rst_btn_raw = 1;
        repeat(30) @(posedge clk);
        rst_btn_raw = 0;
        @(posedge clk); #1;
        $display("  >> after btn: state=%b  count=%04h  (expect: state=00, count=0000)\n",
                 state, count);
        
        // -------------------------------------------------
        // TEST 5: SW[15] (R2) only ? load value 15 (0x000F)
        // -------------------------------------------------
        $display("[TEST 5] SW[15] only (R2 = bit 15 = value 15)");
        $display("         Setting sw = 16'h8000 (only bit 15)");
        sw = 16'h8000;           // Only bit 15 set ? priority encoder loads 15
        repeat(5) @(posedge clk);
        $display("  >> state=%b  count=%04h  (expect: state=10, count=000F)\n",
                 state, count);
        
        sw = 16'h0000;
        repeat(5) @(posedge clk);
        
        // -------------------------------------------------
        // TEST 6: SW[0] only ? load value 0 (0x0000)
        // -------------------------------------------------
        $display("[TEST 6] SW[0] only (bit 0 = value 0)");
        $display("         Setting sw = 16'h0001 (only bit 0)");
        sw = 16'h0001;           // Only bit 0 set ? priority encoder loads 0
        repeat(5) @(posedge clk);
        $display("  >> state=%b  count=%04h  (expect: state=10, count=0000)\n",
                 state, count);
        
        sw = 16'h0000;
        repeat(5) @(posedge clk);
        
        // -------------------------------------------------
        // TEST 7: Multiple bits set (SW[3] and SW[7])
        //         Priority encoder picks lowest bit ? bit 3 = value 3
        // -------------------------------------------------
        $display("[TEST 7] SW[3] and SW[7] both set");
        $display("         Setting sw = 16'h0088 (bits 3 and 7)");
        $display("         Priority encoder picks bit 3 ? loads value 3");
        sw = 16'h0088;           // Bits 3 and 7 set ? picks bit 3, loads 3
        repeat(5) @(posedge clk);
        $display("  >> state=%b  count=%04h  (expect: state=10, count=0003)\n",
                 state, count);
        
        sw = 16'h0000;
        repeat(4) @(posedge clk);
        
        $display("=== Testbench done ===");
        $finish;
    end

endmodule