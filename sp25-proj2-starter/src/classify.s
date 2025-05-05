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
    addi sp, sp, -52
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
    sw s11, 44(sp)
    sw ra, 48(sp)

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
    mv t0, a0
    lw a0, 4(s0)
    lw a1, 0(t0)
    lw a2, 4(t0)
    jal read_matrix
    mv s2, a0
    mv s3, a1
    mv s4, a2
    # Read pretrained m1
    li a0, 8
    jal malloc
    li t0, 0
    beq a0, t0, exit_mal
    mv t0, a0
    lw a0, 8(s0)
    lw a1, 0(t0)
    lw a2, 4(t0)
    jal read_matrix
    mv s5, a0
    mv s6, a1
    mv s7, a2
    # Read input matrix
    li a0, 8
    jal malloc
    li t0, 0
    beq a0, t0, exit_mal
    mv t0, a0
    lw a0, 12(s0)
    lw a1, 0(t0)
    lw a2, 4(t0)
    jal read_matrix
    mv s8, a0
    mv s9, a1
    mv s10, a2
    # Compute h = matmul(m0, input)
    # malloc space for h
    mul a0, s3, s10
    jal malloc
    li t0, 0
    beq a0, t0, exit_mal
    mv s11, a0

    mv a0, s2
    mv a1, s3
    mv a2, s4
    mv a3, s5
    mv a4, s4
    mv a5, s10
    mv a6, s11
    jal matmul
    # Compute h = relu(h)
    mv a0, s11
    mul a1, s3, s4
    jal relu
    # Compute o = matmul(m1, h)
    mul a0, s6, s10
    jal malloc
    li t0 0
    beq a0, t0, exit_mal
    mv s9, a0

    mv a0, s5
    mv a1, s6
    mv a2, s7
    mv a3, s11
    mv a4, s3
    mv a5, s10
    mv a6, s9
    jal matmul

    # Write output matrix o
    lw a0, 16(s1)
    mv a1, s9
    mv a2, s6
    mv a3, s10
    jal write_matrix
    # Compute and return argmax(o)
    mv a0, s9
    mul a1, s6, s10
    jal argmax
    mv s0, a0
    # If enabled, print argmax(o) and newline
    li t0, 1
    bne s1, t0, exit_pri
    mv a0, s0
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
    jal free
    mv a0, s11
    jal free
    mv a0, s0

    lw ra, 48(sp)
    lw s11, 44(sp)
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
    addi sp, sp, 52
    jr ra

exit_arg:
    li a0, 31
    j exit

exit_mal:
    li a0, 26
    j exit
