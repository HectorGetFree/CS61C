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
    # Prologue
    # 检查数组长度是否合理
    li t0, 1
    blt a1, t0, exit 
    # 设置遍历器t0
    li t0, 0
loop_start:
    # 设置退出条件
    bge t0, a1, loop_end
    # 设置int的offset
    slli t2, t0, 2 
    # t3存储地址
    add t3, a0, t2
    # t4存储相应值
    lw t4, 0(t3)
    # 判断正负
    bge t4, x0, loop_continue
    # 检测到是负数 -- 写回数组 
    li t4, 0
    # Note: array is in memory 
    sw t4, 0(t3)
loop_continue:
    addi t0, t0, 1
    jal x0, loop_start
loop_end:
    # Epilogue
    jr ra

exit:
    li a0, 36
    ecall