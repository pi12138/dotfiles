#!/bin/bash

trash_rm() {
    if ! command -v trash-put &> /dev/null; then
        echo "错误：trash-cli 未安装！请安装 trash-cli 后再试。"
        return 1
    fi
    trash-put "$@"
}

alias rm='trash_rm'
alias rmbin="/usr/bin/rm"
