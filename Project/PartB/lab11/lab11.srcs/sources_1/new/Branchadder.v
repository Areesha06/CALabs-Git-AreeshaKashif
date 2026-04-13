`timescale 1ns / 1ps


module branchAdder (
    input  wire [31:0] pc,
    input  wire [31:0] imm,       //sign extended immediate from immGen
    output wire [31:0] branch_target
);

    // Per RV32I spec: branch offset = imm << 1
    assign branch_target = pc + imm;

endmodule