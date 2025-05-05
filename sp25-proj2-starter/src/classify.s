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
    addi sp, sp, -48
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw s10, 40(sp)
    sw ra, 44(sp)

    li t0, 5
    bne a0, t0, exit_arg
    
    mv s0, a1
    mv s1, a2
    
    # Read pretrained m0
    # malloc for the argument
    li a0, 8
    jal malloc
    li t0, 0
    beq a0, t0, exit_mal
    mv s2, a0
    lw a0, 4(s0)
    addi a1, s2, 0
    addi a2, s2, 4
    jal read_matrix
    mv s3, a0
    # do not try to use the a register directly after the function call
    # Read pretrained m1
    li a0, 8
    jal malloc
    li t0, 0
    beq a0, t0, exit_mal
    mv s4, a0
    lw a0, 8(s0)
    # want to get the address
    # don't try to lw
    # but using offset
    addi a1, s4, 0
    addi a2, s4, 4
    jal read_matrix
    mv s5, a0
    # Read input matrix
    li a0, 8
    jal malloc
    li t0, 0
    beq a0, t0, exit_mal
    mv s6, a0
    lw a0, 12(s0)
    addi a1, s6, 0
    addi a2, s6, 4
    jal read_matrix
    mv s7, a0
    # Compute h = matmul(m0, input)
    # malloc space for h
    lw t0, 0(s2)
    lw t1, 4(s6)
    mul a0, t0, t1
    slli a0, a0, 2
    jal malloc
    li t0, 0
    beq a0, t0, exit_mal
    mv s8, a0

    mv a0, s3
    lw a1, 0(s2)
    lw a2, 4(s2)
    mv a3, s7
    lw a4, 0(s6)
    lw a5, 4(s6)
    mv a6, s8
    jal matmul
    # Compute h = relu(h)
    lw t0, 0(s2)
    lw t1, 4(s6)
    mul a1, t0, t1
    jal relu
    # Compute o = matmul(m1, h)
    lw t0, 0(s4)
    lw t1, 4(s6)
    mul a0, t0, t1
    jal malloc
    li t0 0
    beq a0, t0, exit_mal
    mv s9, a0

    mv a0, s5
    lw a1, 0(s4)
    lw a2, 4(s4)
    mv a3, s8
    lw a4, 0(s2)
    lw a5, 4(s6)
    mv a6, s9
    jal matmul

    # Write output matrix o
    lw a0, 16(s0)
    mv a1, s9
    lw a2, 0(s4)
    lw a3, 4(s6)
    jal write_matrix
    # Compute and return argmax(o)
    mv a0, s9
    lw t0, 0(s4)
    lw t1, 4(s6)
    mul a1, t0, t1
    jal argmax
    mv s10, a0
    # If enabled, print argmax(o) and newline
    li t0, 0
    bne s1, t0, exit_pri
    mv a0, s10
    jal print_int

    li a0, '\n'
    jal print_char

exit_pri:
    # free memory
    mv a0, s2
    jal free
    mv a0, s3
    jal free
    mv a0, s4
    jal free
    mv a0, s5
    jal free
    mv a0, s6
    jal free
    mv a0, s7
    jal free
    mv a0, s8
    jal free
    mv a0, s9
    jal free

    mv a0, s10

    lw ra, 44(sp)
    lw s10, 40(sp)
    lw s9, 36(sp)
    lw s8, 32(sp)
    lw s7, 28(sp)
    lw s6, 24(sp)
    lw s5, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 48
    jr ra

exit_arg:
    li a0, 31
    j exit

exit_mal:
    li a0, 26
    j exit
