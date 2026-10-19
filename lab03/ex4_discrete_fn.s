.globl f # this allows other files to find the function f

# f takes in two arguments:
# a0 is the value we want to evaluate f at
# a1 is the address of the "output" array (read the lab spec for more information).
# The return value should be stored in a0
f:
    addi t1, a0, 3 # adds 3 to the index, so that I could gain access to every element in the output array by adding the value at t0
    slli t1, t1, 2 # multiply by 4 to calculate address shift
    add t2, a1, t1 # t2 stores the calculated address of desired output
    lw a0, 0(t2) # gets the value
    # This is how you return from a function. You'll learn more about this later.
    # This should be the last line in your program.
    jr ra
