# CS61C — RISC-V 指令集速查

RV64I 基础指令（含常用伪指令），按功能分类整理。参考：[RISC-V 基础指令汇总](https://blog.csdn.net/aLingYun/article/details/133255722)

符号约定：

+ `rd`：目的寄存器；`rs1`/`rs2`：源寄存器
+ `imm`：立即数；`offset`：访存偏移（12 位有符号）；`shamt`：移位量
+ `label`：跳转目标标签；`x0`：恒为 0 的寄存器
+ 基础指令均为 32 位定长；`*w`/`*iw` 是在 64 位寄存器上做 32 位字运算的版本

## 加载指令

| 指令 | 数据位宽/位 | 说明 |
| :--- | :--- | :--- |
| `lb rd, offset(rs1)` | 8 | 以 rs1 的值为基地址，在偏移 offset 处加载一字节数据，经符号扩展后写入 rd |
| `lbu rd, offset(rs1)` | 8 | 在偏移 offset 处加载一字节数据，经零扩展后写入 rd |
| `lh rd, offset(rs1)` | 16 | 在偏移 offset 处加载两字节数据，经符号扩展后写入 rd |
| `lhu rd, offset(rs1)` | 16 | 在偏移 offset 处加载两字节数据，经零扩展后写入 rd |
| `lw rd, offset(rs1)` | 32 | 在偏移 offset 处加载 4 字节数据，经符号扩展后写入 rd |
| `lwu rd, offset(rs1)` | 32 | 在偏移 offset 处加载 4 字节数据，经零扩展后写入 rd |
| `ld rd, offset(rs1)` | 64 | 在偏移 offset 处加载 8 字节数据，写入 rd |
| `lui rd, imm` | 64 | 先把 imm 左移 12 位，再做符号扩展，结果写入 rd |

## 存储指令

| 指令 | 数据位宽/位 | 说明 |
| :--- | :--- | :--- |
| `sb rs2, offset(rs1)` | 8 | 把 rs2 的低 8 位存储到“rs1 的值 + offset”的地址处 |
| `sh rs2, offset(rs1)` | 16 | 把 rs2 的低 16 位存储到“rs1 的值 + offset”的地址处 |
| `sw rs2, offset(rs1)` | 32 | 把 rs2 的低 32 位存储到“rs1 的值 + offset”的地址处 |
| `sd rs2, offset(rs1)` | 64 | 把 rs2 的 64 位值存储到“rs1 的值 + offset”的地址处 |

## PC 相对寻址

```text
auipc rd, imm
```

把 imm 左移 12 位并符号扩展到 64 位，得到新的（有符号）立即数，再加上当前 PC，结果存入 `rd`。

由 `auipc` + `addi`/加载/存储组合出的伪指令：

| 伪指令 | 指令组合 | 说明 |
| :--- | :--- | :--- |
| `la rd, symbol`（非 PIC） | `auipc rd, delta[31:12] + delta[11]`<br>`addi rd, rd, delta[11:0]` | 加载符号的绝对地址，其中 `delta = symbol - pc` |
| `la rd, symbol`（PIC） | `auipc rd, delta[31:12] + delta[11]`<br>`lw/ld rd, delta[11:0](rd)` | 加载符号的绝对地址，其中 `delta = GOT[symbol] - pc` |
| `lla rd, symbol` | `auipc rd, delta[31:12] + delta[11]`<br>`addi rd, rd, delta[11:0]` | 加载符号的本地地址（local address），其中 `delta = symbol - pc` |
| `lb/lh/lw/ld rd, symbol` | `auipc rd, delta[31:12] + delta[11]`<br>`lb/lh/lw/ld rd, delta[11:0](rd)` | 加载符号处的内容 |
| `sb/sh/sw/sd rs2, symbol, rt` | `auipc rt, delta[31:12] + delta[11]`<br>`sb/sh/sw/sd rs2, delta[11:0](rt)` | 把内容存储到符号处，rt 为临时寄存器 |
| `li rd, imm` | 根据情况扩展为多条指令 | 加载立即数 imm 到 rd 中 |

## 移位指令

| 指令 | 说明 |
| :--- | :--- |
| `sll rd, rs1, rs2` | 逻辑左移：rs1 左移 rs2[5:0] 位，结果写入 rd |
| `slli rd, rs1, shamt` | 立即数逻辑左移：rs1 左移 shamt 位 |
| `slliw rd, rs1, shamt` | 取 rs1 的低 32 位左移 shamt 位，32 位结果符号扩展后写入 rd |
| `sllw rd, rs1, rs2` | 取 rs1 的低 32 位左移 rs2[4:0] 位，32 位结果符号扩展后写入 rd |
| `sra rd, rs1, rs2` | 算术右移：rs1 右移 rs2[5:0] 位，按 rs1 原值符号扩展 |
| `srai rd, rs1, shamt` | 立即数算术右移：rs1 右移 shamt 位，结果符号扩展 |
| `sraiw rd, rs1, shamt` | 取 rs1 的低 32 位右移 shamt 位，32 位结果符号扩展后写入 rd |
| `sraw rd, rs1, rs2` | 取 rs1 的低 32 位右移 rs2[4:0] 位，32 位结果符号扩展后写入 rd |
| `srl rd, rs1, rs2` | 逻辑右移：rs1 右移 rs2[5:0] 位，高位零扩展后写入 rd |
| `srli rd, rs1, shamt` | 立即数逻辑右移：rs1 右移 shamt 位，零扩展后写入 rd |
| `srliw rd, rs1, shamt` | 取 rs1 的低 32 位右移 shamt 位，32 位结果符号扩展后写入 rd |
| `srlw rd, rs1, rs2` | 取 rs1 的低 32 位右移 rs2[4:0] 位，32 位结果符号扩展后写入 rd |

> 注意：RV64 中所有 `*w`/`*iw` 指令都把 32 位结果**符号扩展**到 64 位（原文表格里个别写成“零扩展”）。

## 位操作指令

| 指令 | 说明 |
| :--- | :--- |
| `and rd, rs1, rs2` | 按位与，结果写入 rd |
| `andi rd, rs1, imm` | rs1 与立即数按位与，结果写入 rd |
| `or rd, rs1, rs2` | 按位或，结果写入 rd |
| `ori rd, rs1, imm` | rs1 与立即数按位或，结果写入 rd |
| `xor rd, rs1, rs2` | 按位异或，结果写入 rd |
| `xori rd, rs1, imm` | rs1 与立即数按位异或，结果写入 rd |
| `not rd, rs` | 按位取反，结果写入 rd；伪指令，内部使用 `xori rd, rs, -1` |

## 算术指令

| 指令 | 说明 |
| :--- | :--- |
| `add rd, rs1, rs2` | rs1 + rs2，结果写入 rd |
| `addi rd, rs1, imm` | rs1 + imm，结果写入 rd |
| `addw rd, rs1, rs2` | 取 rs1、rs2 的低 32 位相加，32 位结果符号扩展后写入 rd |
| `addiw rd, rs1, imm` | 取 rs1 的低 32 位加 imm，32 位结果符号扩展后写入 rd |
| `sub rd, rs1, rs2` | rs1 - rs2，结果写入 rd |
| `subw rd, rs1, rs2` | 取 rs1、rs2 的低 32 位相减，32 位结果符号扩展后写入 rd |

## 比较指令

| 指令 | 说明 |
| :--- | :--- |
| `slt rd, rs1, rs2` | 有符号比较：若 rs1 < rs2，向 rd 写入 1，否则写入 0 |
| `sltu rd, rs1, rs2` | 无符号比较：若 rs1 < rs2，向 rd 写入 1，否则写入 0 |
| `slti rd, rs1, imm` | 与立即数的有符号比较：若 rs1 < imm 写 1，否则写 0 |
| `sltiu rd, rs1, imm` | 与立即数的无符号比较：若 rs1 < imm 写 1，否则写 0 |

比较类伪指令（与 0 比较）：

| 伪指令 | 说明 |
| :--- | :--- |
| `sltz rd, rs1` | 小于 0 则置位：rs1 < 0 时 rd = 1，否则 rd = 0 |
| `snez rd, rs1` | 不等于 0 则置位：rs1 != 0 时 rd = 1，否则 rd = 0 |
| `seqz rd, rs1` | 等于 0 则置位：rs1 == 0 时 rd = 1，否则 rd = 0 |
| `sgtz rd, rs1` | 大于 0 则置位：rs1 > 0 时 rd = 1，否则 rd = 0 |

## 无条件跳转指令

| 指令 | 说明 |
| :--- | :--- |
| `jal rd, offset` | 跳转并链接：跳转到 PC + offset，并把返回地址（PC + 4）保存到 rd。offset 为 21 位有符号数，跳转范围约为 PC ± 1 MB（PC - 0x10 0000 ~ PC + 0xFF FFFE） |
| `jalr rd, offset(rs1)` | 使用寄存器的跳转：跳转到“rs1 的值 + offset”处，并把返回地址（PC + 4）保存到 rd。offset 为 12 位有符号数，范围 -2048 ~ 2047 |

跳转类伪指令：

| 伪指令 | 指令组合 | 说明 |
| :--- | :--- | :--- |
| `j label` | `jal x0, offset` | 跳转到 label 处，不带返回地址 |
| `jal label` | `jal ra, offset` | 跳转到 label 处，返回地址保存在 ra 寄存器中 |
| `jr rs` | `jalr x0, 0(rs)` | 跳转到 rs 寄存器中的地址处，不带返回地址 |
| `jalr rs` | `jalr ra, 0(rs)` | 跳转到 rs 寄存器中的地址处，返回地址保存在 ra 寄存器中 |
| `ret` | `jalr x0, 0(ra)` | 从 ra 寄存器中获取返回地址并返回，常用于子函数返回 |
| `call func` | `auipc ra, offset[31:12] + offset[11]`<br>`jalr ra, offset[11:0](ra)` | 调用子函数 func，返回地址保存到 ra 中 |
| `tail func` | `auipc x6, offset[31:12] + offset[11]`<br>`jalr x0, offset[11:0](x6)` | 调用子函数 func，不保存返回地址 |

## 条件跳转指令

| 指令 | 说明 |
| :--- | :--- |
| `beq rs1, rs2, label` | rs1 == rs2 时跳转到 label 处 |
| `bne rs1, rs2, label` | rs1 != rs2 时跳转到 label 处 |
| `blt rs1, rs2, label` | rs1 < rs2（有符号）时跳转到 label 处 |
| `bltu rs1, rs2, label` | 与 blt 类似，但 rs1、rs2 为无符号数 |
| `bgt rs1, rs2, label` | rs1 > rs2（有符号）时跳转到 label 处 |
| `bgtu rs1, rs2, label` | 与 bgt 类似，但 rs1、rs2 为无符号数 |
| `bge rs1, rs2, label` | rs1 >= rs2（有符号）时跳转到 label 处 |
| `bgeu rs1, rs2, label` | 与 bge 类似，但 rs1、rs2 为无符号数 |

条件跳转伪指令：

| 伪指令 | 指令组合 | 判断条件 |
| :--- | :--- | :--- |
| `beqz rs, label` | `beq rs, x0, label` | `rs == 0` |
| `bnez rs, label` | `bne rs, x0, label` | `rs != 0` |
| `blez rs, label` | `bge x0, rs, label` | `rs <= 0` |
| `bgez rs, label` | `bge rs, x0, label` | `rs >= 0` |
| `bltz rs, label` | `blt rs, x0, label` | `rs < 0` |
| `bgtz rs, label` | `blt x0, rs, label` | `rs > 0` |
| `bgt rs, rt, label` | `blt rt, rs, label` | `rs > rt` |
| `ble rs, rt, label` | `bge rt, rs, label` | `rs <= rt` |
| `bgtu rs, rt, label` | `bltu rt, rs, label` | `rs > rt`（无符号比较） |
| `bleu rs, rt, label` | `bgeu rt, rs, label` | `rs <= rt`（无符号比较） |

## CSR 指令

| 指令 | 说明 |
| :--- | :--- |
| `csrrw rd, csr, rs1` | 原子地交换 CSR 和 rs1 的值：读 CSR 旧值，零扩展到 64 位写入 rd；同时把 rs1 的值写入 CSR |
| `csrrs rd, csr, rs1` | 原子地读 CSR 并置位：读 CSR 旧值，零扩展后写入 rd；同时以 rs1 的值作为掩码，置位 CSR 中相应的位 |
| `csrrc rd, csr, rs1` | 原子地读 CSR 并清位：读 CSR 旧值，零扩展后写入 rd；同时以 rs1 的值作为掩码，清除 CSR 中相应的位 |
| `csrrwi rd, csr, uimm` | 作用同 csrrw，区别在于用 5 位无符号立即数代替 rs1 |
| `csrrsi rd, csr, uimm` | 作用同 csrrs，区别在于用 5 位无符号立即数代替 rs1 |
| `csrrci rd, csr, uimm` | 作用同 csrrc，区别在于用 5 位无符号立即数代替 rs1 |

CSR 伪指令：

| 伪指令 | 指令组合 | 说明 |
| :--- | :--- | :--- |
| `csrr rd, csr` | `csrrs rd, csr, x0` | 读取 CSR 的值 |
| `csrw csr, rs` | `csrrw x0, csr, rs` | 写 CSR 的值 |
| `csrs csr, rs` | `csrrs x0, csr, rs` | 设置 CSR 的字段（把 rs 为 1 的位在 CSR 中置 1） |
| `csrc csr, rs` | `csrrc x0, csr, rs` | 清除 CSR 的字段（`csr &= ~rs`） |
| `csrwi csr, imm` | `csrrwi x0, csr, imm` | 把 imm 写入 CSR 中 |
| `csrsi csr, imm` | `csrrsi x0, csr, imm` | 设置 CSR 的字段（把 imm 为 1 的位在 CSR 中置 1） |
| `csrci csr, imm` | `csrrci x0, csr, imm` | 清除 CSR 的字段（`csr &= ~imm`） |
