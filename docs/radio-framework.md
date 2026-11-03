# 教程分支：临时无线电框架

仅在 feature/sun-moon-tutorial 分支试验，未合入 main。目标是让现有文案能在游戏中测试；学姐可替换 radio_tool.gd 的布局，不必重写 radio_model.gd 的状态逻辑。

## 操作

完成日月切换教程（或按 DEV skip）后，右侧三个工具图标下出现可用无线电按钮。先选择已记录的墓碑，再进入该碑的问题页。没有记录的碑不会出现在列表；测试其他碑可在场景中按 F8 全内容预览。

- 未选问题时：右侧列出已经获得的提交记录，可先放入一条以显示隐藏问题。
- 选定问题后：只显示该问题的三个候选；未获得项只显示 Uncollected record 且不可提交，不提前展示其正文。筛选可暂时只显示其中符合类型的项，不会补入其他候选。
- 一次发送固定当前一条证据。与旧版“整通电话固定一条”不同，这一试作允许答复结束后换证据，支持下一层提交。
- 普通问题可先不带证据得到初步回答；原有夜城几何符号直译也保留不带证据的查询。需要证据的隐藏问题、隐藏回答严格检查实际槽位，不把已拥有当作已出示。
- 提交后回复保留在问题列表上方，隐藏反馈用金色标识；不另外强制跳一个结果页。部分回答带有接续玩家选项，完成当前追问后才能换证据。
- 双层消失调查共用状态：先交调查报告开启质疑，再分次交皮肤画与夜父死亡结论，才出现更深的原理和身份追问。所有状态存于 GameState.radio_progress，跨通话保留。
- 证据过滤：All types / Symbol records / Manuscripts / Other clues。悬停已收集的候选可读其原始正文。
- 已显示的问答与实际提交条目进入笔记本 Radio Logs，以墓碑名称命名。尚未执行的分支不会被写入真实日志。
- 回答里的下划线词可以收集到临时身份／死因／独立词条池。报告页目前仍是原来的文本输入，唯一身份下拉尚未在本轮实现。

## 数据和边界

现有45个问题、48段可执行对话控制段；65条可用于无线电的原始记录在此界面归并为59个提交组。另一个 sky_sun_rubbing 是教程导航图标，不进入无线电证据池。

归并只发生在提交界面，不删除原始证据、不丢失来源。精确 evidence ID 条件会阻止相关记录被混并。当前包括三处双生兽拓印、两处月形祭品、两处晶石神图案等。双生兽传说与拓印不合并：前者提供消失典故，后者只记录形状，功能不同。

每题一条主要候选与两条同场景相关干扰项由导出器生成初稿。关键10题已人工指定更贴近上下文的三项，见 radio_candidate_overrides.json；其余候选仍适合在Playtest后调整，不视为最终谜题设计。纯叙事／直译问题的候选仅作参照，本身无需推断唯一证据。

- 文案来源：telecomm_master.ink。
- 底层证据：evidence_master.ink 经 notebook_content.json 注册。
- 候选覆写表：assets/dialogue/radio_candidate_overrides.json，值为三个原证据ID，导出时自动归并。
- 执行数据：assets/dialogue/radio_content.json。
- 控制层：scripts/radio_model.gd；界面：scripts/radio_tool.gd。

文案更新后依次运行：

```text
python tools/build_notebook_content.py
python tools/build_radio_content.py
```

临时控制层只执行当前源稿已经验证的条件、分支、赋值、跳转和后续选项子集，不是完整Ink运行时。未知控制语法会使导出失败；新条件中的未知状态会保守拒绝并记录警告。未来若扩大Ink语法，应接入完整运行时或扩展经过测试的导出器，不能把不同分支简单拼成一段答案。

夜城翻译五项查询状态、实际证据授予、已听回答、阶段性提交各自分开记录。获得证据不自动等于破译、出示或完成报告。

本框架不自动生成其余墓碑场景，也不代替完整报告判分与终局触发。已有需要“建立符号对应”的问题仍会受原门槛限制。当前可从实际场景测试婴儿碑；其他关卡可用开发预览及程序的比较事件入口逐步接入。

## 验证

- tools/radio_framework_test.gd：逐题验证三个不同候选，另测未解锁拒绝、隐藏问题、隐藏回答、跨轮证据、五符号门槛、结论奖励、日志与模态退出。
- tools/radio_framework_shots.gd：真实窗口截图，包含四个工具、选碑、三候选、隐藏问题、回答及筛选；输出到忽略目录 test_output/radio_framework。
- 继续运行 sun_moon_tutorial_test.gd、notebook_content_test.gd、flashlight_input_test.gd 保证本分支其他交互不受影响。

另附 radio-to-searchlight-proposal.md：从无线电移到探照灯的文案整理建议。该清单尚未改写当前获取配置。


## 当前UI补充
问题列表、证据槽和回答已统一复用开场 scenes/dialogue_box.tscn；详细说明见 [radio-shared-dialogue-ui.md](radio-shared-dialogue-ui.md)。Ink源与既有条件逻辑不变。
