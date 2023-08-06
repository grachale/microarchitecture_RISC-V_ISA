addi t1, x0, 0 # int i = 0;
lw s2, 4(x0)   # velikost pole n
lw s3, 8(x0)   # ukazatel na pole
lw a4, 0(s3)   # prvni element pole



for:
  beq  t1, s2, done    # if s1 == s2, go to label done and break the cycle 
  jal prime
  sw a0, 0(s3)
  addi s3, s3, 4    # increment offset and move to the other value in the array
  addi t1, t1, 1    # increment number of passes through the cycle (i++)
  lw a4, 0(s3)
  j for          # jump to  **for** label


prime:
 addi t5, x0, 2       # for checking prime number
 beq a4, t5, isPrime
 inFor:
  beq t5, a4, isPrime  # if the element and our checking number equal
  rem t6, a4, t5
  beq t6, x0, notPrime
  addi t5, t5, 1       # increment for checking prime number  
 j inFor
 
 
 notPrime:
  addi a0, x0, 0
  ret
  
isPrime:
  addi a0, x0, 1
  ret
  
  
done:  

inf_loop:
beq x0,x0,inf_loop

