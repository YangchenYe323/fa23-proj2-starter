.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Malformed input
    blt a1, x0, malformed_input 
    beq a1, x0, malformed_input

loop_start:
    beq a1, x0, loop_end
    lw t0, 0(a0)

    # Save 0 to the array place if it is smaller than 0
    bge t0, x0, loop_continue
    sw x0, 0(a0)
loop_continue:
    addi a0, a0, 4
    addi a1, a1, -1
    jal x0, loop_start

loop_end:
    jr ra

malformed_input:
    li a0, 36
    jal x0 exit