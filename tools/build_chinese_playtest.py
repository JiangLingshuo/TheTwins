"""Export the Chinese Ink text bank as a Godot translation lookup table."""
import json
import re
from pathlib import Path

folder = Path(__file__).resolve().parents[1] / "assets/dialogue"
source = (folder / "chinese_playtest.ink").read_text(encoding="utf-8-sig")
pattern = r"^=== zh_\d+ ===\n// source: ([^\n]+)\n(.*?)^-> DONE$"
entries = {}
for match in re.finditer(pattern, source, re.M | re.S):
    # The source comment holds one JSON string, even for a multiline entry.
    key = match[1]
    value = match[2].strip().replace("{player_name}", "#PLAYER#")
    key = json.loads(key)
    assert key not in entries and value, key
    assert re.findall(r'<link="([^"]+)">', key) == re.findall(r'<link="([^"]+)">', value), key
    entries[key] = value
assert len(entries) == len(re.findall(r"^=== zh_", source, re.M))
(folder / "chinese_playtest.json").write_text(
    json.dumps(entries, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
)
print(f"Exported {len(entries)} Chinese strings")
