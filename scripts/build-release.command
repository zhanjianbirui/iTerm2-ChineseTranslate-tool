#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:-}"
FORCE="${2:-}"

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    printf '用法：%s VERSION\n' "$0"
    printf '示例：%s 1.0.1\n' "$0"
    exit 1
fi

RELEASE_DIR="$ROOT_DIR/release/v$VERSION"
ARCHIVE_NAME="iTerm2-ChineseTranslate-tool-v$VERSION.zip"
NOTES="$ROOT_DIR/RELEASE_NOTES.md"

if [[ -e "$RELEASE_DIR/$ARCHIVE_NAME" && "$FORCE" != "--force" ]]; then
    printf '发布包已经存在：%s\n' "$RELEASE_DIR/$ARCHIVE_NAME"
    exit 1
fi

if ! /usr/bin/grep -q "v$VERSION" "$NOTES"; then
    printf '请先更新 %s 中的版本号和发布说明。\n' "$NOTES"
    exit 1
fi

if [[ "$(find "$ROOT_DIR/tool/assets/nibs" -type f -name '*.nib' | wc -l | tr -d ' ')" != "70" ]]; then
    printf '界面资源数量不正确。\n'
    exit 1
fi

if [[ "$(find "$ROOT_DIR/tool/assets/strings" -type f -name '*.strings' | wc -l | tr -d ' ')" != "9" ]]; then
    printf '字符串表数量不正确。\n'
    exit 1
fi

STAGING="$(mktemp -d /private/tmp/iterm2-release.XXXXXX)"
trap 'rm -rf "$STAGING"' EXIT

BUNDLE="$STAGING/iTerm2-ChineseTranslate-tool-v$VERSION"
mkdir -p "$BUNDLE" "$RELEASE_DIR"

cp "$ROOT_DIR/tool/iTerm2-汉化管理.command" "$BUNDLE/"
cp "$ROOT_DIR/tool/使用说明.md" "$BUNDLE/"
cp "$ROOT_DIR/tool/README.md" "$BUNDLE/"
cp "$NOTES" "$BUNDLE/RELEASE_NOTES.md"
ditto --norsrc --noextattr "$ROOT_DIR/tool/assets" "$BUNDLE/assets"

rm -f "$RELEASE_DIR/$ARCHIVE_NAME" "$RELEASE_DIR/SHA256SUMS.txt"
ditto -c -k --norsrc --noextattr --keepParent "$BUNDLE" "$RELEASE_DIR/$ARCHIVE_NAME"
cp "$NOTES" "$RELEASE_DIR/RELEASE_NOTES.md"
(
    cd "$RELEASE_DIR"
    shasum -a 256 "$ARCHIVE_NAME" > SHA256SUMS.txt
)

unzip -t "$RELEASE_DIR/$ARCHIVE_NAME" >/dev/null

printf '发布包已生成：%s\n' "$RELEASE_DIR/$ARCHIVE_NAME"
cat "$RELEASE_DIR/SHA256SUMS.txt"
