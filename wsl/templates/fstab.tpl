# 仅挂载 VS Code WSL 必要目录，避免默认暴露整个 Windows 文件系统。
# X-mount.mkdir 会在挂载时自动创建目标目录。
__WIN_HOME__/.vscode/extensions    __MOUNT_HOME__/.vscode/extensions    drvfs    defaults,ro,X-mount.mkdir=0755    0    0
__WIN_HOME__/vscode-remote-wsl     __MOUNT_HOME__/vscode-remote-wsl     drvfs    defaults,ro,X-mount.mkdir=0755    0    0
