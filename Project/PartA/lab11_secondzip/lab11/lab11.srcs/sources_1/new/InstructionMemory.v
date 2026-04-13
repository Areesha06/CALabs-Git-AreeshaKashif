//`timescale 1ns / 1ps
//module instructionMemory (
//    input  [31:0] instAddress,
//    output reg [31:0] instruction
//);
//    (* rom_style = "block" *) reg [31:0] memory [0:41];

//    always @(*) begin
//        instruction = memory[instAddress[7:2]];
//    end

//    initial begin
//        memory[0]  = 32'h20000313; // 0x00 addi x6, x0, 512
//        memory[1]  = 32'h00500393; // 0x04 addi x7, x0, 5
//        memory[2]  = 32'h00732023; // 0x08 sw x7, 0(x6)
//        memory[3]  = 32'h1FF00113; // 0x0C addi sp, x0, 511
//        memory[4]  = 32'h20400293; // 0x10 addi x5, x0, 516
//        memory[5]  = 32'h0002A023; // 0x14 sw x0, 0(x5)
//        memory[6]  = 32'h20000313; // 0x18 addi x6, x0, 512
//        memory[7]  = 32'h00032383; // 0x1C lw x7, 0(x6)
//        memory[8]  = 32'hFE038CE3; // 0x20 beq x7, x0, switches
//        memory[9]  = 32'h20400293; // 0x24 addi x5, x0, 516
//        memory[10] = 32'h0072A023; // 0x28 sw x7, 0(x5)
//        memory[11] = 32'h00038513; // 0x2C addi a0, x7, 0
//        memory[12] = 32'hFF810113; // 0x30 addi sp, sp, -8
//        memory[13] = 32'h00112223; // 0x34 sw ra, 4(sp)
//        memory[14] = 32'h00812023; // 0x38 sw s0, 0(sp)
//        memory[15] = 32'h014000EF; // 0x3C jal ra, countdown
//        memory[16] = 32'h00412083; // 0x40 lw ra, 4(sp)
//        memory[17] = 32'h00012403; // 0x44 lw s0, 0(sp)
//        memory[18] = 32'h00810113; // 0x48 addi sp, sp, 8
//        memory[19] = 32'hFC5FF06F; // 0x4C jal x0, input_waiting
//        memory[20] = 32'h00050413; // 0x50 addi s0, a0, 0
//        memory[21] = 32'h20800E13; // 0x54 addi x28, x0, 520
//        memory[22] = 32'h000E2E83; // 0x58 lw x29, 0(x28)
//        memory[23] = 32'h020E9863; // 0x5C bne x29, x0, done
//        memory[24] = 32'h20400293; // 0x60 addi x5, x0, 516
//        memory[25] = 32'h0082A023; // 0x64 sw s0, 0(x5)
//        memory[26] = 32'h00040793; // 0x68 addi x15, s0, 0
//        memory[27] = 32'h02040063; // 0x6C beq s0, x0, done
//        memory[28] = 32'hFFC10113; // 0x70 addi sp, sp, -4
//        memory[29] = 32'h00112023; // 0x74 sw ra, 0(sp)
//        memory[30] = 32'h020000EF; // 0x78 jal ra, delay_1sec
//        memory[31] = 32'h00012083; // 0x7C lw ra, 0(sp)
//        memory[32] = 32'h00410113; // 0x80 addi sp, sp, 4
//        memory[33] = 32'hFFF40413; // 0x84 addi s0, s0, -1
//        memory[34] = 32'hFCDFF06F; // 0x88 jal x0, loop
//        memory[35] = 32'h20400293; // 0x8C addi x5, x0, 516
//        memory[36] = 32'h0002A023; // 0x90 sw x0, 0(x5)
//        memory[37] = 32'h00008067; // 0x94 jalr x0, ra, 0
//        memory[38] = 32'h00300F13; // 0x98 addi x30, x0, 3
//        memory[39] = 32'hFFFF0F13; 
//        memory[40] = 32'hFE0F1EE3; // 0xA0 bne x30, x0, delay_loop
//        memory[41] = 32'h00008067; // 0xA4 jalr x0, ra, 0
//    end
//endmodule

`timescale 1ns / 1ps
module instructionMemory (
    input  [31:0] instAddress,
    output reg [31:0] instruction
);
    (* rom_style = "block" *) reg [31:0] memory [0:30];

    always @(*) begin
        instruction = memory[instAddress[7:2]];
    end

    initial begin
        memory[0]  = 32'h20000313; // 0x00 addi x6, x0, 512
        memory[1]  = 32'h00500393; // 0x04 addi x7, x0, 5
        memory[2]  = 32'h00732023; // 0x08 sw x7, 0(x6)
        memory[3]  = 32'h1FF00113; // 0x0C addi sp, x0, 511
        memory[4]  = 32'h20400293; // 0x10 addi x5, x0, 516
        memory[5]  = 32'h0002A023; // 0x14 sw x0, 0(x5)
        memory[6]  = 32'h20000313; // 0x18 addi x6, x0, 512
        memory[7]  = 32'h00032383; // 0x1C lw x7, 0(x6)
        memory[8]  = 32'hFE038CE3; // 0x20 beq x7, x0, switches
        memory[9]  = 32'h20400293; // 0x24 addi x5, x0, 516
        memory[10] = 32'h0072A023; // 0x28 sw x7, 0(x5)
        memory[11] = 32'h00038513; // 0x2C addi a0, x7, 0
        memory[12] = 32'hFF810113; // 0x30 addi sp, sp, -8
        memory[13] = 32'h00112223; // 0x34 sw ra, 4(sp)
        memory[14] = 32'h00812023; // 0x38 sw s0, 0(sp)
        memory[15] = 32'h014000EF; // 0x3C jal ra, countdown
        memory[16] = 32'h00412083; // 0x40 lw ra, 4(sp)
        memory[17] = 32'h00012403; // 0x44 lw s0, 0(sp)
        memory[18] = 32'h00810113; // 0x48 addi sp, sp, 8
        memory[19] = 32'hFC5FF06F; // 0x4C jal x0, input_waiting
        memory[20] = 32'h00050413;
        memory[21] = 32'h20800E13; // 0x54 loop: addi x28, x0, 520
        memory[22] = 32'h000E2E83; // 0x58 lw x29, 0(x28)
        memory[23] = 32'h000E9E63; // 0x5C bne x29, x0, done
        memory[24] = 32'h20400293; // 0x60 addi x5, x0, 516
        memory[25] = 32'h0082A023; // 0x64 sw s0, 0(x5)
        memory[26] = 32'h00040863; // 0x68 beq s0, x0, done
        memory[27] = 32'h00040793; // 0x6C addi x15, s0, 0
        memory[28] = 32'hFFF40413; // 0x70 addi s0, s0, -1
        memory[29] = 32'hFE1FF06F; // 0x74 jal x0, loop
        memory[30] = 32'h00008067; // 0x78 ret
    end
endmodule