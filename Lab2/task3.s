.text 

.globl main 


main: 

addi x22, x0, 0 #i=0 
addi x5, x0, 0x200 # array a 
addi x6, x0, 10 #for comparison for stopping loop 

loop1: 

bge x22, x6, exit_loop1 
slli x7, x22, 2  # offset by 4 as integer is 4 byte 
add x7, x5, x7 #adding base address to offset 
sw x22, 0(x7) # storing a[i]=i 
addi x22, x22, 1 #i++ 

j loop1 

exit_loop1:  

addi x22, x0, 0 #i=0 
addi x23, x0, 0 #sum=0 
addi x5, x0, 0x200 # array a 
addi x6, x0, 10 #for comparison for stopping loop 

loop2: 

bge x22, x6, exit_loop2 
slli x7, x22, 2  # offset by 4 as integer is 4 byte 
add x7, x5, x7 #adding base address to offset 
lw x8, 0(x7) # loading a[i]
add x23, x23, x8 #sum=sum+a[i] 
addi x22, x22, 1 #i++ 
j loop2 

exit_loop2: 