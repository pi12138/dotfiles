#!/bin/bash

# 自动安装 Oh My Zsh 及常用插件脚本（带前提判断）

set -e

ZSH_DIR="$HOME/.oh-my-zsh"
ZSHRC="$HOME/.zshrc"

# -------------------------------
# 1. 检查 Oh My Zsh 目录
# -------------------------------
if [ -d "$ZSH_DIR" ]; then
  echo "检测到 Oh My Zsh 目录已存在：$ZSH_DIR"
  echo "你希望如何处理？"
  select opt in "删除" "备份" "跳过"; do
    case $opt in
      删除)
        rm -rf "$ZSH_DIR"
        echo "已删除 $ZSH_DIR"
        break
        ;;
      备份)
        mv "$ZSH_DIR" "${ZSH_DIR}.backup.$(date +%Y%m%d%H%M%S)"
        echo "已备份 $ZSH_DIR"
        break
        ;;
      跳过)
        echo "跳过 Oh My Zsh 安装"
        break
        ;;
    esac
  done
fi

# -------------------------------
# 2. 检查 .zshrc 文件
# -------------------------------
if [ -f "$ZSHRC" ]; then
  echo "检测到 .zshrc 文件已存在：$ZSHRC"
  echo "你希望如何处理？"
  select opt in "删除" "备份" "跳过"; do
    case $opt in
      删除)
        rm -f "$ZSHRC"
        echo "已删除 $ZSHRC"
        break
        ;;
      备份)
        mv "$ZSHRC" "${ZSHRC}.backup.$(date +%Y%m%d%H%M%S)"
        echo "已备份 $ZSHRC"
        break
        ;;
      跳过)
        echo "跳过 .zshrc 替换"
        break
        ;;
    esac
  done
fi

# -------------------------------
# 3. 安装 Oh My Zsh（如果不存在）
# -------------------------------
if [ ! -d "$ZSH_DIR" ]; then
  echo "正在安装 Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh 已存在，跳过安装。"
fi

# -------------------------------
# 4. 插件安装目录
# -------------------------------
ZSH_CUSTOM=${ZSH_CUSTOM:-$ZSH_DIR/custom}
PLUGIN_DIR="$ZSH_CUSTOM/plugins"

mkdir -p "$PLUGIN_DIR"

# -------------------------------
# 5. 安装插件函数
# -------------------------------
install_plugin() {
  local name=$1
  local repo=$2
  if [ ! -d "$PLUGIN_DIR/$name" ]; then
    echo "安装插件 $name ..."
    git clone "$repo" "$PLUGIN_DIR/$name"
  else
    echo "插件 $name 已安装，跳过。"
  fi
}

# -------------------------------
# 6. 安装常用插件
# -------------------------------
install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
install_plugin autojump https://github.com/wting/autojump.git

# docker 和 docker-compose 是 oh-my-zsh 自带插件，无需 clone

# -------------------------------
# 7. 软链接 .zshrc
# -------------------------------
if [ -f "./.zshrc" ]; then
  ln -sf "$(pwd)/.zshrc" "$ZSHRC"
  echo "已创建 .zshrc 软链接"
fi

# -------------------------------
# 8. 提示重载配置
# -------------------------------
echo "安装完成，请执行 'source ~/.zshrc' 或重启终端以使插件生效。"

exit 0
