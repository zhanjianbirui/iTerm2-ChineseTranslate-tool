#!/usr/bin/env python3
"""Generate zh-Hans string tables for a patched iTerm2 application bundle."""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
from pathlib import Path


def load_glossary(path: Path) -> dict[str, str]:
    glossary: dict[str, str] = {}
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        if not raw_line or raw_line.startswith("#"):
            continue
        source, translated = raw_line.split("\t", 1)
        glossary[source] = translated
    return glossary


def strings_quote(value: str) -> str:
    escaped = (
        value.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("\n", "\\n")
        .replace("\r", "\\r")
        .replace("\t", "\\t")
    )
    return f'"{escaped}"'


def read_strings_table(path: Path) -> dict[str, str]:
    result = subprocess.run(
        ["plutil", "-convert", "json", "-o", "-", str(path)],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def write_table(path: Path, entries: dict[str, str]) -> None:
    lines = ["// Simplified Chinese localization for iTerm2 3.6.11.", ""]
    for key in sorted(entries):
        lines.append(f"{strings_quote(key)} = {strings_quote(entries[key])};")
    lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--glossary", required=True, type=Path)
    parser.add_argument("--resources", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    glossary = load_glossary(args.glossary)
    if args.output.exists():
        shutil.rmtree(args.output)
    args.output.mkdir(parents=True)

    for source in sorted(args.resources.glob("*.strings")):
        entries = read_strings_table(source)
        translated = {
            key: glossary.get(key, glossary.get(value, value))
            for key, value in entries.items()
        }
        write_table(args.output / source.name, translated)

    write_table(args.output / "Localizable.strings", glossary)

    info_plist_strings = {
        "CFBundleDisplayName": "iTerm2 中文版",
        "CFBundleName": "iTerm2 中文版",
        "NSAppleEventsUsageDescription": "iTerm2 中的应用程序请求使用 AppleScript。",
        "NSBluetoothAlwaysUsageDescription": "iTerm2 中的应用程序请求使用蓝牙。",
        "NSCalendarsUsageDescription": "iTerm2 中的应用程序请求访问日历数据。",
        "NSCameraUsageDescription": "iTerm2 请求使用相机。",
        "NSContactsUsageDescription": "iTerm2 请求访问您的通讯录。",
        "NSLocalNetworkUsageDescription": "iTerm2 中的应用程序请求访问本地网络。",
        "NSLocationAlwaysUsageDescription": "iTerm2 中的应用程序请求在后台使用您的位置信息。",
        "NSLocationUsageDescription": "iTerm2 中的应用程序请求使用您的位置信息。",
        "NSLocationWhenInUseUsageDescription": "iTerm2 中的应用程序请求在使用期间访问您的位置信息。",
        "NSMicrophoneUsageDescription": "iTerm2 中的应用程序请求使用麦克风。",
        "NSPhotoLibraryUsageDescription": "iTerm2 中的应用程序请求访问照片图库。",
        "NSRemindersUsageDescription": "iTerm2 中的应用程序请求访问提醒事项。",
        "NSSpeechRecognitionUsageDescription": "iTerm2 中的应用程序请求使用语音识别。",
        "NSSystemAdministrationUsageDescription": "iTerm2 中的程序执行的操作需要更高权限。",
    }
    write_table(args.output / "InfoPlist.strings", info_plist_strings)

    print(f"Wrote {len(list(args.output.glob('*.strings')))} string tables to {args.output}")


if __name__ == "__main__":
    main()
