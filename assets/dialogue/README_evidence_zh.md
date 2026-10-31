# Evidence Master 中文接入与调试说明

本说明供程序先跑通证据流程使用，以当前 `evidence_master.ink` 为内容来源。先做“能收集、能读、能点击、能比对、能带证据问话”的最小闭环，再接完整剧情。

当前检查到 Godot 的 `scripts/dialogue_loader.gd` 仍读取 XML，`start.gd` 和 `transition.gd` 默认使用 `start.xml`。Ink 中的 tag、link 和下列规则不会自动在现有 XML 系统里运行。本文件是接入约定与调试建议，不代表对应功能已经实现；本次没有修改游戏代码或 Ink 剧本。

## 1 最小调试流程

1. 将证据读成按 `id` 索引的注册表，显示标题、正文和全部 tag；注册所有内容不等于玩家获得所有内容。
2. 做一个仅供开发使用的面板：按 ID 授予证据、模拟 Aurora 传送、选择场景／工具／回溯年份、清空存档。
3. 先授予 `designer_manuscript`，打开并点击 `infant`：全局身份选项增加“婴儿”，其他墓碑调查页也可以选，重复点击不重复添加。
4. 在小碑目标使用探照灯，设置到 2000 年／回溯 50 年，收集 `infant_graffiti`。
5. 选定一个问题并带上这一份证据发送。调试用规则接受 `infant_appearance_mismatch`，只检查本次提交的证据；命中后模拟授予 `infant_death_doubt`。
6. 点击 finding 中的 `unexplained death`，全局死因列表增加“另有隐情”。此处只证明死亡存在疑点，不宣告谋杀已经证实。

第 5 步是建议先做的测试规则，当前 `telecomm_master.ink` 尚未写入对应证据条件分支。程序可先用开发面板模拟回答／授予事件，不要把该测试规则冒充已有剧本。

## 2 一条证据如何读取

```ink
=== ev_infant_graffiti ===
# type:evidence
# id:infant_graffiti
# title:A Sketch of the Infant
# category:trace
# location:day_cemetery
# tool:searchlight
# searchlight_year:2000
# searchlight_years_ago:50
# searchlight_date_status:timeline_suggestion
# evidence_tag:infant_appearance_mismatch
# evidence_tag:infant_actual_appearance
正文……
-> DONE
```

| 字段 | 程序用途 |
| --- | --- |
| knot 名，如 `ev_infant_graffiti` | 定位该段内容；不必与证据 ID 混为一谈 |
| `id` | 收藏、存档、证据槽使用的唯一键，不能拿显示标题替代 |
| `title` | 玩家可见标题 |
| `category` | 记录种类；决定展示分组，不等于获取工具 |
| `location` | 获取场景或渠道；不是文物的历史出土地 |
| `related_location` | 资料关联哪处调查区域，不作为现场拾取点 |
| `tool` | 获取时所用工具；有此字段时优先按它判断，不要只看 category |
| 多个 `evidence_tag` | 同一证据上的标签集合，每条都要保留，不能被最后一条覆盖 |
| `searchlight_year` / `searchlight_years_ago` | 过去的显示年份／从 2050 回溯的年数 |
| `searchlight_date_status` | 建议排期或暂定古代日期，方便日后调整 |

解析约定：按第一个冒号拆分键和值，再去除两侧空格。因此 `tool: camera` 和 `tool:camera` 等价。ID、link ID 和 tag 值按当前原文精确匹配；不要擅自转大小写或把空格换成下划线。正文、标签、`//` 作者注释分别处理，注释不得显示给玩家。

若接 Ink runtime，先编译 Ink，再逐段读取文本与对应 tags；一条正文有多次输出时，应把整段 tags 汇总，不能只读最后一行。证据阅读使用独立的 reader／Story 实例，避免覆盖正在进行的无线电对话。也可先做只针对本文件约定的离线转换器，将 knot 转成数据；这不是完整 Ink 解释器，不能用简单文本切分运行复杂对话。

证据库实际文件名是 `evidence_master.ink`。文件头旧注释提到的 `INCLUDE evidence.ink` 是示例旧名；集成时使用真实路径。文件内 `-> DONE` 结束当前证据读取，不表示物品已授予玩家。

## 3 Category 与工具

| Category | 含义 | 调试处理 |
| --- | --- | --- |
| `rubbing` | 永久符号、轮廓的拓印，也包括书中插图复制 | 现场拓印或阅读资料后复制；不能一律当现场物品 |
| `manuscript` | 手稿、日记、历史记载、命令 | 当前默认由 Aurora 传送，发送事件另配 |
| `trace` | 过去的祭品、涂鸦、皮肤画等痕迹 | 按探照灯的目标与年份获取 |
| `object` | 钱币、晶石等实物参照 | 优先检查 `tool`；如昼城钱币目前也需探照灯回溯 |
| `observation` | 环境参照、重复图标、空间关系 | 场景观察使用 camera；封面阅读和探照灯负向扫描是例外 |
| `finding` | 比对或问答后形成的结论 | 只能由完成事件授予，不能一进场景就获得 |

### Camera

`category:observation` 配合 `tool: camera`。相机记录现存场景和重复图标，不替代探照灯。

每次观察至少记录 `target_id`、`city_id`、`motif_id`。同一目标反复点击不累计次数。调试时可暂用“两个不同目标”测试同城重复、跨城共通；这是测试阈值，正式数量待关卡确认。不是每张 camera 记录都需要重复两次：月亮、太阳、基底等单一环境参照可以按各自目标直接记录。

同城重复、跨城共通、两碑的具体对应要分别记状态。观察模式可以连续点击并切换场景，切换时保留已记录目标。形状重复不自动证明符号含义。

### Aurora 传送与阅读

`location:aurora_transmission` 表示收到副本后可在历史手稿里反复打开，不要求玩家走到 `related_location` 才能读。接收某份资料、阅读资料、点击其中词条是三个不同事件。不要因一份手稿关联终局墓碑就自动把它锁到终局；发送时机尚需事件表配置。

## 4 点击词条的三类收录

下表穷举当前三个 Ink 文件中的实际 `<link>`，按现有设计给出接入分类。分类表需要程序注册，Ink 原文尚未给每个 link 写独立类型 tag。表中的 `identity:`、`death_cause:`、`clue:` 是建议的程序侧动作，不是现有 Ink 命令。

身份／职业和死因加入全局候选池，所有墓碑调查页共享；解锁选项不等于替玩家选中答案，也不等于答案已经正确。独立线索词单独加入笔记本，可用作证据，不能混进调查下拉框。

### 身份／职业

| 原始 link ID | 中文收录名 | 点击动作 | 来源与说明 |
| --- | --- | --- | --- |
| `infant` | 婴儿 | `identity:infant` | designer_manuscript |
| `student` | 学生／学徒 | `identity:student` | designer_journal；称谓最终由作者确认 |
| `scholar` | 学者 | `identity:scholar` | profession_record |
| `tycoon` | 大亨 | `identity:tycoon` | profession_record |

### 死因

| 原始 link ID | 中文收录名 | 点击动作 | 来源与说明 |
| --- | --- | --- | --- |
| `natural` | 自然死亡 | `death_cause:natural` | telecomm_master.ink 的月亮回答 |
| `unexplained death` | 另有隐情 | `death_cause:unexplained` | infant_death_doubt；仅在对应对话授予 finding 后出现，不是已证实谋杀 |
| `thirst` | 饥渴而死 | `death_cause:hunger_and_thirst` | night_mother_death_finding；需先解读后授予 |
| `disappearance` | 消失 | `death_cause:disappearance` | disappearance_inquiry 的失踪记载，以及 infant_memorial_correspondence 的对应结论；任一已解锁来源点击后全局收录 |
| `missed_sleeping_deadline` | 超出昼夜限制 | `death_cause:missed_sleeping_deadline` | night_father_death；先由对应调查／对话授予 finding，再点击收录 |

### 独立线索词

| 原始 link ID | 中文收录名 | 点击动作 | 来源与说明 |
| --- | --- | --- | --- |
| `fresh_wounds` | 醒来时的新伤口 | `clue:fresh_wounds` | disappearance_inquiry；记录现象，不接受作者归罪为事实 |
| `natural_collapse` | 史书所称的自然塌方 | `clue:natural_collapse` | natural_collapse_record；官方归因，不能直接视为真相 |
| `banned_book` | 禁书 | `clue:banned_book` | day_city_history |
| `sleeping_coffin` | 睡棺 | `clue:sleeping_coffin` | day_city_history |
| `sun_moon_people` | 日月之民 | `clue:sun_moon_people` | day_city_history |
| `population_decline` | 地表人口减少的记载 | `clue:population_decline` | day_city_history；保留史书立场 |
| `diary_complicity` | 为谎言刻碑的共犯 | `clue:diary_complicity` | girl_diary；摘录完整句子 |
| `diary_hypocrisy` | 虚伪的世界 | `clue:diary_hypocrisy` | girl_diary |
| `diary_mothers` | 带上她的母亲，就得带上我的母亲 | `clue:diary_mothers` | girl_diary；保留完整条件关系 |
| `diary_escape` | 只由我们自己逃离 | `clue:diary_escape` | girl_diary；不作为已确认死因 |

点击时保存来源 `source_evidence_id`（对话则保存来源段落）和原文摘录。同一 link 多次出现只收录一次，可累积多个来源。独立线索词建议用 `term:<link_id>` 作为证据槽的独立 ID，避免和原始证据 ID 冲突。

词条证据与原手稿的推理标签应显式配置，不要把整篇手稿的全部标签自动复制给每个摘录，否则“禁书”等任意单词也可能误触发整篇文章的隐藏分支。最小测试可先让玩家直接提交原始证据，再逐条补词条可接受的 tag。

Godot 文本控件不会因为出现 `<link>` 就自动完成收录。UI 需将该格式转换为项目所用的可点击富文本，并把点击 ID 交给上表动作；显示下划线／高亮及“已记录”反馈。不要把 link 原始标记直接显示给玩家。

已补入的死因词条：“消失”使用 `disappearance`；“超出昼夜限制”使用 `missed_sleeping_deadline`。二者都加入全局死因候选池。“消失”是调查栏中的记录分类，不等于已经证实死亡，也不等于自动确认逃离；它与 `diary_escape` 的独立线索用途不同。夜父的 finding 必须先由对应调查／对话授予，点击其中词条才解锁候选，不因注册全文而提前解锁。尚待补入：“夜父／夜母”的独立可点击身份词。`student` 当前按身份处理，“学生／学徒”的最终显示名仍需作者确认。

## 5 证据槽与无线电

一次发送只带一份证据；发送时把问题 ID、证据 ID 和该证据的 tag 快照固定下来，当前回应中不再替换。回到问题页后可以选另一份再发送，不限尝试次数。

接受条件是 OR：只要当前提交证据包含该问题允许的任意一个 tag 就命中。不是集齐这些 tag，也不是查询玩家整个背包中有没有某条证据。

```text
accepted_tags = { infant_appearance_mismatch }
submitted_tags = 当前提交那份证据的 tags
matched = 两个集合是否存在交集
```

例如 `designer_journal` 和 `infant_graffiti` 都带有 `infant_appearance_mismatch`，测试规则中任交一条即可；无证据或无关证据给普通回答／明确反馈，不扣次数。当前收集状态可另外影响 Aurora 的潜台词，但必须与“本次提交证据是否匹配”分开判断。

`aurora_translation_knowledge` 表示推理语义：Aurora 掌握某种翻译知识。`location:aurora_transmission` 只表示材料获取渠道，两者不能互相替代，更不能把所有 Aurora 发来的资料都认定为身份疑点。

当前 `telecomm_master.ink` 只有开场及小碑的少量问答，未接证据槽条件，也未实现完整隐藏分支。先用程序侧调试规则验证匹配，之后再接剧本条件。命中隐藏潜台词时用金框／特殊高亮、音效或统计反馈，并存入记录；不要提前显示尚未被证据触发的隐藏选项。

## 6 比对与结论

用显式“允许对应的对象／tag 组合 → 关系或 finding”表配置。不能把任意两个共享 tag 的证据全部自动判为同一含义。标签提供候选匹配，真正解锁由具体比对事件决定。

| 可先调试的对应 | 共享标签 | 应验证的行为 |
| --- | --- | --- |
| 小碑弯曲装饰 ↔ 夜城月亮 | `moon_motif` | 拖拽或选择目标建立形状对应；不由此证明真实死因 |
| 太阳形碑 ↔ 天上的太阳 ↔ 昼城钱币 | `sun_shape` / `sun_motif` | 可记录多条形状关系；不直接解锁大亨身份 |
| 昼城小碑 ↔ 夜城婴儿祭坛 | `infant_memorial` | 完成具体比对后授予 `infant_memorial_correspondence` |
| 学者皮肤画 ↔ 夜母牵手图 | `day_night_handholding` | 先记录图形对应；`paired_skin_pictures` 的完整解释还需伤口等上下文 |
| 女孩碑整体图案 ↔ 日记或调查本封面 | `girl_coffin_motif` | 对应后授予 `girl_cover_correspondence`；相似本身不直接确认 Aurora 身份 |

比对成功后，笔记本展示“概括＋代表符号”，原始拓印可折叠。底层保留原证据 ID、tag 和关系，旧引用不能失效。若一张概括卡包含多个原记录，程序应解析其关联来源参与匹配，而不是只留下显示标题。

## 7 探照灯时间与例外

年份是痕迹在那个位置可见的时间，不一定是物品制造或照片拍摄的时间。当前以 2050 年为基准，回溯年数应等于 `2050 - searchlight_year`。程序不要将数字 tag 当字符串排序。

下表从当前证据文件读取；调试时目标位置、工具和时间同时满足才授予对应记录。可先按整年精确匹配测试，正式容差与可见时间段待定，不能把单个推荐快照当成真实痕迹唯一存在的一瞬间。

| 证据 ID | 年份或范围 | 回溯年数 | 状态 |
| --- | --- | --- | --- |
| `infant_graffiti` | 2000 | 50 | timeline_suggestion |
| `skin_picture` | 2005 | 45 | timeline_suggestion |
| `day_city_coin` | 1990 | 60 | 未标状态，沿用当前文件 |
| `twin_beast_trace` | 1800 | 250 | provisional_ancient_date |
| `family_photo` | 2000 | 50 | timeline_suggestion |
| `removed_crystal_god` | 2000 | 50 | timeline_suggestion |
| `altar_moon_stone` | 2000 | 50 | timeline_suggestion |
| `night_mother_no_traces` | 2005—2050 | 0—45 | 负向扫描范围，不能单次命中即授予 |
| `night_father_moon_stone` | 2000 | 50 | timeline_suggestion |
| `family_statuette` | 2005 | 45 | timeline_suggestion |

双生兽 1800 年是古代日期占位，不是已定历史。夜母“没有可读痕迹”需另配扫描完成条件，不要求玩家穷举 46 个年份，也不能将“没照对年份”当成“没有痕迹”。昼城钱币目前为 `category:object`、`tool:searchlight`，以工具字段为准。

## 8 验收清单

- 注册表不会让未解锁手稿、finding 和终局证据提前进入玩家笔记本。
- 所有重复 `evidence_tag` 被保留，空格格式不会造成 camera 漏识别。
- 点击身份／死因全局解锁；点击线索词只新增独立证据；重复点击不重复收录。
- 日记和手稿收到后随时重读，不消耗无线电次数，不打断对话进度。
- 正确工具但错误目标／年份不授予探照灯证据；相机同一目标连点不累计观察次数。
- `designer_journal` 与 `infant_graffiti` 单独提交均能通过同一测试规则；背包有正确证据但提交错误证据不能通过。
- 一次发送的证据在回答期间固定，可回问题页不限次数重试。
- 建立对应后显示概括卡，原始 ID／tag 仍可用于问答与存档。
- 太阳形碑的初始记录不出现钱币碑／财富身份结论；钱币可以参与形状对应。
- 保存并重开后，已收集证据、全局候选、关系、潜台词反馈状态恢复一致；开发面板能单独清空。

建议开发日志打印：事件类型、目标／城市、证据 ID、当前工具、显示年份、提交问题、提交证据 tags、匹配结果与授予结果。日志只供开发，不放进正式玩家界面。

## 9 当前需补的配置

1. Aurora 每份资料的具体发送事件，以及每个场景目标对应哪个证据 ID。
2. 正式相机观察目标、次数阈值与跨城市组合。
3. 每个问题的 accepted tags、普通回应、隐藏回应与奖励 finding。
4. 独立线索词自身携带哪些推理 tag，而非自动继承全文。
5. 夜父／夜母身份的可点击台词；“消失”与“超出昼夜限制”的 link 已补入，程序仍需注册点击动作。
6. 探照灯容差、古代双生兽年份、夜母负向扫描的完成判定。

以上配置尚未完整写在证据文件里。可以先按本说明的开发面板和测试规则验证数据流，再由作者回填正式条件，不需要等待全部英文文本定稿。

## 可运行的联动测试

已新增 `test.ink`，在 Inky 中模拟证据槽、条件问答、词条收录、报告与结局。文件分工、测试步骤及正式 Godot 接入说明见 [中文总说明](README_dialogue_zh.md)。本文关于 telecomm_master 尚未接完整分支的描述仍指原 master；测试逻辑集中在新文件内。
