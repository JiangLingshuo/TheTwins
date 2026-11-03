# 教程分支：完整新手调查与历史物件比对

本轮仅修改 feature/sun-moon-tutorial，未合并主分支。

## 实际流程
1. 拓印天空太阳，再拓印小碑弧形；Aurora 提醒尝试。
2. Rise & Set：把月亮拖到场景太阳，进入夜城。
3. 播放 tutorial_night_arrival.xml；原拓印更新为「☾ → Moon」。这只是形状对应，不等于自然死亡。
4. 把太阳拖到场景月亮，回昼城。无线电仅显示当前城市已记录的墓碑，模型也阻止跨城市发送。
5. 记录小碑，获得两份设计者文献。问图标含义，提交「☾ → Moon」，点下划线 natural death。
6. 拓印人形，阅读设计者手稿；无线电提交手稿解释人形，点下划线 infant。人形变为已破译。
7. 用探照灯在小碑右后方查看 50 年前（2000）的婴儿涂鸦。原型暂用毛茸茸婴儿示意图，待美术替换。
8. 播放 tutorial_hidden_question.xml。先把涂鸦放入槽才显示隐藏问题，提交后得到金色反馈。
9. 再问图标，出示设计者日记，追加死因疑点；点击 unexplained circumstances。
10. 在墓碑调查页用下拉框选 Infant 及已收集死因，完成教程。自然死亡与另有隐情均可记录，不自动替玩家判断。

## 钱币：探照灯目标也是场景比对目标
- 日城左下新增许愿池调查位置与太阳形拓印的布局示意，不是最终大亨墓碑美术。
- 1990 / 60 年前为沿用现有建议日期，钱币使用 60 年刻度；完整探照灯占位现已将上限扩至 250；可在 main.gd 的条目中修改。
- 使用 scripts/historical_target.gd；正确年份、光束覆盖、稳定 0.7 秒后记录 day_city_coin。
- 未发现时不能作为拖拽目标；发现后保留历史影像，关闭灯或打开笔记本不会消失。
- 拓印太阳形图案，在 Rubbings 中拖到钱币影像，原拓印更新为「图案 → Wishing-pool coin」。不新生成重复证据卡。
- 其他历史物件可复用：evidence_id、years_ago、target_id、meaning、caption；拓印 matching_target_id 必须相同。
- 现有 manuscripts 仍归 Manuscripts，本轮没有把它们改成探照灯获取。

## 调查表
- 身份与死因都是 OptionButton，只显示无线电下划线点击收集的词条。
- GameState.report_options / set_report_choice 控制权限，非 UI 层调用也不能绕过。
- 身份全局互斥，当前碑保留自己的选择；清空后释放给其他碑。死因不互斥。
- Holy Mother / Holy Father 沿用 night_mother / night_father 内部 ID。
- 六身份池中的 Divine Messenger 显示名预留；实际选项仍须先有对应词条收集事件，不直接给玩家。

## 改台词
- 切换前：assets/dialogue/tutorial_sun_moon.xml
- 首次夜城：assets/dialogue/tutorial_night_arrival.xml
- 隐藏提问教学：assets/dialogue/tutorial_hidden_question.xml
- 具体无线电：assets/dialogue/telecomm_master.ink；修改后按序运行 tools/build_notebook_content.py、tools/build_radio_content.py。
- 保留原有文献与 Ink ID。无线电候选项在 radio_candidate_overrides.json 修改。

验证：tools/tutorial_investigation_test.gd 覆盖切城、对应、隐藏问答、词条采集、下拉互斥、错误年份不获取及历史钱币拖拽。
