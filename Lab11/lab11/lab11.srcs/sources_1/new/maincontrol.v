`timescale 1ns / 1ps
module main_control (
    input  wire [6:0] opcode,
    output reg        RegWrite,
    output reg        ALUSrc,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        MemtoReg,
    output reg        Branch,
    output reg  [1:0] ALUOp
);
    localparam R_TYPE = 7'b0110011;
    localparam I_ALU  = 7'b0010011;
    localparam LOAD   = 7'b0000011;
    localparam STORE  = 7'b0100011;
    localparam BRANCH = 7'b1100011;
    localparam JAL    = 7'b1101111;
    localparam JALR   = 7'b1100111;
    localparam LUI    = 7'b0110111;
    localparam AUIPC  = 7'b0010111;

    always @(*) begin
        RegWrite = 1'b0; ALUSrc = 1'b0; MemRead  = 1'b0;
        MemWrite = 1'b0; MemtoReg= 1'b0; Branch  = 1'b0;
        ALUOp   = 2'b00;

        case (opcode)
            R_TYPE: begin
                RegWrite=1; ALUSrc=0; MemRead=0;
                MemWrite=0; MemtoReg=0; Branch=0; ALUOp=2'b10;
            end
            I_ALU: begin
                RegWrite=1; ALUSrc=1; MemRead=0;
                MemWrite=0; MemtoReg=0; Branch=0; ALUOp=2'b11;
            end
            LOAD: begin
                RegWrite=1; ALUSrc=1; MemRead=1;
                MemWrite=0; MemtoReg=1; Branch=0; ALUOp=2'b00;
            end
            STORE: begin
                RegWrite=0; ALUSrc=1; MemRead=0;
                MemWrite=1; MemtoReg=0; Branch=0; ALUOp=2'b00;
            end
            BRANCH: begin
                RegWrite=0; ALUSrc=0; MemRead=0;
                MemWrite=0; MemtoReg=0; Branch=1; ALUOp=2'b01;
            end
            JAL: begin
                RegWrite=1; ALUSrc=0; MemRead=0;
                MemWrite=0; MemtoReg=0; Branch=0; ALUOp=2'b00;
            end
            JALR: begin
                RegWrite=1; ALUSrc=1; MemRead=0;
                MemWrite=0; MemtoReg=0; Branch=0; ALUOp=2'b00;
            end
            LUI: begin
                RegWrite=1; ALUSrc=1; MemRead=0;
                MemWrite=0; MemtoReg=0; Branch=0; ALUOp=2'b10;
            end
            AUIPC: begin
                RegWrite=1; ALUSrc=1; MemRead=0;
                MemWrite=0; MemtoReg=0; Branch=0; ALUOp=2'b10;
            end
            default: begin
                RegWrite=0; ALUSrc=0; MemRead=0;
                MemWrite=0; MemtoReg=0; Branch=0; ALUOp=2'b00;
            end
        endcase
    end
endmodule