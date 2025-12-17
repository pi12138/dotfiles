#!/bin/bash
# ==============================
# 执行 scripts 目录下的所有脚本
# ==============================

set -e

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "错误: 请使用 sudo 运行此脚本"
    echo "用法: sudo ./install.sh"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

# 加载工具函数
source "$SCRIPTS_DIR/utils.sh"

# 检查 scripts 目录是否存在
if [ ! -d "$SCRIPTS_DIR" ]; then
    error "scripts 目录不存在"
    exit 1
fi

# 初始化安装状态文件
init_state

info "开始执行安装脚本..."
echo ""

# 第一阶段: 执行所有安装脚本（排除 utils.sh 和 link.sh）
info "=== 阶段 1: 安装软件 ==="
for script in $(ls "$SCRIPTS_DIR"/*.sh 2>/dev/null | sort); do
    script_name="$(basename "$script")"

    # 跳过 utils.sh 和 link.sh
    if [[ "$script_name" == "utils.sh" || "$script_name" == "link.sh" ]]; then
        continue
    fi

    # 执行脚本
    if [ -f "$script" ]; then
        echo "========================================"
        info "执行: $script_name"
        echo "========================================"

        if bash "$script"; then
            success "$script_name 执行成功"
        else
            warning "$script_name 执行失败，继续执行其他脚本"
        fi
        echo ""
    fi
done

# 第二阶段: 根据安装状态链接配置文件
info "=== 阶段 2: 链接配置文件 ==="
if [ -f "$SCRIPTS_DIR/link.sh" ]; then
    echo "========================================"
    info "执行: link.sh"
    echo "========================================"
    bash "$SCRIPTS_DIR/link.sh"
    echo ""
else
    warning "未找到 link.sh，跳过配置链接"
fi

echo ""
success "✨ 所有脚本执行完成！"
echo ""

# 显示安装状态
show_install_state
