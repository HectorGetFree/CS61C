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
    # Prologue
    li t0, 1
    blt a1, t0, exit

    # 复制数组起始地址
    addi t5, a0, 0
    # 设置初始索引
    lw t6, 0(a0)
    li a0, 0
loop_start:
    bge t0, a1, loop_end
    # 设置偏移量
    slli t2, t0, 2
    # 设置地址
    add t3, t5, t2
    # 储存值
    lw t4, 0(t3)
    # 进行比较
    bge t6, t4, loop_continue
    # 更新最大索引
    mv t6, t4
    mv a0, t0
loop_continue:
    addi t0, t0, 1
    jal x0, loop_start
loop_end:
    # Epilogue
    jr ra
exit:
    li a0, 36
    ecall