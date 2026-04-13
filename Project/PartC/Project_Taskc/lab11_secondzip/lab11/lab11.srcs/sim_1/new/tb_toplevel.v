`timescale 1ns / 1ps
module tb_TopLevel;
    reg        clk, reset;
    reg        gcd_enable, output_enable;
    reg        a_load, b_load;
    reg  [7:0] input_val;
    wire [6:0] seg;
    wire [3:0] an;

    initial clk = 0;
    always #5 clk = ~clk;

    TopLevelProcessor #(.DIV(4)) uDUT (
        .clk           (clk),
        .reset         (reset),
        .gcd_enable    (gcd_enable),
        .output_enable (output_enable),
        .a_load        (a_load),
        .b_load        (b_load),
        .input_val     (input_val),
        .seg           (seg),
        .an            (an)
    );

    wire [31:0] pc    = uDUT.pc;
    wire [31:0] instr = uDUT.instruction;
    wire [31:0] x10   = uDUT.uRF.regs[10];
    wire [31:0] x11   = uDUT.uRF.regs[11];
    wire [31:0] x12   = uDUT.uRF.regs[12];
    wire [31:0] mem128 = uDUT.uDMem.mem[128];
    wire [31:0] mem129 = uDUT.uDMem.mem[129];
    wire [31:0] mem130 = uDUT.uDMem.mem[130];
    wire [31:0] mem131 = uDUT.uDMem.mem[131];

    task wait_slow_cycle;
        repeat(8) @(posedge clk);
    endtask

    task check32;
        input [31:0] actual;
        input [31:0] expected;
        input [255:0] label;
        begin
            if (actual === expected)
                $display("  PASS  %s = %0d", label, actual);
            else
                $display("  FAIL  %s : expected %0d, got %0d", label, expected, actual);
        end
    endtask

    integer i;
    initial begin
        $dumpfile("tb_TopLevel.vcd");
        $dumpvars(0, tb_TopLevel);

        gcd_enable    = 0;
        output_enable = 0;
        a_load        = 0;
        b_load        = 0;
        input_val     = 8'b0;

        $display("\n=== RESET ===");
        reset = 1;
        repeat(20) @(posedge clk);
        reset = 0;

        $display("\n=== Wait for processor to enter wait_start ===");
        repeat(5) wait_slow_cycle;
        $display("PC = 0x%08h", pc);

        $display("\n=== Enable GCD mode ===");
        gcd_enable = 1;
        wait_slow_cycle;

        $display("\n=== Load A = 48 via BTNU ===");
        input_val = 8'd48;
        wait_slow_cycle;
        a_load = 1;
        repeat(4) wait_slow_cycle;
        a_load = 0;
        repeat(2) wait_slow_cycle;
        $display("DataMemory[128] (A) = %0d", mem128);
        check32(mem128, 32'd48, "A value");

        $display("\n=== Load B = 18 via BTND (starts GCD) ===");
        input_val = 8'd18;
        wait_slow_cycle;
        b_load = 1;
        repeat(4) wait_slow_cycle;
        b_load = 0;
        repeat(2) wait_slow_cycle;
        $display("DataMemory[129] (B) = %0d", mem129);
        $display("DataMemory[131] (flag) = %0d", mem131);
        check32(mem129, 32'd18, "B value");

        $display("\n=== GCD Computation Running ===");
        $display("%-6s %-10s %-8s %-8s %-8s", "Cycle", "PC", "x10(a)", "x11(b)", "Result");

        for (i = 0; i < 200; i = i + 1) begin
            wait_slow_cycle;
            if (i < 20 || mem130 != 0)
                $display("%-6d 0x%08h %-8d %-8d %-8d", i, pc, x10, x11, mem130);
            if (mem130 != 0 && pc == 32'h04) begin
                $display("\n=== GCD computation complete! ===");
                i = 200;
            end
        end

        output_enable = 1;
        wait_slow_cycle;

        $display("\n=== Final Verification ===");
        check32(mem130, 32'd6, "GCD(48,18) result");
        check32(x10, 32'd6, "x10 register");
        $display("\nGCD(48, 18) = %0d", mem130);

        $display("\n=== Test 2: GCD(12, 8) ===");
        input_val = 8'd12;
        wait_slow_cycle;
        a_load = 1;
        repeat(4) wait_slow_cycle;
        a_load = 0;
        repeat(2) wait_slow_cycle;
        input_val = 8'd8;
        wait_slow_cycle;
        b_load = 1;
        repeat(4) wait_slow_cycle;
        b_load = 0;
        repeat(2) wait_slow_cycle;

        for (i = 0; i < 200; i = i + 1) begin
            wait_slow_cycle;
            if (mem130 == 32'd4 && pc == 32'h04) begin
                $display("GCD(12, 8) computed!");
                i = 200;
            end
        end
        check32(mem130, 32'd4, "GCD(12,8) result");

        $display("\n=== Test 3: GCD(255, 1) ===");
        input_val = 8'd255;
        wait_slow_cycle;
        a_load = 1;
        repeat(4) wait_slow_cycle;
        a_load = 0;
        repeat(2) wait_slow_cycle;
        input_val = 8'd1;
        wait_slow_cycle;
        b_load = 1;
        repeat(4) wait_slow_cycle;
        b_load = 0;
        repeat(2) wait_slow_cycle;

        for (i = 0; i < 500; i = i + 1) begin
            wait_slow_cycle;
            if (mem130 == 32'd1 && pc == 32'h04) begin
                $display("GCD(255, 1) computed!");
                i = 500;
            end
        end
        check32(mem130, 32'd1, "GCD(255,1) result");

        $display("\n=== All tests complete ===");
        $finish;
    end

    initial begin
        #2_000_000;
        $display("Timeout!");
        $finish;
    end
endmodule