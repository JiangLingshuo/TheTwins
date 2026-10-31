# Twins 对话文件联动与测试说明

## 先怎么打开

用 Inky 打开本文件夹里的 **test.ink**，从右侧测试菜单操作。`test.ink` 与 `evidence_master.ink` 必须放在同一目录。测试版已通过 Ink 编译，并实际跑通证据 OR 匹配、错误证据回退、探照灯年份和终局流程。

这是用来确认内容与条件的文字测试，不是已经接好的 Godot 场景。相机点击、场景拖拽、无线电证据框和可点击富文本，仍由游戏程序实现；Inky 里用 DEV 菜单模拟这些动作。

## 文件分工

| 文件 | 负责什么 | 本次处理 |
| --- | --- | --- |
| `telecomm_master.ink` | 所有无线电通信：开场、每座碑的问题、回复、隐藏潜台词、bonus 与终局对话 | 保留原文件；已有开场与小碑问答逐句复制进测试版，只调整返回路径并加入分支 |
| `tombstone_master.ink` | 墓碑查看页：标题、场景、材质、轮廓、可见装饰等介绍；不承担无线电对话 | 保留原文件，目前仍是占位故事；七座碑介绍先写在测试版 |
| `evidence_master.ink` | 可收集证据、文献、观察、拓印和推理结论的标题、正文、ID 与 tag | 保留原文件；测试版 INCLUDE 它，依据当前 64 条证据与 93 个推理 tag 制作调试菜单和条件 |
| `test.ink` | 独立可运行的测试入口，将上述三类内容接成最小闭环 | 本次新增；含七座碑、26 个普通问题、证据限定的隐藏分支、全局候选、报告与终局 |
| `README_dialogue_zh.md` | 这份总联动说明，告诉程序和作者先怎么试 | 本次新增 |
| `README_evidence_zh.md` | 证据字段、点击词条分类、工具和年份的详细约定 | 沿用，并加入测试入口链接 |
| `start.xml` | 当前 Godot 已在用的旧开场格式 | 未修改，不会因添加 Ink 自动被替换 |

内容依据 `墓碑表.xlsx` 的七座碑工作表。后续明确的新规则优先于表中旧单元格：学者使用双生兽／消失，皮肤画用探照灯，太阳形碑初见不直接称钱币碑，证据接受 OR，普通无线电不限尝试次数。Excel 的待填潜台词与结局衔接补成了英文测试稿，可继续改。

## 先试一个最短例子

1. 选择 `DEV: collect / read a source record`，点 `designer_manuscript`，阅读后点 Back。
2. 在 `Read / collect clickable terms` 中点 Infant，返回。现在所有墓碑调查页均可选婴儿，并非只解锁小碑。
3. 再从 DEV 资料库收集 `designer_journal` 或 `infant_graffiti`，两份任选一份即可。
4. 选择 `Prepare one collected evidence for the radio`，将刚才那份放入槽。
5. `Contact Aurora` → `The Small Human-Shaped Marker` → 月亮的问题。保留的原回答后应出现另有隐情的补充，并授予 `infant_death_doubt`。
6. 在这次通话的 `Collect a word from this call` 中记录自然死亡或另有隐情；或退出后在全局词条菜单收录 finding 中的词。
7. 回主页填写报告。候选来自全局池，不自动填答案；允许改错再试。

再换一个无关证据，例如 `moon_reference`，重复问月亮。即使背包已有涂鸦，只要本次没提交它，也不应触发婴儿疑点。隐藏的“谁画了真实形貌”问题也只在证据符合时出现。

## 程序应保持的状态

| 测试变量 | 意义 |
| --- | --- |
| `owned_evidence` | 已获得证据 ID 的集合；注册全文不等于获得全文 |
| `known_tags` | 玩家已获得证据的标签并集，仅用于背景知识与潜台词条件 |
| `selected_id` / `selected_tags` | 开始通话前准备的一份证据及其标签 |
| `submitted_id` / `submitted_tags` | 开始本次通话时复制的证据快照；回答期间不更换 |
| `active_tomb` | 当前询问或填写报告的墓碑 |
| `identities` / `causes` | 全局身份／职业及死因／命运候选池；每座碑共用 |
| `collected_words` | 独立线索词的调试去重记录；不会加入调查下拉框 |
| `links` | 玩家已建立的对应关系，例如河床、封面 |
| `completed_reports` | 已通过测试判定的报告；重复提交不累计数量 |
| `seen_subtexts` / `subtext_count` | 已触发的独立潜台词；重问同一条不重复增加统计 |
| `girl_revealed` / `final_confronted` | 终局孤碑是否出现、是否完成对质 |

`test.ink` 使用 Ink LIST 保存集合，完整名称如 `EvidenceTag.infant_appearance_mismatch`。它只是把证据库中的字符串 tag 映射为可在 Inky 中判断的集合，并不改变原始 tag 含义。

普通通话：先选一份证据，再选碑；本次通话中不能换证据，结束后可以换证据重试，不限总次数。每问完一个问题返回该碑的问题页。夜城婴儿报告后的 bonus 单独限制为两个不同问题，不是对普通通话次数的限制。

## Evidence tag 怎么触发问题

只判断本次 `submitted_tags` 是否含允许的任意一个 tag。多个可用 tag 是 OR，不要求凑齐；额外的已知资料或对应关系是另一层明确条件，不能偷换为“背包有某证据就算提交过”。

```ink
{has_tag(EvidenceTag.infant_appearance_mismatch):
    // 命中特殊回复；无论提交的是设计师日记还是婴儿涂鸦。
}
```

下面是测试版已写入的普通问答条件，便于程序查找。无匹配证据时有普通回退回答；不惩罚尝试，也不会因错误提交自动授予结论。

| 碑 | 问题 | 当前提交证据可接受的 tag 任一 | 结果与补充条件 |
| --- | --- | --- | --- |
| 小碑 | 月亮是什么意思 | `infant_appearance_mismatch` | 原月亮回答保留；匹配后补充疑点，授予 `infant_death_doubt` |
| 小碑 | 为什么是人形 | `infant_identity` | 原“看设计师手稿”回答保留；匹配后补充婴儿尚无职业 |
| 晶石碑 | Why is the monument shaped like a crystal? | `crystal_shape` / `crystal_research_reference` | 对应解释或可点击词条 |
| 晶石碑 | What does the two-part creature mean? | `ancient_disappearance` | 对应解释或可点击词条 |
| 晶石碑 | Did the cities ever cooperate? | `night_city_mineral_origin` / `intercity_resource_exchange` | 对应解释或可点击词条 |
| 晶石碑 | How could a picture be kept inside this crystal? | `skin_as_message_medium` / `day_night_handholding` | 对应解释或可点击词条；已知醒来新伤时才补授 `paired_skin_pictures` |
| 太阳形碑 | Is this simply a monument to the sun? | `day_city_currency` | 仅确认与钱币的形状对应；已知 `tycoon_identity` 才出现大亨答案 |
| 太阳形碑 | Why is the same beast on other markers? | `ancient_disappearance` | 对应解释或可点击词条 |
| 太阳形碑 | Do these three markers belong together? | `shared_family_plot` / `three_family_markers` | 对应解释或可点击词条 |
| 太阳形碑 | Why are four people remembered by only three markers? | `four_person_family` / `missing_family_member_reference` | 对应解释或可点击词条 |
| 夜城祭坛 | What does the unfamiliar glyph say? | `night_blessing_glyph` | 授予 `altar_blessing_translation` |
| 夜城祭坛 | Is this the child from the small marker? | `infant_memorial` / `paired_day_night_memorials` | 对应解释或可点击词条 |
| 夜城祭坛 | Are the moon-shaped stones coins? | `moon_stone_offering` / `night_blessing_reference` | 授予 `moon_stone_blessing` |
| 夜城祭坛 | What was removed from the empty recess? | `removed_crystal_offering` / `crystal_extraction_reference` | 对应解释或可点击词条 |
| 夜母碑 | Who is the figure holding the child? | `parent_child_image` / `night_mother_past` | 对应解释或可点击词条 |
| 夜母碑 | What does the dry river border record? | `dry_river_motif` / `water_source_lost` | 授予 `night_mother_death_finding`；先完成河床比对 `Relation.river` |
| 夜母碑 | Why does the handholding picture resemble the Scholar's? | `skin_as_message_medium` / `unexplained_waking_wounds` / `shared_body_reference` | 对应解释或可点击词条 |
| 夜母碑 | Does the lack of offerings mean she was the last survivor? | `absence_of_readable_traces` / `last_survivor_question` | 对应解释或可点击词条 |
| 夜父碑 | Who is carrying the child? | `parent_child_image` / `night_father_past` | 对应解释或可点击词条 |
| 夜父碑 | Did he die because the Skyway was dangerous? | `skyway_not_steep` / `missed_sleeping_deadline` | 授予 `night_father_death` |
| 夜父碑 | Could his death be linked to the Scholar's husband? | `husband_disappearance` / `dawn_disappearances` / `paired_day_night_death` | 对应解释或可点击词条 |
| 夜父碑 | What does the moon-shaped offering mean? | `moon_stone_offering` / `night_blessing_reference` | 授予 `moon_stone_blessing` |
| 女孩碑 | What is the upright frame around her? | `upright_coffin_motif` / `shared_day_night_history` | 对应解释或可点击词条 |
| 女孩碑 | Who made this marker? | `funerary_artist_reference` | 对应解释或可点击词条 |
| 女孩碑 | Do the family sculpture and the photograph belong together? | `family_image_reference` / `four_person_family` | 对应解释或可点击词条 |
| 女孩碑 | Does disappearance always mean death? | `deliberate_departure` / `two_mothers_dilemma` | 对应解释或可点击词条 |

### 隐藏问题与潜台词

这些问题只在本次携带的证据符合时显示；不能先把隐藏问题列出来，再让玩家猜证据。回复的 `feedback:gold` 供程序显示金框或对应音效；测试版只有文字 tag，并没有实际绘制金框。

| 碑 | 隐藏问题方向 | 提交证据可接受的 tag 任一 | 额外条件 |
| --- | --- | --- | --- |
| 小碑 | 谁画了真实形貌 | `infant_actual_appearance` / `family_requested_depiction` | 已知 `funerary_artist_reference` 时多一句作者身份暗示 |
| 小碑 | 死亡与另一城消失的联系 | `paired_day_night_death` | 无 |
| 晶石碑 | Aurora 为什么熟悉皮肤画 | `skin_as_message_medium` / `day_night_handholding` | 无 |
| 太阳形碑 | 第四个家庭成员在哪里 | `four_person_family` / `missing_family_member_reference` | 无 |
| 夜城祭坛 | Aurora 如何翻译无文字文明符号 | `aurora_translation_knowledge` / `night_symbol_translation` | 无 |
| 夜城祭坛 | 孩子是否生错城市 | `infant_appearance_mismatch` / `infant_actual_appearance` | 无 |
| 夜母碑 | 图画与女儿的关系 | `day_night_handholding` / `shared_body_reference` | 测试补写，供结尾回调 |
| 夜父碑 | 原始塌方是否自然发生 | `natural_collapse` / `shared_day_night_history` | 只质疑官方叙事，不凭共用睡棺自动证明塌方人为 |
| 女孩碑 | Aurora 与笔记本封面 | `aurora_provided_object` / `aurora_identity_reference` | 先比对整体封面，获得 `Relation.cover` 才进入对质 |

不要把 `location:aurora_transmission` 当成身份疑点；它只表示发送渠道。真正用于推理的是 `aurora_translation_knowledge` 等标签。

## 墓碑介绍与证据显示怎样分开

七个介绍段是 `test_desc_baby`、`test_desc_scholar`、`test_desc_sun`、`test_desc_altar`、`test_desc_mother`、`test_desc_father`、`test_desc_girl`。标题和正文用于场景 overlay 的“左图右介绍”，不等于收集证据，更不能打开介绍就解锁所有装饰含义。

程序可按 `type:tombstone`、`tombstone_id`、`location`、`title` 渲染查看页。正式拆分时把这些段落移入 `tombstone_master.ink`，由场景目标调用；不把无线电问题和手稿正文混进介绍面板。

证据阅读建议使用独立 Ink reader／Story，不改变正在进行的通信位置。测试版的 `test_preview_<id>` 是为 Inky 准备的正文副本；正式游戏应从证据库原 knot（如 `ev_infant_graffiti`）读取到 `DONE`。

**注意同步：**测试版 INCLUDE 证据库，但 DEV 预览、ID 菜单和 EvidenceTag LIST 是生成时的快照，不会因编辑证据库正文或新增 tag 自动更新。改 ID、tag 或文案后要同步测试段；正式游戏应以证据库注册表为准，不维护第二套手工正文。不要误认为 INCLUDE 会把两套快照自动合并。

## 点击词条怎样和调查页联动

原证据的 19 个 link 分类继续参考 `README_evidence_zh.md`。测试版另外在支持的回复中补入以下可点击答案：

| link 或测试动作 ID | 类别 | 收录结果 |
| --- | --- | --- |
| `night_mother` | 身份／职业 | 夜城母亲，全局候选 |
| `night_father` | 身份／职业 | 夜城父亲，全局候选 |
| `funerary_artist` | 身份／职业 | 墓碑艺术家，全局候选 |
| `aurora` | 身份／职业 | 对质后玩家选择记录 Aurora |
| `escape` | 死因／命运 | 对质后玩家选择记录逃离；不作为对人物的道德判决 |

`natural`、`disappearance`、`missed_sleeping_deadline`、`thirst` 等继续沿用原分类。未知 link 不能一律塞进身份或死因列表。

Inky 不会自动实现 Godot 的词条点击 UI，测试里用 `Collect a word from this call` 和主页词条菜单模拟。普通回复的模拟点击根据本次证据条件开放，方便调试；正式游戏必须由玩家实际点击已经显示的词触发，不能把测试菜单当作正式收集界面。Aurora／escape 在终局用明确的“记录”选项测试收录。

独立线索词在本测试中先验证“收录、去重、不进入下拉框”。证据槽目前只列证据库原有记录；摘录自身作为证据提交及其 tag 映射尚未加入，不能把全文 tag 全部自动继承给其中任意一个词。

## 比对和工具怎样先测试

DEV 资料库可以直接授予任意记录，包括 finding 与终局资料，只供测试，不能给正式玩家。探照灯菜单则会检查目标年份，先选年份再照目标；不正确时不授予。夜母负向扫描用 2005 和 2050 两个端点模拟完成，尚不是正式扫描玩法。

比对页只显示双方已获得的允许组合。小碑与祭坛、河床、皮肤画、家庭照片与雕像、封面等均有具体关系；未建立关系不会自动视为完成。太阳、太阳形碑、钱币共用形状 tag，但没有“大亨”身份的资料时不提前公布身份。

camera 的目标点击、去重次数、跨城连续观察尚未实现成场景操作。DEV 可以授予这些 observation 来测试下游问答。正式接入仍按证据说明里的 target／city／motif 去重，不以多次点击一个目标凑出结论。

## 六份报告与结局怎样先测试

测试用答案表如下，暂用于验证报告流转，不是最终谜题难度与判分规则。因关卡表未完全定稿，测试版不校验所有工具动作和每一条支撑关系；正式版需另定提交规则。

| 报告 | 身份 | 死因／命运候选 |
| --- | --- | --- |
| 小碑 | `infant` | `natural` 或 `unexplained` |
| 晶石碑 | `scholar` | `disappearance` |
| 太阳形碑 | `tycoon` | `disappearance` |
| 夜城祭坛 | `infant` | `disappearance` |
| 夜母碑 | `night_mother` | `hunger_and_thirst` |
| 夜父碑 | `night_father` | `missed_sleeping_deadline` |
| 女孩碑 | `funerary_artist` 或 `aurora` | `disappearance` 或 `escape`，并已完成对质 |

六份报告完成后，主页出现“提交六份报告”。提交后经历封面思考与行走，再出现孤碑。最终身份不会因为打开介绍直接揭晓；需收集女孩整体图案和日记／调查本封面，建立对应，带相关证据联系 Aurora。

结尾会根据已收集的家庭雕像、牵手画回调母亲的情感。玩家可以记录事实、保留空白，不提供“原谅／不原谅 Aurora”的审判选项。

## Godot 接入的事件约定

这些 tag 是测试约定，需要程序消费；Ink 本身不会画 UI、播放声音或添加实物。每次 Continue 的正文与 tags 都要读取，正文为空也要处理 tags。授予操作需按 ID 幂等，重复问话不重复生成卡片。

| tag 前缀 | 建议处理 |
| --- | --- |
| `event:grant_evidence:<id>` | 加入笔记本，或确认该证据已获得 |
| `ui:open_evidence:<id>` | 打开独立证据阅读面板 |
| `event:collect_term:<link_id>` | 按词条注册表解锁候选或独立线索，不把任何 tag 都当答案 |
| `event:comparison:<relation>` | 显示已建立的对应，概括卡保留原始证据引用 |
| `event:radio_start` | 固定本轮证据槽，准备通信 UI |
| `feedback:gold` | 隐藏潜台词反馈；统计按不同条目去重 |
| `event:report_accepted:<tomb>` | 标记报告完成，不自动判定全部叙事真相 |
| `event:reports_submitted` / `music_phase:after_reports` | 提交报告并进入报告后音乐阶段 |
| `ui:notebook_cover` | 显示本子封面思考过渡 |
| `event:reveal_girl_marker` | 在墓园中开放终局孤碑 |
| `event:aurora_confronted` / `event:open_ending` | 记录对质和开放结尾状态 |

Ink 测试变量已经保存这些状态。正式程序接入时应明确由 Ink 还是 GameState 管理，再由事件同步，避免两边各判一次造成重复授予或进度不同步。存档至少保留证据、词条池、对应、报告、潜台词和终局阶段；不要只保存当前对话位置。

## 后面怎样拆回 master

1. 先在 `test.ink` 改问答与条件，确认测试结果符合预期。
2. 把介绍段搬到 `tombstone_master.ink`；把 `opening`、`daybaby_tele`、`test_radio_*`、bonus、对质等无线电内容搬到 `telecomm_master.ink`。
3. 让正式主入口声明公共变量与函数，再 INCLUDE 三个 master。每个文件只包含一次，段名与 ID 全局唯一。
4. 正式被 INCLUDE 的内容文件不应在顶层自行启动故事；当前 telecomm 的顶层 `->opening` 需在整合时改为由正式入口调用，当前 tombstone 占位故事也需替换。本次未动这两个文件。
5. 整合完成后移除测试正文副本、DEV 强制授予菜单和临时判分，不同时 INCLUDE `test.ink` 与三份正式内容，否则会有重复段落或入口冲突。

当前测试版故意不 INCLUDE telecomm／tombstone，而将它们的测试内容集中在一个文件，便于保留作者原稿并比较。这不是正式文件组织已迁移完成。

## 本次已做的检查

- Ink 编译通过，无编译报错。
- 设计师日记、婴儿涂鸦分别提交，均能命中同一疑点分支并授予 finding。
- 持有正确证据但提交月亮参照，不误触发疑点；通话中没有替换证据入口。
- 探照灯错误年份不授予；2000 年正确获得婴儿涂鸦。
- 实际走通六份报告、两个不同 bonus 问题、封面过渡、女孩碑比对、Aurora 对质及两个母亲回调。
- 对照原稿核对开场与小碑的原有英文段落，并检查三个原 master 在本次未被覆盖。

以上是 Ink 文本运行测试；还没有在 Godot UI 中验证工具、拖拽、金框、音频或存档接入。
