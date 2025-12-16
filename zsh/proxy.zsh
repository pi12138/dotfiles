#!/bin/zsh
# ==============================
# Proxy Management Functions
# ==============================

# Enable terminal proxy
function proxy_on() {
    export http_proxy=http://127.0.0.1:7890
    export https_proxy=$http_proxy
    echo -e "终端代理已开启。"
}

# Disable terminal proxy
function proxy_off() {
    unset http_proxy https_proxy
    echo -e "终端代理已关闭。"
}
