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
    # Validate number of argument
    li t0, 5
    bne a0, t0, exit_bad_argument

    # BEGIN PROLOGUE
    # ra: 0(sp)
    # height_m0: 4(sp)
    # width_m0: 8(sp)
    # height_m1: 12(sp)
    # width_m1: 16(sp)
    # height_input: 20(sp)
    # width_input: 24(sp)
    # height_output = height_m1
    # width_output = width_input
    # s0: pointer to the input matrix
    # s1: pointer to m0
    # s2: pointer to m1
    # s3: pointer to matmul(m0, input)
    # s4: pointer to output matrix
    # s5: pointer to an array of argument strings 
    # s6: If set to 0, print out the classification.
    addi sp, sp -56
    sw ra, 0(sp)
    sw s0, 28(sp)
    sw s1, 32(sp)
    sw s2, 36(sp)
    sw s3, 40(sp)
    sw s4, 44(sp)
    sw s5, 48(sp)
    sw s6, 52(sp)
    # END PROLOGUE

    mv s5, a1
    mv s6, a2

    # Read pretrained m0
    # m0 is stored at path s5[1]
    # height_m0: 4(sp), width_m0: 8(sp)
    addi a0, s5, 4
    lw a0, 0(a0)
    addi a1, sp, 4
    addi a2, sp, 8
    jal ra, read_matrix
    mv s1, a0

    # Read pretrained m1
    # m1 is stored at path s5[2]
    # height_m1: 12(sp), width_m1: 16(sp)
    addi a0, s5, 8
    lw a0, 0(a0)
    addi a1, sp, 12
    addi a2, sp, 16
    jal ra, read_matrix
    mv s2, a0

    # Read input matrix
    # input is stored at path s5[3]
    # height_input: 20(sp), width_input: 24(sp)
    addi a0, s5, 12
    lw a0, 0(a0)
    addi a1, sp, 20
    addi a2, sp, 24
    jal ra, read_matrix
    mv s0, a0

    # Allocate h, sizeof(h) = (height_m0 * width_input) * 4
    lw t0, 4(sp)
    lw t1, 24(sp)
    mul t0, t0, t1
    slli t0, t0, 2
    mv a0, t0
    jal ra, malloc
    beqz a0, exit_bad_malloc
    # Store &h to s3
    mv s3, a0

    # Compute h = matmul(m0, input)
    mv a0, s1
    lw a1, 4(sp)
    lw a2, 8(sp)
    mv a3, s0
    lw a4, 20(sp)
    lw a5, 24(sp)
    mv a6, s3
    jal ra, matmul

    # Compute h = relu(h)
    lw t0, 4(sp)
    lw t1, 24(sp)
    mul t0, t0, t1
    mv a0, s3
    mv a1, t0
    jal ra, relu

    # Allocate o, sizeof(o) = (height_m1 * width_input) * 4
    lw t0, 12(sp)
    lw t1, 24(sp)
    mul t0, t0, t1
    slli t0, t0, 2
    mv a0, t0
    jal ra, malloc
    beqz a0, exit_bad_malloc
    mv s4, a0

    # Compute o = matmul(m1, h)
    mv a0, s2
    lw a1, 12(sp)
    lw a2, 16(sp)
    mv a3, s3
    lw a4, 4(sp)
    lw a5, 24(sp)
    mv a6, s4
    jal ra, matmul

    # Write output matrix o
    # output matrix is stored at s5[4]
    addi a0, s5, 16
    lw a0, 0(a0)
    mv a1, s4
    lw a2, 12(sp)
    lw a3, 24(sp)
    jal ra, write_matrix

    # Compute and return argmax(o)
    lw t0, 12(sp)
    lw t1, 24(sp)
    mv a0, s4
    mul a1, t0, t1
    jal ra, argmax
    # Now a0: argmax(o)

    # If enabled, print argmax(o) and newline
    bne s6, x0, finish
    
    # BEGIN CALLER PROLOGUE
    addi sp, sp, -4
    sw a0, 0(sp)
    # END CALLER PROLOGUE

    jal ra, print_int
    li a0, '\n'
    jal ra, print_char

    # BEGIN CALLER EPILOGUE
    lw a0, 0(sp)
    addi sp, sp, 4
    # END CALLER EPILOGUE
  
  finish:
    # BEGIN EPILOGUE
    lw ra, 0(sp) 
    lw s0, 28(sp)
    lw s1, 32(sp)
    lw s2, 36(sp)
    lw s3, 40(sp)
    lw s4, 44(sp)
    lw s5, 48(sp)
    lw s6, 52(sp)
    addi sp, sp 56
    # END EPILOGUE

    jr ra

exit_bad_malloc:
    li a0, 26
    jal x0, exit

exit_bad_argument:
    li a0, 31
    jal x0, exit