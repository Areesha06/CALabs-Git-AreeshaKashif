.text
.globl main

main:
    # initialize array in memory
    addi x24, x0, 2  # x24 = 2
    addi x25, x0, 1  # x25 = 1
    addi x27, x0, 5  # x27 = 5

    sw x24, 0x100(x0)   # v[0] = 2; address 0x100
    sw x25, 0x104(x0)   # v[1] = 1; address 0x104
    sw x27, 0x108(x0)   # v[2] = 5; address 0x108

    addi x10, x0, 0x100 # base of array v[]
    addi x11, x0, 1     # index k = 1, the index to swap

    jal x1, swap        # call swap(v, k); and store return value in x1

    # exit program
    li x10, 10          # ecall 10 mean exit program 
    ecall

swap:                   # swap function
    
    addi sp, sp, -8      # reserve 4 bytes for temp + 4 bytes for ra
    sw x1, 4(sp)         # save return address in x1 with 4 offset

    slli x5, x11, 2      # x5 = k*4; we find the addresses 
    add x6, x10, x5      # x6 = &v[k]
    addi x5, x5, 4       # x5 = 4*(k+1)
    add x7, x10, x5      # x7 = &v[k+1]

    lw x28, 0(x6)        # load word with 0 offset from x6 to x28
    sw x28, 0(sp)        # store word with 0 offset in x28 from stack

    lw x28, 0(x7)        # load word with 0 offset from x7 to x28
    sw x28, 0(x6)        # store word with 0 offset in x28 from x6

    lw x28, 0(sp)        # load word with 0 offset from stack to x28
    sw x28, 0(x7)        # store word with 0 offset in x28 from x7

    lw x1, 4(sp)         # load word with 4 offset from stack to x1
    addi sp, sp, 8       # deallocate the memory used for swapping in the stack
    jalr x0, 0(x1)       # retur the address of function with 0 offset 
