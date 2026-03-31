//`timescale 1ns / 1ps

//module instructionMemory #(
//    parameter OPERAND_LENGTH = 31
//)(
//    input  [OPERAND_LENGTH:0] instAddress,
//    output reg [31:0]         instruction
//);

//    reg [7:0] memory [0:255];

//    initial begin

//        // PC 0x00: li x6, 0x200  =  addi x6, x0, 512
//        memory[0]  = 8'h13; memory[1]  = 8'h03; memory[2]  = 8'h00; memory[3]  = 8'h20;

//        // PC 0x04: li x7, 5  =  addi x7, x0, 5
//        memory[4]  = 8'h93; memory[5]  = 8'h03; memory[6]  = 8'h50; memory[7]  = 8'h00;

//        // PC 0x08: sw x7, 0(x6)
//        memory[8]  = 8'h23; memory[9]  = 8'h20; memory[10] = 8'h73; memory[11] = 8'h00;

//        // PC 0x0C: li sp, 511  =  addi x2, x0, 511
//        memory[12] = 8'h13; memory[13] = 8'h01; memory[14] = 8'hF0; memory[15] = 8'h1F;

//        // PC 0x10: li x5, 0x204  =  addi x5, x0, 516
//        memory[16] = 8'h93; memory[17] = 8'h02; memory[18] = 8'h40; memory[19] = 8'h20;

//        // PC 0x14: sw x0, 0(x5)  = clear LEDs
//        memory[20] = 8'h23; memory[21] = 8'hA0; memory[22] = 8'h02; memory[23] = 8'h00;

//        // PC 0x18: li x6, 0x200  =  addi x6, x0, 512
//        memory[24] = 8'h13; memory[25] = 8'h03; memory[26] = 8'h00; memory[27] = 8'h20;

//        // PC 0x1C: lw x7, 0(x6)  = read switch value
//        memory[28] = 8'h83; memory[29] = 8'h23; memory[30] = 8'h03; memory[31] = 8'h00;

//        // PC 0x20: beq x7, x0, -8  = if zero keep polling (target=0x18)
//        memory[32] = 8'hE3; memory[33] = 8'h8C; memory[34] = 8'h03; memory[35] = 8'hFE;

//        // PC 0x24: li x5, 0x204
//        memory[36] = 8'h93; memory[37] = 8'h02; memory[38] = 8'h40; memory[39] = 8'h20;

//        // PC 0x28: sw x7, 0(x5)  = show switch value on LEDs
//        memory[40] = 8'h23; memory[41] = 8'hA0; memory[42] = 8'h72; memory[43] = 8'h00;

//        // PC 0x2C: mv a0, x7  =  addi x10, x7, 0
//        memory[44] = 8'h13; memory[45] = 8'h85; memory[46] = 8'h03; memory[47] = 8'h00;

//        // PC 0x30: addi sp, sp, -8
//        memory[48] = 8'h13; memory[49] = 8'h01; memory[50] = 8'h81; memory[51] = 8'hFF;

//        // PC 0x34: sw ra, 4(sp)
//        memory[52] = 8'h23; memory[53] = 8'h22; memory[54] = 8'h11; memory[55] = 8'h00;

//        // PC 0x38: sw s0, 0(sp)
//        memory[56] = 8'h23; memory[57] = 8'h20; memory[58] = 8'h81; memory[59] = 8'h00;

//        // PC 0x3C: jal ra, countdown  (target=0x50, offset=+20)
//        memory[60] = 8'hEF; memory[61] = 8'h00; memory[62] = 8'h40; memory[63] = 8'h01;

//        // PC 0x40: lw ra, 4(sp)
//        memory[64] = 8'h83; memory[65] = 8'h20; memory[66] = 8'h41; memory[67] = 8'h00;

//        // PC 0x44: lw s0, 0(sp)
//        memory[68] = 8'h03; memory[69] = 8'h24; memory[70] = 8'h01; memory[71] = 8'h00;

//        // PC 0x48: addi sp, sp, 8
//        memory[72] = 8'h13; memory[73] = 8'h01; memory[74] = 8'h81; memory[75] = 8'h00;

//        // PC 0x4C: j input_waiting  (target=0x10, offset=-60)
//        memory[76] = 8'h6F; memory[77] = 8'hF0; memory[78] = 8'h5F; memory[79] = 8'hFC;

//        // PC 0x50: addi sp, sp, -8
//        memory[80] = 8'h13; memory[81] = 8'h01; memory[82] = 8'h81; memory[83] = 8'hFF;

//        // PC 0x54: sw ra, 4(sp)
//        memory[84] = 8'h23; memory[85] = 8'h22; memory[86] = 8'h11; memory[87] = 8'h00;

//        // PC 0x58: sw s0, 0(sp)
//        memory[88] = 8'h23; memory[89] = 8'h20; memory[90] = 8'h81; memory[91] = 8'h00;

//        // PC 0x5C: mv s0, a0  =  addi x8, x10, 0
//        memory[92] = 8'h13; memory[93] = 8'h04; memory[94] = 8'h05; memory[95] = 8'h00;

//        // PC 0x60: li x28, 0x208  =  addi x28, x0, 520
//        memory[96]  = 8'h13; memory[97]  = 8'h0E; memory[98]  = 8'h80; memory[99]  = 8'h20;

//        // PC 0x64: lw x29, 0(x28)  = read reset button
//        memory[100] = 8'h83; memory[101] = 8'h2E; memory[102] = 8'h0E; memory[103] = 8'h00;

//        // PC 0x68: bne x29, x0, done  (target=0x98, offset=+48)
//        memory[104] = 8'h63; memory[105] = 8'h98; memory[106] = 8'h0E; memory[107] = 8'h02;

//        // PC 0x6C: li x5, 0x204
//        memory[108] = 8'h93; memory[109] = 8'h02; memory[110] = 8'h40; memory[111] = 8'h20;

//        // PC 0x70: sw s0, 0(x5)  = display current count on LEDs
//        memory[112] = 8'h23; memory[113] = 8'hA0; memory[114] = 8'h82; memory[115] = 8'h00;

//        // PC 0x74: mv x15, s0
//        memory[116] = 8'h93; memory[117] = 8'h07; memory[118] = 8'h04; memory[119] = 8'h00;

//        // PC 0x78: beq s0, x0, done  (target=0x98, offset=+32)
//        memory[120] = 8'h63; memory[121] = 8'h00; memory[122] = 8'h04; memory[123] = 8'h02;

//        // PC 0x7C: addi sp, sp, -4
//        memory[124] = 8'h13; memory[125] = 8'h01; memory[126] = 8'hC1; memory[127] = 8'hFF;

//        // PC 0x80: sw ra, 0(sp)
//        memory[128] = 8'h23; memory[129] = 8'h20; memory[130] = 8'h11; memory[131] = 8'h00;

//        // PC 0x84: jal ra, delay_1sec  (target=0xB0, offset=+44)
//        memory[132] = 8'hEF; memory[133] = 8'h00; memory[134] = 8'hC0; memory[135] = 8'h02;

//        // PC 0x88: lw ra, 0(sp)
//        memory[136] = 8'h83; memory[137] = 8'h20; memory[138] = 8'h01; memory[139] = 8'h00;

//        // PC 0x8C: addi sp, sp, 4
//        memory[140] = 8'h13; memory[141] = 8'h01; memory[142] = 8'h41; memory[143] = 8'h00;

//        // PC 0x90: addi s0, s0, -1
//        memory[144] = 8'h13; memory[145] = 8'h04; memory[146] = 8'hF4; memory[147] = 8'hFF;

//        // PC 0x94: j loop  (target=0x60, offset=-52)
//        memory[148] = 8'h6F; memory[149] = 8'hF0; memory[150] = 8'hDF; memory[151] = 8'hFC;

//        // PC 0x98: li x5, 0x204
//        memory[152] = 8'h93; memory[153] = 8'h02; memory[154] = 8'h40; memory[155] = 8'h20;

//        // PC 0x9C: sw x0, 0(x5)  = clear LEDs
//        memory[156] = 8'h23; memory[157] = 8'hA0; memory[158] = 8'h02; memory[159] = 8'h00;

//        // PC 0xA0: lw s0, 0(sp)
//        memory[160] = 8'h03; memory[161] = 8'h24; memory[162] = 8'h01; memory[163] = 8'h00;

//        // PC 0xA4: lw ra, 4(sp)
//        memory[164] = 8'h83; memory[165] = 8'h20; memory[166] = 8'h41; memory[167] = 8'h00;

//        // PC 0xA8: addi sp, sp, 8
//        memory[168] = 8'h13; memory[169] = 8'h01; memory[170] = 8'h81; memory[171] = 8'h00;

//        // PC 0xAC: ret  =  jalr x0, 0(x1)
//        memory[172] = 8'h67; memory[173] = 8'h80; memory[174] = 8'h00; memory[175] = 8'h00;

//        // PC 0xB0: li x30, 3
//        memory[176] = 8'h13; memory[177] = 8'h0F; memory[178] = 8'h30; memory[179] = 8'h00;

//        // PC 0xB4: addi x30, x30, -1
//        memory[180] = 8'h13; memory[181] = 8'h0F; memory[182] = 8'hFF; memory[183] = 8'hFF;

//        // PC 0xB8: bne x30, x0, -4  (target=0xB4)
//        memory[184] = 8'hE3; memory[185] = 8'h1E; memory[186] = 8'h0F; memory[187] = 8'hFE;

//        // PC 0xBC: ret
//        memory[188] = 8'h67; memory[189] = 8'h80; memory[190] = 8'h00; memory[191] = 8'h00;

//        // PC 0xC0: j end  =  jal x0, 0
//        memory[192] = 8'h6F; memory[193] = 8'h00; memory[194] = 8'h00; memory[195] = 8'h00;

//    end

//    always @(*) begin
//        instruction = {
//            memory[instAddress + 3],
//            memory[instAddress + 2],
//            memory[instAddress + 1],
//            memory[instAddress + 0]
//        };
//    end

//endmodule


`timescale 1ns / 1ps

module instructionMemory #(
    parameter OPERAND_LENGTH = 31
)(
    input  wire                    clk,
    input  wire [OPERAND_LENGTH:0] instAddress,
    output reg  [31:0]             instruction
);

    (* rom_style = "block" *) reg [31:0] memory [0:63];

    // Word address: PC is always 4-byte aligned, so shift right by 2.
    // 6 bits addresses 64 words = 256 bytes - enough for this program.
    wire [5:0] waddr = instAddress[7:2];

    initial begin
        // Each entry is the full 32-bit little-endian instruction word.
        // Byte order: memory[i] = {byte3, byte2, byte1, byte0}

        // PC 0x00: addi x6, x0, 512
        memory[0]  = 32'h20000313;
        // PC 0x04: addi x7, x0, 5
        memory[1]  = 32'h00500393;
        // PC 0x08: sw x7, 0(x6)
        memory[2]  = 32'h00732023;
        // PC 0x0C: addi x2, x0, 511
        memory[3]  = 32'h1FF00113;
        // PC 0x10: addi x5, x0, 516
        memory[4]  = 32'h20400293;
        // PC 0x14: sw x0, 0(x5)
        memory[5]  = 32'h0002A023;
        // PC 0x18: addi x6, x0, 512
        memory[6]  = 32'h20000313;
        // PC 0x1C: lw x7, 0(x6)
        memory[7]  = 32'h00032383;
        // PC 0x20: beq x7, x0, -8  (target=0x18)
        memory[8]  = 32'hFE038CE3;
        // PC 0x24: addi x5, x0, 516
        memory[9]  = 32'h20400293;
        // PC 0x28: sw x7, 0(x5)
        memory[10] = 32'h0072A023;
        // PC 0x2C: addi x10, x7, 0
        memory[11] = 32'h00038513;
        // PC 0x30: addi x2, x2, -8
        memory[12] = 32'hFF810113;
        // PC 0x34: sw x1, 4(x2)
        memory[13] = 32'h00112223;
        // PC 0x38: sw x8, 0(x2)
        memory[14] = 32'h00812023;
        // PC 0x3C: jal x1, +20  (target=0x50)
        memory[15] = 32'h014000EF;
        // PC 0x40: lw x1, 4(x2)
        memory[16] = 32'h00410083;
        // PC 0x44: lw x8, 0(x2)
        memory[17] = 32'h00012403;
        // PC 0x48: addi x2, x2, 8
        memory[18] = 32'h00810113;
        // PC 0x4C: jal x0, -60  (target=0x10)
        memory[19] = 32'hFC5FF06F;
        // PC 0x50: addi x2, x2, -8
        memory[20] = 32'hFF810113;
        // PC 0x54: sw x1, 4(x2)
        memory[21] = 32'h00112223;
        // PC 0x58: sw x8, 0(x2)
        memory[22] = 32'h00812023;
        // PC 0x5C: addi x8, x10, 0
        memory[23] = 32'h00050413;
        // PC 0x60: addi x28, x0, 520
        memory[24] = 32'h20800E13;
        // PC 0x64: lw x29, 0(x28)
        memory[25] = 32'h000E2E83;
        // PC 0x68: bne x29, x0, +48  (target=0x98)
        memory[26] = 32'h020E9863;
        // PC 0x6C: addi x5, x0, 516
        memory[27] = 32'h20400293;
        // PC 0x70: sw x8, 0(x5)
        memory[28] = 32'h0082A023;
        // PC 0x74: addi x15, x8, 0
        memory[29] = 32'h00040793;
        // PC 0x78: beq x8, x0, +32  (target=0x98)
        memory[30] = 32'h02040063;
        // PC 0x7C: addi x2, x2, -4
        memory[31] = 32'hFFC10113;
        // PC 0x80: sw x1, 0(x2)
        memory[32] = 32'h00112023;
        // PC 0x84: jal x1, +44  (target=0xB0)
        memory[33] = 32'h02C000EF;
        // PC 0x88: lw x1, 0(x2)
        memory[34] = 32'h00012083;
        // PC 0x8C: addi x2, x2, 4
        memory[35] = 32'h00410113;
        // PC 0x90: addi x8, x8, -1
        memory[36] = 32'hFFF40413;
        // PC 0x94: jal x0, -52  (target=0x60)
        memory[37] = 32'hFCDFF06F;
        // PC 0x98: addi x5, x0, 516
        memory[38] = 32'h20400293;
        // PC 0x9C: sw x0, 0(x5)
        memory[39] = 32'h0002A023;
        // PC 0xA0: lw x8, 0(x2)
        memory[40] = 32'h00012403;
        // PC 0xA4: lw x1, 4(x2)
        memory[41] = 32'h00410083;
        // PC 0xA8: addi x2, x2, 8
        memory[42] = 32'h00810113;
        // PC 0xAC: jalr x0, 0(x1)
        memory[43] = 32'h00008067;
        // PC 0xB0: addi x30, x0, 3
        memory[44] = 32'h00300F13;
        // PC 0xB4: addi x30, x30, -1
        memory[45] = 32'hFFFF0F13;
        // PC 0xB8: bne x30, x0, -4  (target=0xB4)
        memory[46] = 32'hFE0F1EE3;
        // PC 0xBC: jalr x0, 0(x1)
        memory[47] = 32'h00008067;
        // PC 0xC0: jal x0, 0  (infinite loop / end)
        memory[48] = 32'h0000006F;

        // Remaining entries default to NOP (addi x0, x0, 0 = 0x00000013)
        // Vivado fills uninitialized BRAM with 0 which decodes as
        // the all-zero instruction - safe as long as PC never reaches here.
    end

    // Registered read - REQUIRED for BRAM inference.
    always @(posedge clk) begin
        instruction <= memory[waddr];
    end

endmodule