    .text
    .globl main
main:
    addi t0, x0, 10         # t0 = 10
    addi t1, x0, 20         # t1 = 20
    auipc ra, 0             # 获取当前 PC 到 ra（用于后面计算返回地址）
    addi ra, ra, 12         # ra = 当前 PC + 12 （指向 return 地址）
    jalr x0, func           # 跳转到函数 func，不保存返回地址（演示纯跳转）

    # 以下内容是跳转后执行的“主程序继续处”
    addi t2, x0, 99         # t2 = 99 (被跳过，如果 jalr 生效)

# 函数 func：
func:
    add t2, t0, t1          # t2 = t0 + t1 = 30
    jalr x0, ra, 0          # 返回（模拟手动跳回 ra，注意：这里 x0 表示丢弃返回地址）