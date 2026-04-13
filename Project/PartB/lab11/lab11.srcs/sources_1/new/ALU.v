`timescale 1ns / 1ps
// ALU for single-cycle RISC-V processor
// Control codes:
//   4'b0000 = AND
//   4'b0001 = OR
//   4'b0010 = ADD
//   4'b0011 = XOR
//   4'b0100 = SLL
//   4'b0101 = SRL
//   4'b0110 = SUB
//   4'b0111 = SLT  (set less than)
//   4'b1000 = SRA  (shift right arithmetic)
//   4'b1001 = SLTU (set less than unsigned)    
//   4'b1111 = NOP / LUI passthrough (returns B)

module alu (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0]  ALUControl,
    output reg  [31:0] ALUResult,
    output wire Zero
);
    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResult = A & B;
            4'b0001: ALUResult = A | B;
            4'b0010: ALUResult = A + B;
            4'b0011: ALUResult = A ^ B;
            4'b0100: ALUResult = A << B[4:0];
            4'b0101: ALUResult = A >> B[4:0];
            4'b0110: ALUResult = A - B;
            4'b0111: ALUResult = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;  // SLT 
            4'b1000: ALUResult = $signed(A) >>> B[4:0];                       // SRA 
            4'b1001: ALUResult = (A < B) ? 32'd1 : 32'd0;                    // SLTU
            4'b1111: ALUResult = B;
            default: ALUResult = 32'b0;
        endcase
    end

    assign Zero = (ALUResult == 32'b0);
endmodule