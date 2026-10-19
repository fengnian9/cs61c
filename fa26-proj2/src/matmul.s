.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    #
    #registers:
    # s0: m0 pointer
    # s1: m1 pointer
    # s2: d pointer
    # s3: row of m0
    # s4: col of m0 and height of m1
    # s5: col of m1
    # s6: row counter
    # s7: col counter
    
    # Error checks
    ble a1, zero, exceptions
    ble a2, zero, exceptions
    ble a4, zero, exceptions
    ble a5, zero, exceptions
    bne a2, a4, exceptions
    
    # Prologue
    addi sp, sp, -48
    sw ra, 0(sp) # since i have to call dot, i need to save ra
    sw s0, 4(sp) 
    sw s1, 8(sp) 
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    
    
    mv s0, a0 # m0 pointer
    mv s1, a3 # m1 pointer
    mv s2, a6 # d pointer
    mv s3, a1 # m0 row
    mv s4, a2 # m0 col, m1 row
    mv s5, a5 # m1 col
    li s6, 0 # row counter


    

outer_loop_start:

    li s7, 0 # col counter
    mv t0, s0 # t0 stores the current address of m0
    mul t1, s6, s4 # calculates offset
    slli t1, t1, 2 # calculates byteshift
    add t0, t0, t1 # adds the offset

inner_loop_start:
    beq s5, s7, outer_loop_end
    # prologue
    sw t0, 36(sp)
    mv a0, t0 # pointer to the start of arr 0
    slli t1, s7, 2 # calculate offset for arr1
    add a1, s1, t1 # pointer to the start of arr 1
    mv a2, s4 # num of elem to use, equal to col m0/ row m1
    li a3, 1 # stride for m0, always 1
    mv a4, s5 # stride for m1 would always be col of m1
    jal ra dot
    

inner_loop_end:
    #epilogue
    lw t0, 36(sp)
    addi s7, s7, 1 # increment counter by 1
    sw, a0, 0(s2) # store the returned value to d
    addi s2, s2, 4 # increment d pointer
    j inner_loop_start
    




outer_loop_end:
    addi s6, s6, 1
    blt s6, s3, outer_loop_start # if counter reaches row number, then finish

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    addi sp, sp, 48

    jr ra

exceptions:
    li a0 38
    j exit
    
