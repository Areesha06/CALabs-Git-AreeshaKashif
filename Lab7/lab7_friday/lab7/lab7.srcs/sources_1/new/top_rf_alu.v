`timescale 1ns / 1ps

module top_rf_alu (
    input clk,
    input rst,
    input btn,         
    input  [3:0] sw,
    output [15:0] leds
);
    wire [3:0] sw_clean;
    wire btn_clean;     

    switch sw_inst (
        .clk     (clk),
        .sw_raw  (sw),
        .sw_clean(sw_clean)
    );


    debouncer btn_db (
        .clk  (clk),
        .noisy(btn),
        .clean(btn_clean)
    );

    reg btn_prev;
    always @(posedge clk) btn_prev <= btn_clean;
    wire btn_pulse = btn_clean & ~btn_prev;

    wire WE;
    wire [4:0] rs1, rs2, rd;
    wire [31:0] WriteData;
    wire [3:0]  ALUControl;
    wire [4:0] state;
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;
    wire [31:0] ALU_Result;
    wire ALU_Zero;

    reg [31:0] ALU_Result_reg;
    always @(posedge clk) ALU_Result_reg <= ALU_Result;

    wire [3:0] alu_op;
    wire [4:0] rs1_mux, rs2_mux;
    wire [4:0] rd_mux;      
    wire we_mux;           

    assign alu_op  = (state == 5'd14) ? {1'b0, sw_clean[2:0]} : ALUControl;
    assign rs1_mux = (state == 5'd14) ? {1'b0, sw_clean[3:0]} : rs1;
    assign rs2_mux = (state == 5'd14) ? 5'd2                  : rs2;
    assign rd_mux  = (state == 5'd14) ? {1'b0, sw_clean[3:0]} : rd;    
    assign we_mux  = (state == 5'd14) ? btn_pulse              : WE;   

    FSM fsm_inst (
        .clk        (clk),
        .rst        (rst),
        .ALU_Zero   (ALU_Zero),
        .ALU_Result (ALU_Result),
        .WE         (WE),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .WriteData  (WriteData),
        .ALUControl (ALUControl),
        .state      (state)
    );

    RegisterFile rf_inst (
        .clk        (clk),
        .rst        (rst),
        .WriteEnable(we_mux),           
        .rs1        (rs1_mux),
        .rs2        (rs2_mux),
        .rd         (rd_mux),          
        .WriteData  (state == 5'd14 ? ALU_Result_reg : WriteData),
        .ReadData1  (ReadData1),
        .ReadData2  (ReadData2)
    );

    alu alu_inst (
        .A          (ReadData1),
        .B          (ReadData2),
        .ALUControl (alu_op),
        .ALUResult  (ALU_Result),
        .Zero       (ALU_Zero)
    );

    led led_inst (
        .fsm_state   (state),
        .alu_low_bits(ALU_Result[7:0]),
        .alu_zero    (ALU_Zero),
        .leds        (leds)
    );
endmodule