`timescale 1ns / 1ps

module RF_ALU_FSM (
    input  clk,
    input  rst,

    output [31:0] ReadData1,    // RF read port 1 
    output [31:0] ReadData2,    // RF read port 2 
    output [31:0] ALU_Result,   // ALU output
    output        ALU_Zero,     // ALU zero flag
    output [4:0]  state         // FSM current state
);

    wire        WE;
    wire [4:0]  rs1, rs2, rd;
    wire [31:0] WriteData;
    wire [3:0]  ALUControl;

    // Instantiate FSM
    FSM fsm_inst (
        .clk (clk),
        .rst (rst),
        .ALU_Zero (ALU_Zero),
        .ALU_Result (ALU_Result),
        .WE (WE),
        .rs1 (rs1),
        .rs2 (rs2),
        .rd (rd),
        .WriteData (WriteData),
        .ALUControl (ALUControl),
        .state (state)
    );

    // Instantiate Register File
    RegisterFile rf_inst (
        .clk (clk),
        .rst (rst),
        .WriteEnable(WE),
        .rs1 (rs1),
        .rs2 (rs2),
        .rd (rd),
        .WriteData (WriteData),
        .ReadData1 (ReadData1),
        .ReadData2  (ReadData2)
    );

    // Instantiate ALU
    alu alu_inst (
        .A (ReadData1),
        .B (ReadData2),
        .ALUControl (ALUControl),
        .ALUResult (ALU_Result),
        .Zero (ALU_Zero)
    );

endmodule