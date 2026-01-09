#!/bin/zsh
# ==============================
# Proxy Management Functions
# ==============================

# Enable terminal proxy
proxy_on() {
    local addr="${1:-$PROXY_ADDR}"
    local port="${2:-${PROXY_PORT:-7890}}"

    if [[ -z "$addr" ]]; then
        echo "❌ 未指定代理地址"
        return 1
    fi

    local proxy="http://${addr}:${port}"
    export http_proxy="$proxy"
    export https_proxy="$proxy"
    export all_proxy="$proxy"

    echo "终端代理已开启：$proxy"
}


# Disable terminal proxy
function proxy_off() {
    unset http_proxy https_proxy
    echo -e "终端代理已关闭。"
}
