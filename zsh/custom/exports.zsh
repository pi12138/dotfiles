#!/bin/zsh
# ==============================
# Environment Variables
# ==============================

# Disable Python virtualenv prompt (handled by zsh theme)
export DISABLE_VIRTUALENV_PROMPT=true

# Editor
# export EDITOR='nvim'
# export VISUAL='nvim'

# Language
# export LANG=en_US.UTF-8
# export LC_ALL=en_US.UTF-8

# Add your custom environment variables here

LOCAL_BIN="$HOME/.local/bin"

if [[ ! -d "$LOCAL_BIN" ]]; then
    echo "创建目录: $LOCAL_BIN"
    mkdir -p "$LOCAL_BIN"
fi

export PATH="$LOCAL_BIN:$PATH"