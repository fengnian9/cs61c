.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    ble a1, zero, invalid # if size of array <= 0 , exit with 36
    mv t0, a1 # stores the number of elements in the array, this also acts as counter
    mv t1, a0 # stores address shifts
    lw t3, 0(t1) # stores the temp largest
    li t4, 0 # stores the first index of largest elem



loop_start:
    beq zero, t0, loop_end # loop finishes if counter == 0
    lw t2, 0(t1) # gets the int from address
    ble t2, t3, loop_continue # skip if current int <= largest int
    mv t3, t2 # copies the content of current int to temp largest int
    sub t4, a1, t0 # update the value of temp largest
    

loop_continue:
    addi t1, t1, 4 # increments the address
    addi t0, t0, -1 # decrements the counter
    j loop_start
    
loop_end:
    # Epilogue
    mv a0, t4
    jr ra
    
invalid:
    li a0, 36 # exit with 36
    j exit

