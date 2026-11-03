# 无线电共用开场对话框

本轮仍在教程分支。源文案和条件继续用 assets/dialogue/telecomm_master.ink，经现有构建器导出 radio_content.json；未改为 XML，无需另写一份台词。

## 界面
- 墓碑选择、问题列表、证据槽、筛选和三选一：RadioSelectionBox，实例化 scenes/dialogue_box.tscn，通过 show_menu() 在同一底部面板内放交互控件。
- Aurora 回答及旁白：RadioDialogueBox，同一场景，逐句打字、空格/回车/点击继续，隐藏回答金框。
- 回复时收起选项与证据面板，阻止换证据、结束通话或操作场景；回答结束自动回问题页。追问仍由 Ink 给出。
- Read last reply 可以重新播放并补点漏收词条，不重新执行 Ink、不给第二次奖励、不重复写日志。
- 所有 UI 沿用开场面板的底部位置、字体、边框、间距和背景遮罩；选择区域根据内容适度增高。

## 词条
ContentLabel 升级为 RichTextLabel。现有 Ink 的 <link="id">word</link> 转成下划线链接；点词条只收集，不跳句。未点词条仍可通过重读收集。开场 XML 仍可正常播放，普通文字保持原样。

## 日志
只有实际开始显示的回答句进入 Radio Logs；未来句子不提前写入。去除标记后存可读文本；问题和本次证据仍单独记录。

## 验证
- tools/radio_dialogue_ui_test.gd：共用场景、逐句播放、点击词条不跳句、金框、回问题页、重读无重复、XML兼容。
- tools/tutorial_investigation_test.gd：新手全流程。
- tools/radio_framework_test.gd：原有问答和证据条件。
