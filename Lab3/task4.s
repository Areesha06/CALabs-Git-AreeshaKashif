.data 
x: .space 100 # array to store copied string 
y: .byte 'H','i', 0 # source string 

.text 
.globl main 
main:
    la x10, x           # load address of label x into register
    la x11, y           # load address of label y into register  
    jal x1, strcpy      # calling strcpy 
        li x10, 10      # exit program 
        ecall           # print 
    j exit 

strcpy: 
    addi sp, sp, -4     # reserving space in stack 
    sw x19, 0(sp)       # temporary register in stack 
    addi x19, x0, 0     # i=0 

loop: 
    add x5, x19, x11    # x5 = address of y[i] = base address + offset 
    lbu x6, 0(x5)       # loading characters from y[i], x6 = y[i] 
    add x7, x19, x10    # x7 = address of x[i] = base address + offset 
    sb x6, 0(x7)        # storing y[i] characters into x[i], x[i] = y[i]  
    beq x6, x0, end     # if y[i] == '\0', loop ends 
    addi x19, x19, 1    # i+=1 
    j loop              # repeat loop 
end: 
    lw x19, 0(sp)      # restore register 
    addi sp, sp, 4     # restore stack 
    jalr x0, 0(x1)     # return 

exit: 