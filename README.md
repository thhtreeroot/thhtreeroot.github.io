# 拾遗集 · 黄昏港湾主题博客

Astro 5 静态博客，内容方向 CTF / 计算机学习。视觉：**全屏黄昏港湾背景（按宽度铺满）+ 入场动态标题 + 滚动缓慢浮现的毛玻璃面板**。

> 「人类的悲欢并不相通，我只觉得他们吵闹。」—— 鲁迅《小杂感》

## 一键部署（全自动）

```bash
bash deploy.sh 你的用户名/你的用户名.github.io        # 个人主页仓库（根路径）
bash deploy.sh 你的用户名/my-blog                     # 项目仓库（自动挂 /my-blog 子路径）
# 也支持直接粘贴 https:// 或 git@ 开头的完整仓库地址
```

脚本自动完成：git 初始化 → 按仓库改写 `site`/`base` → 本地构建验证 → 提交推送 → （装有 gh CLI 并登录时）自动创建仓库并开启 Pages/Actions。首次推送会弹出 GitHub 授权登录窗口，过一次之后全自动。

没有 gh CLI 时，只需一次性手动操作：仓库 Settings → Pages → Source 选 **GitHub Actions**。

## 换背景图

```
覆盖 public/bg.jpg → 重新构建（或直接跑 bash deploy.sh "改背景"）
```

图片建议横宽比 ≥ 1.8（背景按屏幕宽度铺满、左右不裁切；窄屏/竖屏自动按高度铺满）。

## 写文章

在 `src/content/blog/` 新建 Markdown：

```yaml
---
title: 文章标题
description: 一句话摘要（卡片和 SEO 用）
date: 2026-10-16
tags: [CTF, Web]
draft: false
---
```

代码块自动 Shiki 高亮，表格/引用/分隔线都有配套样式。

## 本地开发

```bash
npm install
npm run dev        # http://localhost:4321
npm run build      # 输出 dist/
```

## 想改什么去哪儿

| 想改 | 位置 |
| --- | --- |
| 背景图 | `public/bg.jpg` |
| 博客名 / 标语 | `SiteHeader.astro`、`SiteFooter.astro`、`index.astro`、`BaseLayout.astro` 默认描述 |
| 标题入场 / 卡片浮现速度 | `global.css` 的 `hero-in`、`.reveal` 时长 |
| 玻璃雾浓度 | `--glass`（卡片）、`--glass-strong`（文章/关于主面板）、`backdrop-filter: blur()` |
| 背景铺法（按宽/按高） | `.bg` 的 `background-size` |
| 关于页、社交链接 | `src/pages/about.astro` |
