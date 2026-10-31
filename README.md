# TheTwins
A tiny little puzzle game

## Evidence categories and tools

Evidence content is defined in `assets/dialogue/evidence_master.ink`.
`category` describes the record; `tool` describes how the player obtains it.
These are project metadata conventions and require game-side handling.

| Category | Purpose |
| --- | --- |
| `rubbing` | A copied permanent symbol or outline, including a copied book illustration. |
| `manuscript` | A written record, diary, historical account, or order; currently delivered by Aurora. |
| `trace` | A past object or mark revealed with the searchlight. |
| `object` | A physical reference object or sample. |
| `observation` | A recorded visible feature or relationship; scene observations use the camera. |
| `finding` | A conclusion awarded after comparison or dialogue, rather than an initial observation. |

### Camera observations

```ink
# category:observation
# tool: camera
```

The camera records visible scene references, repeated motifs, and spatial relationships.
It does not rewind time or reveal microscopic details on the preserved skin; the searchlight reveals that picture.
Camera records currently include the Dayfolk appearance reference, the moon, the shared family base,
the giant footprint, repeated twin-beast motifs, the dry riverbed, and the Skyway.

For repeated observations, the game should track distinct observed targets and their city:
clicking the same target again must not count as another example.
Repeated motifs in one city can support a local-custom observation; matching motifs across cities
can support a cross-cultural observation. A specific correspondence between two markers is a separate comparison.
Photographing one example alone does not establish a symbol's meaning or automatically award a finding.

Not every `observation` uses the camera: notebook/diary covers are inspected while reading,
and `night_mother_no_traces` remains a searchlight scan. Existing comparison and dialogue
requirements still apply; camera tags alone do not implement collection or unlock conclusions.

### Acquisition and time

`location:aurora_transmission` marks a record sent by Aurora; `related_location` preserves its associated investigation area.
Searchlight snapshots use `searchlight_year` and `searchlight_years_ago`, relative to the 2050 investigation.
Suggested and provisional dates are identified by `searchlight_date_status`.

### Sun-shaped monument

Use `sun_shaped_marker_rubbing` and `sun_shaped_beast_rubbing` for the monument's initial records.
`sun_reference`, the monument rubbing, and `day_city_coin` share `sun_shape` and `sun_motif`
so the sun, the marker, and Day City currency can be compared. `day_city_coin` is an actual
coin record, not the monument's identity. A shape match alone does not award the Tycoon identity.
The former monument IDs `coin_marker_rubbing` and `tycoon_beast_rubbing` have been renamed;
update any external references accordingly.

## 中文调试说明

程序接入与词条分类见 [Evidence Master 中文接入与调试说明](assets/dialogue/README_evidence_zh.md)。包含 tag 解析、三类点击词条、camera、探照灯、OR 证据匹配及待补配置。

## 对话联动测试入口

用 Inky 打开 [test.ink](assets/dialogue/test.ink)。七座碑的介绍、无线电证据分支与报告结局联动见 [中文总说明](assets/dialogue/README_dialogue_zh.md)。原始 master 文件保留。
