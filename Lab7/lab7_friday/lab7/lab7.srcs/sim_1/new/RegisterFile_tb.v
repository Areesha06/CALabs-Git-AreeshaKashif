`timescale 1ns / 1ps

module RegisterFile_tb;

    // DUT Inputs
    reg clk;
    reg rst;
    reg WriteEnable;
    reg [4:0]  rs1, rs2, rd;
    reg [31:0] WriteData;

    //DUT Outputs
    wire [31:0] ReadData1, ReadData2;

    //Instantiate DUT
    RegisterFile uut (
        .clk(clk), .rst(rst),
        .WriteEnable(WriteEnable),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    //10 ns clock period
    initial clk = 0;
    always #5 clk = ~clk;

    //apply a write, then check reads on next cycle
    task write_reg;
        input [4:0]  addr;
        input [31:0] data;
        begin
            rd = addr; WriteData = data; WriteEnable = 1;
            @(posedge clk); #1;
            WriteEnable = 0;
        end
    endtask

    //TEST CASES
    
    integer pass_count;
    integer fail_count;

    task check;
        input [31:0] got;
        input [31:0] expected;
        input [63:0] test_num;
        begin
            if (got === expected) begin
                $display("PASS [Test %0d]: got 0x%08h", test_num, got);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL [Test %0d]: expected 0x%08h, got 0x%08h",
                         test_num, expected, got);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0; fail_count = 0;

        // Initialise inputs
        rst = 1; WriteEnable = 0;
        rs1 = 0; rs2 = 0; rd = 0; WriteData = 0;
        @(posedge clk); #1;
        rst = 0;

        write_reg(5'd5, 32'hDEADBEEF);
        rs1 = 5'd5;
        #1;
        check(ReadData1, 32'hDEADBEEF, 1);

        write_reg(5'd0, 32'hFFFFFFFF);
        rs1 = 5'd0;
        #1;
        check(ReadData1, 32'h00000000, 2);

        write_reg(5'd7, 32'hA5A5A5A5);
        rs1 = 5'd5; rs2 = 5'd7;
        #1;
        check(ReadData1, 32'hDEADBEEF, 3);
        check(ReadData2, 32'hA5A5A5A5, 3);

        write_reg(5'd5, 32'h12345678);
        rs1 = 5'd5;
        #1;
        check(ReadData1, 32'h12345678, 4);
        
        rst = 1;
        @(posedge clk); #1;
        rst = 0;
        rs1 = 5'd5; rs2 = 5'd7;
        #1;
        check(ReadData1, 32'h00000000, 5);
        check(ReadData2, 32'h00000000, 5);

        // Summary
        $display("------------------------------");
        $display("Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("------------------------------");
        $finish;
    end

    // Dump waveforms
    initial begin
        $dumpfile("RegisterFile_tb.vcd");
        $dumpvars(0, RegisterFile_tb);
    end

endmodule