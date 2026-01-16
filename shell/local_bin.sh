#!/bin/bash

# 确保 ~/.local/bin 存在
if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
fi

# 如果 ~/.local/bin 不在 PATH 中，则加入
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *)
        export PATH="$HOME/.local/bin:$PATH"
        ;;
esac
