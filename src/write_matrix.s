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
    # BEGIN PROLOGUE
    # s0: pointer to the matrix in memory
    # s1: file descriptor
    # 0(sp): number of rows in the matrix
    # 4(sp): number of columns in the matrix
    addi sp, sp, -20
    sw a2, 0(sp)
    sw a3, 4(sp)
    sw s0, 8(sp)
    sw s1, 12(sp)
    sw ra, 16(sp)
    # END PROLOGUE

    mv s0, a1

    # a0: file path
    li a1, 1 # a1: write permission
    jal ra, fopen
    blt a0, x0, exit_bad_fopen
    mv s1, a0

    # write number of rows
    # a0: file descriptor
    addi a1, sp, 0 # a1: address of the buffer
    li a2, 1
    li a3, 4
    jal ra, fwrite
    li t0, 1
    bne a0, t0, exit_bad_fwrite

    # write number of rows
    mv a0, s1
    addi a1, sp, 4
    li a2, 1
    li a3, 4
    jal ra, fwrite
    li t0, 1
    bne a0, t0, exit_bad_fwrite

    # write buffer
    # number of items: row * col
    lw t0, 0(sp)
    lw t1, 4(sp)
    mul t0, t0, t1

    # BEGIN CALLER PROLOGUE
    addi sp, sp, -4
    sw t0, 0(sp)
    # END CALLER PROLOGUE

    mv a0, s1
    mv a1, s0
    mv a2, t0
    li a3, 4
    jal ra, fwrite
    
    # BEGIN CALLER EPILOGUE
    lw t0, 0(sp)
    addi sp, sp, 4
    # END CALLER EPILOGUE

    bne a0, t0, exit_bad_fwrite

    # Call fclose
    mv a0, s1
    jal ra, fclose
    blt a0, x0, exit_bad_fclose

    # BEGIN EPILOGUE
    lw s0, 8(sp)
    lw s1, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20
    # END EPILOGUE

    jr ra

exit_bad_fopen:
    li a0, 27
    jal x0, exit

exit_bad_fclose:
    li a0, 28
    jal x0, exit

exit_bad_fwrite:
    li a0, 30
    jal x0, exit