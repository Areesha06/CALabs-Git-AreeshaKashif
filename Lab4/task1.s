    .text
    .globl main

main:
    li   x10, 6      # n = 6
    li   x11, 1      # add value intiially = 1
    li   x12, 0      # temp for stack storage

factorial:
    ble  x10, x0, exit   # if n <= 0, exit loop

    addi sp, sp, -4      # add x10 (curr n) to stack
    sw   x10, 0(sp)      # store word in x10 with 0 offset

    mul  x11, x11, x10   # multiply previous add value by n

    addi x10, x10, -1    # decrement n by 1
    jal  x0, factorial   # repeat loop again 

exit:
    li   x10, 1          # ecall 1 is printing integer
    ecall
