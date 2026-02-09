addi x10, x0, 0x100     # x10 = a = base address of array 
addi x11, x0, 10        # x11 = 10, size of array
 
addi x1, x0, 23 
sw x1, 0(x10) 
addi x1, x0, 12 
sw x1, 4(x10) 
addi x1, x0, 5 
sw x1, 8(x10) 
addi x1, x0, 44 
sw x1, 12(x10) 
addi x1, x0, 98 
sw x1, 16(x10) 
addi x1, x0, 53 
sw x1, 20(x10) 
addi x1, x0, 6 
sw x1, 24(x10) 
addi x1, x0, 89 
sw x1, 28(x10) 
addi x1, x0, 32 
sw x1, 32(x10) 
addi x1, x0, 65
sw x1, 36(x10) 
beq x10, x0, exit      # if a==NULL, return
beq x11, x0, exit      # if len==0, return 
addi x5, x0, 0         # i=0 

outer_loop:            # for (int i = 0; i < len; i++) 
bge x5, x11, exit      # if i >= len, exit 
addi x22, x5, 0        # j=i 

inner_loop:             
bge x22, x11, else      # if j >= len, exit inner loop 
slli x7, x5, 2          # offset (i*4) 
add x7, x10, x7         #adding base address to offset
lw x8, 0(x7)            #a[i] 
slli x6, x22, 2         # offset (j*4) 
add x6, x10, x6         # adding base address to offset 
lw x28, 0(x6)           # a[j] 
 
bge x8, x28, no_swap    # if a[i] >= a[j], no swap 
addi x29, x8, 0         # x29=temp, temp=a[i] 
sw x28, 0(x7)           # a[i]=a[j] 
sw x29, 0(x6)           # a[j]=temp 
 
no_swap: 
addi x22, x22, 1        # j++ 
j inner_loop
else: 
addi x5, x5, 1          # i++ 
j outer_loop 
exit: 