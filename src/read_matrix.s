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
    # BEGIN PROLOGUE
    # s0: pointer to number of rows
    # s1: pointer to number of columns
    # s2: file descriptor
    # s3: size of the buffer
    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw ra, 16(sp)
    # END PROLOGUE

    mv s0, a1
    mv s1, a2

    # Open the file and save file descriptor
    # a0 is already the file path
    # a1: read permission
    li a1, 0
    jal ra fopen
    blt a0, x0, exit_bad_fopen
    mv s2, a0

    # Read the first two 4-byte from the file and interpret
    # as row and column
    mv a0, s2
    mv a1, s0
    li a2, 4
    jal ra, fread
    li t0, 4
    bne a0, t0, exit_bad_fread
    mv a0, s2
    mv a1, s1
    li a2, 4
    jal ra, fread
    li t0, 4
    bne a0, t0, exit_bad_fread

    # Allocate memory buffer based on the read size of the matrix
    # size = row * column * 4
    # t0: size of the buffer
    lw t0, 0(s0)
    lw t1, 0(s1)
    mul t0, t0, t1
    slli t0, t0, 2
    mv s3, t0
    mv a0, t0
    jal ra, malloc
    beqz a0, exit_bad_malloc
    mv t0, a0
    
    # Read matrix data to the buffer
    # BEGIN CALLER PROLOGUE
    addi sp, sp, -4
    sw t0, 0(sp)
    # END CALLER PROLOGUE

    mv a0, s2 # a0: file descriptor
    mv a1, t0 # a1: pointer to buffer
    mv a2, s3 # a2: number of bytes to be read
    jal ra fread
    bne a0, s3, exit_bad_fread

    # BEGIN CALLER EPILOGUE
    lw t0, 0(sp)
    addi sp, sp, 4
    # END CALLER EPILOGUE

    # Call fclose
    addi sp, sp, -4
    sw t0, 0(sp)

    mv a0, s2
    jal ra, fclose
    blt a0, x0, exit_bad_fclose

    lw t0, 0(sp)
    addi sp, sp, 4

    # Return pointer to buffer
    mv a0, t0

    # BEGIN EPILOGUE
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20
    # END EPILOGUE

    jr ra

exit_bad_malloc:
    li a0, 26
    jal x0, exit

exit_bad_fopen:
    li a0, 27
    jal x0, exit

exit_bad_fclose:
    li a0, 28
    jal x0, exit

exit_bad_fread:
    li a0, 29
    jal x0, exit