//`timescale 1ns / 1ps
//module RegisterFile (
//    input  wire        clk,
//    input  wire        rst,
//    input  wire        WriteEnable,
//    input  wire [4:0]  rs1,
//    input  wire [4:0]  rs2,
//    input  wire [4:0]  rd,
//    input  wire [31:0] WriteData,
//    output reg  [31:0] ReadData1,
//    output reg  [31:0] ReadData2
//);
//    reg [31:0] regs [31:0];
//    integer i;

//    always @(posedge clk) begin
//        if (rst) begin
//            for (i = 0; i < 32; i = i + 1)
//                regs[i] <= 32'b0;
//        end else begin
//            if (WriteEnable && (rd != 5'b0))
//                regs[rd] <= WriteData;
//        end
//    end

//    always @(*) begin
//        ReadData1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
//    end
//    always @(*) begin
//        ReadData2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];
//    end
//endmodule

`timescale 1ns / 1ps

module RegisterFile (
    input  wire        clk,
    input  wire        rst,
    input  wire        WriteEnable,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [31:0] WriteData,
    output wire [31:0] ReadData1,
    output wire [31:0] ReadData2
);
    (* ram_style = "distributed" *) reg [31:0] regs [1:31];

    integer i;
    initial begin
        for (i = 1; i <= 31; i = i + 1)
            regs[i] = 32'b0;
    end

    // Write port - single write per cycle, clean RAM inference.
    // rst clears all registers synchronously when asserted.
    always @(posedge clk) begin
        if (rst) begin
            regs[1]  <= 0; regs[2]  <= 0; regs[3]  <= 0; regs[4]  <= 0;
            regs[5]  <= 0; regs[6]  <= 0; regs[7]  <= 0; regs[8]  <= 0;
            regs[9]  <= 0; regs[10] <= 0; regs[11] <= 0; regs[12] <= 0;
            regs[13] <= 0; regs[14] <= 0; regs[15] <= 0; regs[16] <= 0;
            regs[17] <= 0; regs[18] <= 0; regs[19] <= 0; regs[20] <= 0;
            regs[21] <= 0; regs[22] <= 0; regs[23] <= 0; regs[24] <= 0;
            regs[25] <= 0; regs[26] <= 0; regs[27] <= 0; regs[28] <= 0;
            regs[29] <= 0; regs[30] <= 0; regs[31] <= 0;
        end else begin
            if (WriteEnable && rd != 5'b0)
                regs[rd] <= WriteData;
        end
    end

    // Read ports - combinational, x0 hardwired to 0.
    assign ReadData1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
    assign ReadData2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];

endmodule