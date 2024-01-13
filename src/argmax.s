.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Check input
    blt a1, x0, malformed_input
    beq a1, x0, malformed_input

    # Prologue
    
    # t0: index of the biggest element
    # t1: the value of the biggest element
    # t2: index of the current element
    # t3: the value of the current element
    mv t0, x0
    lw t1, 0(t0)
    mv t2, x0
loop_start:
    beq a1, x0, loop_end
    
    # t3: current element
    lw t3, 0(a0)
    # if t3 > t1, update new largest
    blt t1, t3, update_new_max
    jal x0, loop_continue
update_new_max:
    mv t0, t2
    mv t1, t3
loop_continue:
    addi t2, t2, 1
    addi a0, a0, 4
    addi a1, a1, -1
    jal x0, loop_start

loop_end:
    mv a0, t0
    jr ra

malformed_input:
    li a0, 36
    jal x0, exit