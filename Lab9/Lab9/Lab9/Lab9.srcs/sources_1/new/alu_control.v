`timescale 1ns / 1ps



// ALUOp  (from Main Control):
//   00 = ADD  (Load / Store address calculation)
//   01 = SUB  (Branch comparison)
//   10 = R-type (decode funct3 + funct7)
//   11 = I-type ALU (decode funct3 only; funct7 ignored)


module alu_control (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] ALUControl
);

    // ALUControl output codes
    localparam ALU_AND = 4'b0000;
    localparam ALU_OR  = 4'b0001;
    localparam ALU_ADD = 4'b0010;
    localparam ALU_XOR = 4'b0011;
    localparam ALU_SUB = 4'b0110;
    localparam ALU_SLL = 4'b0100;
    localparam ALU_SRL = 4'b0101;
    localparam ALU_NOP = 4'b1111;

    always @(*) begin
        ALUControl = ALU_NOP; // default

        case (ALUOp)
        
            2'b00: ALUControl = ALU_ADD; //used for load store

            2'b01: ALUControl = ALU_SUB; // used for BEQ

            2'b10: begin
                case (funct3)
                    3'b000: ALUControl = funct7[5] ? ALU_SUB : ALU_ADD;
                    3'b001: ALUControl = ALU_SLL;
                    3'b101: ALUControl = ALU_SRL; // only SRL (funct7[5]=0)
                    3'b110: ALUControl = ALU_OR;
                    3'b111: ALUControl = ALU_AND;
                    3'b100: ALUControl = ALU_XOR;
                    default: ALUControl = ALU_NOP;
                endcase
            end

            2'b11: begin
                case (funct3)
                    3'b000: ALUControl = ALU_ADD; // ADDI
                    3'b001: ALUControl = ALU_SLL; // SLLI
                    3'b101: ALUControl = ALU_SRL; // SRLI
                    3'b110: ALUControl = ALU_OR;  // ORI
                    3'b111: ALUControl = ALU_AND; // ANDI
                    3'b100: ALUControl = ALU_XOR; // XORI
                    default: ALUControl = ALU_NOP;
                endcase
            end

            default: ALUControl = ALU_NOP;
        endcase
    end

endmodule
