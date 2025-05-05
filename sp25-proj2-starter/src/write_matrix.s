.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
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

    # save the value
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3

    # open the file
    mv a0, s0
    li a1, 1
    jal fopen
    li s4, -1
    beq a0, s4, exit_1
    mv s0, a0

    # write the row and the col first
    # before that we should first store the data into the memory first
    # don't forget to use malloc
    li a0, 8
    jal malloc
    sw s2, 0(a0)
    sw s3, 4(a0)
    mv a0, s0
    mv a1, a0
    li a2, 2
    li a3, 4
    jal fwrite
    li t0, 2
    bne a0, t0, exit_2
    # wirte in the matrix
    mv a0, s0
    mv a1, s1
    mul s5, s2, s3
    mv a2, s5
    li a3, 4
    jal fwrite
    mul t0, s2, s3
    bne a0, t0, exit_2

    # close
    mv a0, s0
    jal fclose
    li t0, -1
    beq a0, t0, exit_3


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
    li a0, 30
    j exit

exit_3:
    li a0, 28
    j exit