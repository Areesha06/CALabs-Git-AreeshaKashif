.text
.globl main


main:
    li x10, 48          # a = 48
    li x11, 18          # b = 18

    jal x1, gcd        # call gcd(x10, x11)

    # result is in x10

    li a7, 10          # exit ecall is 10
    ecall


gcd:
    addi sp, sp, -16   # create stack 
    sw x1, 12(sp)     # save return address in x1 register with 12 offset
    sw x11, 8(sp)      # save b value with 8 offset in x11

    beq x11, x0, gcd_base   # if b == 0 (base case)

    rem x12, x10, x11    # x12 = a % b
    mv x10, x11         # x10 = b
    mv x11, x12         # x11 = a % b

    jal x1, gcd       # call again until we get to base case

gcd_base:
    lw x1, 12(sp)     # restore return address
    addi sp, sp, 16   # destroy stack
    jr x1             # return address for next instruction 
