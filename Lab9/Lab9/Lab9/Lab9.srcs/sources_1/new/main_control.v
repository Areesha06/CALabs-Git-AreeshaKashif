`timescale 1ns / 1ps

module main_control (
    input  wire [6:0] opcode,
    output reg RegWrite,
    output reg ALUSrc,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg Branch,
    output reg [1:0] ALUOp
);

    localparam R_TYPE  = 7'b0110011;  // ADD, SUB, SLL, SRL, AND, OR, XOR
    localparam I_ALU   = 7'b0010011;  // ADDI and I types
    localparam LOAD    = 7'b0000011;  // LW, LH, LB
    localparam STORE   = 7'b0100011;  // SW, SH, SB
    localparam BRANCH  = 7'b1100011;  // BEQ

    always @(*) begin
        RegWrite = 1'b0;
        ALUSrc   = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemtoReg = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 2'b00;

        case (opcode)

            // R-type: ADD, SUB, SLL, SRL, AND, OR, XOR
            //  RegWrite=1  ALUSrc=0, MemRead=0   MemWrite=0, MemtoReg=0  Branch=0, ALUOp=10 (ALU control decodes funct3/funct7)

            R_TYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b10;
            end

            // I-type ALU: ADDI
            // RegWrite=1  ALUSrc=1, MemRead=0 MemWrite=0 MemtoReg=0  Branch=0 ALUOp=11 (ALU control decodes funct3; funct7 ignored)
            
            I_ALU: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b11;
            end

            
            // Load: LW, LH, LB
            //   RegWrite=1  ALUSrc=1 MemRead=1 MemWrite=0 MemtoReg=1  Branch=0 ALUOp=00 (ADD for address computation)
            LOAD: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemRead  = 1'b1;
                MemWrite = 1'b0;
                MemtoReg = 1'b1;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end

            // Store: SW, SH, SB
            // RegWrite=0  ALUSrc=1 (base + imm address) MemRead=0 MemWrite=1 MemtoReg=X  Branch=0 ALUOp=00 (ADD for address computation)
            STORE: begin
                RegWrite = 1'b0;
                ALUSrc   = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b1;
                MemtoReg = 1'b0;   // dont care set to 0
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end

            // Branch: BEQ
            // RegWrite=0  ALUSrc=0 MemRead=0   MemWrite=0 MemtoReg=X  Branch=1 ALUOp=01 (SUB for comparison)
            BRANCH: begin
                RegWrite = 1'b0;
                ALUSrc   = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;  // dont care set to 0
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end
            default: begin
                RegWrite = 1'b0;
                ALUSrc   = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end
        endcase
    end

endmodule