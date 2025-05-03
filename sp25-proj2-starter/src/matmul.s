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
    blt a1, t0, exit1
    blt a2, t0, exit1
    blt a4, t0, exit1
    blt a5, t0, exit1
    
    bne a2, a4, exit1
    # Prologue
    addi sp, sp, -40
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw ra, 36(sp)
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
    mv s5, a5
    mv s6, a6
    mv s7, a3
    mv s8, a0

    # represent i
    li t0, 0
outer_loop_start:   
    # represent j
    li t1, 0
    bge t0, s1, outer_loop_end
    mv s0, s8
    mul t3, t0, s2
    slli t3, t3, 2
    add s0, s0, t3

    
inner_loop_start:
    bge t1, s5, inner_loop_end
    mv s3, s7
    slli t2, t1, 2
    add s3, s3, t2
    # before calliing dot
    mv a0, s0
    mv a1, s3
    mv a2, s2
    li a3, 1
    mv a4, s5

    # prologue
    addi sp, sp, -8
    sw t0, 0(sp)
    sw t1, 4(sp)

    jal dot
    sw a0, 0(s6)
    addi s6, s6, 4

    # epilogue
    lw t0, 0(sp)
    lw t1, 4(sp)
    addi sp, sp, 8
    # after calling dot

    addi t1, t1, 1 
    j inner_loop_start
inner_loop_end:
    addi t0, t0, 1
    j outer_loop_start
outer_loop_end:
    # Epilogue
    lw ra, 36(sp)
    lw s8, 32(sp)
    lw s7, 28(sp)
    lw s6, 24(sp)
    lw s5, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 40
    jr ra

exit1:
    li a0, 38
    j exit