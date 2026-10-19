.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    #registers:
    # s0: pointer to m0
    # s1: pointer m1
    # s2: pointer to input
    # s3: pointer to string of output
    # s4: silent mode
    # s5: pointer to h, malloced
    # s6: pointer to o, malloced
    # s7: elems in o

    li t0, 5 # there should be 5 args
    bne a0, t0, incorrect_args # checkargs
    
    addi sp, sp, -80
    sw ra, 0(sp) 
    sw s0, 4(sp) 
    sw s1, 8(sp) 
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    # 36: m0 row
    # 40: m0 col
    # 44: m1 row
    # 48: m1 col
    # 52: input row
    # 56: input col
    # 60: elems in h
    # 64: final output

    lw a0, 4(a1) # pointer to string of m0
    lw s1, 8(a1) # pointer to string of m1
    lw s2, 12(a1) # pointer to string of input
    lw s3, 16(a1) # pointer to string of output
    mv s4, a2 # stores silent mode identifier
    
    # Read pretrained m0
    # a0 is already stored
    addi a1, sp, 36 # place to store pointer for m0 row
    addi a2, sp, 40 # place to store pointer for m0 col
    jal ra read_matrix
    mv s0, a0 # save the pointer to m0
    

    # Read pretrained m1
    mv a0, s1 # set pointer to m1 string
    addi a1, sp, 44 # place to store pointer for m1 row
    addi a2, sp, 48 # place to store pointer for m1 col
    jal ra read_matrix
    mv s1, a0 # save pointer to m1

    # Read input matrix
    mv a0, s2 # set pointer to m1 string
    addi a1, sp, 52 # place to store pointer for input row
    addi a2, sp, 56 # place to store pointer for input col
    jal ra read_matrix
    mv s2, a0 # save pointer to input

    # Compute h = matmul(m0, input)
    
    lw a0, 36(sp) # row of m0
    lw a1, 56(sp) # col of input
    mul a0, a0, a1 # num of elem in h
    sw a0, 60(sp) # store num of elem in stack
    slli a0, a0, 2 # 4 bytes per int
    
    jal ra malloc
    beq a0, zero, malloc_error # if return 0 then error
    
    mv s5, a0 # store pointer to h in s5
    mv a6, a0 # pointer to h would be at a6
    mv a0, s0 # pointer to m0
    lw a1, 36(sp) # row of m0
    lw a2, 40(sp) # col of m0
    mv a3, s2 # pointer to input
    lw a4, 52(sp) # input row
    lw a5, 56(sp) # input col
    jal ra matmul

    # Compute h = relu(h)
    mv a0, s5 # set pointer to h as a0
    lw a1, 60(sp) # get elems in h
    jal ra relu

    # Compute o = matmul(m1, h)
    
    lw a0, 44(sp) # row of m1
    lw a1, 56(sp) # col of h, also col of input
    mul a0, a0, a1 # num of elem in o
    mv s7, a0 # save elem in o to s7S
    slli a0, a0, 2 # 4 bytes per int
    
    jal ra malloc
    beq a0, zero, malloc_error # if return 0 then error
    
    mv s6, a0 # store pointer to o in s6
    mv a6, a0 # pointer to o would be at a6
    mv a0, s1 # pointer to m1
    lw a1, 44(sp) # row of m1
    lw a2, 48(sp) # col of m1
    mv a3, s5 # pointer to h
    lw a4, 36(sp) # row of m0
    lw a5, 56(sp) # input col
    jal ra matmul
    
    # Write output matrix o
    mv a0, s3 # pointer to output string
    mv a1, s6 # pointer to matrix o
    lw a2, 44(sp) # num of rows for o, equiv to row m1
    lw a3, 56(sp) # num of cols for o, equiv to col input
    jal ra write_matrix


    # Compute and return argmax(o)
    mv a0, s6 # set pointer to matrix o
    mv a1, s7 # num of elem in matrix o
    jal ra argmax
    sw a0, 64(sp)

    # If enabled, print argmax(o) and newline
    
    bne s4, zero, end # if set to 0, print, not 0, skip and print nothing
    jal ra print_int # print the classification
    li a0 '\n'
    jal ra print_char # print newline
    
end:
    mv a0, s5 # free h
    jal ra free
    mv a0, s6 # free o
    jal ra free
    
    lw ra, 0(sp) 
    lw s0, 4(sp) 
    lw s1, 8(sp) 
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw a0, 64(sp)
    addi sp, sp, 80
    
    jr ra

incorrect_args:
    li a0, 31
    j exit

malloc_error:
    li a0, 26
    j exit