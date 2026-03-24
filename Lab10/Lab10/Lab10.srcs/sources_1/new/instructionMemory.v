`timescale 1ns / 1ps

module instructionMemory #(
    parameter OPERAND_LENGTH = 31
)(
    input  [OPERAND_LENGTH:0] instAddress,
    output reg [31:0]         instruction
);

    reg [7:0] memory [0:255];

    initial begin

        // PC 0x00: li x6, 0x200  =  addi x6, x0, 512
        // Binary: 00100000000000000000001100010011
        memory[0]  = 8'h13; memory[1]  = 8'h03; memory[2]  = 8'h00; memory[3]  = 8'h20;


        // PC 0x04: li x7, 5  =  addi x7, x0, 5
        // Binary: 00000000010100000000001110010011
        memory[4]  = 8'h93; memory[5]  = 8'h03; memory[6]  = 8'h50; memory[7]  = 8'h00;


        // PC 0x08: sw x7, 0(x6)  = simulate switch = 5
        // Binary: 00000000011100110010000000100011
        memory[8]  = 8'h23; memory[9]  = 8'h20; memory[10] = 8'h73; memory[11] = 8'h00;


        // PC 0x0C: li sp, 511  =  addi x2, x0, 511
        // Binary: 00011111111100000000000100010011
        memory[12] = 8'h13; memory[13] = 8'h01; memory[14] = 8'hF0; memory[15] = 8'h1F;


        // input_waiting:
        // PC 0x10: li x5, 0x204  =  addi x5, x0, 516
        // Binary: 00100000010000000000001010010011
        memory[16] = 8'h93; memory[17] = 8'h02; memory[18] = 8'h40; memory[19] = 8'h20;


        // PC 0x14: sw x0, 0(x5)  = clear LEDs
        // Binary: 00000000000000101010000000100011
        memory[20] = 8'h23; memory[21] = 8'hA0; memory[22] = 8'h02; memory[23] = 8'h00;

        // switches:
        // PC 0x18: li x6, 0x200  =  addi x6, x0, 512
        // Binary: 00100000000000000000001100010011
        memory[24] = 8'h13; memory[25] = 8'h03; memory[26] = 8'h00; memory[27] = 8'h20;


        // PC 0x1C: lw x7, 0(x6)  = read switch value
        // Binary: 00000000000000110010001110000011
        memory[28] = 8'h83; memory[29] = 8'h23; memory[30] = 8'h03; memory[31] = 8'h00;


        // PC 0x20: beq x7, x0, -8  = if zero keep polling (target=0x18)
        // Binary: 11111110000000111000110011100011
        memory[32] = 8'hE3; memory[33] = 8'h8C; memory[34] = 8'h03; memory[35] = 8'hFE;


        // PC 0x24: li x5, 0x204  =  addi x5, x0, 516
        // Binary: 00100000010000000000001010010011
        memory[36] = 8'h93; memory[37] = 8'h02; memory[38] = 8'h40; memory[39] = 8'h20;


        // PC 0x28: sw x7, 0(x5)  = show switch value on LEDs
        // Binary: 00000000011100101010000000100011
        memory[40] = 8'h23; memory[41] = 8'hA0; memory[42] = 8'h72; memory[43] = 8'h00;


        // PC 0x2C: mv a0, x7  =  addi x10, x7, 0
        // Binary: 00000000000000111000010100010011
        memory[44] = 8'h13; memory[45] = 8'h85; memory[46] = 8'h03; memory[47] = 8'h00;


        // PC 0x30: addi sp, sp, -8  = make stack room
        // Binary: 11111111100000010000000100010011
        memory[48] = 8'h13; memory[49] = 8'h01; memory[50] = 8'h81; memory[51] = 8'hFF;


        // PC 0x34: sw ra, 4(sp)  = save return address
        // Binary: 00000000000100010010001000100011
        memory[52] = 8'h23; memory[53] = 8'h22; memory[54] = 8'h11; memory[55] = 8'h00;

        // PC 0x38: sw s0, 0(sp)  = save s0
        // Binary: 00000000100000010010000000100011
        memory[56] = 8'h23; memory[57] = 8'h20; memory[58] = 8'h81; memory[59] = 8'h00;


        // PC 0x3C: jal ra, countdown  = call countdown (target=0x50, offset=+20)
        // Binary: 00000001010000000000000011101111
        memory[60] = 8'hEF; memory[61] = 8'h00; memory[62] = 8'h40; memory[63] = 8'h01;


        // PC 0x40: lw ra, 4(sp)  = restore return address
        // Binary: 00000000010000010010000010000011
        memory[64] = 8'h83; memory[65] = 8'h20; memory[66] = 8'h41; memory[67] = 8'h00;


        // PC 0x44: lw s0, 0(sp)  = restore s0
        // Binary: 00000000000000010010010000000011
        memory[68] = 8'h03; memory[69] = 8'h24; memory[70] = 8'h01; memory[71] = 8'h00;


        // PC 0x48: addi sp, sp, 8  = free stack space
        // Binary: 00000000100000010000000100010011
        memory[72] = 8'h13; memory[73] = 8'h01; memory[74] = 8'h81; memory[75] = 8'h00;


        // PC 0x4C: j input_waiting  = loop back (target=0x10, offset=-60)
        // Binary: 11111100010111111111000001101111
        memory[76] = 8'h6F; memory[77] = 8'hF0; memory[78] = 8'h5F; memory[79] = 8'hFC;


        // countdown:
        // PC 0x50: addi sp, sp, -8  = make stack room
        // Binary: 11111111100000010000000100010011
        memory[80] = 8'h13; memory[81] = 8'h01; memory[82] = 8'h81; memory[83] = 8'hFF;


        // PC 0x54: sw ra, 4(sp)  = save return address
        // Binary: 00000000000100010010001000100011
        memory[84] = 8'h23; memory[85] = 8'h22; memory[86] = 8'h11; memory[87] = 8'h00;


        // PC 0x58: sw s0, 0(sp)  = save s0
        // Binary: 00000000100000010010000000100011
        memory[88] = 8'h23; memory[89] = 8'h20; memory[90] = 8'h81; memory[91] = 8'h00;


        // PC 0x5C: mv s0, a0  =  addi x8, x10, 0
        // Binary: 00000000000001010000010000010011
        memory[92] = 8'h13; memory[93] = 8'h04; memory[94] = 8'h05; memory[95] = 8'h00;


        // loop:
        // PC 0x60: li x28, 0x208  =  addi x28, x0, 520
        // Binary: 00100000100000000000111000010011
        memory[96]  = 8'h13; memory[97]  = 8'h0E; memory[98]  = 8'h80; memory[99]  = 8'h20;


        // PC 0x64: lw x29, 0(x28)  = read reset button
        // Binary: 00000000000011100010111010000011
        memory[100] = 8'h83; memory[101] = 8'h2E; memory[102] = 8'h0E; memory[103] = 8'h00;


        // PC 0x68: bne x29, x0, done  = if reset pressed exit (target=0x98, offset=+48)
        // Binary: 00000000001011101001100001100011
        memory[104] = 8'h63; memory[105] = 8'h98; memory[106] = 8'h0E; memory[107] = 8'h02;


        // PC 0x6C: li x5, 0x204  =  addi x5, x0, 516
        // Binary: 00100000010000000000001010010011
        memory[108] = 8'h93; memory[109] = 8'h02; memory[110] = 8'h40; memory[111] = 8'h20;


        // PC 0x70: sw s0, 0(x5)  = display current count on LEDs
        // Binary: 00000000100000101010000000100011
        memory[112] = 8'h23; memory[113] = 8'hA0; memory[114] = 8'h82; memory[115] = 8'h00;


        // PC 0x74: mv x15, s0  =  addi x15, x8, 0  = show in register
        // Binary: 00000000000001000000011110010011
        memory[116] = 8'h93; memory[117] = 8'h07; memory[118] = 8'h04; memory[119] = 8'h00;


        // PC 0x78: beq s0, x0, done  = if showed 0 then exit (target=0x98, offset=+32)
        // Binary: 00000000001000000000010001100011
        memory[120] = 8'h63; memory[121] = 8'h00; memory[122] = 8'h04; memory[123] = 8'h02;


        // PC 0x7C: addi sp, sp, -4  = make room for ra
        // Binary: 11111111110000010000000100010011
        memory[124] = 8'h13; memory[125] = 8'h01; memory[126] = 8'hC1; memory[127] = 8'hFF;


        // PC 0x80: sw ra, 0(sp)  = save ra before delay call
        // Binary: 00000000000100010010000000100011
        memory[128] = 8'h23; memory[129] = 8'h20; memory[130] = 8'h11; memory[131] = 8'h00;


        // PC 0x84: jal ra, delay_1sec  = call delay (target=0xB0, offset=+44)
        // Binary: 00000010110000000000000011101111
        memory[132] = 8'hEF; memory[133] = 8'h00; memory[134] = 8'hC0; memory[135] = 8'h02;


        // PC 0x88: lw ra, 0(sp)  = restore ra
        // Binary: 00000000000000010010000010000011
        memory[136] = 8'h83; memory[137] = 8'h20; memory[138] = 8'h01; memory[139] = 8'h00;


        // PC 0x8C: addi sp, sp, 4  = free stack
        // Binary: 00000000010000010000000100010011
        memory[140] = 8'h13; memory[141] = 8'h01; memory[142] = 8'h41; memory[143] = 8'h00;


        // PC 0x90: addi s0, s0, -1  = decrement counter
        // Binary: 11111111111101000000010000010011
        memory[144] = 8'h13; memory[145] = 8'h04; memory[146] = 8'hF4; memory[147] = 8'hFF;


        // PC 0x94: j loop  = go back to top (target=0x60, offset=-52)
        // Binary: 11111100110111111111000001101111
        memory[148] = 8'h6F; memory[149] = 8'hF0; memory[150] = 8'hDF; memory[151] = 8'hFC;


        // done:
        // PC 0x98: li x5, 0x204  =  addi x5, x0, 516
        // Binary: 00100000010000000000001010010011
        memory[152] = 8'h93; memory[153] = 8'h02; memory[154] = 8'h40; memory[155] = 8'h20;


        // PC 0x9C: sw x0, 0(x5)  = clear LEDs
        // Binary: 00000000000000101010000000100011
        memory[156] = 8'h23; memory[157] = 8'hA0; memory[158] = 8'h02; memory[159] = 8'h00;


        // PC 0xA0: lw s0, 0(sp)  = restore s0
        // Binary: 00000000000000010010010000000011
        memory[160] = 8'h03; memory[161] = 8'h24; memory[162] = 8'h01; memory[163] = 8'h00;


        // PC 0xA4: lw ra, 4(sp)  = restore ra
        // Binary: 00000000010000010010000010000011
        memory[164] = 8'h83; memory[165] = 8'h20; memory[166] = 8'h41; memory[167] = 8'h00;

        // PC 0xA8: addi sp, sp, 8  = free stack
        // Binary: 00000000100000010000000100010011
        memory[168] = 8'h13; memory[169] = 8'h01; memory[170] = 8'h81; memory[171] = 8'h00;


        // PC 0xAC: ret  =  jalr x0, 0(x1)
        // Binary: 00000000000000001000000001100111
        memory[172] = 8'h67; memory[173] = 8'h80; memory[174] = 8'h00; memory[175] = 8'h00;


        // delay_1sec:
        // PC 0xB0: li x30, 3  =  addi x30, x0, 3
        // Binary: 00000000001100000000111100010011
        memory[176] = 8'h13; memory[177] = 8'h0F; memory[178] = 8'h30; memory[179] = 8'h00;


        // delay_loop:
        // PC 0xB4: addi x30, x30, -1
        // Binary: 11111111111111110000111100010011
        memory[180] = 8'h13; memory[181] = 8'h0F; memory[182] = 8'hFF; memory[183] = 8'hFF;


        // PC 0xB8: bne x30, x0, -4  = loop back (target=0xB4)
        // Binary: 11111110000011110001111011100011
        memory[184] = 8'hE3; memory[185] = 8'h1E; memory[186] = 8'h0F; memory[187] = 8'hFE;


        // PC 0xBC: ret  =  jalr x0, 0(x1)
         // Binary: 00000000000000001000000001100111
        memory[188] = 8'h67; memory[189] = 8'h80; memory[190] = 8'h00; memory[191] = 8'h00;


        // end:
        // PC 0xC0: j end  =  jal x0, 0
        // Binary: 00000000000000000000000001101111
        memory[192] = 8'h6F; memory[193] = 8'h00; memory[194] = 8'h00; memory[195] = 8'h00;

    end

    // assemble 32-bit instruction from 4 bytes
    // byte 0 = LSB, byte 3 = MSB

    always @(*) begin
        instruction = {
            memory[instAddress + 3],    // bits [31:24]
            memory[instAddress + 2],    // bits [23:16]
            memory[instAddress + 1],    // bits [15:8]
            memory[instAddress + 0]     // bits [7:0]
        };
    end

endmodule