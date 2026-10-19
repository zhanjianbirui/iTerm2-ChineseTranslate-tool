# iTerm2 简体中文汉化工具

为 macOS 版 iTerm2 3.6.11 提供可安装、可恢复的简体中文本地化方案。

<p align="center">
  <a href="https://github.com/zhanjianbirui/iTerm2-ChineseTranslate-tool/raw/refs/heads/main/release/v1.0.0/iTerm2-ChineseTranslate-tool-v1.0.0.zip">
    <img src="https://img.shields.io/badge/%E2%AC%87_%E4%B8%8B%E8%BD%BD_v1.0.0-2ea44f?style=for-the-badge&logo=github&logoColor=white" alt="一键下载 iTerm2 简体中文汉化工具">
  </a>
</p>

<p align="center">
  <a href="DOWNLOAD.md">下载说明</a> ·
  <a href="release/v1.0.0/RELEASE_NOTES.md">发布说明</a> ·
  <a href="release/v1.0.0/SHA256SUMS.txt">SHA-256 校验</a>
</p>

---

[**下载最新发布包**](release/v1.0.0/iTerm2-ChineseTranslate-tool-v1.0.0.zip) ·
[查看发布说明](release/v1.0.0/RELEASE_NOTES.md)

![Platform](https://img.shields.io/badge/platform-macOS-black)
![iTerm2](https://img.shields.io/badge/iTerm2-3.6.11-blue)
![Language](https://img.shields.io/badge/language-Simplified%20Chinese-red)

> 本项目为非官方汉化工具，iTerm2 及其原始资源版权归原作者所有。

## 项目简介

iTerm2 功能强大，但官方界面目前只有英文。本项目通过替换界面 NIB、
字符串表和语言配置，为常用功能提供简体中文界面。

工具在安装前会完整备份原应用；不需要汉化时，可以一键恢复英文原版，
不会丢失 iTerm2 的配置、配置文件和 Shell 集成。

## 功能特点

| 功能 | 说明 |
| --- | --- |
| 一键汉化 | 自动写入中文界面资源并重新签名 |
| 一键恢复 | 从备份恢复原应用，不残留中文资源 |
| 自动备份 | 首次安装前保存完整原应用 |
| 签名校验 | 修改后自动执行 Ad-hoc 签名和完整性校验 |
| 防止覆盖 | 汉化后移除自动更新源，避免更新覆盖中文资源 |
| 双操作方式 | 支持交互菜单和命令行参数 |

## 汉化效果

- 覆盖 70 个可替换界面 NIB
- 主菜单约 96% 中文化
- 界面文字字段约 90% 中文化
- 已覆盖设置、配置文件、脚本窗口、Shell 集成和常用弹窗

少量高级帮助、动态错误信息、品牌名及协议名仍可能显示英文。

## 系统要求

| 项目 | 要求 |
| --- | --- |
| 系统 | macOS 12.4 或更高版本 |
| 应用 | iTerm2 3.6.11 |
| 架构 | Apple Silicon 或 Intel |
| 终端 | 系统自带“终端”或 iTerm2 |

> 当前版本的汉化资源与 iTerm2 3.6.11 绑定，不支持其他版本。

## 快速开始

### 1. 下载发布包

点击页面顶部的“一键下载”按钮，或从 [下载说明](DOWNLOAD.md) 获取：

```text
iTerm2-ChineseTranslate-tool-v1.0.0.zip
```

### 2. 解压并退出 iTerm2

解压后得到：

```text
iTerm2-ChineseTranslate-tool-v1.0.0/
├── iTerm2-汉化管理.command
├── assets/
├── README.md
├── RELEASE_NOTES.md
└── 使用说明.md
```

在 iTerm2 中按 `⌘Q` 完全退出应用。

### 3. 启动汉化工具

双击 `iTerm2-汉化管理.command`，选择：

```text
1. 安装汉化
2. 删除汉化并恢复原版
3. 查看当前状态
4. 退出
```

首次安装前，脚本会将原应用备份到：

```text
~/Library/Application Support/iTerm2-Chinese-Localization/iTerm.app.original
```

如果 macOS 提示脚本没有执行权限：

```bash
chmod +x iTerm2-汉化管理.command
./iTerm2-汉化管理.command
```

## 命令行操作

```bash
# 查看状态
./iTerm2-汉化管理.command status

# 安装汉化
./iTerm2-汉化管理.command apply

# 恢复英文原版
./iTerm2-汉化管理.command remove
```

当 iTerm2 不在默认位置时：

```bash
ITERM_APP_PATH="/Applications/iTerm2.app" ./iTerm2-汉化管理.command
```

## 常见问题

### 汉化会影响现有配置吗？

不会。工具只替换应用界面资源，现有设置、配置文件和工作区保持不变。

### 如何恢复英文原版？

重新运行管理工具，选择“删除汉化并恢复原版”。

### 为什么汉化后不能自动更新？

中文资源与特定版本绑定。自动更新可能覆盖汉化文件并造成界面异常，
因此工具会移除更新源。

### 首次启动被 macOS 拦截怎么办？

在 Finder 中右键应用，选择“打开”。汉化版本使用 Ad-hoc 签名，
不等同于原作者发布的官方签名版本。

## 项目结构

```text
├── release/   按版本归档的发布包、说明和校验值
├── tool/      可直接运行的管理脚本与汉化资源
├── source/    翻译词表和本地化构建脚本
├── scripts/   发布等维护脚本
└── .local/    本地构建缓存，不进入 Git
```

主要入口：

- [汉化管理工具](tool/iTerm2-汉化管理.command)
- [简体中文翻译词表](source/translation/ui_zh.tsv)
- [界面翻译脚本](source/scripts/apply_ui_translation.py)
- [字符串表生成脚本](source/scripts/build_localized_strings.py)
- [发布构建脚本](scripts/build-release.command)

## 安全说明

- 执行安装或恢复前必须完全退出 iTerm2。
- 不要删除原应用备份，否则无法安全恢复。
- 汉化脚本仅修改 `/Applications/iTerm.app` 和独立备份目录。
- 建议在执行前确认应用版本为 3.6.11。

## 关于项目

**iTerm2 简体中文汉化工具**是一个非官方、可撤销的本地化项目，目标是让
中文用户以更低门槛使用 iTerm2，同时保留可靠的原版恢复能力。

欢迎通过 Issues 反馈翻译遗漏、界面布局问题或改进建议。
