#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"

WSL_USER="${SUDO_USER:-${USER:-}}"
WIN_USER="${WSL_WIN_USER:-${WIN_USER:-$WSL_USER}}"
WIN_DRIVE="${WSL_WIN_DRIVE:-c}"

DRY_RUN=0
YES=0
TMP_DIR=""

usage() {
    cat <<'EOF'
用法:
  sudo ./install.sh [选项]

选项:
  --wsl-user NAME     WSL 默认用户，默认取 sudo 调用者
  --win-user NAME     Windows 用户名，默认同 WSL 用户
  --win-drive LETTER  Windows 盘符，默认 c
  --dry-run           只预览生成结果，不写入 /etc
  -y, --yes           跳过覆盖确认
  -h, --help          显示帮助

示例:
  ./install.sh --wsl-user pyo1024 --win-user miljenko --dry-run
  sudo ./install.sh --wsl-user pyo1024 --win-user miljenko --yes
EOF
}

info() {
    printf '[INFO] %s\n' "$*"
}

warn() {
    printf '[WARN] %s\n' "$*" >&2
}

die() {
    printf '[ERROR] %s\n' "$*" >&2
    exit 1
}

cleanup() {
    if [[ -n "${TMP_DIR:-}" ]]; then
        rm -rf -- "$TMP_DIR"
    fi
}

need_value() {
    local option="$1"
    local value="${2:-}"
    [[ -n "$value" ]] || die "$option 需要参数"
}

parse_args() {
    while (($# > 0)); do
        case "$1" in
            --wsl-user|--username)
                need_value "$1" "${2:-}"
                WSL_USER="$2"
                shift 2
                ;;
            --win-user|--windows-user)
                need_value "$1" "${2:-}"
                WIN_USER="$2"
                shift 2
                ;;
            --win-drive|--windows-drive)
                need_value "$1" "${2:-}"
                WIN_DRIVE="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=1
                shift
                ;;
            -y|--yes)
                YES=1
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                die "未知选项: $1"
                ;;
        esac
    done
}

escape_fstab_field() {
    local value="$1"
    value="${value// /\\040}"
    value="${value//$'\t'/\\011}"
    printf '%s' "$value"
}

render_template() {
    local template="$1"
    local output="$2"
    local win_home="$3"
    local mount_home="$4"
    local content

    content="$(<"$template")"
    content="${content//__WSL_USER__/$WSL_USER}"
    content="${content//__WIN_USER__/$WIN_USER}"
    content="${content//__WIN_HOME__/$win_home}"
    content="${content//__MOUNT_HOME__/$mount_home}"

    printf '%s\n' "$content" >"$output"
}

backup_and_install() {
    local source="$1"
    local target="$2"
    local backup

    if [[ -e "$target" ]]; then
        backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
        cp -a -- "$target" "$backup"
        info "已备份 $target -> $backup"
    fi

    install -D -m 0644 -- "$source" "$target"
    info "已安装 $target"
}

validate() {
    WIN_DRIVE="${WIN_DRIVE%:}"
    WIN_DRIVE="$(printf '%s' "$WIN_DRIVE" | tr '[:upper:]' '[:lower:]')"

    [[ -n "$WSL_USER" ]] || die "WSL 用户名为空，请使用 --wsl-user 指定"
    [[ -n "$WIN_USER" ]] || die "Windows 用户名为空，请使用 --win-user 指定"
    [[ ! "$WSL_USER" =~ [[:space:]/:] ]] || die "WSL 用户名不能包含空白、斜杠或冒号"
    [[ "$WIN_DRIVE" =~ ^[a-z]$ ]] || die "Windows 盘符必须是单个字母，例如 c"

    [[ -f "$TEMPLATE_DIR/wsl.conf.tpl" ]] || die "缺少模板: $TEMPLATE_DIR/wsl.conf.tpl"
    [[ -f "$TEMPLATE_DIR/fstab.tpl" ]] || die "缺少模板: $TEMPLATE_DIR/fstab.tpl"

    if ((DRY_RUN == 0 && EUID != 0)); then
        die "写入 /etc 需要 root 权限，请使用 sudo 运行；预览可使用 --dry-run"
    fi
}

confirm() {
    ((DRY_RUN == 0)) || return 0
    ((YES == 0)) || return 0

    local answer
    read -r -p "将覆盖 /etc/wsl.conf 和 /etc/fstab，是否继续？[y/N] " answer
    case "$answer" in
        y|Y|yes|YES|Yes) ;;
        *) die "已取消" ;;
    esac
}

main() {
    parse_args "$@"
    validate

    local win_home_raw
    local mount_home_raw
    local win_home
    local mount_home

    win_home_raw="${WIN_DRIVE}:/Users/${WIN_USER}"
    mount_home_raw="/mnt/${WIN_DRIVE}/Users/${WIN_USER}"
    win_home="$(escape_fstab_field "$win_home_raw")"
    mount_home="$(escape_fstab_field "$mount_home_raw")"

    TMP_DIR="$(mktemp -d)"
    trap cleanup EXIT

    render_template "$TEMPLATE_DIR/wsl.conf.tpl" "$TMP_DIR/wsl.conf" "$win_home" "$mount_home"
    render_template "$TEMPLATE_DIR/fstab.tpl" "$TMP_DIR/fstab" "$win_home" "$mount_home"

    info "WSL 用户: $WSL_USER"
    info "Windows 用户: $WIN_USER"
    info "Windows 源路径: $win_home_raw"
    info "WSL 挂载路径: $mount_home_raw"

    if ((DRY_RUN == 1)); then
        printf '\n===== /etc/wsl.conf =====\n'
        cat "$TMP_DIR/wsl.conf"
        printf '\n===== /etc/fstab =====\n'
        cat "$TMP_DIR/fstab"
        return 0
    fi

    confirm
    backup_and_install "$TMP_DIR/wsl.conf" /etc/wsl.conf
    backup_and_install "$TMP_DIR/fstab" /etc/fstab

    info "完成。请在 Windows PowerShell 中执行: wsl --shutdown"
    info "重新进入 WSL 后，wsl.conf 和 fstab 挂载配置才会完整生效。"
}

main "$@"
