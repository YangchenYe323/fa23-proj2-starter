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
    # Check malformed input
    li t0, 1
    blt a2, t0, malformed_input_element
    blt a3, t0, malformed_input_stride
    blt a4, t0, malformed_input_stride

    # BEGIN PROLOGUE:
    # s0: current index in arr0
    # s1: current index in arr1
    # s2: dot product value
    addi sp, sp, -12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    # END PROLOGUE

    mv s0, x0
    mv s1, x0
    mv s2, x0

loop_start:
    beq a2, x0, loop_end
    
    # Compute the address of the current element
    # Fetch current element from both arrays
    # Multiply, add to dot product
    li t0, 4
    mul t1, s0, t0
    mul t2, s1, t0
    add t1, t1, a0
    add t2, t2, a1
    lw t1, 0(t1)
    lw t2, 0(t2)
    mul t1, t1, t2
    add s2, s2, t1

    # Increment index
    add s0, s0, a3
    add s1, s1, a4
    addi a2, a2, -1

    jal x0, loop_start

loop_end:
    mv a0, s2

    # BEGIN EPILOGUE:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp, sp, 12
    # END EPILOGUE 
    jr ra

malformed_input_element:
    li a0, 36
    jal x0, exit

malformed_input_stride:
    li a0, 37
    jal x0, exit