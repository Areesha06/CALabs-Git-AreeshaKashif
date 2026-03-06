`timescale 1ns / 1ps

module RF_ALU_FSM_tb;

    // Clock and reset
    reg clk, rst;
    initial clk = 0;
    always #5 clk = ~clk;

    // DUT outputs
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;
    wire [31:0] ALU_Result;
    wire ALU_Zero;
    wire [4:0]  state;

    //Instantiate DUT
    RF_ALU_FSM dut (
        .clk (clk),
        .rst (rst),
        .ReadData1 (ReadData1),
        .ReadData2 (ReadData2),
        .ALU_Result(ALU_Result),
        .ALU_Zero (ALU_Zero),
        .state (state)
    );

    integer pass_count;
    integer fail_count;

    initial begin
        pass_count = 0;
        fail_count = 0;

        //Hold reset high for 2 cycles to clear all registers
        rst = 1;
        @(posedge clk);
        @(posedge clk);
        #1;
        rst = 0;
        
        //TEST CASES

        //Wait for FSM to finish all state transitions
        repeat(16) @(posedge clk);
        #1;
        
        force dut.rs1 = 5'd4; #1;
        if (ReadData1 === 32'h11111111)
            begin $display("PASS [ADD  x4]: 0x%08h", ReadData1); pass_count = pass_count + 1; end
        else
            begin $display("FAIL [ADD  x4]: expected 0x11111111  got 0x%08h", ReadData1); fail_count = fail_count + 1; end

        force dut.rs1 = 5'd5; #1;
        if (ReadData1 === 32'h0F0F0F0F)
            begin $display("PASS [SUB  x5]: 0x%08h", ReadData1); pass_count = pass_count + 1; end
        else
            begin $display("FAIL [SUB  x5]: expected 0x0f0f0f0f  got 0x%08h", ReadData1); fail_count = fail_count + 1; end

        force dut.rs1 = 5'd6; #1;
        if (ReadData1 === 32'h00000000)
            begin $display("PASS [AND  x6]: 0x%08h", ReadData1); pass_count = pass_count + 1; end
        else
            begin $display("FAIL [AND  x6]: expected 0x00000000  got 0x%08h", ReadData1); fail_count = fail_count + 1; end

        force dut.rs1 = 5'd7; #1;
        if (ReadData1 === 32'h11111111)
            begin $display("PASS [OR   x7]: 0x%08h", ReadData1); pass_count = pass_count + 1; end
        else
            begin $display("FAIL [OR   x7]: expected 0x11111111  got 0x%08h", ReadData1); fail_count = fail_count + 1; end

        force dut.rs1 = 5'd8; #1;
        if (ReadData1 === 32'h11111111)
            begin $display("PASS [XOR  x8]: 0x%08h", ReadData1); pass_count = pass_count + 1; end
        else
            begin $display("FAIL [XOR  x8]: expected 0x11111111  got 0x%08h", ReadData1); fail_count = fail_count + 1; end

        force dut.rs1 = 5'd9; #1;
        if (ReadData1 === 32'h02020200)
            begin $display("PASS [SLL  x9]: 0x%08h", ReadData1); pass_count = pass_count + 1; end
        else
            begin $display("FAIL [SLL  x9]: expected 0x02020200  got 0x%08h", ReadData1); fail_count = fail_count + 1; end

        force dut.rs1 = 5'd10; #1;
        if (ReadData1 === 32'h00808080)
            begin $display("PASS [SRL x10]: 0x%08h", ReadData1); pass_count = pass_count + 1; end
        else
            begin $display("FAIL [SRL x10]: expected 0x00808080  got 0x%08h", ReadData1); fail_count = fail_count + 1; end

        force dut.rs1 = 5'd11; #1;
        if (ReadData1 === 32'h00000001)
            begin $display("PASS [BEQ x11]: 0x%08h", ReadData1); pass_count = pass_count + 1; end
        else
            begin $display("FAIL [BEQ x11]: expected 0x00000001  got 0x%08h", ReadData1); fail_count = fail_count + 1; end

        force dut.rs1 = 5'd12; #1;
        if (ReadData1 === 32'hABCDABCD)
            begin $display("PASS [RAW x12]: 0x%08h", ReadData1); pass_count = pass_count + 1; end
        else
            begin $display("FAIL [RAW x12]: expected 0xabcdabcd  got 0x%08h", ReadData1); fail_count = fail_count + 1; end

        force dut.rs1 = 5'd0; #1;
        if (ReadData1 === 32'h00000000)
            begin $display("PASS [x0 = 0 ]: 0x%08h", ReadData1); pass_count = pass_count + 1; end
        else
            begin $display("FAIL [x0 = 0 ]: expected 0x00000000  got 0x%08h", ReadData1); fail_count = fail_count + 1; end

        // Release force so DUT returns to normal
        release dut.rs1;

        $display("-------------------------------");
        $display("Total: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("-------------------------------");
        $finish;
    end

    //Dump waveforms
    initial begin
        $dumpfile("RF_ALU_FSM_tb.vcd");
        $dumpvars(0, RF_ALU_FSM_tb);
    end

    //Print state and ALU result every clock cycle
    always @(posedge clk) begin
        if (!rst)
            $display("t=%0t  state=%0d  ALU_Result=0x%08h  Zero=%b",
                     $time, state, ALU_Result, ALU_Zero);
    end

endmodule