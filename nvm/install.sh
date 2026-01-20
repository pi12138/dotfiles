#!/bin/bash
# install-nvm-only.sh - 只安装 NVM（不安装 Node.js）

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== 安装最新版本的 NVM ===${NC}"

# 获取最新版本号
echo "正在获取 NVM 最新版本..."
NVM_LATEST=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$NVM_LATEST" ]; then
    echo -e "${RED}无法获取最新版本，使用默认版本 v0.40.1${NC}"
    NVM_LATEST="v0.40.1"
fi

echo -e "${GREEN}最新版本: $NVM_LATEST${NC}"

# 检查是否已安装
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -d "$NVM_DIR" ]; then
    echo -e "${YELLOW}检测到 NVM 已安装在: $NVM_DIR${NC}"
    read -p "是否重新安装? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "取消安装"
        exit 0
    fi
    rm -rf "$NVM_DIR"
fi

# 下载并安装
echo "下载并安装 NVM $NVM_LATEST..."
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_LATEST/install.sh" | bash

# 配置环境变量
echo -e "${GREEN}配置环境变量...${NC}"

# 检测当前 shell
CURRENT_SHELL=$(basename "$SHELL")
echo "检测到 shell: $CURRENT_SHELL"

# 立即加载 NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 验证安装
if command -v nvm &> /dev/null; then
    echo -e "${GREEN}✓ NVM 安装成功！${NC}"
    echo "版本: $(nvm --version)"
else
    echo -e "${RED}✗ NVM 安装失败${NC}"
    exit 1
fi

# 使用提示
echo -e "\n${GREEN}=== 安装完成 ===${NC}"
echo "请运行以下命令使环境生效："
echo -e "  ${YELLOW}source ~/.bashrc${NC}  # bash 用户"
echo -e "  ${YELLOW}source ~/.zshrc${NC}   # zsh 用户"
echo ""
echo "然后可以使用以下命令安装 Node.js："
echo -e "  ${YELLOW}nvm install --lts${NC}      # 安装 LTS 版本"
echo -e "  ${YELLOW}nvm install 20${NC}         # 安装 Node.js 20"
echo -e "  ${YELLOW}nvm install node${NC}       # 安装最新版本"
