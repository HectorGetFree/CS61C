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
    # Prologue
    li t0, 1
    blt a2, t0, exit1
    blt a3, t0, exit2
    blt a4, t0, exit2

    li t0, 0
    li t1, 0
    li t2, 0
    mv t3, a0
    li a0, 0
loop_start:
    bge t2, a2, loop_end
    slli t4, t0, 2
    slli t5, t1, 2
    add t4, t3, t4
    add t5, a1, t5

    lw t4, 0(t4)
    lw t5, 0(t5)
    mul t4, t4, t5
    add a0, a0, t4

    add t0, t0, a3
    add t1, t1, a4
    addi t2, t2, 1
    j loop_start
loop_end:
    # Epilogue
    jr ra

exit1:
    li a0, 36       # exit code
    j exit

exit2:
    li a0, 37
    j exit
