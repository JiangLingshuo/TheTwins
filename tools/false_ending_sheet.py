"""Round-trip the false ending ("ending_false" in telecomm_master.ink) through an Excel
backfill sheet, so it can be rewritten like the rest of the dialogue.

    python tools/false_ending_sheet.py export    # ink -> assets/dialogue/假结局回填表.xlsx
    python tools/false_ending_sheet.py import    # the sheet -> ink, Chinese playtest text, game data

One row per line. Add, delete, reorder or rewrite rows freely. Columns:
  说话人    Aurora / 玩家 / 旁白
  台词      the line (旁白 lines are usually in parentheses)
  音效      none, or a sound cue on that line: busy / wind / hangup
  中文试玩  Chinese playtest text; leave empty to show the English in the Chinese build
"""
import io
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
D = ROOT / "assets/dialogue"
SHEET = D / "假结局回填表.xlsx"
INK = D / "telecomm_master.ink"
ZH_INK = D / "chinese_playtest.ink"
ZH_JSON = D / "chinese_playtest.json"
KNOT = "ending_false"

ROLE_TO_NAME = {"aurora": "Aurora", "player": "玩家", "narrator": "旁白"}
NAME_TO_ROLE = {v: k for k, v in ROLE_TO_NAME.items()}
SFX_CHOICES = ["无", "busy 忙音", "wind 风声", "hangup 挂断"]
SFX_FROM_LABEL = {"无": "", "busy 忙音": "busy", "wind 风声": "wind", "hangup 挂断": "hangup"}
SFX_TO_LABEL = {v: k for k, v in SFX_FROM_LABEL.items()}


def read(path):
    return path.read_text(encoding="utf-8-sig").replace("\r\n", "\n")


def write(path, text, like):
    crlf = "\r\n" in like.read_text(encoding="utf-8-sig")
    path.write_text(text.replace("\n", "\r\n") if crlf else text, encoding="utf-8")


def knot_span(source):
    m = re.search(r"^=== %s ===\n" % KNOT, source, re.M)
    if not m:
        raise SystemExit("Knot %s not found in telecomm_master.ink" % KNOT)
    nxt = re.search(r"^===", source[m.end():], re.M)
    end = m.end() + nxt.start() if nxt else len(source)
    return m.start(), m.end(), end


def lines_from_ink():
    source = read(INK)
    _, body_start, end = knot_span(source)
    rows = []
    for raw in source[body_start:end].splitlines():
        line = raw.strip()
        sfx = re.fullmatch(r"# sfx:(\w+)", line)
        speech = re.match(r"^(.*?)\s*#(aurora|player|narrator)\s*$", line)
        if sfx and rows:
            rows[-1]["sfx"] = sfx.group(1)
        elif speech:
            rows.append({"role": speech.group(2), "text": speech.group(1), "sfx": ""})
    return rows


def zh_map():
    return json.loads(ZH_JSON.read_text(encoding="utf-8"))


def export():
    import openpyxl
    from openpyxl.styles import Alignment, Font, PatternFill
    from openpyxl.worksheet.datavalidation import DataValidation

    zh = zh_map()
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "假结局"
    ws["A2"] = "假结局"
    ws["A2"].font = Font(size=16, bold=True)
    ws["A3"] = ("每行一句，可随意增删、调换顺序、改写。说话人和音效可下拉。旁白通常带括号。"
                "中文试玩留空＝中文版里显示英文原文。改完告诉我，运行 import 即可写回游戏。")
    ws["A3"].alignment = Alignment(wrap_text=True, vertical="top")
    ws.merge_cells("A3:E3")
    ws.row_dimensions[3].height = 34
    headers = ["序号", "说话人（下拉）", "台词／旁白", "音效（下拉）", "中文试玩文本"]
    for col, text in enumerate(headers, 1):
        cell = ws.cell(row=5, column=col, value=text)
        cell.font = Font(bold=True)
        cell.fill = PatternFill("solid", fgColor="DDE3EE")
    rows = lines_from_ink()
    for index, row in enumerate(rows, 1):
        r = 5 + index
        ws.cell(row=r, column=1, value=index)
        ws.cell(row=r, column=2, value=ROLE_TO_NAME[row["role"]])
        ws.cell(row=r, column=3, value=row["text"])
        ws.cell(row=r, column=4, value=SFX_TO_LABEL.get(row["sfx"], "无"))
        ws.cell(row=r, column=5, value=zh.get(row["text"], ""))
        for col in (3, 5):
            ws.cell(row=r, column=col).alignment = Alignment(wrap_text=True, vertical="top")
        for col in (1, 2, 4):
            ws.cell(row=r, column=col).alignment = Alignment(vertical="top")
    last = max(5 + len(rows) + 60, 80)  # room to add rows
    speakers = DataValidation(type="list", formula1='"%s"' % ",".join(ROLE_TO_NAME.values()), allow_blank=True)
    cues = DataValidation(type="list", formula1='"%s"' % ",".join(SFX_CHOICES), allow_blank=True)
    ws.add_data_validation(speakers)
    ws.add_data_validation(cues)
    speakers.add("B6:B%d" % last)
    cues.add("D6:D%d" % last)
    for letter, width in zip("ABCDE", (6, 16, 78, 14, 60)):
        ws.column_dimensions[letter].width = width
    ws.freeze_panes = "A6"
    SHEET.parent.mkdir(parents=True, exist_ok=True)
    wb.save(SHEET)
    print("Wrote %s (%d lines)" % (SHEET.name, len(rows)))


def read_sheet():
    import openpyxl
    wb = openpyxl.load_workbook(SHEET, data_only=True)
    ws = wb["假结局"]
    rows = []
    for r in range(6, ws.max_row + 1):
        speaker = ws.cell(row=r, column=2).value
        text = ws.cell(row=r, column=3).value
        if speaker is None and text is None:
            continue
        if speaker is None or text is None or not str(text).strip():
            raise SystemExit("Row %d needs both a speaker and a line." % r)
        speaker = str(speaker).strip()
        if speaker not in NAME_TO_ROLE:
            raise SystemExit("Row %d: unknown speaker %r (use Aurora / 玩家 / 旁白)." % (r, speaker))
        cue = str(ws.cell(row=r, column=4).value or "无").strip()
        if cue not in SFX_FROM_LABEL:
            raise SystemExit("Row %d: unknown sound %r." % (r, cue))
        zh = ws.cell(row=r, column=5).value
        rows.append({
            "role": NAME_TO_ROLE[speaker],
            "text": " ".join(str(text).split("\n")).strip(),
            "sfx": SFX_FROM_LABEL[cue],
            "zh": " ".join(str(zh).split("\n")).strip() if zh else "",
        })
    if not rows:
        raise SystemExit("The sheet has no lines.")
    return rows


def import_sheet():
    rows = read_sheet()
    source = read(INK)
    start, body_start, end = knot_span(source)
    header = "=== %s ===\n// Source: 假结局回填表.xlsx (tools/false_ending_sheet.py).\n" % KNOT
    body = ""
    for row in rows:
        body += "%s #%s\n" % (row["text"], row["role"])
        if row["sfx"]:
            body += "# sfx:%s\n" % row["sfx"]
    body += "-> END\n\n"
    write(INK, source[:start] + header + body + source[end:], INK)

    # Chinese playtest text: update a line's translation, or add one.
    zh_source = read(ZH_INK)
    existing = set(re.findall(r"^// source: (.*)$", zh_source, re.M))
    last_id = max(int(x) for x in re.findall(r"^=== zh_(\d+) ===", zh_source, re.M))
    added = updated = 0
    for row in rows:
        if not row["zh"]:
            continue
        key = json.dumps(row["text"], ensure_ascii=False)
        if key in existing:
            pattern = re.compile(r"(// source: %s\n)([^\n]*)(\n-> DONE)" % re.escape(key))
            new_source, count = pattern.subn(lambda m: m.group(1) + row["zh"] + m.group(3), zh_source, count=1)
            if count and new_source != zh_source:
                zh_source = new_source
                updated += 1
        else:
            last_id += 1
            zh_source = zh_source.rstrip("\n") + "\n\n=== zh_%04d ===\n// source: %s\n%s\n-> DONE\n" % (last_id, key, row["zh"])
            added += 1
    write(ZH_INK, zh_source, ZH_INK)
    print("Imported %d lines (Chinese: %d updated, %d added)" % (len(rows), updated, added))
    for script in ("build_radio_content.py", "build_chinese_playtest.py"):
        subprocess.run([sys.executable, "-I", str(ROOT / "tools" / script)], check=True)


if __name__ == "__main__":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")
    command = sys.argv[1] if len(sys.argv) > 1 else ""
    if command == "export":
        export()
    elif command == "import":
        import_sheet()
    else:
        raise SystemExit(__doc__)
