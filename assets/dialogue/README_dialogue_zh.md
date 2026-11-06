# Twins 对话文件联动与测试说明

## 先怎么打开

用 Inky 打开本文件夹里的 **test.ink**，从右侧测试菜单操作。`test.ink` 与 `evidence_master.ink` 必须放在同一目录。测试版已通过 Ink 编译，并实际跑通证据 OR 匹配、错误证据回退、探照灯年份和终局流程。

这是用来确认内容与条件的文字测试，不是已经接好的 Godot 场景。相机点击、场景拖拽、无线电证据框和可点击富文本，仍由游戏程序实现；Inky 里用 DEV 菜单模拟这些动作。

## 文件分工

| 文件 | 负责什么 | 本次处理 |
| --- | --- | --- |
| `telecomm_master.ink` | 所有无线电通信：开场、每座碑的问题、回复、隐藏潜台词、bonus 与终局对话 | 保留原文件；已有开场与小碑问答逐句复制进测试版，只调整返回路径并加入分支 |
| `tombstone_master.ink` | 墓碑查看页：标题、场景、材质、轮廓、可见装饰等介绍；不承担无线电对话 | 保留原文件，目前仍是占位故事；七座碑介绍先写在测试版 |
| `evidence_master.ink` | 可收集证据、文献、观察、拓印和推理结论的标题、正文、ID 与 tag | 保留原文件；测试版 INCLUDE 它，依据当前 65 条证据与 94 个推理 tag 制作调试菜单和条件 |
| `test.ink` | 独立可运行的测试入口，将上述三类内容接成最小闭环 | 本次新增；含七座碑、27 个普通问题、证据限定的隐藏分支、全局候选、报告与终局 |
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

## 证据条件与两种隐藏机制

本节以2026年11月1日最新回填表为准。测试版现在有37个主问题，另有人形回答后的两条汇合追问；主问题含27个普通问题、10个隐藏问题；另有小碑月亮问题中的1段追加隐藏回答。小碑表里两个同名“为什么人形”问题保留供作者编辑；测试只显示一次，普通回复采用本次改过的前一格，证据回复采用包含新增追问的后一格。

| 机制 | 是否产生新问题 | 触发时机 | 不满足时 |
| --- | --- | --- | --- |
| 隐藏问题 | 是 | 开始通话时的那一份证据符合，才把该选项列出来 | 不显示问题；背包里有证据但本次没出示也不显示 |
| 隐藏回答 | 否 | 提交普通问题时，根据本次出示证据，在基础回答之后追加内容 | 保留基础回答，省略这段追加内容 |
| 证据回复 | 否 | 普通问题已有的证据支持版本，与无证据时的提示回复择一使用 | 使用普通提示，避免一边要求找资料、一边已经解释资料 |

回填表用A列“隐藏问题”表达显示条件，用B列“隐藏回答（附证据追加）”表达追加内容。“问题回复”只是隐藏问题自身的回答，不等于一段追加隐藏回答。隐藏问题原有普通回复槽仍保留作作者草稿；在测试里，条件不符时问题根本不出现，因此不会走这个槽。

多条证据仍是OR。一份证据可以同时支持多个已标明的回复，例如双生兽“重复出现”和“一夜消失”是不同依据：重复观察只讲文化共性，传说资料才解释消失含义，不把二者混为同一条提示。

### 这次同步的作者改稿

- 学者的晶石回答、反复出现的双生兽、消失传说与合作回答采用最新回填段落，中文草稿已初步译成英文。
- 新增“为什么黑白配色”普通问题，保留与调查本配色的暗示。
- 看清皮肤画并听过Aurora的反应后，带醒来伤口记录才能看到“她是否割伤自己传信”的追问；带缺少家庭成员的证据才能看到“你对学者似乎有私人感情”的追问。
- “为什么无人拜访学者碑”只接受新证据 `scholar_no_traces` 的唯一 tag `scholar_no_visitors`，不接受夜母碑的空扫描替代。
- 保留“长叹后暗示也许无人幸存”的作者情绪结构。反应写作主要依靠无线电可听见的呼吸、停顿、声线和杂音；不把玩家看不到的表情写成可见事实。

### 当前问题条件

表中证据条件均判断本次冻结的证据，而非所有背包物品。图像解释类问题还会检查具体对应关系；因此先比对、再提问。单份证据下拉按ID精确匹配，同类下拉按tag匹配，不把一份证据上所有标签都误当成新的可替代证据。

| 墓碑 | 问题 | 种类 | 本次证据可接受项（任一） |
| --- | --- | --- | --- |
| 小碑 | How do we interpret the icon on the tombstone? | 普通问题 | `tag:infant_appearance_mismatch` |
| 小碑 | Why is the tombstone shaped like a person? | 普通问题 | `tag:infant_identity` |
| 小碑 | Who drew the child's real appearance? | 隐藏问题 | `tag:infant_actual_appearance / tag:family_requested_depiction` |
| 学者 | Why is the monument shaped like a crystal? | 普通问题 | `tag:crystal_shape / tag:crystal_research_reference` |
| 学者 | What does the two-part creature mean? | 普通问题 | `id:repeated_beast_motifs / tag:ancient_disappearance` |
| 学者 | Did the cities ever cooperate? | 普通问题 | `tag:night_city_mineral_origin / tag:intercity_resource_exchange` |
| 学者 | Why is the color in black and white? | 普通问题 | `无；按基础回复` |
| 学者 | How could a picture be kept inside this crystal? | 普通问题 | `tag:skin_as_message_medium / tag:day_night_handholding` |
| 学者 | The Scholar seems reputable in the Day City. Why is her grave never visited by anyone else? | 隐藏问题 | `tag:scholar_no_visitors` |
| 学者 | Did she cut her own skin to send the message? | 隐藏问题 | `tag:unexplained_waking_wounds` |
| 学者 | You seem to have some personal feelings towards the Scholar. | 隐藏问题 | `tag:missing_family_member_reference / tag:four_person_family` |
| 太阳形碑 | Is this simply a monument to the sun? | 普通问题 | `tag:day_city_currency` |
| 太阳形碑 | Why is the same beast on other markers? | 普通问题 | `tag:ancient_disappearance` |
| 太阳形碑 | Do these three markers belong together? | 普通问题 | `tag:shared_family_plot / tag:three_family_markers` |
| 太阳形碑 | Why are four people remembered by only three markers? | 普通问题 | `tag:four_person_family / tag:missing_family_member_reference` |
| 太阳形碑 | Which family member has no place on the base? | 隐藏问题 | `tag:four_person_family / tag:missing_family_member_reference` |
| 夜城祭坛 | What does the unfamiliar glyph say? | 普通问题 | `tag:night_blessing_glyph` |
| 夜城祭坛 | Is this the child from the small marker? | 普通问题 | `tag:infant_memorial / tag:paired_day_night_memorials` |
| 夜城祭坛 | Are the moon-shaped stones coins? | 普通问题 | `tag:moon_stone_offering / tag:night_blessing_reference` |
| 夜城祭坛 | What was removed from the empty recess? | 普通问题 | `tag:removed_crystal_offering / tag:crystal_extraction_reference` |
| 夜城祭坛 | How can you translate a symbol from a culture without a written language? | 隐藏问题 | `tag:aurora_translation_knowledge / tag:night_symbol_translation` |
| 夜城祭坛 | Was the child in the wrong city? | 隐藏问题 | `tag:infant_appearance_mismatch / tag:infant_actual_appearance` |
| 夜母 | Who is the figure holding the child? | 普通问题 | `tag:parent_child_image / tag:night_mother_past` |
| 夜母 | What does the dry river border record? | 普通问题 | `tag:dry_river_motif / tag:water_source_lost` |
| 夜母 | Why does the handholding picture resemble the Scholar's? | 普通问题 | `tag:skin_as_message_medium / tag:unexplained_waking_wounds / tag:shared_body_reference` |
| 夜母 | Does the lack of offerings mean she was the last survivor? | 普通问题 | `tag:absence_of_readable_traces / tag:last_survivor_question` |
| 夜母 | Was the message meant for her daughter as well? | 隐藏问题 | `tag:day_night_handholding / tag:shared_body_reference` |
| 夜父 | Who is carrying the child? | 普通问题 | `tag:parent_child_image / tag:night_father_past` |
| 夜父 | Did he die because the Skyway was dangerous? | 普通问题 | `tag:skyway_not_steep / tag:missed_sleeping_deadline` |
| 夜父 | Could his death be linked to the Scholar's husband? | 普通问题 | `tag:husband_disappearance / tag:dawn_disappearances / tag:paired_day_night_death` |
| 夜父 | What does the moon-shaped offering mean? | 普通问题 | `tag:moon_stone_offering / tag:night_blessing_reference` |
| 夜父 | Was the original separation really a natural disaster? | 隐藏问题 | `tag:natural_collapse / tag:shared_day_night_history` |
| 女孩 | What is the upright frame around her? | 普通问题 | `tag:upright_coffin_motif / tag:shared_day_night_history` |
| 女孩 | Who made this marker? | 普通问题 | `tag:funerary_artist_reference` |
| 女孩 | Do the family sculpture and the photograph belong together? | 普通问题 | `tag:family_image_reference / tag:four_person_family` |
| 女孩 | Does disappearance always mean death? | 普通问题 | `tag:deliberate_departure / tag:two_mothers_dilemma` |
| 女孩 | Aurora, why is this girl on the notebook you gave me? | 隐藏问题 | `tag:aurora_provided_object / tag:aurora_identity_reference` |

小碑月亮普通问题在月牙与实际月亮建立对应后开放；形貌不一致的日记或涂鸦任选一份，即可在“月亮表示自然死亡”的基础回复之后追加疑点并授予 finding。没有为这段疑点另造一个隐藏问题。

### 问题页顶部反馈与结束语

口吻按当前问哪座碑决定，不按证据来自哪座城市决定。普通回复、支持回复和隐藏回复前都有反应旁白；开场、bonus、对质中的Aurora回复也加入了反应。正文的世界观信息不因为增加反应而省略。

返回问题页时，`test_menu_feedback` 在选项之前输出当次一条随机短句：未对应、对应正确、隐藏回答后三类分别取词库。小碑优先使用作者写在本碑页的三句未对应回复。隐藏反馈优先于普通成功反馈，显示后立即清除状态，不累积旧句子，也没有单独的“继续／返回结果页”。

完成比对会记录 `pending_relation_feedback`，下一次进入问题页先给对应成功反馈。结束通话从相应城市词库随机取一句，然后回主页／场景。普通通话仍不限次数，证据在一次通话中固定。

`#narrator` 表示括号中的反应旁白，`#aurora` 表示她真正说出的内容。程序应分别渲染，别把反应读成Aurora的自述。`ui:radio_questions` 和 `ui:question_feedback` 用于同一问题面板，不创建新的结果窗口；完整回答可以保留在问答记录里。

```
feedback_kind = unmatched / linked / hidden / 空
```

随机句取自回填表“开场与结局”66至97行。反应旁白已经随句进入测试版。玩家名暂用Ink变量 `player_name`，默认 Investigator，程序可在进入故事前替换。

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

下划线只用于可填入调查表的身份和死因。证据槽提交的是整份记录，使用该记录配置的 tag。

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

追加问答在昼城、夜城**各有至少两座不同墓碑的调查报告通过**后自动触发一次，与提交顺序无关，不再由祭坛报告单独触发。昼城计入小碑、晶石碑、太阳形碑；夜城计入祭坛、夜母碑、夜父碑。重复提交不累计，女孩终局碑不计入。保留原来的四选二提问及内容；提前选择继续调查也视为本次追加问答结束。

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

1. 先在回填Excel里改文案，再同步到 `test.ink` 运行条件测试。
2. 把介绍段搬到 `tombstone_master.ink`；把 `opening`、`daybaby_tele`、`test_radio_*`、bonus、对质等无线电内容搬到 `telecomm_master.ink`。
3. 让正式主入口声明公共变量与函数，再 INCLUDE 三个 master。每个文件只包含一次，段名与 ID 全局唯一。
4. 正式被 INCLUDE 的内容文件不应在顶层自行启动故事；当前 telecomm 的顶层 `->opening` 需在整合时改为由正式入口调用，当前 tombstone 占位故事也需替换。本次未动这两个文件。
5. 整合完成后移除测试正文副本、DEV 强制授予菜单和临时判分，不同时 INCLUDE `test.ink` 与三份正式内容，否则会有重复段落或入口冲突。

当前测试版故意不 INCLUDE telecomm／tombstone，而将它们的测试内容集中在一个文件，便于保留作者原稿并比较。这不是正式文件组织已迁移完成。

## 本次已做的检查

- Ink 编译通过，无编译报错；已区分证据限定的问题显示与基础回答后的隐藏追加。
- 设计师日记、婴儿涂鸦分别提交，均在月亮基础回答后追加疑点并授予 finding。
- 持有正确证据但提交月亮参照，不误触发疑点；通话中没有替换证据入口。
- 探照灯错误年份不授予；2000 年正确获得婴儿涂鸦。
- 实际走通六份报告、两个不同 bonus 问题、封面过渡、女孩碑比对、Aurora 对质及两个母亲回调。
- 按最新回填表同步作者改稿；telecomm_master 与 tombstone_master 保留，evidence_master 仅补入作者新需的学者碑无访客观察。

以上是 Ink 文本运行测试；还没有在 Godot UI 中验证工具、拖拽、金框、音频或存档接入。

## 本次保存后的同步

- 小碑月亮回复与设计手稿提示中，作者删除的反应不再播放。
- 人形证据回复后的引文与思考作为旁白，不由Aurora说出；随后显示两条玩家追问，任一选项汇合到同一段“不自然停顿／大胆而危险的判断”回复，再回问题页。这是当前回答的后续选择，不额外要求新证据，也不授予新的死因结论。
- 学者段落保留“I made that decision. I made that decision...”；夜母段落保留“I left her alone. I left her alone...”。私人情感追问的最后一句采用“Shall we return to the investigation?”。
- 本次只同步test与本说明，回填Excel及证据源文件未改。


## 本次保存的对话回填同步

已同步学者、太阳形碑、夜城祭坛的22处既有文字修改，以及新增家族墓室问题和消失调查追问。保留作者英文原文，未自动润色；段落中的玩家感受、舞台说明使用 narrator 标签，不作为 Aurora 发言。Excel 原稿未修改。

- 学者家族墓室：普通问题，出示 `profession_record` 得到证据回复，否则给出资格尚不确定的回复。
- 消失调查追问：学者碑和太阳形碑共享进度；先听过任意一处双生兽的有效消失解读，再附 `dawn_disappearances` 类调查报告，显示此隐藏问题。
- 开启调查追问后，后续通话可附 `skin_as_message_medium` 类伤口画或 `paired_day_night_death` 类夜父死亡结论。只记录实际出示，不以已收集代替出示；一次通话仍固定一份证据。
- 只交调查报告给一般质疑提示；已交伤口画则解释学者对伤口的误判。伤口画与昼夜死亡对应证据均已分次出示后，出现“消失的确切原理”“你是谁”两项追问。原理回答复用既有共享生命说明，身份回答使用本次作者新稿。两处墓碑不需要重复提交同一进度。
- 这属于对话进度记录，不生成线索与线索合成的新证据。身份追问不自动解锁 Aurora 的报告身份。
- 祭坛月形石只要求原始 `moon_stone_offering` 类证据，回答后授予 `moon_stone_blessing`；不要求事先取得祝福解读。翻译回答仍授予 `altar_blessing_translation`（含 Aurora 翻译知识标签）。
- 昼夜各通过两份不同墓碑报告才触发一次四选二追加问答的规则保持不变。

测试：编译通过；检查原始月形石解读、墓室问答两分支、隐藏问题显示、跨通话两类证据进度、两项追问及返回流程。Godot 是否实际消费这些 Ink 状态，仍需程序接入；本次只更新 Ink 测试与说明。


## 墓碑介绍文本维护位置

七座墓碑的简短介绍现集中在 `tombstone_master.ink` 的 `tombstone_baby / scholar / sun / altar / mother / father / girl` 段落。仅搬移现有文本，未改写。`telecomm_master.ink` INCLUDE 此文件，原 `test_desc_*` 页面以 tunnel 调用介绍后，继续显示联系 Aurora／返回墓园选项。请在 tombstone_master 修改介绍，避免另存一份重复文案。独立调用介绍时读取正文和 type、tombstone_id、location、title 标签；这些段落以 `->->` 返回调用方。


## 夜城几何符号改为无线电直译（2026-11-02）

本节覆盖前文相关旧显示条件。夜城不再要求用具象场景逐一破译几何符号。几何符号含义由 Aurora 查询直给，调查判断与现场证据仍分开。

五个必查符号：`blessing` 祭坛祝福符、`unending_path` 未归／无尽之路、`dry_river` 干涸河道、`ascending_path` 通向地表的上行之路、`crystal_god` 晶石神。人物、亲子、牵手图像不计入这五项。

- 祝福符复用祭坛原问题；持有 `altar_blessing_glyph` 拓印即可有效回答，不需要在通话证据槽出示。直接出示原符号也有效。
- 祭坛增加未归之路、晶石神查询；夜母增加干涸河道查询；夜父增加上行之路、晶石神查询。对应拓印持有后显示查询，证据槽保持原有冻结规则、不要求换入拓印。晶石神在两碑任一处查询均计同一项。
- 每次有效回答后以 `queried_night_glyphs` LIST 记录一种；可读取 `event:night_symbol_queried:<id>`。仅收集拓印、取得翻译知识 tag、重复问同一符号，都不能替代查询齐五种。
- 祭坛隐藏问题“How can you translate a symbol from a culture without a written language?” 仅在五种全部查询后显示，不再检查本次出示证据。原隐藏回答和金色反馈保留。
- 未归之路可直接得知“消失／离去未归”的含义，但不直接解释共享身体机制。干涸河道直译不直接授予夜母死因；进一步询问死亡仍需实际河床或水源断绝证据。上行之路直译不证明路途陡峭或夜父超时死亡，后者仍需现场／历史依据。
- 正式程序请持久保存查询集合；若新增必查符号，需同步五项清单与完成条件。本次未修改 Excel，后续回填同步须保留此新版规则。

已检查：Ink 编译；五类查询、四类未解锁／五类解锁、重复查询不凑数、无附证据也能问隐藏问题、单凭河道拓印不授予死因结论。
