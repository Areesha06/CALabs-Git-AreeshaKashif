`timescale 1ns / 1ps
module tb_TopLevel;
    reg        clk, reset;
    wire [6:0] seg;
    wire [3:0] an;

    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz, 10ns period

    TopLevelProcessor #(.DIV(4)) uDUT (
        .clk  (clk),
        .reset(reset),
        .seg  (seg),
        .an   (an)
    );

    wire [31:0] pc    = uDUT.pc;
    wire [31:0] x2    = uDUT.uRF.regs[2];
    wire [31:0] x6    = uDUT.uRF.regs[6];
    wire [31:0] x7    = uDUT.uRF.regs[7];
    wire [31:0] x10   = uDUT.uRF.regs[10];
    wire [31:0] s0  = uDUT.uRF.regs[8];   // s0 = x8
    wire [31:0] x15 = uDUT.uRF.regs[15];  // visible countdown value
    wire [31:0] instr = uDUT.instruction;

    // 1 slow cycle = DIV*2 fast cycles = 4*2*10ns = 80ns
    // Use this task to wait one slow clock cycle
    task wait_slow_cycle;
        repeat(8) @(posedge clk); // DIV*2 = 8 fast edges per slow cycle
    endtask

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

        // ---- RESET ----
        // Change reset block to:
        reset = 1;
        repeat(20) @(posedge clk);   // hold reset longer
        reset = 0;
        // Change your fast clock trace display to:
        $display("%-6s %-10s %-10s %-4s %-4s %-10s %-10s",
                 "Cycle","PC","x7","rd","WE","WData","ALUres");
        for (i = 0; i < 20; i = i + 1) begin
            @(posedge clk);
            $display("%-6d 0x%08h 0x%08h %2d   %b   0x%08h 0x%08h",
                     i, pc,
                     uDUT.uRF.regs[7],
                     uDUT.rd_addr,
                     uDUT.RegWrite,
                     uDUT.wb_final,
                     uDUT.alu_result);
        end
                   // settle after reset  // settle

        // ---- Init phase ----
        $display("\n=== Init phase (first 10 slow cycles) ===");
        $display("%-6s %-10s %-10s %-10s %-10s",
                 "Cycle","PC","Instr","x6","x7");
        for (i = 0; i < 10; i = i + 1) begin
            wait_slow_cycle;
            $display("%-6d 0x%08h 0x%08h 0x%08h 0x%08h",
                     i, pc, instr, x6, x7);
        end

        $display("\n=== Checks after init ===");
        check32(x6, 32'h200, "x6  (switch addr = 0x200)");
        check32(x7, 32'd5,   "x7  (hardcoded value = 5)");
        check32(x2, 32'd511, "sp  (stack ptr = 511)");

        $display("\n=== Data memory check ===");
        if (uDUT.uDMem.mem[128] === 32'd5)
            $display("  PASS  DataMemory[0x200] = 5");
        else
            $display("  FAIL  DataMemory[0x200] = 0x%08h (expected 5)",
                     uDUT.uDMem.mem[128]);

        // ---- Countdown phase ----
        $display("%-6s %-10s %-10s %-10s %-10s",
         "Cycle","PC","x10(a0)","s0(x8)","x15");
        for (i = 0; i < 500; i = i + 1) begin
            wait_slow_cycle;
            $display("%-6d 0x%08h 0x%08h 0x%08h 0x%08h",
                     i, pc, x10,
                     uDUT.uRF.regs[8],
                     uDUT.uRF.regs[15]);
        end
        
        $display("\n=== Checks after countdown ===");
        check32(x10, 32'd5, "x10 (countdown started from 5)");

        $display("\n=== Simulation complete ===");
        $finish;
    end

    initial begin
        #500_000;
        $display("Timeout!");
        $finish;
    end
endmodule