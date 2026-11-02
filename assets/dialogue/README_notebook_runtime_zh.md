# 笔记本文本接入说明

## 作者修改哪里

- 墓碑简短介绍：`tombstone_master.ink`。
- 证据、文献、痕迹、结论：`evidence_master.ink`。
- 无线电对白：`telecomm_master.ink`（原 test.ink 已改名）。
- 改完上述文件后运行 `python tools/build_notebook_content.py`，更新游戏读取的 `notebook_content.json`。这份 JSON 是可再生成的文案目录，不是玩家已解锁列表，也不执行 Ink 条件。

当前已登记七座墓碑、65条证据、77个无线电文本段。旁白、说话人、正文保留；作者注释、控制语句与 link 标记不会直接显示成正文。文字中的玩家姓名由 GameState 替换。

## 玩家实际能看到什么

- 点击已配置的墓碑：通过 `GameState.record_gravestone(id)` 记录并在对应页显示描述。七座碑的数据齐全，场景当前仍只放置了可调查的婴儿碑；不会自动生成其余墓碑的场景节点。
- 六座主调查碑按昼夜配对占据前三跨页；只有女孩碑被记录后才增加终局跨页。
- 拓印：沿用程序原 `record_rubbing` 与 `confirm_rubbing_meaning`，仍区分未获取、获取未破译、已破译，不因加载目录自动解锁含义。
- 墓碑相关的非拓印、非文献线索：显示在该碑右栏 Clues；含标题和全文，右栏可滚动。
- 环境参照：显示在独立 Clues 栏目，不重复塞进墓碑页。
- Manuscripts：仅显示已收到的文献，每页四个条目框（每跨页八项），点击条目后在本页展开全文，可滚动并通过“← Manuscripts”返回列表；栏目自动增加页数。
- Radio Logs：仅保存实际播放到的对话行。开场 `start.xml` 已接上；正常流程不会提前展示未触发回答。
- 记录、翻页、关闭再打开使用现有 GameState 保持跨场景状态，本次未新增磁盘存档系统。

## 程序挂接入口

- 获取证据／收到手稿：`GameState.record_evidence(evidence_id)`。必须由对应操作成功事件调用；目录载入不代表获取。
- 探照灯成功或 Ink 输出授予事件：`GameState.apply_notebook_event("event:grant_evidence:<id>")`。
- 夜城翻译成功：`apply_notebook_event("event:night_symbol_queried:<glyph>")`，为已经获得的对应拓印确认含义；不会补发未获取拓印。
- 播放一段已确定分支的无线电：`DialogueBox.play(lines, session_id)`。文本显示时逐行进入记录，避免尚未播放或被取消的后续内容泄漏。
- 如果对话已经由其他控制器播放，可用 `append_radio_line(session_id, {speaker, content})`。两种日志路径任选其一，不能重复调用。
- `record_radio_answer(answer_id, session_id)` 可用于已确认成功播放的静态回答段。含多选／条件的尾段会标记 preview_only，不允许作为单一回答写入正常历史。新增无线电系统仍需执行 Ink 的分支与奖励规则；本次没有把整个 Ink 调试菜单搬到游戏里。
- `get_gravestone_info(id)` 返回最新描述和已获取线索；跨碑对应结论支持多个墓碑归属。

## 暂定的资料发送节点

先按首次记录墓碑分批发送，避免一次全给：婴儿碑→设计手稿与设计师日记；学者碑→职业记录与消失调查；祭坛→晶石神传说；夜父碑→天梯史与塌方记载；女孩碑→女孩日记与昼城史。这个表位于 `GameState.record_gravestone`，属于本次为测试接入设置的暂定顺序，可按正式关卡表继续改。其他资料仍需调用 record_evidence 发送，尚未绑定最终报告提交时机。

## 开发预览与验证

在编辑器运行主场景，按 **F8**：仅本次开发运行解锁所有笔记本文本，包含未发生回答的 **DEV text preview**。正常游戏不调用此入口；重启游戏恢复干净状态。预览不是正式通关，不提供证据获取玩法的替代。

- `tools/notebook_content_test.gd`：验证目录数量、分栏、墓碑描述、解锁边界、正文阅读与日志。
- `tools/notebook_content_shots.gd`：生成四个栏目的实际截图到忽略目录 test_output/notebook_content。
- 现有 `tools/smoke.gd`：保留原有笔记本／拓印流程检查。

本次不调整报告身份唯一性、每题三个证据候选、探照灯目标碰撞或完整无线电UI，这些需要另接相应控制器。只导入全部文本不等于这些玩法自动实现。


## 探照灯选点与年份操作

点击探照灯按钮后，点击场景位置锁定光束。鼠标离开该点不会移动光束；在场景上滚轮向上增加回溯年数，向下减少，每格沿用 FocusScale.wheel_step（默认一年）。再次点击场景可换照射点。右侧刻度仍可拖动或滚轮调整，照射点保持固定。点击工具按钮或 Escape 收起；打开笔记本／切换拓印仍沿用互斥逻辑。年份上下限保持原配置。

程序：`Flashlight.turn_on_at(point, true)` 用于锁定，默认参数 false 保留旧的跟随模式供其他调用方使用。`tools/flashlight_input_test.gd` 验证滚轮、锁定、刻度兼容、重新选点、上下限和退出。
