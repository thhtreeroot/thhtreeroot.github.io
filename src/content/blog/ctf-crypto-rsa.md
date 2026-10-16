---
title: CTF Crypto 手记：从质数到 RSA 的浪漫
description: n = p × q 是 RSA 的浪漫，也是它的软肋。记录几类入门级 RSA 题目的破法。
date: 2026-10-03
tags: [CTF, Crypto]
---

## 先把结构画清楚

RSA 的参数关系一张图背下来：

```
p, q 为大素数
n = p * q             模数（公开）
φ(n) = (p-1)(q-1)     欧拉函数（保密）
e * d ≡ 1 (mod φ(n))  公钥 e、私钥 d
c = m^e mod n         加密
m = c^d mod n         解密
```

**所有入门题的突破口都在同一件事上：n 被拆开了，或者 φ(n) 被猜错了。**

## 题型一：n 太小，直接分解

`n` 只有 512 bit 甚至更短的时候，`yafu` / `sympy` 直接分解：

```python
from sympy import factorint
import gmpy2

n = 0x1d3e_..._e7b1
p, q = sorted(factorint(n))

phi = (p - 1) * (q - 1)
d = int(gmpy2.invert(e, phi))
m = pow(c, d, n)
print(long_to_bytes(m))
```

## 题型二：p 和 q 太接近

当 `|p - q|` 很小（题目提示「p 和 q 只差一点」），用费马分解：

```python
from gmpy2 import isqrt

a = isqrt(n)
while a * a - n != 0:
    a += 1
b = isqrt(a * a - n)
p, q = a - b, a + b
```

原理是 `n = a² - b² = (a-b)(a+b)`，p、q 接近时 `a = (p+q)/2` 离 `√n` 只差几步。

## 题型三：e 太小——低加密指数攻击

- **e = 3 且 m³ < n**：密文没发生回绕，对 `c` 直接开三次整数根就是明文；
- **e = 3 且同一明文发给三个人**：中国剩余定理拼出 `m³ mod (n1·n2·n3)`，再开根。

```python
from gmpy2 import iroot
r, exact = iroot(c, 3)
assert exact
print(long_to_bytes(int(r)))
```

## 题型四：共模攻击

同一个 `n`、同一个明文，两个互素的 `e1, e2`。扩展欧几里得找到 `s, t` 使 `s·e1 + t·e2 = 1`：

```
m = c1^s · c2^t mod n
```

> s 或 t 为负数也没关系：负指数就是对 `c` 的逆元求幂，`gmpy2.invert` 照算。

## 小结

| 题目线索 | 攻击 |
| --- | --- |
| n 位数少 | 直接分解 |
| p、q 接近 | 费马分解 |
| e = 3 | 开根 / CRT |
| 两个 e 一个 n | 共模攻击 |

Crypto 题的浪漫之处：所有花样的题面，最后都落在同一行 `e·d ≡ 1 (mod φ(n))` 上。找不到方向时，就回到这行字面前发呆。
