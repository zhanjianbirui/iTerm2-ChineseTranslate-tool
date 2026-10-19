# iTerm2 简体中文汉化工具

一个面向 macOS 的 iTerm2 汉化与恢复工具。工具会修改本机
`/Applications/iTerm.app` 的界面资源，并在首次安装前自动备份原应用。

> 当前仅支持 **iTerm2 3.6.11**。这是非官方项目，iTerm2 版权归原作者所有。

## 功能

- 一键安装简体中文界面
- 一键恢复英文原版
- 安装前自动备份原应用
- 修改后自动重新签名并校验
- 汉化后移除自动更新源，避免更新覆盖中文资源
- 支持交互菜单和命令行操作

## 快速使用

### 1. 下载并解压

下载仓库中的 [汉化工具压缩包](outputs/Iterm2-汉化工具-3.6.11.zip)，解压后得到：

```text
iTerm2-Localization-Manager/
├── iTerm2-汉化管理.command
├── assets/
└── 使用说明.md
```

### 2. 退出 iTerm2

在 iTerm2 中按 `⌘Q` 完全退出应用。

### 3. 启动管理工具

双击 `iTerm2-汉化管理.command`，选择所需操作：

```text
1. 安装汉化
2. 删除汉化并恢复原版
3. 查看当前状态
4. 退出
```

首次安装时，原应用会备份到：

```text
~/Library/Application Support/iTerm2-Chinese-Localization/iTerm.app.original
```

如果 macOS 提示脚本没有执行权限，可在终端中运行：

```bash
chmod +x iTerm2-汉化管理.command
./iTerm2-汉化管理.command
```

## 命令行用法

除交互菜单外，也可以直接执行：

```bash
./iTerm2-汉化管理.command status
./iTerm2-汉化管理.command apply
./iTerm2-汉化管理.command remove
```

如果 iTerm2 不在默认位置，可指定应用路径：

```bash
ITERM_APP_PATH="/Applications/iTerm2.app" ./iTerm2-汉化管理.command
```

## 工作方式

```text
原应用
  ↓ 首次安装时完整备份
写入中文 NIB、界面字符串和语言配置
  ↓
重新签名并校验
  ↓
中文版 iTerm2
```

执行“删除汉化”时，工具会使用备份恢复原始 NIB、字符串表和
`Info.plist`，移除新增的中文资源，然后重新签名。

## 汉化范围

- 覆盖 70 个可替换界面 NIB
- 主菜单约 96% 中文化
- 界面文字字段约 90% 中文化
- 设置、配置文件、脚本窗口、Shell 集成和常用弹窗均已覆盖

少量高级帮助、动态错误信息、品牌名和协议名仍可能显示英文。

## 项目结构

```text
├── outputs/  可分发工具和使用说明
└── work/     翻译词表、构建脚本、界面资源和中间产物
```

主要文件：

- [汉化管理脚本](work/iTerm2-Localization-Manager/iTerm2-汉化管理.command)
- [简体中文翻译词表](work/ui_zh.tsv)
- [界面翻译脚本](work/apply_ui_translation.py)
- [字符串表生成脚本](work/build_localized_strings.py)

## 注意事项

- 安装或删除前必须完全退出 iTerm2。
- 应用版本不匹配时，工具会拒绝操作，避免破坏其他版本。
- 工具会使用 Ad-hoc 签名；首次运行如被 macOS 拦截，可右键应用并选择“打开”。
- 请勿直接删除备份目录，否则“删除汉化”将无法安全恢复原应用。

## 恢复原版

重新运行 `iTerm2-汉化管理.command`，选择：

```text
2. 删除汉化并恢复原版
```

脚本会恢复原始资源并重新签名。
