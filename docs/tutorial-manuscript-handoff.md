# 新手教程：昼城返回与手稿衔接

## 本轮修复的卡点
过去拓印只添加 rubbing，未添加 gravestone，导致无线电墓碑列表为空。现在首个人形拓印后自动进入登记流程，无需再退出工具点击墓碑；已拓印但尚未登记的旧会话状态也由相同流程补录。

## 顺序
1. 首次从夜城返回昼城，播放 tutorial_day_return.xml。
2. 拓印小碑的人形。自动收起工具、打开笔记本墓碑页，先显示未登记页，再登记并换成婴儿碑。播放 tutorial_recorded.xml。
3. 提示点击 Manuscripts，打开设计者手稿。保留原 Ink 的 <link="infant">infant</link>，显示下划线和轻微水波动画，附动态圆环提示。
4. 点击关键词后收集为全局调查选项，播放 tutorial_keyword_noted.xml。不会自动把答案填进报告。
5. 阅读设计者日记，返回文献列表或合上笔记本确认读完后，再播放 tutorial_radio_ready.xml；此后开放无线电按钮。
6. 无线电分别教学：提交月亮对应获得有信息的回复；提交设计者手稿解释人形；探照灯取得涂鸦后，先放入槽再出现隐藏问题；出示日记为已有问题追加隐藏回答。继续点击死因词条。
7. 填写婴儿身份与死因后播放 tutorial_investigation_complete.xml，之后才标记教程结束并发放昼城全部8份文献；夜城3份文献不在这一批发放。

## 文案
新增衔接台词在 assets/dialogue/tutorial_*.xml，和现有开场/日月教学共用 DialogueBox。无线电仍以 telecomm_master.ink 为源。手稿内容与链接仍以 evidence_master.ink 为源；导出器保留 interactive_body 供阅读器使用，原 body 仍是纯文本。

## 关键词
GameState.collect_term 是无线电与手稿共用入口；身份/死因按同一词池分类。手稿中的其他链接可以是线索词，不一律当身份。点击 infant 的教学确认不影响玩家随后修改报告。

## 验证
完整顺序与原始卡点复现：tools/tutorial_manuscript_flow_test.gd。原有 radio_framework_test 与 tutorial_investigation_test 继续覆盖证据、隐藏分支、历史钱币与表单行为。
