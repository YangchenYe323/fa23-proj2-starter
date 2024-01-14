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
    # Error checks
    li t0, 1
    # Exit if either input matrix's height or weight is less then 1
    blt a1, t0, exit_bad
    blt a2, t0, exit_bad
    blt a4, t0, exit_bad
    blt a5, t0, exit_bad
    # Exit if the width of m1 is different from the height of m2 
    bne a2, a4, exit_bad

    # BEGIN PROLOGUE
    # s0: current row index of the output matrix
    # s1: current column index of the output matrix
    # s2: height_m0
    # s3: width_m0 = height_m1
    # s4: width_m1
    # s5: addr of m0
    # s6: addr of m1
    # s7: addr of d
    addi sp, sp, -36
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw ra, 32(sp)
    # END PROLOGUE

    mv s2, a1
    mv s3, a2
    mv s4, a5
    mv s5, a0
    mv s6, a3
    mv s7, a6

    li s0, 0
outer_loop_start:
    # for s0 in 0..height_m0
    beq s0, s2, outer_loop_end
    li s1, 0
inner_loop_start:
    # for s1 in 0..width_m1
    beq s1, s4, inner_loop_end 

    # Compute the ith row and jth column of the output matrix
    # d[i][j] = m0[i][..] * m1[..][j]
    # Compute the start address of the ith row of m0: a0 + (i * width_m0) * 4
    mul t0, s0, s3
    slli t0, t0, 2
    add t0, s5, t0
    # Compute the start address of the jth column of m1: a3 + j * 4
    slli t1, s1, 2
    add t1, s6, t1
    # Number of element: width_m0 = height_m1
    # Stride for the ith row of m1: 1
    # Stride for the jth column of m2: width_m1

    # Call dot to calculate dot product
    mv a0, t0
    mv a1, t1
    mv a2, s3
    li a3, 1
    mv a4, s4
    jal ra, dot

    # Write dot to the ith row and jth column of the output
    # Compute start address of the ith row and jth column of
    # the output matrix: d + (i * width_d + j) * 4
    mul t0, s0, s4
    add t0, t0, s1
    slli t0, t0, 2
    add t0, s7, t0
    sw a0, 0(t0)

    # Increment s1
    addi s1, s1, 1
    j inner_loop_start

inner_loop_end:
    # Increment s0
    addi s0, s0, 1   
    j outer_loop_start

outer_loop_end:
    # BEGIN EPILOGUE
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw ra, 32(sp)
    addi sp, sp, 36
    # END EPILOGUE

    jr ra

exit_bad:
    li a0, 38
    jal x0, exit