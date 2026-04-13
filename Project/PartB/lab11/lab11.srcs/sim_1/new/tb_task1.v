`timescale 1ns / 1ps

module tb_Task1;

    reg clk;
    reg reset;

    initial clk = 0;
    always #5 clk = ~clk;   // 10 ns period -> 100 MHz

    wire [31:0] pc;
    wire [31:0] pc_plus4;
    wire [31:0] branch_target;
    wire [31:0] pc_next;

    // Control
    reg  PCSrc;

    // Immediate generation
    reg  [31:0] inst;
    wire [31:0] imm_out;

    ProgramCounter uPC (
        .clk     (clk),
        .reset   (reset),
        .pc_next (pc_next),
        .pc      (pc)
    );

    pcAdder uPCAdder (
        .pc      (pc),
        .pc_plus4(pc_plus4)
    );

    branchAdder uBranchAdder (
        .pc            (pc),
        .imm           (imm_out),
        .branch_target (branch_target)
    );

    mux2 #(.WIDTH(32)) uMux (
        .in0 (pc_plus4),
        .in1 (branch_target),
        .sel (PCSrc),
        .out (pc_next)
    );

    immGen uImmGen (
        .inst    (inst),
        .imm_out (imm_out)
    );

    task check;
        input [31:0] actual;
        input [31:0] expected;
        input [127:0] label;
        begin
            if (actual === expected)
                $display("PASS  %s : got 0x%08h", label, actual);
            else
                $display("FAIL  %s : expected 0x%08h, got 0x%08h", label, expected, actual);
        end
    endtask

    
    integer i;

    initial begin
        // Reset
        reset  = 1;
        PCSrc  = 0;
        inst   = 32'b0;
        @(posedge clk); #1;
        reset  = 0;

        $display("\n--- Sequential PC increment (PCSrc = 0) ---");
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge clk); #1;
            $display("  PC = 0x%08h  (expected 0x%08h)", pc, (i+1)*4);
        end
        check(pc, 32'd20, "PC after 5 increments");

        //    Use ADDI x0,x0,8  
        $display("\n--- Branch taken (PCSrc = 1) ---");
        inst   = {12'd8, 5'd0, 3'b000, 5'd0, 7'b0010011}; // ADDI imm=8
        PCSrc  = 1;
        @(posedge clk); #1;
        $display("  PC = 0x%08h  branch_target was 0x%08h", pc, 32'd36);
        check(pc, 32'd36, "PC after branch (20 + 8<<1)");

        PCSrc = 0;
        @(posedge clk); #1;
        check(pc, 32'd40, "PC sequential after branch");

        //    ADDI x1, x2, -5  
        $display("\n--- Immediate Generation ---");
        inst = {12'hFFB, 5'd2, 3'b000, 5'd1, 7'b0010011}; // ADDI x1,x2,-5
        #1;
        check(imm_out, 32'hFFFFFFFB, "I-type imm (-5)");

        // I-type positive: ADDI x3,x4,100
        inst = {12'd100, 5'd4, 3'b000, 5'd3, 7'b0010011};
        #1;
        check(imm_out, 32'd100, "I-type imm (+100)");

        // LOAD: LW x5, 12(x6)
        inst = {12'd12, 5'd6, 3'b010, 5'd5, 7'b0000011};
        #1;
        check(imm_out, 32'd12, "I-type LOAD imm (12)");

        //    SW x7, -3(x8)  
        inst = {7'h7F, 5'd7, 5'd8, 3'b010, 5'h1D, 7'b0100011}; // SW imm=-3
        #1;
        check(imm_out, 32'hFFFFFFFD, "S-type imm (-3)");

        // SW x9, 20(x10)
        inst = {7'b0000000, 5'd9, 5'd10, 3'b010, 5'b10100, 7'b0100011};
        #1;
        check(imm_out, 32'd20, "S-type imm (+20)");

        //    BEQ x1,x2, +16  
        inst = {1'b0, 6'b000000, 5'd2, 5'd1, 3'b000, 4'b1000, 1'b0, 7'b1100011};
        #1;
        check(imm_out, 32'd16, "B-type imm (+16)");

        // BNE with negative offset: offset = -8
        inst = {1'b1, 6'b111111, 5'd2, 5'd1, 3'b001, 4'b1100, 1'b1, 7'b1100011};
        #1;
        check(imm_out, 32'hFFFFFFF8, "B-type imm (-8)");

        $display("\n--- Simulation complete ---\n");
        $finish;
    end

    // Optional waveform dump
    initial begin
        $dumpfile("tb_Task1.vcd");
        $dumpvars(0, tb_Task1);
    end

endmodule