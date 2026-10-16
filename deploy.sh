#!/usr/bin/env bash
# ============================================================
# 拾遗集 · 一键部署脚本
# 用法:  bash deploy.sh <GitHub仓库> ["提交信息"]
#   <GitHub仓库> 可以是以下任意一种写法：
#     - 用户名/仓库名                例:  zhangsan/zhangsan.github.io
#     - https://github.com/用户/仓库(.git)
#     - git@github.com:用户/仓库(.git)
#
# 自动完成: git 初始化 → 按仓库类型改写 site/base → 本地构建验证
#          → 提交推送 → (装了 gh CLI 且已登录时) 自动建仓+开 Pages
# 前提: 已安装 Git 与 Node；首次推送会弹出 GitHub 登录授权窗口，过一次即可
# ============================================================
set -euo pipefail
cd "$(dirname "$0")"

ARG="${1:-}"
MSG="${2:-update: $(date '+%Y-%m-%d %H:%M')}"
if [ -z "$ARG" ]; then
  echo "用法: bash deploy.sh <owner/repo 或仓库URL> [\"提交信息\"]"
  exit 1
fi

# ---------- 1. 归一化仓库地址 → owner/repo ----------
R="$ARG"
R="${R#https://}"; R="${R#http://}"; R="${R#ssh://}"; R="${R#git@}"
R="${R%.git}"; R="${R%/}"
R="${R#github.com[:/]}"
OWNER="${R%%/*}"; REPO="${R#*/}"
if [ -z "$OWNER" ] || [ -z "$REPO" ] || [ "$OWNER" = "$REPO" ] || [[ "$REPO" == */* ]]; then
  echo "❌ 无法从「$ARG」解析出 owner/repo，请检查写法（例: zhangsan/my-blog）"
  exit 1
fi
REMOTE="https://github.com/$OWNER/$REPO.git"
echo "→ 目标仓库: $REMOTE"

# ---------- 2. git 初始化与身份 ----------
[ -d .git ] || git init -b main
git config user.name  >/dev/null 2>&1 || git config user.name  "shiyi"
git config user.email >/dev/null 2>&1 || git config user.email "shiyi@users.noreply.github.com"
git branch -M main

# ---------- 3. 按仓库类型自动改写 astro.config.mjs ----------
# 主页仓库(<owner>.github.io)部署在根路径，其他仓库部署在 /<repo> 子路径
if [ "$REPO" = "$OWNER.github.io" ]; then BASE="/"; else BASE="/$REPO"; fi
sed -i "s#^  site: .*#  site: 'https://$OWNER.github.io',#" astro.config.mjs
sed -i "s#^  base: .*#  base: '$BASE',#"                   astro.config.mjs
echo "→ astro.config 已自动配置 (site=https://$OWNER.github.io, base=$BASE)"

# ---------- 4. 依赖安装 + 本地构建（失败就不推，避免把坏版本推上线） ----------
[ -d node_modules ] || npm install --no-fund --no-audit
npm run build

# ---------- 5. 提交并推送 ----------
git add -A
git diff --cached --quiet || git commit -m "$MSG"
git remote add origin "$REMOTE" 2>/dev/null || git remote set-url origin "$REMOTE"
if ! git push -u origin main 2>/dev/null; then
  echo "→ 远端已有提交，尝试变基后重推..."
  git pull --rebase origin main
  git push -u origin main
fi

# ---------- 6. 若装有 gh CLI 且已登录：自动建仓 + 开启 Pages(Actions) ----------
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  if ! gh api "repos/$OWNER/$REPO" --silent >/dev/null 2>&1; then
    echo "→ 仓库不存在，尝试自动创建..."
    gh api -X POST /user/repos -f name="$REPO" -f private=0 >/dev/null \
      && echo "✓ 已创建 $OWNER/$REPO" \
      || echo "⚠ 自动建仓失败，请到 GitHub 手动创建后重跑本脚本"
  fi
  if gh api "repos/$OWNER/$REPO/pages" --silent >/dev/null 2>&1; then
    gh api -X PUT "repos/$OWNER/$REPO/pages" -f build_type=workflow --silent 2>/dev/null \
      && echo "✓ Pages 已设为 GitHub Actions 部署" || true
  else
    gh api -X POST "repos/$OWNER/$REPO/pages" -f build_type=workflow --silent 2>/dev/null \
      && echo "✓ Pages 已开启（GitHub Actions 来源）" \
      || echo "⚠ 自动开启失败：请到 仓库 Settings → Pages → Source 选 GitHub Actions"
  fi
else
  echo "ℹ 未检测到已登录的 gh CLI。首次部署请手动开一次: 仓库 Settings → Pages → Source 选 GitHub Actions"
fi

# ---------- 7. 结果 ----------
echo ""
echo "🎉 已推送！等 GitHub Actions 构建完成（约 1 分钟，仓库 Actions 页可看进度），访问:"
echo "   https://$OWNER.github.io$BASE"
