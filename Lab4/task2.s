 

li x10, 4        # num=4 

jal x1, ntri     # call ntri(num) 

j exit 

 

ntri: 

    addi sp, sp, -8      # reserving space in stack 

    sw x1, 4(sp)         # save return address 

    sw x10, 0(sp)        # save num 

 

    li x5, 1 

    ble x10, x5, base_case #num<=1 then go to basecase 

 

    # recursive case 

    addi x10, x10, -1    # x10=num-1 

    jal x1, ntri         # call ntri(num-1) 

 

    lw x6, 0(sp)         # loading num from stack and restoring stack 

    add x10, x10, x6     # num + ntri(num-1) 

    j end 

 

base_case: 

    li x10, 1            # return 1 

 

end: 

    lw x1, 4(sp)         # restore return address from stack 

    addi sp, sp, 8       # restore stack 

    jalr x0, 0(x1)       #jump back to return address 

 

exit: 