# 仅挂载 VS Code WSL 必要目录，避免默认暴露整个 Windows 文件系统。
# X-mount.mkdir=0755 会在挂载时自动创建目标目录。
# nofail 允许 Windows 源目录尚未存在（如未初始化 VS Code）时跳过挂载，
# 避免 WSL 启动报错；目录就绪后执行 sudo mount -a 或重启 WSL 即可生效。
__WIN_HOME__/.vscode/extensions    __MOUNT_HOME__/.vscode/extensions    drvfs    defaults,ro,nofail,X-mount.mkdir=0755    0    0
__WIN_HOME__/vscode-remote-wsl     __MOUNT_HOME__/vscode-remote-wsl     drvfs    defaults,ro,nofail,X-mount.mkdir=0755    0    0
