---
title: 把晚霞写进博客：拾遗集诞生记
description: 为什么做这个博客、用了什么技术、以及这片晚霞是怎么被挂上去的。
date: 2026-10-01
tags: [建站, Astro]
---

## 为什么要做这个博客

刷 CTF 题的时候，我习惯把过程记在本地 Markdown 里。但本地笔记有两个问题：

1. 三个月后我就不记得自己记在哪了；
2. 没有地方能让我把「今天夕阳很好」和「今天 XOR 出了 flag」说成同一件事。

于是有了**拾遗集**——「拾遗」是捡拾被遗漏的东西：题目里漏掉的知识点，课堂上漏掉的内容，一篇篇捡回来。
页脚那句话来自鲁迅《小杂感》：『人类的悲欢并不相通，我只觉得他们吵闹』——
深夜对着屏幕发呆的心跳别人未必懂，但写下来，说不定就通了。

## 技术选型

| 需求 | 选择 | 理由 |
| --- | --- | --- |
| 静态站生成 | Astro 5 | 产出纯静态 HTML，GitHub Pages 直接托管；Markdown 写作，视觉层完全自由 |
| 背景 | 一张黄昏港湾图 + CSS 呼吸动效 | 照片质感是 CSS 画不出来的，把真实交给图，把动效交给 transform |
| 代码高亮 | Shiki（Astro 内置） | 构建期高亮，零运行时开销 |
| 部署 | GitHub Actions | push 即上线，构建产物不入库 |

## 那些「缓慢出现」是怎么做的

所有动效只碰两个 GPU 友好属性，所以满屏毛玻璃也不掉帧：

```css
.reveal {
  opacity: 0;
  transform: translateY(68px) scale(0.985);
  transition: opacity 1.25s ease, transform 1.7s cubic-bezier(0.22, 1, 0.36, 1);
}
.reveal.in { opacity: 1; transform: none; }
```

一个 IntersectionObserver 在元素滚进视野时补上 `.in` 类，卡片就以一点八秒的时长缓缓浮起——
每张卡片再按序号加 `transition-delay`，像多米诺一样错峰出现。

> 所有动画都遵守 `prefers-reduced-motion`：系统设置减弱动效的读者，看到的是同一片静止的晚霞。

## 接下来

- [ ] 题目索引页（按 CTF 方向分类的知识树）
- [ ] RSS
- [ ] 评论区（先用 GitHub Issues 方案）

第一篇正文性质的文章，从 SQL 注入开始吧。
