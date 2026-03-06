`timescale 1ns / 1ps

module top_rf_alu (
    input clk,           // clock
    input rst,           // reset button
    input  [3:0] sw,     // switch inputs 
    output [15:0] leds  // 16 LEDs showing FSM state and ALU result
);

    // Pass all switches through the switch interface to clean them up
    wire [3:0] sw_clean;

    switch sw_inst (
        .clk     (clk),
        .sw_raw  (sw),
        .sw_clean(sw_clean)
    );

    wire WE;
    wire [4:0] rs1, rs2, rd;
    wire [31:0] WriteData;
    wire [3:0]  ALUControl;
    wire [4:0] state;

    wire [31:0] ReadData1;
    wire [31:0] ReadData2;
    wire [31:0] ALU_Result;
    wire ALU_Zero;

    // Once FSM reaches DONE state, switches take over ALU operation select
    // Otherwise the FSM drives ALUControl itself
    wire [3:0] alu_op;
    assign alu_op = (state == 5'd14) ? {1'b0, sw_clean[2:0]} : ALUControl;

    // Instantiate FSM
    FSM fsm_inst (
        .clk (clk),
        .rst  (rst),
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
        .ReadData2 (ReadData2)
    );

    // Instantiate ALU
    alu alu_inst (
        .A  (ReadData1),
        .B  (ReadData2),
        .ALUControl (alu_op),
        .ALUResult (ALU_Result),
        .Zero (ALU_Zero)
    );

    // Instantiate led
    led led_inst (
        .fsm_state (state),
        .alu_low_bits(ALU_Result[7:0]),
        .alu_zero (ALU_Zero),
        .leds (leds)
    );

endmodule