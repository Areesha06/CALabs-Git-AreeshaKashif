// ============================================================================
// ORIGINAL COUNTDOWN PROGRAM (commented out for reference)
// ============================================================================
//`timescale 1ns / 1ps
//module instructionMemory (
//    input  [31:0] instAddress,
//    output reg [31:0] instruction
//);
//    (* rom_style = "block" *) reg [31:0] memory [0:30];
//
//    always @(*) begin
//        instruction = memory[instAddress[7:2]];
//    end
//
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
//        memory[20] = 32'h00050413;
//        memory[21] = 32'h20800E13; // 0x54 loop: addi x28, x0, 520
//        memory[22] = 32'h000E2E83; // 0x58 lw x29, 0(x28)
//        memory[23] = 32'h000E9E63; // 0x5C bne x29, x0, done
//        memory[24] = 32'h20400293; // 0x60 addi x5, x0, 516
//        memory[25] = 32'h0082A023; // 0x64 sw s0, 0(x5)
//        memory[26] = 32'h00040863; // 0x68 beq s0, x0, done
//        memory[27] = 32'h00040793; // 0x6C addi x15, s0, 0
//        memory[28] = 32'hFFF40413; // 0x70 addi s0, s0, -1
//        memory[29] = 32'hFE1FF06F; // 0x74 jal x0, loop
//        memory[30] = 32'h00008067; // 0x78 ret
//    end
//endmodule

// ============================================================================
// GCD PROGRAM - Euclidean algorithm using subtraction
// ============================================================================
// Assembly source (RISC-V):
//
// Memory-mapped I/O:
//   0x200 (mem[128]) = Input A   (written by BTNU button press)
//   0x204 (mem[129]) = Input B   (written by BTND button press)
//   0x208 (mem[130]) = Output    (GCD result, read by 7-seg display)
//   0x20C (mem[131]) = Start flag (set to 1 when BTND pressed)
//
// Algorithm (subtraction-based, no rem/div needed):
//   while b != 0:
//       if a < b: swap(a, b)
//       else:     a = a - b
//   return a
//
// main:
//     addi sp, x0, 511          # initialize stack pointer
// wait_start:
//     addi x5, x0, 524          # x5 = address of start flag (0x20C)
//     lw   x6, 0(x5)            # x6 = start_flag
//     beq  x6, x0, wait_start   # poll until flag is set
//     addi x5, x0, 512          # x5 = address of A (0x200)
//     lw   x10, 0(x5)           # x10 = A
//     addi x5, x0, 516          # x5 = address of B (0x204)
//     lw   x11, 0(x5)           # x11 = B
//     addi x5, x0, 524          # x5 = address of flag
//     sw   x0, 0(x5)            # clear start flag
// gcd_loop:
//     beq  x11, x0, gcd_done    # if b == 0, result is in x10
//     sub  x12, x10, x11        # x12 = a - b
//     srli x13, x12, 31         # x13 = sign bit (1 if a < b)
//     bne  x13, x0, gcd_swap    # if a < b, go swap
//     addi x10, x12, 0          # a = a - b  (a >= b case)
//     jal  x0, gcd_loop         # loop back
// gcd_swap:
//     addi x12, x10, 0          # temp = a
//     addi x10, x11, 0          # a = b
//     addi x11, x12, 0          # b = old_a
//     jal  x0, gcd_loop         # loop back
// gcd_done:
//     addi x5, x0, 520          # x5 = address of result (0x208)
//     sw   x10, 0(x5)           # store GCD result
//     jal  x0, wait_start       # wait for next input
// ============================================================================

`timescale 1ns / 1ps
module instructionMemory (
    input  [31:0] instAddress,
    output reg [31:0] instruction
);
    (* rom_style = "block" *) reg [31:0] memory [0:22];

    always @(*) begin
        instruction = memory[instAddress[7:2]];
    end

    initial begin
        // ---- main: initialize stack pointer ----
        memory[0]  = 32'h1FF00113; // 0x00: addi sp, x0, 511

        // ---- wait_start: poll start flag ----
        memory[1]  = 32'h20C00293; // 0x04: addi x5, x0, 524       (x5 = &flag)
        memory[2]  = 32'h0002A303; // 0x08: lw   x6, 0(x5)         (x6 = flag)
        memory[3]  = 32'hFE030CE3; // 0x0C: beq  x6, x0, -8        (loop if flag==0)

        // ---- Load A and B from memory-mapped registers ----
        memory[4]  = 32'h20000293; // 0x10: addi x5, x0, 512       (x5 = &A)
        memory[5]  = 32'h0002A503; // 0x14: lw   x10, 0(x5)        (x10 = A)
        memory[6]  = 32'h20400293; // 0x18: addi x5, x0, 516       (x5 = &B)
        memory[7]  = 32'h0002A583; // 0x1C: lw   x11, 0(x5)        (x11 = B)

        // ---- Clear start flag ----
        memory[8]  = 32'h20C00293; // 0x20: addi x5, x0, 524       (x5 = &flag)
        memory[9]  = 32'h0002A023; // 0x24: sw   x0, 0(x5)         (flag = 0)

        // ---- gcd_loop: subtraction-based Euclidean GCD ----
        memory[10] = 32'h02058463; // 0x28: beq  x11, x0, +40      (if b==0, goto gcd_done)
        memory[11] = 32'h40B50633; // 0x2C: sub  x12, x10, x11     (x12 = a - b)
        memory[12] = 32'h01F65693; // 0x30: srli x13, x12, 31      (x13 = sign bit of a-b)
        memory[13] = 32'h00069663; // 0x34: bne  x13, x0, +12      (if a<b, goto gcd_swap)
        memory[14] = 32'h00060513; // 0x38: addi x10, x12, 0       (a = a-b, a>=b case)
        memory[15] = 32'hFEDFF06F; // 0x3C: jal  x0, -20           (goto gcd_loop)

        // ---- gcd_swap: swap a and b ----
        memory[16] = 32'h00050613; // 0x40: addi x12, x10, 0       (temp = a)
        memory[17] = 32'h00058513; // 0x44: addi x10, x11, 0       (a = b)
        memory[18] = 32'h00060593; // 0x48: addi x11, x12, 0       (b = temp)
        memory[19] = 32'hFDDFF06F; // 0x4C: jal  x0, -36           (goto gcd_loop)

        // ---- gcd_done: store result and restart ----
        memory[20] = 32'h20800293; // 0x50: addi x5, x0, 520       (x5 = &result)
        memory[21] = 32'h00A2A023; // 0x54: sw   x10, 0(x5)        (result = x10)
        memory[22] = 32'hFADFF06F; // 0x58: jal  x0, -84           (goto wait_start)
    end
endmodule