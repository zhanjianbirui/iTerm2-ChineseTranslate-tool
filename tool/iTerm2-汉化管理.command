#!/bin/bash

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ASSET_DIR="$SCRIPT_DIR/assets"
APP_PATH="${ITERM_APP_PATH:-/Applications/iTerm.app}"
STATE_DIR="${ITERM_L10N_STATE_DIR:-$HOME/Library/Application Support/iTerm2-Chinese-Localization}"
BACKUP_APP="$STATE_DIR/iTerm.app.original"
META_FILE="$STATE_DIR/backup-version.txt"
SUPPORTED_VERSION="3.6.11"
NIB_DIR="$ASSET_DIR/nibs"
STRING_DIR="$ASSET_DIR/strings"

if [[ ! -d "$APP_PATH" ]]; then
    printf '未找到应用：%s\n' "$APP_PATH"
    printf '可以用环境变量指定路径，例如：\n'
    printf 'ITERM_APP_PATH="/Applications/iTerm2.app" "%s"\n' "$0"
    exit 1
fi

if [[ ! -d "$NIB_DIR" || ! -d "$STRING_DIR" ]]; then
    printf '汉化资源缺失，请确认整个文件夹已完整解压。\n'
    exit 1
fi

app_version() {
    /usr/bin/plutil -extract CFBundleShortVersionString raw "$APP_PATH/Contents/Info.plist" 2>/dev/null
}

app_is_chinese() {
    [[ -d "$APP_PATH/Contents/Resources/zh-Hans.lproj" ]] &&
        [[ "$(/usr/bin/plutil -extract CFBundleDevelopmentRegion raw "$APP_PATH/Contents/Info.plist" 2>/dev/null)" == "zh-Hans" ]]
}

require_supported_version() {
    local version
    version="$(app_version)"
    if [[ "$version" != "$SUPPORTED_VERSION" ]]; then
        printf '当前应用版本为 %s，本工具只支持 iTerm2 %s。\n' "${version:-未知}" "$SUPPORTED_VERSION"
        return 1
    fi
}

require_app_not_running() {
    if /usr/bin/pgrep -x "iTerm2" >/dev/null 2>&1; then
        printf 'iTerm2 正在运行。请先按 ⌘Q 完全退出应用，再重新运行本工具。\n'
        return 1
    fi
}

prepare_permissions() {
    NEED_SUDO=0
    if [[ ! -w "$APP_PATH/Contents/Resources" || ! -w "$APP_PATH/Contents" ]]; then
        printf '修改“应用程序”中的 iTerm2 需要管理员权限。\n'
        /usr/bin/sudo -v || return 1
        NEED_SUDO=1
    fi
}

privileged() {
    if [[ "$NEED_SUDO" -eq 1 ]]; then
        /usr/bin/sudo "$@"
    else
        "$@"
    fi
}

safe_remove_added_files() {
    privileged /bin/rm -rf "$APP_PATH/Contents/Resources/zh-Hans.lproj"
    privileged /bin/rm -f "$APP_PATH/Contents/Resources/Localizable.strings"
    privileged /bin/rm -f "$APP_PATH/Contents/Resources/InfoPlist.strings"
}

resign_app() {
    printf '正在重新签名应用…\n'
    privileged /usr/bin/codesign --force --deep --sign - --timestamp=none "$APP_PATH" || return 1
    privileged /usr/bin/codesign --verify --deep --strict "$APP_PATH" || return 1
}

backup_original() {
    if [[ -d "$BACKUP_APP" ]]; then
        local backup_version
        backup_version="$(/usr/bin/plutil -extract CFBundleShortVersionString raw "$BACKUP_APP/Contents/Info.plist" 2>/dev/null)"
        if [[ "$backup_version" != "$SUPPORTED_VERSION" ]]; then
            printf '已有备份版本为 %s，与当前工具不匹配。\n' "${backup_version:-未知}"
            return 1
        fi
        return 0
    fi

    printf '首次安装前正在备份原应用，可能需要一点时间…\n'
    /bin/mkdir -p "$STATE_DIR" || return 1
    /usr/bin/ditto --norsrc --noextattr "$APP_PATH" "$BACKUP_APP" || return 1
    printf '%s\n' "$SUPPORTED_VERSION" > "$META_FILE"
    printf '原应用已备份到：%s\n' "$BACKUP_APP"
}

install_localization() {
    require_supported_version || return 1

    if app_is_chinese; then
        printf '当前应用已经安装汉化，无需重复操作。\n'
        return 0
    fi

    require_app_not_running || return 1
    prepare_permissions || return 1
    backup_original || return 1

    printf '正在安装简体中文资源…\n'
    privileged /bin/mkdir -p "$APP_PATH/Contents/Resources/zh-Hans.lproj" || return 1

    local nib
    for nib in "$NIB_DIR"/*.nib; do
        local name
        name="$(/usr/bin/basename "$nib")"
        privileged /bin/cp "$nib" "$APP_PATH/Contents/Resources/$name" || return 1
        privileged /bin/cp "$nib" "$APP_PATH/Contents/Resources/zh-Hans.lproj/$name" || return 1
    done

    local table
    for table in "$STRING_DIR"/*.strings; do
        local name
        name="$(/usr/bin/basename "$table")"
        privileged /bin/cp "$table" "$APP_PATH/Contents/Resources/$name" || return 1
        privileged /bin/cp "$table" "$APP_PATH/Contents/Resources/zh-Hans.lproj/$name" || return 1
    done

    privileged /usr/bin/plutil -replace CFBundleDevelopmentRegion -string zh-Hans "$APP_PATH/Contents/Info.plist" || return 1
    privileged /usr/bin/plutil -replace CFBundleLocalizations -json '["zh-Hans"]' "$APP_PATH/Contents/Info.plist" || return 1
    privileged /usr/bin/plutil -insert CFBundleDisplayName -string "iTerm2 中文版" "$APP_PATH/Contents/Info.plist" 2>/dev/null ||
        privileged /usr/bin/plutil -replace CFBundleDisplayName -string "iTerm2 中文版" "$APP_PATH/Contents/Info.plist" || return 1

    privileged /usr/bin/plutil -remove SUFeedURL "$APP_PATH/Contents/Info.plist" 2>/dev/null || true
    privileged /usr/bin/plutil -remove SUFeedURLForFinal "$APP_PATH/Contents/Info.plist" 2>/dev/null || true
    privileged /usr/bin/plutil -remove SUFeedURLForTesting "$APP_PATH/Contents/Info.plist" 2>/dev/null || true

    resign_app || {
        printf '签名失败，正在恢复原应用资源。\n'
        remove_localization
        return 1
    }

    printf '汉化安装完成。请重新打开 iTerm2。\n'
}

remove_localization() {
    require_supported_version || return 1

    if [[ ! -d "$BACKUP_APP" ]]; then
        printf '没有找到原应用备份，无法安全删除汉化。\n'
        printf '备份位置：%s\n' "$BACKUP_APP"
        return 1
    fi

    require_app_not_running || return 1
    prepare_permissions || return 1

    printf '正在恢复原应用资源…\n'

    local nib
    for nib in "$NIB_DIR"/*.nib; do
        local name
        name="$(/usr/bin/basename "$nib")"
        privileged /bin/cp "$BACKUP_APP/Contents/Resources/$name" "$APP_PATH/Contents/Resources/$name" || return 1
    done

    local table
    for table in "$STRING_DIR"/*.strings; do
        local name
        name="$(/usr/bin/basename "$table")"
        if [[ "$name" == "Localizable.strings" || "$name" == "InfoPlist.strings" ]]; then
            continue
        fi
        privileged /bin/cp "$BACKUP_APP/Contents/Resources/$name" "$APP_PATH/Contents/Resources/$name" || return 1
    done

    privileged /bin/cp "$BACKUP_APP/Contents/Info.plist" "$APP_PATH/Contents/Info.plist" || return 1
    safe_remove_added_files
    resign_app || return 1

    printf '汉化已删除，应用已恢复为英文原版。\n'
}

show_status() {
    printf '应用路径：%s\n' "$APP_PATH"
    printf '应用版本：%s\n' "$(app_version)"
    if app_is_chinese; then
        printf '汉化状态：已安装\n'
    else
        printf '汉化状态：未安装\n'
    fi
    if [[ -d "$BACKUP_APP" ]]; then
        printf '原应用备份：%s\n' "$BACKUP_APP"
    else
        printf '原应用备份：尚未创建\n'
    fi
}

perform_action() {
    case "$1" in
        apply)
            install_localization
            ;;
        remove)
            remove_localization
            ;;
        status)
            show_status
            ;;
        *)
            printf '未知操作：%s\n' "$1"
            return 1
            ;;
    esac
}

if [[ $# -gt 0 ]]; then
    perform_action "$1"
    exit $?
fi

while true; do
    printf '\n========================================\n'
    printf ' iTerm2 简体中文汉化管理工具\n'
    printf '========================================\n'
    printf '1. 安装汉化\n'
    printf '2. 删除汉化并恢复原版\n'
    printf '3. 查看当前状态\n'
    printf '4. 退出\n\n'
    printf '请选择 [1-4]：'
    read -r choice

    case "$choice" in
        1) install_localization ;;
        2) remove_localization ;;
        3) show_status ;;
        4) exit 0 ;;
        *) printf '请输入 1、2、3 或 4。\n' ;;
    esac
done
