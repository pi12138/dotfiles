# WSL 配置

这个目录维护 WSL 隔离相关配置：

- `templates/wsl.conf.tpl`：关闭 Windows 整盘自动挂载和 PATH 注入，开启 systemd，并设置默认 WSL 用户。
- `templates/fstab.tpl`：只读挂载 VS Code WSL 所需的 Windows 目录，并在挂载时自动创建目标目录。
- `install.sh`：渲染模板并安装到 `/etc/wsl.conf`、`/etc/fstab`。

预览生成结果：

```bash
./install.sh --wsl-user pyo1024 --win-user miljenko --dry-run
```

安装配置：

```bash
sudo ./install.sh --wsl-user pyo1024 --win-user miljenko --yes
```

安装后建议在 Windows PowerShell 中执行：

```powershell
wsl --shutdown
```

重新进入 WSL 后，`/etc/wsl.conf` 的 `automount.enabled=false` 会阻止默认挂载整个 Windows 盘，`/etc/fstab` 只会按模板挂载必要目录。
