`timescale 1ns / 1ps
// ALUOp (from Main Control):
//   00 = ADD  (Load / Store)
//   01 = Branch comparison
//   10 = R-type (funct3 + funct7)
//   11 = I-type ALU (funct3 only)
//
// Task B additions:
//   SLTI : ALUOp=11, funct3=010  -> ALU_SLT  (set less than immediate)           [Instruction 1]
//   SRA  : ALUOp=10, funct3=101, funct7[5]=1 -> ALU_SRA (shift right arithmetic) [Instruction 2]
//   BLTU : ALUOp=01, funct3=110  -> ALU_SLTU (branch less than unsigned)         [Instruction 3]

module alu_control (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] ALUControl
);
    localparam ALU_AND  = 4'b0000;
    localparam ALU_OR   = 4'b0001;
    localparam ALU_ADD  = 4'b0010;
    localparam ALU_XOR  = 4'b0011;
    localparam ALU_SLL  = 4'b0100;
    localparam ALU_SRL  = 4'b0101;
    localparam ALU_SUB  = 4'b0110;
    localparam ALU_SLT  = 4'b0111;
    localparam ALU_SRA  = 4'b1000; 
    localparam ALU_SLTU = 4'b1001;  
    localparam ALU_NOP  = 4'b1111;

    always @(*) begin
        ALUControl = ALU_NOP;
        case (ALUOp)

            // Load / Store: always ADD
            2'b00: ALUControl = ALU_ADD;

            // Branch: choose comparison based on funct3
            2'b01: begin
                case (funct3)
                    3'b000: ALUControl = ALU_SUB;   // BEQ
                    3'b001: ALUControl = ALU_SUB;   // BNE
                    3'b110: ALUControl = ALU_SLTU;  // BLTU
                    default: ALUControl = ALU_SUB;
                endcase
            end

            // R-type: funct3 + funct7[5]
            2'b10: begin
                case (funct3)
                    3'b000: ALUControl = funct7[5] ? ALU_SUB : ALU_ADD;
                    3'b001: ALUControl = ALU_SLL;
                    3'b101: ALUControl = funct7[5] ? ALU_SRA : ALU_SRL; // SRA 
                    3'b110: ALUControl = ALU_OR;
                    3'b111: ALUControl = ALU_AND;
                    3'b100: ALUControl = ALU_XOR;
                    3'b010: ALUControl = ALU_SLT;
                    default: ALUControl = ALU_NOP;
                endcase
            end

            // I-type ALU: funct3 only
            2'b11: begin
                case (funct3)
                    3'b000: ALUControl = ALU_ADD;  // ADDI
                    3'b001: ALUControl = ALU_SLL;  // SLLI
                    3'b010: ALUControl = ALU_SLT;  // SLTI 
                    3'b101: ALUControl = funct7[5] ? ALU_SRA : ALU_SRL; // SRAI/SRLI
                    3'b110: ALUControl = ALU_OR;   // ORI
                    3'b111: ALUControl = ALU_AND;  // ANDI
                    3'b100: ALUControl = ALU_XOR;  // XORI
                    default: ALUControl = ALU_NOP;
                endcase
            end

            default: ALUControl = ALU_NOP;
        endcase
    end
endmodule