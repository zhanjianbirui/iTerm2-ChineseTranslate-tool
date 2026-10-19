# iTerm2 简体中文汉化工具 v1.0.0

适用于 macOS 版 iTerm2 3.6.11。

## 使用

1. 按 `⌘Q` 完全退出 iTerm2。
2. 双击 `iTerm2-汉化管理.command`。
3. 选择“安装汉化”或“删除汉化并恢复原版”。
4. 根据提示授权，然后重新打开 iTerm2。

首次安装前会自动备份原应用：

```text
~/Library/Application Support/iTerm2-Chinese-Localization/iTerm.app.original
```

不要删除该备份，否则无法安全恢复英文原版。

## 命令行

```bash
./iTerm2-汉化管理.command status
./iTerm2-汉化管理.command apply
./iTerm2-汉化管理.command remove
```

详细操作见 `使用说明.md`，版本变化见 `RELEASE_NOTES.md`。
