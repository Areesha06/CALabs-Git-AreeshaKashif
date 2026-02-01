
addi x10, x0, 12    # g 
addi x11, x0, 5     # h 
addi x12, x0, 7     # i
addi x13, x0, 5     # j 
 
jal x1, leaf #saving return address in x1 
    addi x11, x10, 0 #xcopying return value to x11 
    li x10, 1 #call to exit program 
    ecall #print 
j exit  

leaf: 
    addi sp, sp, -12 #reserving space on stack (3x4=12) 
    sw x18, 8(sp)  #temporary register 
    sw x19, 4(sp)   #temporary register 
    sw x20, 0(sp)   #temporary register 
    add x18, x10, x11  #x18=g+h 
    add x19, x12, x13 #x19=i+j 
    sub x20, x18, x19 #x20=(g+h)-(i+j) (f=x20) 
    addi x10, x20, 0 #copying f to return register 
    lw x20, 0(sp) #restoring register 
    lw x19, 4(sp) #restoring register 
    lw x18, 8(sp) #restoring register 
    addi sp, sp, 12 #restoring stack 
    jalr x0, 0(x1) #jump back to return address x1 

exit: 