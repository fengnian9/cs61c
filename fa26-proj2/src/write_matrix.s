.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    #registers:
    # s0: file descriptor
    # s1: pointer to matrix
    # s2: num of rows
    # s3: num of cols
    
    # Prologue
    addi sp, sp, -32
    sw ra, 0(sp) 
    sw s0, 4(sp) 
    sw s1, 8(sp) 
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    mv s1, a1 # pointer to matrix
    mv s2, a2 # num of rows
    mv s3, a3 # num of cols
    
    li a1, 1 # setting up write permission
    jal ra fopen # call fopen with write permission
    li a1, -1 # -1 comparator for error
    beq a0, a1, fopen_error # check for fopen errors
    
    mv s0, a0 # store the descriptor to s0
    
    sw s2, 24(sp) # store row to memory
    sw s3, 28(sp) # store col to memory
    
    addi a1, sp, 24 # add the offset to stack pointer
    li a2, 2 # num of elem
    li a3, 4 # size of elem

    jal ra fwrite
    li a1, 2 # 2 item should be written
    bne a0, a1, fwrite_error # if not ,error
    
    mv a0, s0, # recover file descriptor
    mv a1, s1 # set a0 to matrix pointer
    
    mul s4, s2, s3 # calculate total num of elems
    mv a2, s4 # set num of elem as arg
    
    li a3, 4 # each int is 4 bytes
    
    jal ra fwrite
    
    bne a0, s4, fwrite_error
    
    mv a0, s0 # recover file descriptor
    jal ra fclose
    bne a0, zero, fclose_error


    # Epilogue
    
    lw ra, 0(sp) 
    lw s0, 4(sp) 
    lw s1, 8(sp) 
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 32
    
    jr ra

    
fopen_error:
    li a0, 27
    j exit

fclose_error:
    li a0, 28
    j exit
    
fwrite_error:
    li a0, 30
    j exit
