#!/bin/bash
# 把这台 Mac 连上 GitHub。可重复运行，已完成的步骤会自动跳过。
# 新电脑上：bash setup-github.sh
set -euo pipefail

# 1. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "==> 安装 Homebrew（会要求输入开机密码）"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  grep -q 'brew shellenv' ~/.zprofile 2>/dev/null ||
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
fi

# 2. GitHub CLI
command -v gh >/dev/null 2>&1 || brew install gh

# 3. 登录（浏览器授权，token 存在 macOS 钥匙串）
if ! gh auth status -h github.com >/dev/null 2>&1; then
  echo "==> 登录 GitHub：复制下面的一次性代码，在弹出的浏览器里粘贴并授权"
  gh auth login -h github.com -p https -w -s workflow
fi
gh auth setup-git   # 让 git push/pull 自动用 gh 的凭证

# 4. git 身份：从 GitHub 账号自动读取，邮箱用 noreply 地址保护隐私
login=$(gh api user -q .login)
id=$(gh api user -q .id)
name=$(gh api user -q '.name // ""')
git config --global user.name "${name:-$login}"
git config --global user.email "${id}+${login}@users.noreply.github.com"
git config --global init.defaultBranch main
git config --global push.autoSetupRemote true

echo
echo "==> 完成"
gh auth status
echo "git 身份: $(git config --global user.name) <$(git config --global user.email)>"
