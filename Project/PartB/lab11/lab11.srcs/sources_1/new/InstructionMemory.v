`timescale 1ns / 1ps
// Executes SLTI, SRA, BLTU in a loop
//
// The clock is divided (DIV=5000000 = ~10 Hz on 100MHz board),
// so each instruction executes roughly every 0.1 seconds
//
// SLTI and ADDI share the same opcode (I_ALU = 0010011) so the
// control unit output is the same
// Main control sees I-type opcode for both ADDI and
// SLTI. The distinction is in alu_control.v where funct3=010 maps to
// ALU_SLT instead of ALU_ADD
//
//
//
//   # Setup
//   addi x1, x0, 20       # x1 = 20
//   addi x2, x0, 8        # x2 = 8
//   addi x5, x0, 2        # x5 = shift amount = 2
//
//   # Test SLTI (I-type) - ctrl shows 195
//   slti x3, x1, 25       # x3 = (20 < 25) = 1  
//   slti x4, x1, 10       # x4 = (20 < 10) = 0 
//
//   # Test SRA (R-type) - ctrl shows 130
//   sra  x6, x1, x5       # x6 = 20 >> 2 = 5    - arithmetic shift
//   addi x7, x0, -16      # x7 = -16 (0xFFFFFFF0)
//   sra  x8, x7, x5       # x8 = -16 >> 2 = -4  - sign preserved
//
//   # Test BLTU (B-type) - ctrl shows 5
//   addi x9,  x0, 3       # x9  = 3
//   addi x10, x0, 7       # x10 = 7
//   bltu x9, x10, skip    # 3 < 7 unsigned = branch taken
//   addi x0, x0, 0        # NOP (skipped)
//   skip:
//   addi x11, x0, 1       # x11 = 1 (proof branch was taken)
//
//   # Loop back to show signals repeatedly
//   jal  x0, -52          # jump back to SLTI test

module instructionMemory (
    input  [31:0] instAddress,
    output reg [31:0] instruction
);
    (* rom_style = "block" *) reg [31:0] memory [0:30];

    always @(*) begin
        instruction = memory[instAddress[7:2]];
    end

    initial begin
        // -------------------------------------------------------
        // Setup (PC 0x00 - 0x08)
        // -------------------------------------------------------
        // PC 0x00: addi x1, x0, 20
        memory[0]  = 32'h01400093;
        // PC 0x04: addi x2, x0, 8
        memory[1]  = 32'h00800113;
        // PC 0x08: addi x5, x0, 2
        memory[2]  = 32'h00200293;

        // -------------------------------------------------------
        // SLTI tests (PC 0x0C - 0x10)
        // ctrl bundle = {1,1,0,0,0,0,1,1} = 195
        // Main control sees "I_ALU" = same ctrl signals.
        // alu_control distinguishes via funct3=010 = ALU_SLT.
        // -------------------------------------------------------
        // PC 0x0C: slti x3, x1, 25      funct3=010, imm=25
        //   encoding: imm[11:0]=000000011001, rs1=00001, funct3=010, rd=00011, op=0010011
        memory[3]  = 32'h0190A193;
        // PC 0x10: slti x4, x1, 10      funct3=010, imm=10
        memory[4]  = 32'h00A0A213;

        // -------------------------------------------------------
        // SRA tests (PC 0x14 - 0x1C)
        // ctrl bundle = {1,0,0,0,0,0,1,0} = 130
        // R-type: funct7=0100000, funct3=101
        // -------------------------------------------------------
        // PC 0x14: sra x6, x1, x5      (20 >> 2 = 5, positive, fills with 0)
        //   funct7=0100000, rs2=x5=5, rs1=x1=1, funct3=101, rd=x6=6, op=0110011
        memory[5]  = 32'h4050D333;
        // PC 0x18: addi x7, x0, -16
        memory[6]  = 32'hFF000393;
        // PC 0x1C: sra x8, x7, x5      (-16 >> 2 = -4, fills with 1 -- proves arithmetic)
        memory[7]  = 32'h4053D433;

        // -------------------------------------------------------
        // BLTU tests (PC 0x20 - 0x2C)
        // ctrl bundle = {0,0,0,0,0,1,0,1} = 5
        // B-type: funct3=110
        // -------------------------------------------------------
        // PC 0x20: addi x9, x0, 3
        memory[8]  = 32'h00300493;
        // PC 0x24: addi x10, x0, 7
        memory[9]  = 32'h00700513;
        // PC 0x28: bltu x9, x10, +8    (3 < 7 unsigned = taken, jumps to 0x30)
        //   B-type: imm=+8, funct3=110, rs1=x9=9, rs2=x10=10
        //   imm=8: b12=0,b11=0,b10_5=000000,b4_1=0100
        //   [31]=0,[30:25]=000000,[24:20]=01010,[19:15]=01001,[14:12]=110,[11:8]=0100,[7]=0,[6:0]=1100011
        memory[10] = 32'h00A4E463;
        // PC 0x2C: addi x0, x0, 0      NOP= should be SKIPPED by bltu
        memory[11] = 32'h00000013;
        // PC 0x30: addi x11, x0, 1     proof branch taken (x11=1 after this)
        memory[12] = 32'h00100593;

        // -------------------------------------------------------
        // Loop back to SLTI (PC 0x34)
        // JAL ctrl bundle = {1,0,0,0,0,0,0,0} = 128
        // offset = 0x0C - 0x34 = -40
        // -------------------------------------------------------
        // PC 0x34: jal x0, -40
        memory[13] = 32'hFD9FF06F;

        // Remaining: NOP
        memory[14] = 32'h00000013;
        memory[15] = 32'h00000013;
        memory[16] = 32'h00000013;
        memory[17] = 32'h00000013;
        memory[18] = 32'h00000013;
        memory[19] = 32'h00000013;
        memory[20] = 32'h00000013;
        memory[21] = 32'h00000013;
        memory[22] = 32'h00000013;
        memory[23] = 32'h00000013;
        memory[24] = 32'h00000013;
        memory[25] = 32'h00000013;
        memory[26] = 32'h00000013;
        memory[27] = 32'h00000013;
        memory[28] = 32'h00000013;
        memory[29] = 32'h00000013;
        memory[30] = 32'h00000013;
    end
endmodule