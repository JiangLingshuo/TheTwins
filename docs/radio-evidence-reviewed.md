# 无线电三选一维护清单

文案源：`assets/dialogue/telecomm_master.ink`。候选源：`radio_candidate_overrides.json`（43题全部人工指定）；渐进提交源：`radio_stage_candidates.json`。修改后运行 `python tools/build_radio_content.py`。

一般证据问题第一项为有效证据，后两项在当前问题上不能得出该结论；相关性来自同一人物、物件形状、习俗或同一事件。只允许提交已获取记录；隐藏问题仍须槽内证据满足条件。

**例外**：婴儿月亮问题的第二项涂鸦是有效隐藏回答入口，刻意保留，不能标为错误证据。纯查询符号和纯叙事问题不要求附证，因此三个候选只是参考材料，不声称两项为错误。隐藏问题以证据槽控制显隐，换成无关证据时会隐藏。

|问题 ID / 问题|主要记录|候选二|候选三|
|---|---|---|---|
|baby:test_answer_baby_8<br>How do we interpret the icon on the tombstone?|The Small Marker's Curved Decoration (`infant_moon_rubbing`)|A Sketch of the Infant (`infant_graffiti`)|A Marker for Someone Without an Occupation (`designer_manuscript`)|
|baby:test_answer_baby_17<br>Why is the tombstone shaped like a person?|A Marker for Someone Without an Occupation (`designer_manuscript`)|The Small Human-Shaped Marker (`infant_figure_rubbing`)|A Sketch of the Infant (`infant_graffiti`)|
|baby:test_answer_baby_21<br>Who drew the child's real appearance?|A Sketch of the Infant (`infant_graffiti`)|A Page of the Designer's Journal (`designer_journal`)|The Small Human-Shaped Marker (`infant_figure_rubbing`)|
|scholar:test_answer_scholar_8<br>Why is the monument shaped like a crystal?|The Scholar, Her Work, and Her Patron (`profession_record`)|The Picture Preserved on Skin (`skin_picture`)|An Order for a One-Way Passage (`one_way_passage_order`)|
|scholar:test_answer_scholar_12<br>What does the two-part creature mean?|An Account of the Twin-Bodied Creature (`twin_beast_account`)|The Crystal Monument's Twin Beast (`scholar_beast_rubbing`)|A Giant Footprint in the Ruins (`giant_footprint`)|
|scholar:test_answer_scholar_17<br>Did the cities ever cooperate?|An Order for a One-Way Passage (`one_way_passage_order`)|The Picture Preserved on Skin (`skin_picture`)|The Scholar, Her Work, and Her Patron (`profession_record`)|
|scholar:test_answer_scholar_20<br>Why is the color in black and white?|The Crystal Monument's Outline (`crystal_marker_rubbing`)|The Picture Preserved on Skin (`skin_picture`)|The Cover of Your Investigation Notebook (`notebook_cover`)|
|scholar:test_answer_scholar_25<br>How could a picture be kept inside this crystal?|The Picture Preserved on Skin (`skin_picture`)|A Sketch of the Infant (`infant_graffiti`)|The Scholar, Her Work, and Her Patron (`profession_record`)|
|scholar:test_answer_scholar_31<br>The Scholar seems reputable in the Day City. Why is her grave never visited by anyone else?|No Later Visitors at the Crystal Monument (`scholar_no_traces`)|The Scholar, Her Work, and Her Patron (`profession_record`)|One Base, Three Tombs (`shared_family_base`)|
|scholar:test_answer_scholar_35<br>Did she cut her own skin to send the message?|The Scholar's Notes on Disappearances (`disappearance_inquiry`)|The Picture Preserved on Skin (`skin_picture`)|A Sketch of the Infant (`infant_graffiti`)|
|scholar:test_answer_scholar_39<br>You seem to have some personal feelings towards the Scholar.|A Photograph of Four (`family_photo`)|The Scholar, Her Work, and Her Patron (`profession_record`)|The Picture Preserved on Skin (`skin_picture`)|
|scholar:test_scholar_mausoleum<br>Why did the Scholar never apply for the family mausoleum?|The Scholar, Her Work, and Her Patron (`profession_record`)|One Base, Three Tombs (`shared_family_base`)|No Later Visitors at the Crystal Monument (`scholar_no_traces`)|
|scholar:test_disappearance_hypothesis<br>Do you think the cause of disappearance aligns with what the Scholar has investigated?|The Scholar's Notes on Disappearances (`disappearance_inquiry`)|The Crystal Monument's Twin Beast (`scholar_beast_rubbing`)|An Account of the Twin-Bodied Creature (`twin_beast_account`)|
|sun:test_answer_sun_13<br>Why is the same beast on other markers?|An Account of the Twin-Bodied Creature (`twin_beast_account`)|The Same Beast on Other Graves (`repeated_beast_motifs`)|A Giant Footprint in the Ruins (`giant_footprint`)|
|sun:test_answer_sun_17<br>Do these three markers belong together?|One Base, Three Tombs (`shared_family_base`)|A Photograph of Four (`family_photo`)|The Scholar, Her Work, and Her Patron (`profession_record`)|
|sun:test_answer_sun_21<br>Why are four people remembered by only three markers?|A Photograph of Four (`family_photo`)|The Scholar, Her Work, and Her Patron (`profession_record`)|The Small Human-Shaped Marker (`infant_figure_rubbing`)|
|sun:test_answer_sun_25<br>Which family member has no place on the base?|A Photograph of Four (`family_photo`)|The Scholar, Her Work, and Her Patron (`profession_record`)|A Page of the Designer's Journal (`designer_journal`)|
|sun:test_disappearance_hypothesis<br>Do you think the cause of disappearance aligns with what the Scholar has investigated?|The Scholar's Notes on Disappearances (`disappearance_inquiry`)|The Crystal Monument's Twin Beast (`scholar_beast_rubbing`)|An Account of the Twin-Bodied Creature (`twin_beast_account`)|
|altar:test_answer_altar_8<br>There is a symbol on the platform. What does it mean?|An Unfamiliar Glyph on the Altar (`altar_blessing_glyph`)|The Altar's Unending Path (`altar_path_rubbing`)|The Crystal God's Outline (`crystal_god_rubbing`)|
|altar:test_answer_altar_12<br>Is this the child from the small marker?|Two Memorials to an Infant (`infant_memorial_correspondence`)|A Sketch of the Infant (`infant_graffiti`)|The Crystal God's Prophecy (`crystal_god_prophecy`)|
|altar:test_answer_altar_16<br>Are the moon-shaped stones coins?|A Moon-Shaped Stone on the Altar (`altar_moon_stone`)|A Coin from the Wishing Pool (`day_city_coin`)|The Moon Above Night City (`moon_reference`)|
|altar:test_answer_altar_20<br>What was removed from the empty recess?|The Crystal Figure That Once Stood Here (`removed_crystal_god`)|The Crystal God's Outline (`crystal_god_rubbing`)|Crystal from Night City (`night_city_crystal`)|
|altar:test_answer_altar_24<br>How can you translate a symbol from a culture without a written language?|An Unfamiliar Glyph on the Altar (`altar_blessing_glyph`)|The Crystal God's Prophecy (`crystal_god_prophecy`)|The Collapse That Sealed the Road (`natural_collapse_record`)|
|altar:test_answer_altar_28<br>Was the child in the wrong city?|A Sketch of the Infant (`infant_graffiti`)|The Crystal God's Prophecy (`crystal_god_prophecy`)|The Infant on the White Altar (`altar_infant_rubbing`)|
|altar:query_night_unending_path<br>What does the geometric border on the altar mean?|The Altar's Unending Path (`altar_path_rubbing`)|An Unfamiliar Glyph on the Altar (`altar_blessing_glyph`)|The Crystal God's Outline (`crystal_god_rubbing`)|
|altar:query_night_crystal_god<br>What does the angular figure represent?|The Crystal God's Outline (`crystal_god_rubbing`)|The Altar's Unending Path (`altar_path_rubbing`)|A Moon-Shaped Stone on the Altar (`altar_moon_stone`)|
|mother:test_answer_mother_8<br>Who is the figure holding the child?|A Figure Holding a Child (`night_mother_child_rubbing`)|The Infant on the White Altar (`altar_infant_rubbing`)|A Photograph of Four (`family_photo`)|
|mother:test_answer_mother_12<br>What does the dry river border tell us about her death?|The Underground Riverbed (`dry_underground_river`)|The Dry River Around the Stone (`night_mother_river_rubbing`)|No Readable Traces Around the Stone (`night_mother_no_traces`)|
|mother:test_answer_mother_17<br>Why does the handholding picture resemble the Scholar's?|The Picture Preserved on Skin (`skin_picture`)|A Figure Holding a Child (`night_mother_child_rubbing`)|A Sketch of the Infant (`infant_graffiti`)|
|mother:test_answer_mother_21<br>Does the lack of offerings mean she was the last survivor?|No Readable Traces Around the Stone (`night_mother_no_traces`)|The Underground Riverbed (`dry_underground_river`)|An Order for a One-Way Passage (`one_way_passage_order`)|
|mother:query_night_dry_river<br>What does the geometric border on this stone mean?|The Dry River Around the Stone (`night_mother_river_rubbing`)|Two Figures Holding Hands (`night_mother_hands_rubbing`)|A Figure Holding a Child (`night_mother_child_rubbing`)|
|father:test_answer_father_8<br>Who is carrying the child?|A Figure Carrying a Child (`night_father_child_rubbing`)|The Infant on the White Altar (`altar_infant_rubbing`)|A Photograph of Four (`family_photo`)|
|father:test_answer_father_12<br>Did he die because the Skyway was dangerous?|The Path to the Surface (`skyway_reference`)|The Collapse That Sealed the Road (`natural_collapse_record`)|A Figure Ascending the Path (`night_father_path_rubbing`)|
|father:test_answer_father_16<br>Could his death be linked to the Scholar's husband?|The Father's Search Beyond His Waking Hours (`night_father_death`)|The Scholar's Notes on Disappearances (`disappearance_inquiry`)|An Account of the Skyway (`skyway_history`)|
|father:test_answer_father_20<br>What does the moon-shaped offering mean?|A Moon-Shaped Stone on the Altar (`altar_moon_stone`)|A Coin from the Wishing Pool (`day_city_coin`)|A Figure Ascending the Path (`night_father_path_rubbing`)|
|father:test_answer_father_24<br>Was the original separation really a natural disaster?|The Collapse That Sealed the Road (`natural_collapse_record`)|An Order for a One-Way Passage (`one_way_passage_order`)|An Account of the Skyway (`skyway_history`)|
|father:query_night_ascending_path<br>What does the rising pattern along the border mean?|A Figure Ascending the Path (`night_father_path_rubbing`)|A Figure Carrying a Child (`night_father_child_rubbing`)|The Crystal God's Outline (`crystal_god_rubbing`)|
|father:query_night_crystal_god<br>What does the angular figure represent?|The Crystal God's Outline (`crystal_god_rubbing`)|A Figure Ascending the Path (`night_father_path_rubbing`)|A Moon-Shaped Stone on the Altar (`altar_moon_stone`)|
|girl:test_answer_girl_8<br>What is the upright frame around her?|An Upright Sleeping Coffin (`history_coffin_illustration`)|The Girl-and-Coffin Motif (`girl_signature_rubbing`)|The Motif on the Diary Cover (`diary_cover`)|
|girl:test_answer_girl_12<br>Who made this marker?|A Diary Page, Author Unknown (`girl_diary`)|The Motif on the Diary Cover (`diary_cover`)|The Girl-and-Coffin Motif (`girl_signature_rubbing`)|
|girl:test_answer_girl_16<br>Do the family sculpture and the photograph belong together?|A Statuette of Four (`family_statuette`)|One Base, Three Tombs (`shared_family_base`)|The Girl Inside the Frame (`girl_figure_rubbing`)|
|girl:test_answer_girl_20<br>Does disappearance always mean death?|A Diary Page, Author Unknown (`girl_diary`)|The Scholar's Notes on Disappearances (`disappearance_inquiry`)|The Crystal Monument's Twin Beast (`scholar_beast_rubbing`)|
|girl:test_answer_girl_24<br>Aurora, why is this girl on the notebook you gave me?|The Same Girl on Stone and Paper (`girl_cover_correspondence`)|The Motif on the Diary Cover (`diary_cover`)|The Girl-and-Coffin Motif (`girl_signature_rubbing`)|

## 渐进提交

消失调查：首先交失踪调查报告 → 交皮肤画 → 交夜父死亡记录。每一步仍一次只交一份，跨步骤累计调查进展。

|阶段|有效记录|混淆项一|混淆项二|
|---|---|---|
|skin|skin_picture|designer_journal|night_mother_child_rubbing|
|death|night_father_death|twin_beast_account|skyway_reference|

已移除旧版“母亲向女儿传达情感”的隐藏问答与终局回扣；皮肤画、四人雕像及家族对应保留为解谜事实。

太阳／钱币无线电问答已移除：大亨身份由职业文献提供，钱币意义通过场景图形对应建立，不要求无线电重复确认。
