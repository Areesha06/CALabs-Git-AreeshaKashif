.text
.globl main

main:
    addi x10, x0, 12      # a = 12
    addi x11, x0, 12      # b = 12

    jal  x1, sum          # call sum(a, b), and we store the return address in x1

    addi x11, x10, 0     # store result in x11 so we can print
    li   x10, 1          # ecall 1 mean print integer
    ecall

    j exit               # only jump to exit label

sum:                     # sum label is defined here
    add  x10, x11, x10   # add x10 and x11 (x10 = a+b; return value)
    jalr x0, 0(x1)       # return to call

exit:                    # exit
