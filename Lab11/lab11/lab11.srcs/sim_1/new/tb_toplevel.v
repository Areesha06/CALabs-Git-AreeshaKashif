`timescale 1ns / 1ps
module tb_TopLevel;

    reg  clk, reset;
    wire [7:0] leds;

    initial clk = 0;
    always #5 clk = ~clk;

    TopLevelProcessor uDUT (
        .clk  (clk),
        .reset(reset),
        .leds (leds)
    );

    wire [31:0] pc    = uDUT.pc;
    wire [31:0] x2    = uDUT.uRF.regs[2];
    wire [31:0] x5    = uDUT.uRF.regs[5];
    wire [31:0] x6    = uDUT.uRF.regs[6];
    wire [31:0] x7    = uDUT.uRF.regs[7];
    wire [31:0] x10   = uDUT.uRF.regs[10];
    wire [31:0] instr = uDUT.instruction;

    task check32;
        input [31:0] actual;
        input [31:0] expected;
        input [127:0] label;
        begin
            if (actual === expected)
                $display("  PASS  %s = 0x%08h", label, actual);
            else
                $display("  FAIL  %s : expected 0x%08h, got 0x%08h",
                         label, expected, actual);
        end
    endtask

    integer i;
    initial begin
        $dumpfile("tb_TopLevel.vcd");
        $dumpvars(0, tb_TopLevel);

        reset = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;

        $display("\n=== Cycle trace (first 10 cycles) ===");
        $display("%-6s %-12s %-12s %-10s %-10s %-6s",
                 "Cycle","PC","Instr","x6","x7","LEDs");
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk); #1;
            $display("%-6d 0x%08h  0x%08h  0x%08h  0x%08h  0x%02h",
                     i, pc, instr, x6, x7, leds);
        end

        $display("\n=== Register checks ===");
        check32(x6,  32'd512, "x6 (switch addr 0x200) ");
        check32(x7,  32'd5,   "x7 (switch value = 5)  ");
        check32(x2,  32'd511, "sp (stack ptr = 511)   ");

        $display("\n=== Data memory check (SW x7,0(x6) -> mem[512]=5) ===");
        if ({uDUT.uDMem.mem[515], uDUT.uDMem.mem[514],
             uDUT.uDMem.mem[513], uDUT.uDMem.mem[512]} === 32'd5)
            $display("  PASS  DataMemory[0x200] = 5");
        else
            $display("  FAIL  DataMemory[0x200] = 0x%08h (expected 5)",
                     {uDUT.uDMem.mem[515],uDUT.uDMem.mem[514],
                      uDUT.uDMem.mem[513],uDUT.uDMem.mem[512]});

        $display("\n=== Running 200 more cycles ===");
        for (i = 0; i < 200; i = i + 1)
            @(posedge clk);
        #1;

        $display("  PC   = 0x%08h", pc);
        $display("  x10  = 0x%08h  (a0 countdown value)", x10);
        $display("  x5   = 0x%08h  (LED periph addr)", x5);
        $display("  sp   = 0x%08h", x2);
        $display("  LEDs = 0x%02h", leds);

        $display("\n=== Key checks after 210 cycles ===");
        check32(x5, 32'h204, "x5 (LED periph addr 0x204)");

        $display("\n=== Simulation complete ===\n");
        $finish;
    end
endmodule