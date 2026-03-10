`timescale 1ns / 1ps

module RegisterFile (
    input clk,
    input rst,
    input WriteEnable,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] WriteData,
    output reg [31:0] ReadData1,
    output reg [31:0] ReadData2
);

    reg [31:0] regs [31:0];
    integer i;

    //Synchronous write and reset
    always @(posedge clk) begin
        //Clear all registers on reset
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end else begin
            //Write only if enabled and destination is not x0
            if (WriteEnable && (rd != 5'b0))
                regs[rd] <= WriteData;
        end
    end

    //Asynchronous reads
    reg [31:0] ReadData1, ReadData2;

    always @(*) begin
        if (rs1 == 5'b0)
            ReadData1 = 32'b0;
        else
            ReadData1 = regs[rs1];
    end

    always @(*) begin
        if(rs2==5'b0)
            ReadData2=32'b0;
        else
            ReadData2=regs[rs2];
    end

endmodule