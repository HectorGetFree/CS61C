.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    # Prologue
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

    mv s0, a0
    mv s1, a1
    mv s2, a2

    # open the file
    li a1, 0
    jal fopen
    li s3, -1
    beq a0, s3, exit_1
    mv s3, a0

    # read the row and the col
    mv a1, s1
    li a2, 4
    jal fread
    li s4, 4
    bne s4, a0, exit_2

    mv a0, s3
    mv a1, s2
    li a2, 4
    jal fread
    bne s4, a0, exit_2
    lw s1, 0(s1)
    lw s2, 0(s2)
    
    # malloc
    mul s5, s1, s2
    slli s5, s5, 2
    mv a0, s5
    jal malloc
    beq a0, x0, exit_3
    mv s6, a0

    # the total number of integers
    mul s5, s1, s2

    # i = 0
    li s4, 0

    # set pointer
    mv s7, s6

    # read data
loop_start:
    mv a0, s3
    mv a1, s7
    li a2, 4
    jal fread
    li t0, 4
    bne t0, a0, exit_2
    addi s4, s4, 1
    beq s4, s5, loop_end
    addi s7, s7, 4
    j loop_start
loop_end:
    # close the file
    mv a0, s3
    jal fclose
    li t0, -1
    beq a0, t0, exit_4
    mv a0, s6
    # Epilogue
    lw ra, 32(sp)
    lw s7, 28(sp)
    lw s6, 24(sp)
    lw s5, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 36
    jr ra

exit_1:
    li a0, 27
    j exit

exit_2:
    li a0, 29
    j exit

exit_3:
    li a0, 26
    j exit

exit_4:
    li a0, 28
    j exit