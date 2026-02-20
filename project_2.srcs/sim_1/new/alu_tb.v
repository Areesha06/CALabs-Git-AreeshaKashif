`timescale 1ns/1ps

module alu_tb;

    reg  [31:0] A;
    reg  [31:0] B;
    reg  [3:0]  ALUControl;
    wire [31:0] ALUResult;
    wire Zero;

    alu uut (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    initial begin
        
        A = 32'b00000000000000000000000000000100;

        B = 32'b00000000000000000000000000000101;


        // ADD
        ALUControl = 4'b0000; #10;

        // SUB
        ALUControl = 4'b0001; #10;

        // AND
        ALUControl = 4'b0010; #10;

        // OR
        ALUControl = 4'b0011; #10;

        // XOR
        ALUControl = 4'b0100; #10;

        // SLL
        ALUControl = 4'b0101; #10;

        // SRL
        ALUControl = 4'b0110; #10;

        // BEQ (equal test)
        A = 32'b00000000000000000000000000000100;
        B = 32'b00000000000000000000000000000100;
        ALUControl = 4'b0111; #10;

    end

endmodule
