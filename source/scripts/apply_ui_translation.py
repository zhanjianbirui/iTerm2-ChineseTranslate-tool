#!/usr/bin/env python3
"""Apply the reviewed Simplified Chinese UI glossary to iTerm2 XIB files."""

from __future__ import annotations

import argparse
import html
import shutil
from pathlib import Path


TRANSLATABLE_ATTRIBUTES = (
    "title",
    "placeholderString",
    "toolTip",
    "subtitle",
)


def load_glossary(path: Path) -> dict[str, str]:
    glossary: dict[str, str] = {}
    for line_number, raw_line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = raw_line.rstrip()
        if not line or line.startswith("#"):
            continue
        try:
            source, translated = line.split("\t", 1)
        except ValueError as exc:
            raise ValueError(f"{path}:{line_number}: expected a tab-separated pair") from exc
        if source in glossary and glossary[source] != translated:
            raise ValueError(f"{path}:{line_number}: conflicting translation for {source!r}")
        glossary[source] = translated
    return glossary


def translate_xib(source_root: Path, output_root: Path, glossary: dict[str, str]) -> None:
    if output_root.exists():
        shutil.rmtree(output_root)
    output_root.mkdir(parents=True)

    translated_count = 0
    for source in sorted(source_root.glob("*.xib")):
        text = source.read_text(encoding="utf-8")
        for original, translation in glossary.items():
            original_xml = html.escape(original, quote=True)
            translated_xml = html.escape(translation, quote=True)
            for attribute in TRANSLATABLE_ATTRIBUTES:
                needle = f'{attribute}="{original_xml}"'
                if needle in text:
                    text = text.replace(needle, f'{attribute}="{translated_xml}"')
                    translated_count += 1
                element_needle = f'<string key="{attribute}">{original_xml}</string>'
                if element_needle in text:
                    text = text.replace(
                        element_needle,
                        f'<string key="{attribute}">{translated_xml}</string>',
                    )
                    translated_count += 1
        (output_root / source.name).write_text(text, encoding="utf-8")

    print(f"Translated {translated_count} XIB attributes across {len(list(source_root.glob('*.xib')))} files")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--glossary", required=True, type=Path)
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    glossary = load_glossary(args.glossary)
    translate_xib(args.source, args.output, glossary)
    print(f"Loaded {len(glossary)} reviewed translations")


if __name__ == "__main__":
    main()
