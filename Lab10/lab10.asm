.text
.globl main

main:
    li   x6, 0x200          # x6 = switch address
    li   x7, 5              # x7 = switch value = 5
    sw   x7, 0(x6)          # store 5 into switch address

    li   sp, 511            # initialize stack pointer

input_waiting:
    li   x5, 0x204          # x5 = LED address
    sw   x0, 0(x5)          # clear LEDs

switches:
    li   x6, 0x200          # x6 = switch address
    lw   x7, 0(x6)          # x7 = current switch value
    beq  x7, x0, switches   # if switches = 0, keep looping

    # switch is non zero, capture and display value
    li   x5, 0x204          # x5 = LED address
    sw   x7, 0(x5)          # show switch value on LEDs

    mv   a0, x7             # pass switch value as argument to function call

    addi sp, sp, -8         # make room on stack
    sw   ra, 4(sp)          # save return address
    sw   s0, 0(sp)          # save s0

    jal  ra, countdown      # call countdown 

    lw   ra, 4(sp)          # restore return address
    lw   s0, 0(sp)          # restore s0
    addi sp, sp, 8          # free stack space

    j input_waiting         # go back to waiting state


# countdown: counts from value in a0 down to 0
# shows each value on LEDs and in x15 register

countdown:
    mv s0, a0               # s0 = counter

loop:
    li   x28, 0x208         # x28 = reset button address
    lw   x29, 0(x28)        # x29 = reset button value
    bne  x29, x0, done      # if reset pressed (value!=0), exit

    li   x5, 0x204          # x5 = LED address
    sw   s0, 0(x5)          # display current value on LEDs
    mv   x15, s0            # show current value in register

    beq  s0, x0, done       # if we just showed 0 (countdown complete), exit

    addi sp, sp, -4         # save return address before delay call
    sw   ra, 0(sp)          # save it on stack 
    jal  ra, delay_1sec     # wait
    lw   ra, 0(sp)          # restore value (since jal overwrites ra)
    addi sp, sp, 4            # deallocate space

    addi s0, s0, -1         # decrement after displaying
    jal x0, loop            # go back to top

done:                       # countdown finished (or reset pressed) 
    li   x5, 0x204          # x5 = LED address
    sw   x0, 0(x5)          # clear LEDs
    ret                     # return to main

delay_1sec:
    li   x30, 3             # 3 for simulation 

delay_loop:
    addi x30, x30, -1        # decrement
    bne  x30, x0, delay_loop # if not zero, loop again  
    ret