    .text
    .globl main
main:
    addi t0, x0, 1         # t0 = 1
    jal x0, skip           # 跳转到 skip 标签，不保存返回地址（rd = x0）

    addi t0, x0, 2         # 不会执行（被跳过）

skip:
    addi t1, x0, 3         # t1 = 3