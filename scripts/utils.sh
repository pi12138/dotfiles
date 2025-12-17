#!/bin/bash
# ==============================
# Utility Functions
# ==============================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        CYGWIN*)    echo "cygwin";;
        MINGW*)     echo "mingw";;
        *)          echo "unknown";;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ask user for confirmation
confirm() {
    local prompt="${1:-Are you sure?}"
    local response

    while true; do
        read -p "$prompt [y/N] " response
        case "$response" in
            [yY][eE][sS]|[yY])
                return 0
                ;;
            [nN][oO]|[nN]|"")
                return 1
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

# Get script directory
get_dotfiles_dir() {
    echo "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
}

# ==============================
# 安装状态管理
# ==============================

STATE_FILE="$(get_dotfiles_dir)/.install_state"

# 初始化状态文件
init_state() {
    > "$STATE_FILE"
    info "初始化安装状态文件: $STATE_FILE"
}

# 记录安装成功的软件
record_installed() {
    local package="$1"
    echo "$package" >> "$STATE_FILE"
    success "记录安装: $package"
}

# 检查软件是否已记录为安装
is_installed_recorded() {
    local package="$1"
    [ -f "$STATE_FILE" ] && grep -q "^${package}$" "$STATE_FILE"
}

# 获取所有已安装的软件列表
get_installed_list() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    fi
}

# 显示安装状态
show_install_state() {
    if [ -f "$STATE_FILE" ]; then
        info "已安装的软件:"
        while read -r package; do
            echo "  ✓ $package"
        done < "$STATE_FILE"
    else
        warning "未找到安装状态文件"
    fi
}
