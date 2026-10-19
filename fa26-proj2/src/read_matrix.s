.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    #registers:
    # s0: file descriptor
    # s1: pointer to number of rows
    # s2: pointer to number of cols
    # s3: size of memory to allocate
    # s4: pointer to matrix in memory
    # s5
    # s6
    # s7

    # Prologue

    addi sp, sp, -32
    sw ra, 0(sp) 
    sw s0, 4(sp) 
    sw s1, 8(sp) 
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)


    mv s1, a1 # pointer to rows
    mv s2, a2 # pointer to cols
    
    li a1, 0 # setting up read permission
    jal ra fopen # call fopen with read permission
    li a1, -1 # -1 comparator for error
    beq a0, a1, fopen_error # check for fopen errors
    
    mv s0, a0 # store the descriptor to s0
    
    mv a1, s1 # setting up arg for fread, read row num
    li a2, 4 # read 4 bytes
    
    jal ra fread
    li a1, 4 # suppose to read 4 bytes from file
    bne a0, a1, fread_error # if not then error
    
    mv a0, s0 # recover file descriptor
    mv a1, s2 # setting up arg for fread, read col num
    li a2, 4 # read 4 bytes
    
    jal ra fread
    li a1, 4 # suppose to read 4 bytes from file
    bne a0, a1, fread_error # if not then error
    
    lw t0, 0(s1) # get row from pointer
    lw t1, 0(s2) # get col from pointer
    mul t0, t0, t1 # find the total num of ints
    slli s3, t0, 2 # every int occupy 4 byte
    
    mv a0, s3 # size of memory
    jal ra malloc
    beq a0, zero, malloc_error # if return 0 then error
    
    mv s4, a0 # store the matrix pointer
    mv a1, s4 # move the returned memory pointer to a1 for fread
    mv a0, s0 # recover file descriptor
    mv a2, s3 # s3 stores the size of memory, which is also how many bytes we want to read
    jal ra fread
    bne a0, s3, fread_error # if not then error
    
    mv a0, s0 # recover file descriptor
    jal ra fclose
    bne a0, zero, fclose_error
 
    # Epilogue
    mv a0, s4 # return matrix pointer
    
    lw ra, 0(sp) 
    lw s0, 4(sp) 
    lw s1, 8(sp) 
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 32
    
    jr ra
    
    
malloc_error:
    li a0, 26
    j exit
    
fopen_error:
    li a0, 27
    j exit

fclose_error:
    li a0, 28
    j exit
    
fread_error:
    ebreak
    li a0, 29
    j exit
