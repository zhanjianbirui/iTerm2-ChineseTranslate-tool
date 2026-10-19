# iTerm2 汉化管理工具

双击 `iTerm2-汉化管理.command` 即可打开菜单。首次运行时，macOS 可能会
询问是否允许终端运行该脚本，请确认运行。

菜单功能：

1. 安装汉化：备份原应用，写入简体中文界面资源并重新签名。
2. 删除汉化：从备份恢复原始界面资源，重新签名并移除中文资源。
3. 查看状态：显示应用版本、当前汉化状态和备份位置。
4. 退出。

注意事项：

- 安装或删除前请先按 `⌘Q` 完全退出 iTerm2。
- 只支持 iTerm2 3.6.11。
- 首次安装会把原应用完整备份到：
  `~/Library/Application Support/iTerm2-Chinese-Localization/iTerm.app.original`
- 如果原应用位于“应用程序”中，脚本会按需请求管理员权限。
- 汉化安装后会移除官方更新源，避免更新覆盖中文资源。
- 也可以通过 `apply`、`remove`、`status` 参数直接执行操作，例如：

```bash
./iTerm2-汉化管理.command status
```

若 iTerm2 不在 `/Applications/iTerm.app`，可以指定路径：

```bash
ITERM_APP_PATH="/Applications/iTerm2.app" ./iTerm2-汉化管理.command
```
