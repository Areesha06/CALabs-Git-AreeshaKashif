.text 
.globl main

main:

    addi x5, x0, 5        
    addi x6, x0, 3         
    addi x7, x0, 0          # i = 0

    addi x10, x0, 0x200     # Base address of array D = 0x200

L1:
    bge  x7, x5, end       # if (i >= a) exit outer loop

    addi x29, x0, 0        # j = 0

L2:
    bge  x29, x6, nextval  # if (j >= b) exit inner loop

    add  x11, x7, x29     # x11 = i + j
    slli x12, x29, 4      # offset = 16 * j  (D[4*j])
    add  x12, x10, x12    # address of D[4*j]
    sw   x11, 0(x12)      # D[4*j] = i + j

    addi x29, x29, 1      # j++
    j    L2               # jump to Loop L2

nextval:
    addi x7, x7, 1        # i++
    j    L1               # jump to Loop L1

end:
