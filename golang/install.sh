#!/bin/bash
# 安装指定版本的 Go 语言环境脚本
# 支持通过第一个参数传入版本号，默认安装最新稳定版"1.25.5"
# 默认安装到当前用户的目录下

set -e

# 默认 Go 版本
DEFAULT_GO_VERSION="1.25.5"
GO_VERSION="${1:-$DEFAULT_GO_VERSION}"

# 下载相关变量
GO_TARFILE="go${GO_VERSION}.linux-amd64.tar.gz"
DOWNLOAD_URL="https://golang.org/dl/${GO_TARFILE}"
INSTALL_DIR="$HOME/.local"

echo "准备安装 Go 版本：${GO_VERSION}"

# 下载目录临时路径
TMP_DIR="/tmp"
TMP_TAR_PATH="${TMP_DIR}/${GO_TARFILE}"

# 备份已有安装
if [ -d "${INSTALL_DIR}/go" ]; then
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    BACKUP_DIR="${INSTALL_DIR}/go.bak.${TIMESTAMP}"
    echo "检测到已有 Go 版本，备份到 ${BACKUP_DIR} ..."
    mv "${INSTALL_DIR}/go" "${BACKUP_DIR}"
fi

# 下载 Go 安装包（如果不存在）
if [ -f "${TMP_TAR_PATH}" ]; then
    echo "安装包已存在，跳过下载：${TMP_TAR_PATH}"
else
    echo "开始下载 Go 安装包：${DOWNLOAD_URL} ..."
    curl -L --retry 3 --retry-delay 2 -o "${TMP_TAR_PATH}" "${DOWNLOAD_URL}"
fi

# 解压到安装目录
echo "解压安装包到 ${INSTALL_DIR} ..."
tar -C "${INSTALL_DIR}" -xzf "${TMP_TAR_PATH}"

# 配置环境变量脚本路径
SHELL_CFG_PATH="$HOME/.config/shell"
if [ ! -d "${SHELL_CFG_PATH}" ]; then
    mkdir -p "${SHELL_CFG_PATH}"
fi

GO_PROFILE="${SHELL_CFG_PATH}/go.sh"

# 写入环境变量配置（覆盖之前配置）
echo "写入环境变量配置到 ${GO_PROFILE} ..."
tee "${GO_PROFILE}" > /dev/null << EOF
# Go 语言环境变量
export GOROOT=\${HOME}/.local/go
export GOPATH=\${HOME}/.go
EOF

if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
fi 

${INSTALL_DIR}/go/bin/go env -w GOPROXY=https://goproxy.cn,direct

ln -sf "${INSTALL_DIR}/go/bin/go" "$HOME/.local/bin/go"
ln -sf "${INSTALL_DIR}/go/bin/gofmt" "$HOME/.local/bin/gofmt"

echo "安装完成。请执行以下命令使环境变量生效："
echo "  source ${GO_PROFILE}"
echo "或重新打开终端。"

# 验证安装
if command -v go &> /dev/null; then
    echo "Go 安装成功，版本信息："
    go version
else
    echo "安装完成，但未检测到 go 命令，请确认环境变量已生效。"
fi

