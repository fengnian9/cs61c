.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    # Register allocation:
    # a0: current pointer to arr0
    # a1: current pointer to arr1
    # a2: number of elements
    # t0: remaining elements
    # t1: accumulated dot product
    # t2: byte stride for arr0
    # t3: byte stride for arr1
    ble a2, zero, size_error # if num of elements <= 0 , exit with 36
    ble a3, zero, stride_error # if stride of arr0 <= 0 , exit with 37
    ble a4, zero, stride_error # if stride of arr1 <= 0 , exit with 37    
    mv t0, a2 # remaining elements
    slli t2, a3, 2
    slli t3, a4, 2
    li t1, 0 # initializing accumulated sum

    
    # Prologue


loop_start:
    lw t4, 0(a0) # gets current value of arr0
    lw t5, 0(a1) # gets current value of arr1
    
    mul t4, t4, t5 # multiply to get dot product
    add t1, t1, t4 # add that to accumulated dot product
    
    addi t0, t0, -1 # decrement remaining elements
    add a0, a0, t2 # increment byte stride for arr0
    add a1, a1, t3 # increment byte stride for arr1
    bgt t0, zero, loop_start 

loop_end:
    mv a0, t1
    # Epilogue
    jr ra
    
stride_error:
    li a0, 37 # exit with 37
    j exit
size_error:
    li a0, 36 # exit with 36
    j exit
