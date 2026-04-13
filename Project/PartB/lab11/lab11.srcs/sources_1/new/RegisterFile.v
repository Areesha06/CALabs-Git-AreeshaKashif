`timescale 1ns / 1ps

module RegisterFile (
    input  wire clk,
    input  wire rst,
    input  wire WriteEnable,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [31:0] WriteData,
    output wire [31:0] ReadData1,  // changed to wire
    output wire [31:0] ReadData2
);
    (* ram_style = "distributed" *) reg [31:0] regs [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end else if (WriteEnable && (rd != 5'b0))
            regs[rd] <= WriteData;
    end

    // Async read � correct for distributed RAM, good for single-cycle
    assign ReadData1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
    assign ReadData2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];
endmodule