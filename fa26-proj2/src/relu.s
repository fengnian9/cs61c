.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    mv t0, a1 # stores the number of elements in the array, this also acts as counter
    mv t1, a0 # stores address shifts
    blt zero, a1, loop_start # if size of array > 0, start the loop
    li a0, 36 # else a0 would be 36
    j exit


loop_start:
    beq zero, t0, loop_end # loop finishes if counter == 0
    lw t2, 0(t1) # gets the int from address
    bge t2, zero, loop_continue # skip if positive
    sw zero, 0(t1) # replace with 0

loop_continue:
    addi t1, t1, 4 # increments the address
    addi t0, t0, -1 # decrements the counter
    j loop_start

    




loop_end:
    # Epilogue


    jr ra
