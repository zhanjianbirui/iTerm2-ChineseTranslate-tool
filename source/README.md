# 源码与翻译资源

本目录保留可维护的汉化材料，不包含 iTerm2 官方源码或完整应用包。

```text
source/
├── translation/
│   └── ui_zh.tsv
└── scripts/
    ├── apply_ui_translation.py
    └── build_localized_strings.py
```

- `ui_zh.tsv`：英文原文与简体中文译文的对照表。
- `apply_ui_translation.py`：将词表应用到界面 XIB。
- `build_localized_strings.py`：生成 `.strings` 本地化文件。

重新编译 NIB 和签名应用需要对应版本的 iTerm2 源码、Xcode 和
`ibtool`。这些大型构建依赖放在本地 `.local/` 目录，不提交到 Git。
