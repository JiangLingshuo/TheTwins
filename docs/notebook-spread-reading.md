# 双页阅读与 student 点击修复

## student 问题
日志报错为 collect_term 将 String 赋给 Array。Ink 的 clue_words 是旧调试文本字符串，不能当词条集合。身份继续进 identities、死因进 causes；其余点击词进独立 clue_terms 数组，保留 Ink 原字段。对已有字符串状态做兼容，不丢已有值。

## 排版
手稿、Clues、Radio Logs 共用 scripts/spread_reader.gd：正文按单词与完整链接分页，先左页再右页，超长内容继续下一跨页；不使用竖向滚动条。正文22号，分页保留全部原文与链接，不缩小到不可读。

- 手稿列表仍为卡片；点开后同一份手稿占用左右两页。左上返回列表。
- Continue / Previous 或书页角可浏览文档后续跨页；长记录先翻完当前记录，再进入下一条记录。
- Clues、Radio Logs 每条记录至少占一跨页；左右不会各自显示两条无关记录。
- 点击词条的回调与笔记本刷新延后到输入事件处理结束，避免点击中拆除当前文本控件。
- 关闭文档、切换标签、读完后合上笔记本仍能推进手稿阅读教程。

## 相关文件
- scripts/book.gd：文档选择、阅读位置、页角导航。
- scripts/manuscript_items.gd：卡片列表，发出文档打开请求。
- scripts/spread_reader.gd：双页正文、关键词与分页按钮。
- scripts/game_state.gd：词条分类与收集。

验证：spread_reading_test.gd 覆盖 student 首次/重复点击、全部66份证据原文分页无丢失、页面高度和长日志继续翻页；tutorial_manuscript_flow_test.gd 覆盖完整新手教学。
