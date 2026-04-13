`timescale 1ns / 1ps

module immGen (
    input  wire [31:0] inst,
    output reg  [31:0] imm_out
);

    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            // I-type: LOAD, OP-IMM, JALR
            7'b0000011,          // LOAD
            7'b0010011,          // OP-IMM (ADDI, SLTI, etc.)
            7'b1100111:          // JALR
                imm_out = {{20{inst[31]}}, inst[31:20]};

            // S-type: STORE
            7'b0100011:
                imm_out = {{20{inst[31]}}, inst[31:25], inst[11:7]};

            // B-type: BRANCH
            7'b1100011:
                imm_out = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};

            // U-type: LUI, AUIPC  (upper immediate)
            7'b0110111,          // LUI
            7'b0010111:          // AUIPC
                imm_out = {inst[31:12], 12'b0};

            // J-type: JAL
            7'b1101111:
                imm_out = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};

            default:
                imm_out = 32'b0;
        endcase
    end

endmodule