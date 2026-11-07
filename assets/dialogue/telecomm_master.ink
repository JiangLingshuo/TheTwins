// TWINS - STANDALONE LINKAGE TEST
// Source: 墓碑表.xlsx; newer author instructions and current evidence tags override stale cells.
// English dialogue is a test draft, not final production copy.
// Author-edited spreadsheet dialogue, reactions and explicit hidden mechanisms synchronized on 2026-11-01.
// Tombstone descriptions are maintained in tombstone_master.ink and called as tunnels.
// Evidence IDs/tags and DEV previews are generated from the current evidence_master.ink.
// Rebuild/sync these snapshots when changing source evidence tags or prose.
INCLUDE evidence_master.ink
INCLUDE tombstone_master.ink

LIST EvidenceId = infant_medical_record, girl_painted_flower, girl_teddy_bear, night_mother_flower, mother_daughter_flower_meaning, dayfolk_appearance, moon_reference, infant_figure_rubbing, infant_moon_rubbing, designer_manuscript, designer_journal, infant_graffiti, infant_death_doubt, shared_family_base, crystal_marker_rubbing, scholar_beast_rubbing, night_city_crystal, skin_picture, disappearance_inquiry, profession_record, one_way_passage_order, sun_reference, sun_shaped_marker_rubbing, sun_shaped_beast_rubbing, day_city_coin, ram_spirit_emblem, giant_footprint, twin_beast_trace, twin_beast_account, repeated_beast_motifs, family_photo, altar_infant_rubbing, altar_path_rubbing, altar_blessing_glyph, altar_blessing_translation, crystal_god_rubbing, removed_crystal_god, altar_moon_stone, crystal_god_prophecy, moon_stone_blessing, infant_memorial_correspondence, night_mother_child_rubbing, night_mother_hands_rubbing, night_mother_river_rubbing, dry_underground_river, night_mother_no_traces, night_mother_death_finding, night_father_child_rubbing, night_father_path_rubbing, night_father_god_rubbing, night_father_moon_stone, natural_collapse_record, skyway_history, skyway_reference, night_father_death, paired_skin_pictures, girl_figure_rubbing, girl_coffin_rubbing, girl_beast_rubbing, girl_path_rubbing, girl_signature_rubbing, family_statuette, day_city_history, history_coffin_illustration, girl_diary, diary_cover, notebook_cover, four_person_family_finding, girl_cover_correspondence, scholar_no_traces

LIST EvidenceTag = infant_euthanasia, girl_painted_flower_trace, girl_teddy_bear_trace, night_mother_flower_trace, mother_daughter_flower_meaning, absence_of_readable_traces, ancient_creature_trace, ancient_disappearance, ascending_path_motif, aurora_identity_reference, aurora_provided_object, aurora_translation_knowledge, author_identity_reference, contradictory_death_accounts, contrasting_halves, crystal_extraction_reference, crystal_god_motif, crystal_research_reference, crystal_shape, dawn_disappearances, day_city_belief, day_city_bias, day_city_currency, day_night_handholding, dayfolk_appearance, death_by_hunger_and_thirst, deliberate_departure, different_exchange_customs, disappearance_symbol_reference, dry_river_motif, endless_path_motif, family_image_reference, family_mausoleum_custom, family_requested_depiction, four_person_family, funerary_artist_reference, girl_coffin_motif, girl_memorial, human_figure_reference, husband_disappearance, infant_actual_appearance, infant_appearance_mismatch, infant_death_unresolved, infant_identity, infant_memorial, intercity_resource_exchange, last_survivor_question, missed_sleeping_deadline, missing_family_member_reference, moon_motif, moon_reference, moon_stone_offering, natural_collapse, night_blessing_glyph, night_blessing_reference, night_city_belief, night_city_mineral_origin, night_city_supply_blockade, night_departure_reference, night_father_final_journey, night_father_past, night_infant_reference, night_mother_death_reference, night_mother_future, night_mother_past, night_symbol_translation, occupation_marker_custom, one_way_passage, original_separation, paired_day_night_death, paired_day_night_memorials, parent_child_image, population_decline, ram_spirit_motif, removed_crystal_offering, repeated_local_symbol, resentment_toward_mother, scholar_identity, scholar_no_visitors, scholar_tycoon_marriage, shared_body_reference, shared_day_night_history, shared_family_plot, skin_as_message_medium, skyway_not_steep, sleep_coffin_required, smooth_skinned_child, sun_motif, sun_shape, three_family_markers, twin_beast_motif, twin_beast_reference, two_mothers_dilemma, tycoon_identity, unexplained_waking_wounds, upright_coffin_motif, water_source_lost, well_preserved_diary

LIST TombId = baby, scholar, sun, altar, mother, father, girl

LIST Identity = infant, scholar, tycoon, night_mother, night_father, funerary_artist, aurora

LIST Cause = natural, unexplained, euthanasia, hunger_and_thirst, disappearance, missed_sleeping_deadline, escape

VAR owned_evidence = ()
VAR known_tags = ()
VAR selected_id = ""
VAR selected_tags = ()
VAR submitted_id = ""
VAR submitted_tags = ()
VAR active_tomb = ""
VAR identities = ()
VAR causes = ()
VAR clue_words = ""
LIST WordId = w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17
VAR collected_words = ()
VAR report_identity = ()
VAR report_cause = ()
VAR completed_reports = ()
VAR links = ()
LIST Subtext = baby_drawer, baby_shared, scholar_skin, sun_missing, altar_translation, altar_child, mother_message, father_history, final, baby_8_additional, baby_21, scholar_31, scholar_35, scholar_39, sun_25, altar_24, altar_28, mother_25, father_24, girl_24
VAR seen_subtexts = ()
VAR subtext_count = 0
VAR reports_submitted = false
VAR girl_revealed = false
VAR final_confronted = false
VAR ending_cause = 0
VAR sun_photo_asked = false
VAR searchlight_year = 2050
VAR scan_2005 = false
VAR scan_2050 = false
VAR bonus_remaining = 2
VAR bonus_done = false
VAR hypothesis_open = false
VAR hypothesis_skin = false
VAR hypothesis_death = false
VAR hypothesis_return = "sun"
VAR return_after_terms = "hub"
VAR natural_reply_seen = false
VAR player_name = "Investigator"
VAR feedback_kind = ""
VAR pending_relation_feedback = false
LIST AnswerId = scholar_passage_gate_hidden, mother_flower_supported, mother_flower_normal, baby_8_normal_9, baby_8_additional_10, baby_17_supported_19, baby_17_comparison, baby_17_normal_13, baby_21_hidden_23, scholar_8_supported_10, scholar_8_normal_9, repeated_beast_hidden, scholar_12_supported_15, scholar_12_normal_13, scholar_17_supported_19, scholar_17_normal_18, scholar_20_normal_21, scholar_25_supported_27, scholar_25_normal_26, scholar_31_hidden_33, scholar_35_hidden_37, scholar_39_hidden_41, sun_13_supported_15, sun_13_normal_14, sun_17_supported_19, sun_17_normal_18, sun_25_hidden_27, altar_8_supported_10, altar_8_normal_9, altar_12_supported_14, altar_12_normal_13, altar_16_supported_18, altar_16_normal_17, altar_20_supported_22, altar_20_normal_21, altar_24_hidden_26, altar_28_hidden_30, mother_8_supported_10, mother_8_normal_9, mother_12_supported_14, mother_12_normal_13, mother_17_supported_19, mother_17_normal_18, mother_21_supported_23, mother_21_normal_22, mother_25_hidden_27, father_8_supported_10, father_8_normal_9, father_12_supported_14, father_12_normal_13, father_16_supported_18, father_16_normal_17, father_20_supported_22, father_20_normal_21, father_24_hidden_26, girl_8_supported_10, girl_8_normal_9, girl_12_supported_14, girl_12_normal_13, girl_16_supported_18, girl_16_normal_17, girl_20_supported_22, girl_20_normal_21
VAR read_answers = ()
LIST NightGlyph = blessing, unending_path, dry_river, ascending_path, crystal_god
VAR queried_night_glyphs = ()
VAR glyph_return = "altar"
VAR scan_scholar_2005 = false
VAR scan_scholar_2050 = false
-> test_start

=== function has_tag(tag) ===
~ return submitted_tags ? tag

=== function know(tag) ===
~ return known_tags ? tag

=== test_start ===
DEV: Author-edited dialogue / evidence linkage test, 2026-11-01.
Hidden QUESTIONS need submitted evidence to appear. Hidden ANSWERS append to an ordinary reply.
Choose a source evidence, then contact Aurora. One evidence is frozen for the whole call.
-> test_hub

=== test_hub ===
// Trigger once after two distinct accepted reports in EACH city, in any order.
{not bonus_done && LIST_COUNT(completed_reports) >= 4:
    ~ bonus_remaining = 2
    -> test_bonus
}
DEV: Collected {LIST_COUNT(owned_evidence)} evidence records. Reports {LIST_COUNT(completed_reports)}/6 before the final marker. Subtexts {subtext_count}.
DEV: Prepared evidence: {selected_id == "":none|{selected_id}}.
+ [Play the original opening] -> opening
+ [Inspect a tombstone] -> test_tomb_menu
+ [DEV: collect / read a source record] -> test_library
+ [Prepare one collected evidence for the radio] -> test_slot
+ [Read / collect clickable terms] -> test_terms
+ [Compare records] -> test_compare
+ [DEV: test the searchlight year] -> test_searchlight
+ [Contact Aurora] -> test_radio_menu
+ [Fill in an investigation report] -> test_reports
+ {LIST_COUNT(completed_reports) >= 6 && not reports_submitted} [Submit the six investigation reports] -> test_submit_all
+ {girl_revealed} [Walk to the solitary marker] -> test_desc_girl
+ [DEV: status and tag snapshot] -> test_status
+ [End test] -> END

=== test_status ===
DEV: owned={owned_evidence}
DEV: prepared={selected_id}; prepared tags={selected_tags}
DEV: last submitted={submitted_id}; frozen tags={submitted_tags}
DEV: known tags={known_tags}
DEV: identity candidates={identities}; cause candidates={causes}
DEV: completed reports={completed_reports}; relationships={links}
-> test_hub

// PRESERVED AUTHOR OPENING: only END routing changes for the test.

=== opening ===
Oh, my notebook’s in black and white. #player
Aurora never told me why. I guess it’s an aesthetic choice. #player
... #??
...Hello? Can you hear me? #??
(It doesn't take you a second to realize who's speaking. That's the first time you hear her voice beyond your textual exchange. Her voice is huskier than you thought.) #narrator
Aurora? Is that you? The connection’s finally back. I’ve landed safely on Twins. #player
Glad you’re safe! I hope the trip wasn’t too rough. Have you had a chance to look through your handbook? #aurora
Yeah, I was just looking at it. Interesting color scheme. #player
There’s a reason for it. Seen from space, Twins is a planet in black and white... Just like the civilization that once lived there. Of course, that’s a bonus to the name. It was first named the Twins because its day and night align with Earth’s, despite the distance between them. #aurora
Should I expect to meet anyone here? #player
No, but you’ll find their traces—a fallen civilization of two cities. Our archaeologists have searched their libraries, their homes, their schools. All the places where they lived. But there’s one place they overlooked. #aurora
Where? #player
(You might have an answer in mind. But you wait for her confirmation.) #narrator
Where they remembered the dead. The cemeteries. That’s your mission: to uncover what words alone cannot tell us, through the memories they left behind. #aurora
We don’t have much transmission time left. I have to go. Talk to you later. #aurora
(Now it’s just you, your handbook, and the faint breath of the planet.) #narrator
(You feel a tremor in your limbs.) #narrator
(You stand up. The faint breeze brushing past your ears feels much like the wind back home. Perhaps the people who once lived here weren’t so different from you, either.) #narrator
(You’re here to gather their memories. Your steps grow steadier.) #narrator
(Then you see it: the place where an entire civilization rests.) #narrator
-> test_hub

=== test_tomb_menu ===
Which marker would you like to inspect?

+ [The Small Human-Shaped Marker] -> test_desc_baby

+ [The Crystal Monument] -> test_desc_scholar

+ [The Sun-Shaped Monument] -> test_desc_sun

+ [The White Infant Altar] -> test_desc_altar

+ [The Small Stone Beside the Altar] -> test_desc_mother

+ [The Other Stone Beside the Altar] -> test_desc_father

+ {girl_revealed} [The Solitary Human-Shaped Marker] -> test_desc_girl

+ [Back] -> test_hub

=== test_desc_baby ===
-> tombstone_baby ->
+ [Contact Aurora about this marker]
    ~ active_tomb = "baby"
    -> test_freeze_evidence
+ [Back to the cemetery] -> test_hub

=== test_desc_scholar ===
-> tombstone_scholar ->
+ [Contact Aurora about this marker]
    ~ active_tomb = "scholar"
    -> test_freeze_evidence
+ [Back to the cemetery] -> test_hub

=== test_desc_sun ===
-> tombstone_sun ->
+ [Contact Aurora about this marker]
    ~ active_tomb = "sun"
    -> test_freeze_evidence
+ [Back to the cemetery] -> test_hub

=== test_desc_altar ===
-> tombstone_altar ->
+ [Contact Aurora about this marker]
    ~ active_tomb = "altar"
    -> test_freeze_evidence
+ [Back to the cemetery] -> test_hub

=== test_desc_mother ===
-> tombstone_mother ->
+ [Contact Aurora about this marker]
    ~ active_tomb = "mother"
    -> test_freeze_evidence
+ [Back to the cemetery] -> test_hub

=== test_desc_father ===
-> tombstone_father ->
+ [Contact Aurora about this marker]
    ~ active_tomb = "father"
    -> test_freeze_evidence
+ [Back to the cemetery] -> test_hub

=== test_desc_girl ===
-> tombstone_girl ->
+ [Contact Aurora about this marker]
    ~ active_tomb = "girl"
    -> test_freeze_evidence
+ [Back to the cemetery] -> test_hub

=== test_library ===
DEV ONLY: collect a record and read it. This bypasses scene / story gates.
+ [dayfolk_appearance — The Appearance of the Dayfolk]
    ~ owned_evidence += EvidenceId.dayfolk_appearance
    ~ known_tags += (EvidenceTag.dayfolk_appearance, EvidenceTag.human_figure_reference)
    # event:grant_evidence:dayfolk_appearance
    -> test_preview_dayfolk_appearance
+ [moon_reference — The Moon Above Night City]
    ~ owned_evidence += EvidenceId.moon_reference
    ~ known_tags += (EvidenceTag.moon_reference, EvidenceTag.moon_motif)
    # event:grant_evidence:moon_reference
    -> test_preview_moon_reference
+ [infant_figure_rubbing — The Small Human-Shaped Marker]
    ~ owned_evidence += EvidenceId.infant_figure_rubbing
    ~ known_tags += (EvidenceTag.human_figure_reference, EvidenceTag.infant_memorial, EvidenceTag.dayfolk_appearance)
    # event:grant_evidence:infant_figure_rubbing
    -> test_preview_infant_figure_rubbing
+ [infant_moon_rubbing — The Small Marker's Curved Decoration]
    ~ owned_evidence += EvidenceId.infant_moon_rubbing
    ~ known_tags += (EvidenceTag.moon_motif)
    # event:grant_evidence:infant_moon_rubbing
    -> test_preview_infant_moon_rubbing
+ [designer_manuscript — A Marker for Someone Without an Occupation]
    ~ owned_evidence += EvidenceId.designer_manuscript
    ~ known_tags += (EvidenceTag.infant_identity, EvidenceTag.occupation_marker_custom, EvidenceTag.human_figure_reference)
    # event:grant_evidence:designer_manuscript
    -> test_preview_designer_manuscript
+ [designer_journal — A Page of the Designer's Journal]
    ~ owned_evidence += EvidenceId.designer_journal
    ~ known_tags += (EvidenceTag.infant_appearance_mismatch, EvidenceTag.family_requested_depiction)
    # event:grant_evidence:designer_journal
    -> test_preview_designer_journal
+ [infant_graffiti — A Sketch of the Infant]
    ~ owned_evidence += EvidenceId.infant_graffiti
    ~ known_tags += (EvidenceTag.infant_appearance_mismatch, EvidenceTag.infant_actual_appearance)
    # event:grant_evidence:infant_graffiti
    -> test_preview_infant_graffiti
+ [infant_medical_record — Day City Medical Record: Infant Case]
    ~ owned_evidence += EvidenceId.infant_medical_record
    ~ known_tags += EvidenceTag.infant_euthanasia
    # event:grant_evidence:infant_medical_record
    -> test_preview_infant_medical_record

+ [infant_death_doubt — An Unresolved Death]
    ~ owned_evidence += EvidenceId.infant_death_doubt
    ~ known_tags += (EvidenceTag.infant_death_unresolved, EvidenceTag.infant_appearance_mismatch)
    # event:grant_evidence:infant_death_doubt
    -> test_preview_infant_death_doubt
+ [shared_family_base — One Base, Three Tombs]
    ~ owned_evidence += EvidenceId.shared_family_base
    ~ known_tags += (EvidenceTag.shared_family_plot, EvidenceTag.three_family_markers, EvidenceTag.missing_family_member_reference)
    # event:grant_evidence:shared_family_base
    -> test_preview_shared_family_base
+ [crystal_marker_rubbing — The Crystal Monument's Outline]
    ~ owned_evidence += EvidenceId.crystal_marker_rubbing
    ~ known_tags += (EvidenceTag.crystal_shape, EvidenceTag.crystal_research_reference)
    # event:grant_evidence:crystal_marker_rubbing
    -> test_preview_crystal_marker_rubbing
+ [scholar_beast_rubbing — The Crystal Monument's Twin Beast]
    ~ owned_evidence += EvidenceId.scholar_beast_rubbing
    ~ known_tags += (EvidenceTag.twin_beast_motif, EvidenceTag.disappearance_symbol_reference)
    # event:grant_evidence:scholar_beast_rubbing
    -> test_preview_scholar_beast_rubbing
+ [night_city_crystal — Crystal from Night City]
    ~ owned_evidence += EvidenceId.night_city_crystal
    ~ known_tags += (EvidenceTag.crystal_shape, EvidenceTag.night_city_mineral_origin, EvidenceTag.intercity_resource_exchange)
    # event:grant_evidence:night_city_crystal
    -> test_preview_night_city_crystal
+ [skin_picture — The Picture Preserved on Skin]
    ~ owned_evidence += EvidenceId.skin_picture
    ~ known_tags += (EvidenceTag.day_night_handholding, EvidenceTag.skin_as_message_medium, EvidenceTag.shared_body_reference)
    # event:grant_evidence:skin_picture
    -> test_preview_skin_picture
+ [disappearance_inquiry — The Scholar's Notes on Disappearances]
    ~ owned_evidence += EvidenceId.disappearance_inquiry
    ~ known_tags += (EvidenceTag.dawn_disappearances, EvidenceTag.unexplained_waking_wounds, EvidenceTag.sleep_coffin_required, EvidenceTag.husband_disappearance, EvidenceTag.day_city_bias)
    # event:grant_evidence:disappearance_inquiry
    -> test_preview_disappearance_inquiry
+ [profession_record — The Scholar, Her Work, and Her Patron]
    ~ owned_evidence += EvidenceId.profession_record
    ~ known_tags += (EvidenceTag.scholar_identity, EvidenceTag.tycoon_identity, EvidenceTag.crystal_research_reference, EvidenceTag.scholar_tycoon_marriage, EvidenceTag.family_mausoleum_custom)
    # event:grant_evidence:profession_record
    -> test_preview_profession_record
+ [one_way_passage_order — An Order for a One-Way Passage]
    ~ owned_evidence += EvidenceId.one_way_passage_order
    ~ known_tags += (EvidenceTag.one_way_passage, EvidenceTag.intercity_resource_exchange, EvidenceTag.night_city_supply_blockade, EvidenceTag.day_city_bias)
    # event:grant_evidence:one_way_passage_order
    -> test_preview_one_way_passage_order
+ [sun_reference — The Sun Above Day City]
    ~ owned_evidence += EvidenceId.sun_reference
    ~ known_tags += (EvidenceTag.sun_shape, EvidenceTag.sun_motif)
    # event:grant_evidence:sun_reference
    -> test_preview_sun_reference
+ [sun_shaped_marker_rubbing — The Sun-Shaped Monument]
    ~ owned_evidence += EvidenceId.sun_shaped_marker_rubbing
    ~ known_tags += (EvidenceTag.sun_shape, EvidenceTag.sun_motif)
    # event:grant_evidence:sun_shaped_marker_rubbing
    -> test_preview_sun_shaped_marker_rubbing
+ [sun_shaped_beast_rubbing — The Sun-Shaped Monument's Twin Beast]
    ~ owned_evidence += EvidenceId.sun_shaped_beast_rubbing
    ~ known_tags += (EvidenceTag.twin_beast_motif, EvidenceTag.disappearance_symbol_reference)
    # event:grant_evidence:sun_shaped_beast_rubbing
    -> test_preview_sun_shaped_beast_rubbing
+ [day_city_coin — A Coin from the Wishing Pool]
    ~ owned_evidence += EvidenceId.day_city_coin
    ~ known_tags += (EvidenceTag.sun_shape, EvidenceTag.day_city_currency, EvidenceTag.sun_motif)
    # event:grant_evidence:day_city_coin
    -> test_preview_day_city_coin
+ [ram_spirit_emblem — The Ram-Spirit Emblem]
    ~ owned_evidence += EvidenceId.ram_spirit_emblem
    ~ known_tags += (EvidenceTag.day_city_belief, EvidenceTag.ram_spirit_motif)
    # event:grant_evidence:ram_spirit_emblem
    -> test_preview_ram_spirit_emblem
+ [giant_footprint — A Giant Footprint in the Ruins]
    ~ owned_evidence += EvidenceId.giant_footprint
    ~ known_tags += (EvidenceTag.ancient_creature_trace, EvidenceTag.twin_beast_reference)
    # event:grant_evidence:giant_footprint
    -> test_preview_giant_footprint
+ [twin_beast_trace — The Creature Revealed Above the Footprint]
    ~ owned_evidence += EvidenceId.twin_beast_trace
    ~ known_tags += (EvidenceTag.twin_beast_motif, EvidenceTag.twin_beast_reference, EvidenceTag.contrasting_halves)
    # event:grant_evidence:twin_beast_trace
    -> test_preview_twin_beast_trace
+ [twin_beast_account — An Account of the Twin-Bodied Creature]
    ~ owned_evidence += EvidenceId.twin_beast_account
    ~ known_tags += (EvidenceTag.twin_beast_reference, EvidenceTag.contrasting_halves, EvidenceTag.ancient_disappearance)
    # event:grant_evidence:twin_beast_account
    -> test_preview_twin_beast_account
+ [repeated_beast_motifs — The Same Beast on Other Graves]
    ~ owned_evidence += EvidenceId.repeated_beast_motifs
    ~ known_tags += (EvidenceTag.twin_beast_motif, EvidenceTag.repeated_local_symbol)
    # event:grant_evidence:repeated_beast_motifs
    -> test_preview_repeated_beast_motifs
+ [family_photo — A Photograph of Four]
    ~ owned_evidence += EvidenceId.family_photo
    ~ known_tags += (EvidenceTag.four_person_family, EvidenceTag.missing_family_member_reference, EvidenceTag.family_image_reference)
    # event:grant_evidence:family_photo
    -> test_preview_family_photo
+ [altar_infant_rubbing — The Infant on the White Altar]
    ~ owned_evidence += EvidenceId.altar_infant_rubbing
    ~ known_tags += (EvidenceTag.infant_memorial, EvidenceTag.night_infant_reference)
    # event:grant_evidence:altar_infant_rubbing
    -> test_preview_altar_infant_rubbing
+ [altar_path_rubbing — The Altar's Unending Path]
    ~ owned_evidence += EvidenceId.altar_path_rubbing
    ~ known_tags += (EvidenceTag.endless_path_motif, EvidenceTag.night_departure_reference)
    # event:grant_evidence:altar_path_rubbing
    -> test_preview_altar_path_rubbing
+ [altar_blessing_glyph — An Unfamiliar Glyph on the Altar]
    ~ owned_evidence += EvidenceId.altar_blessing_glyph
    ~ known_tags += (EvidenceTag.night_blessing_glyph, EvidenceTag.night_symbol_translation, EvidenceTag.aurora_translation_knowledge)
    # event:grant_evidence:altar_blessing_glyph
    -> test_preview_altar_blessing_glyph
+ [altar_blessing_translation — A Blessing for the Unending Journey]
    ~ owned_evidence += EvidenceId.altar_blessing_translation
    ~ known_tags += (EvidenceTag.night_blessing_glyph, EvidenceTag.night_symbol_translation, EvidenceTag.endless_path_motif, EvidenceTag.aurora_translation_knowledge)
    # event:grant_evidence:altar_blessing_translation
    -> test_preview_altar_blessing_translation
+ [crystal_god_rubbing — The Crystal God's Outline]
    ~ owned_evidence += EvidenceId.crystal_god_rubbing
    ~ known_tags += (EvidenceTag.crystal_god_motif, EvidenceTag.night_city_belief)
    # event:grant_evidence:crystal_god_rubbing
    -> test_preview_crystal_god_rubbing
+ [removed_crystal_god — The Crystal Figure That Once Stood Here]
    ~ owned_evidence += EvidenceId.removed_crystal_god
    ~ known_tags += (EvidenceTag.crystal_god_motif, EvidenceTag.removed_crystal_offering, EvidenceTag.crystal_extraction_reference)
    # event:grant_evidence:removed_crystal_god
    -> test_preview_removed_crystal_god
+ [altar_moon_stone — A Moon-Shaped Stone on the Altar]
    ~ owned_evidence += EvidenceId.altar_moon_stone
    ~ known_tags += (EvidenceTag.moon_stone_offering, EvidenceTag.night_blessing_reference, EvidenceTag.moon_motif)
    # event:grant_evidence:altar_moon_stone
    -> test_preview_altar_moon_stone
+ [crystal_god_prophecy — The Crystal God's Prophecy]
    ~ owned_evidence += EvidenceId.crystal_god_prophecy
    ~ known_tags += (EvidenceTag.night_infant_reference, EvidenceTag.smooth_skinned_child, EvidenceTag.night_city_belief, EvidenceTag.aurora_translation_knowledge)
    # event:grant_evidence:crystal_god_prophecy
    -> test_preview_crystal_god_prophecy
+ [moon_stone_blessing — A Blessing, Not a Payment]
    ~ owned_evidence += EvidenceId.moon_stone_blessing
    ~ known_tags += (EvidenceTag.moon_stone_offering, EvidenceTag.night_blessing_reference, EvidenceTag.different_exchange_customs)
    # event:grant_evidence:moon_stone_blessing
    -> test_preview_moon_stone_blessing
+ [infant_memorial_correspondence — Two Memorials to an Infant]
    ~ owned_evidence += EvidenceId.infant_memorial_correspondence
    ~ known_tags += (EvidenceTag.infant_memorial, EvidenceTag.paired_day_night_memorials, EvidenceTag.contradictory_death_accounts)
    # event:grant_evidence:infant_memorial_correspondence
    -> test_preview_infant_memorial_correspondence
+ [night_mother_child_rubbing — A Figure Holding a Child]
    ~ owned_evidence += EvidenceId.night_mother_child_rubbing
    ~ known_tags += (EvidenceTag.night_infant_reference, EvidenceTag.parent_child_image, EvidenceTag.night_mother_past)
    # event:grant_evidence:night_mother_child_rubbing
    -> test_preview_night_mother_child_rubbing
+ [night_mother_hands_rubbing — Two Figures Holding Hands]
    ~ owned_evidence += EvidenceId.night_mother_hands_rubbing
    ~ known_tags += (EvidenceTag.day_night_handholding, EvidenceTag.night_mother_future, EvidenceTag.shared_body_reference)
    # event:grant_evidence:night_mother_hands_rubbing
    -> test_preview_night_mother_hands_rubbing
+ [night_mother_river_rubbing — The Dry River Around the Stone]
    ~ owned_evidence += EvidenceId.night_mother_river_rubbing
    ~ known_tags += (EvidenceTag.dry_river_motif, EvidenceTag.night_mother_death_reference)
    # event:grant_evidence:night_mother_river_rubbing
    -> test_preview_night_mother_river_rubbing
+ [dry_underground_river — The Underground Riverbed]
    ~ owned_evidence += EvidenceId.dry_underground_river
    ~ known_tags += (EvidenceTag.dry_river_motif, EvidenceTag.water_source_lost)
    # event:grant_evidence:dry_underground_river
    -> test_preview_dry_underground_river
+ [night_mother_no_traces — No Readable Traces Around the Stone]
    ~ owned_evidence += EvidenceId.night_mother_no_traces
    ~ known_tags += (EvidenceTag.absence_of_readable_traces, EvidenceTag.last_survivor_question)
    # event:grant_evidence:night_mother_no_traces
    -> test_preview_night_mother_no_traces
+ [night_mother_death_finding — The Meaning of the Dry River Border]
    ~ owned_evidence += EvidenceId.night_mother_death_finding
    ~ known_tags += (EvidenceTag.night_mother_death_reference, EvidenceTag.death_by_hunger_and_thirst, EvidenceTag.water_source_lost)
    # event:grant_evidence:night_mother_death_finding
    -> test_preview_night_mother_death_finding
+ [night_father_child_rubbing — A Figure Carrying a Child]
    ~ owned_evidence += EvidenceId.night_father_child_rubbing
    ~ known_tags += (EvidenceTag.night_infant_reference, EvidenceTag.parent_child_image, EvidenceTag.night_father_past)
    # event:grant_evidence:night_father_child_rubbing
    -> test_preview_night_father_child_rubbing
+ [night_father_path_rubbing — A Figure Ascending the Path]
    ~ owned_evidence += EvidenceId.night_father_path_rubbing
    ~ known_tags += (EvidenceTag.ascending_path_motif, EvidenceTag.night_father_final_journey)
    # event:grant_evidence:night_father_path_rubbing
    -> test_preview_night_father_path_rubbing
+ [night_father_god_rubbing — The Crystal God Below the Father]
    ~ owned_evidence += EvidenceId.night_father_god_rubbing
    ~ known_tags += (EvidenceTag.crystal_god_motif, EvidenceTag.night_city_belief)
    # event:grant_evidence:night_father_god_rubbing
    -> test_preview_night_father_god_rubbing
+ [night_father_moon_stone — A Moon-Shaped Stone Before the Father's Marker]
    ~ owned_evidence += EvidenceId.night_father_moon_stone
    ~ known_tags += (EvidenceTag.moon_stone_offering, EvidenceTag.night_blessing_reference, EvidenceTag.moon_motif)
    # event:grant_evidence:night_father_moon_stone
    -> test_preview_night_father_moon_stone
+ [natural_collapse_record — The Collapse That Sealed the Road]
    ~ owned_evidence += EvidenceId.natural_collapse_record
    ~ known_tags += (EvidenceTag.shared_day_night_history, EvidenceTag.original_separation, EvidenceTag.natural_collapse)
    # event:grant_evidence:natural_collapse_record
    -> test_preview_natural_collapse_record
+ [skyway_history — An Account of the Skyway]
    ~ owned_evidence += EvidenceId.skyway_history
    ~ known_tags += (EvidenceTag.ascending_path_motif, EvidenceTag.skyway_not_steep, EvidenceTag.intercity_resource_exchange, EvidenceTag.night_city_mineral_origin)
    # event:grant_evidence:skyway_history
    -> test_preview_skyway_history
+ [skyway_reference — The Path to the Surface]
    ~ owned_evidence += EvidenceId.skyway_reference
    ~ known_tags += (EvidenceTag.ascending_path_motif, EvidenceTag.skyway_not_steep, EvidenceTag.night_father_final_journey)
    # event:grant_evidence:skyway_reference
    -> test_preview_skyway_reference
+ [night_father_death — The Father's Search Beyond His Waking Hours]
    ~ owned_evidence += EvidenceId.night_father_death
    ~ known_tags += (EvidenceTag.sleep_coffin_required, EvidenceTag.missed_sleeping_deadline, EvidenceTag.night_father_final_journey, EvidenceTag.paired_day_night_death)
    # event:grant_evidence:night_father_death
    -> test_preview_night_father_death
+ [paired_skin_pictures — A Picture Across Day and Night]
    ~ owned_evidence += EvidenceId.paired_skin_pictures
    ~ known_tags += (EvidenceTag.day_night_handholding, EvidenceTag.skin_as_message_medium, EvidenceTag.unexplained_waking_wounds, EvidenceTag.shared_body_reference)
    # event:grant_evidence:paired_skin_pictures
    -> test_preview_paired_skin_pictures
+ [girl_figure_rubbing — The Girl Inside the Frame]
    ~ owned_evidence += EvidenceId.girl_figure_rubbing
    ~ known_tags += (EvidenceTag.human_figure_reference, EvidenceTag.girl_memorial)
    # event:grant_evidence:girl_figure_rubbing
    -> test_preview_girl_figure_rubbing
+ [girl_coffin_rubbing — The Upright Frame Around the Girl]
    ~ owned_evidence += EvidenceId.girl_coffin_rubbing
    ~ known_tags += (EvidenceTag.upright_coffin_motif, EvidenceTag.girl_memorial)
    # event:grant_evidence:girl_coffin_rubbing
    -> test_preview_girl_coffin_rubbing
+ [girl_beast_rubbing — The Girl's Twin-Beast Decoration]
    ~ owned_evidence += EvidenceId.girl_beast_rubbing
    ~ known_tags += (EvidenceTag.twin_beast_motif, EvidenceTag.disappearance_symbol_reference)
    # event:grant_evidence:girl_beast_rubbing
    -> test_preview_girl_beast_rubbing
+ [girl_path_rubbing — The Unending Path Around the Girl]
    ~ owned_evidence += EvidenceId.girl_path_rubbing
    ~ known_tags += (EvidenceTag.endless_path_motif, EvidenceTag.night_departure_reference)
    # event:grant_evidence:girl_path_rubbing
    -> test_preview_girl_path_rubbing
+ [girl_signature_rubbing — The Girl-and-Coffin Motif]
    ~ owned_evidence += EvidenceId.girl_signature_rubbing
    ~ known_tags += (EvidenceTag.girl_coffin_motif, EvidenceTag.girl_memorial, EvidenceTag.author_identity_reference)
    # event:grant_evidence:girl_signature_rubbing
    -> test_preview_girl_signature_rubbing
+ [family_statuette — A Statuette of Four]
    ~ owned_evidence += EvidenceId.family_statuette
    ~ known_tags += (EvidenceTag.four_person_family, EvidenceTag.family_image_reference)
    # event:grant_evidence:family_statuette
    -> test_preview_family_statuette
+ [day_city_history — A History of Day City]
    ~ owned_evidence += EvidenceId.day_city_history
    ~ known_tags += (EvidenceTag.shared_day_night_history, EvidenceTag.sleep_coffin_required, EvidenceTag.upright_coffin_motif, EvidenceTag.population_decline)
    # event:grant_evidence:day_city_history
    -> test_preview_day_city_history
+ [history_coffin_illustration — An Upright Sleeping Coffin]
    ~ owned_evidence += EvidenceId.history_coffin_illustration
    ~ known_tags += (EvidenceTag.upright_coffin_motif, EvidenceTag.shared_day_night_history)
    # event:grant_evidence:history_coffin_illustration
    -> test_preview_history_coffin_illustration
+ [girl_diary — A Diary Page, Author Unknown]
    ~ owned_evidence += EvidenceId.girl_diary
    ~ known_tags += (EvidenceTag.author_identity_reference, EvidenceTag.funerary_artist_reference, EvidenceTag.deliberate_departure, EvidenceTag.two_mothers_dilemma, EvidenceTag.resentment_toward_mother)
    # event:grant_evidence:girl_diary
    -> test_preview_girl_diary
+ [diary_cover — The Motif on the Diary Cover]
    ~ owned_evidence += EvidenceId.diary_cover
    ~ known_tags += (EvidenceTag.girl_coffin_motif, EvidenceTag.author_identity_reference, EvidenceTag.well_preserved_diary)
    # event:grant_evidence:diary_cover
    -> test_preview_diary_cover
+ [notebook_cover — The Cover of Your Investigation Notebook]
    ~ owned_evidence += EvidenceId.notebook_cover
    ~ known_tags += (EvidenceTag.girl_coffin_motif, EvidenceTag.author_identity_reference, EvidenceTag.aurora_provided_object)
    # event:grant_evidence:notebook_cover
    -> test_preview_notebook_cover
+ [four_person_family_finding — Four People Remembered, Three Graves Together]
    ~ owned_evidence += EvidenceId.four_person_family_finding
    ~ known_tags += (EvidenceTag.four_person_family, EvidenceTag.missing_family_member_reference)
    # event:grant_evidence:four_person_family_finding
    -> test_preview_four_person_family_finding
+ [girl_cover_correspondence — The Same Girl on Stone and Paper]
    ~ owned_evidence += EvidenceId.girl_cover_correspondence
    ~ known_tags += (EvidenceTag.girl_coffin_motif, EvidenceTag.author_identity_reference, EvidenceTag.aurora_identity_reference)
    # event:grant_evidence:girl_cover_correspondence
    -> test_preview_girl_cover_correspondence
+ [scholar_no_traces — No Later Visitors at the Crystal Monument]
    ~ owned_evidence += EvidenceId.scholar_no_traces
    ~ known_tags += (EvidenceTag.scholar_no_visitors, EvidenceTag.absence_of_readable_traces, EvidenceTag.last_survivor_question)
    # event:grant_evidence:scholar_no_traces
    -> test_preview_scholar_no_traces
+ [Back] -> test_hub

=== test_preview_dayfolk_appearance ===
# ui:open_evidence:dayfolk_appearance
The figure has a smooth face and the familiar outline of the Dayfolk. Its features offer a reference for the human-shaped marker.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_moon_reference ===
# ui:open_evidence:moon_reference
A pale crescent is visible above the cemetery. Its outline resembles the curved decoration on the small marker, although it is not quite the shape of Earth's moon.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_infant_figure_rubbing ===
# ui:open_evidence:infant_figure_rubbing
The marker takes the shape of a person rather than the tools of an occupation. Its face follows the smooth appearance of the Dayfolk.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_infant_moon_rubbing ===
# ui:open_evidence:infant_moon_rubbing
A curved shape is carved into the small marker. The rubbing preserves its outline for comparison with the surrounding world.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_designer_manuscript ===
# ui:open_evidence:designer_manuscript
A translated copy of designer manuscript
Our cemetery usually represents a person through an icon of their occupation. This burial is different: the deceased is an <link="infant">infant</link> who had not yet been assigned an occupation. None of the existing designs would do.

The family asked us not to define the child by work he had never begun. We chose a human figure instead. The child had no occupation, but he was still a person.

"A child without an occupation is a person before anything else."
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_designer_journal ===
# ui:open_evidence:designer_journal
My student visited me with urgency. She showed me a photo of the actual appearance of the infant. I was stunned as I never saw a dayfolk that was born like this. She asked me to design the tombstone with his real appearance, so that he can truly be remembered. I rejected her, as I have having a commission from the infant's parents, not her. She left with disappointment, and perhaps, a little bit of anger.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_infant_graffiti ===
# ui:open_evidence:infant_graffiti
The searchlight reveals an old sketch of the infant. His appearance differs from the smooth figure chosen for the marker.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_infant_medical_record ===
# ui:open_evidence:infant_medical_record
Clinical examination: The infant was covered in thick hair. His eyes barely opened. The attending physicians judged that he would be unable to adapt to conditions in Day City.

Authorization: Both parents signed the consent form.

Outcome: <link="euthanasia">Euthanasia</link> was approved and carried out. Death was confirmed by the attending physician.
-> test_library

=== test_preview_infant_death_doubt ===
# ui:open_evidence:infant_death_doubt
The family's chosen depiction does not match with the records of the infant's appearance. The tombstone's expression of natural death does not settle what actually happened to him. There may be <link="unexplained death">unexplained circumstances</link> behind this death.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_shared_family_base ===
# ui:open_evidence:shared_family_base
The small gravestone, the crystal monument, and the sun-shaped monument share one continuous stone base. They are not merely three separate graves standing close together.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_crystal_marker_rubbing ===
# ui:open_evidence:crystal_marker_rubbing
The monument is a transparent, many-sided crystal, half black and half white. The rubbing preserves the outline of its facets.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_scholar_beast_rubbing ===
# ui:open_evidence:scholar_beast_rubbing
A twin beast is carved on the crystal monument. Its two halves belong to one body, but their appearances differ.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_city_crystal ===
# ui:open_evidence:night_city_crystal
This mineral was found in Night City. Its facets resemble the outline of the crystal monument in Day City.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_skin_picture ===
# ui:open_evidence:skin_picture
Rewound to a time before the skin decayed, the searchlight reveals the picture clearly. A member of the Dayfolk and a member of the Nightfolk reach out and clasp hands.

The lines are formed by blue blood seeping through the skin. A drawing on skin, made for an unknown reason.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_disappearance_inquiry ===
# ui:open_evidence:disappearance_inquiry
The unexplained <link="disappearance">disappearances</link> in Day City are always reported at dawn, when people wake.

The Dayfolk's bodies are unusual. Anyone who fails to enter a sleeping coffin on time will die. Once inside, however, they lose all awareness and ability to act for the entire night, under the coffin's complete protection.

Who has been tampering with their sleeping coffins? I cannot investigate the movements of the Nightfolks while they are awake. I can only suspect that, while taking our food, they have also done something to my husband and my people.

It is not only disappearances. Many of us, myself included, have found fresh wounds upon waking. Given the Nightfolk's habit of plundering, they are most likely responsible. I must remain vigilant.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_profession_record ===
# ui:open_evidence:profession_record
The record describes a Day City resident who first studied this transparent mineral and discovered the energy within it. She was granted the title of <link="scholar">Scholar</link>.

The stones were later used to power machinery. The occupational title thus became associated with crystal research.

A young man from a wealthy family was the first to invest in her research. He later became her husband and came to be known as the <link="tycoon">Tycoon</link>.

In recognition of her outstanding contributions to Day City, the Scholar may apply for a mausoleum beyond the usual grave-marker design and have her family interred within it. For the Dayfolk, who place such importance on the rituals of death, this is the highest honor.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_one_way_passage_order ===
# ui:open_evidence:one_way_passage_order
An order to the Scholar: We must put an end to Nightfolk incursions at their source.

They were once allowed to take our food in exchange for the crystals they excavated. Now they neglect their work, yet continue to demand more and more from Day City.

A one-way passage must be established: the Dayfolk may descend, but the Nightfolk must not be allowed to ascend.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_sun_reference ===
# ui:open_evidence:sun_reference
The bright sun above Day City offers a possible reference for the monument's radiating outline. The same sun-like outline can also be compared with the pointed rims of Day City coins.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_sun_shaped_marker_rubbing ===
# ui:open_evidence:sun_shaped_marker_rubbing
Radiating points surround the monument like a shining sun. The rubbing records its distinctive outline.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_sun_shaped_beast_rubbing ===
# ui:open_evidence:sun_shaped_beast_rubbing
A small creature occupies the center of the monument. One half looks different from the other, although both are joined to the same body.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_day_city_coin ===
# ui:open_evidence:day_city_coin
Circulating coins once lay in the wishing pool beneath the ram-spirit emblem. Their pointed rims form a sun-like outline, similar to the sun-shaped monument. The pool fell out of use as technology developed and people turned to other beliefs.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_ram_spirit_emblem ===
# ui:open_evidence:ram_spirit_emblem
A ram-spirit emblem stands above the wishing pool. It belongs to the religious imagery of Day City.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_giant_footprint ===
# ui:open_evidence:giant_footprint
A vast footprint remains in the ruins. The print alone does not reveal the full appearance of the creature that left it.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_twin_beast_trace ===
# ui:open_evidence:twin_beast_trace
The searchlight reveals the creature that once occupied this space: one body with two strikingly different halves. Its outline can be compared with the small beasts carved on the monuments.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_twin_beast_account ===
# ui:open_evidence:twin_beast_account
Legend tells of a twin-bodied creature that lived here before Day City was founded. Its two halves looked entirely different: one was covered in fur, with narrow eyes; the other was smooth, with clearly visible eyes.

Then, in a single night, they disappeared.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_repeated_beast_motifs ===
# ui:open_evidence:repeated_beast_motifs
The same twin beast appears on several other markers in Day City. It is not a decoration unique to the sun-shaped monument.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_family_photo ===
# ui:open_evidence:family_photo
A photograph once stood in front of the monument. It shows four members of a family. There are only three markers on the shared base.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_altar_infant_rubbing ===
# ui:open_evidence:altar_infant_rubbing
An infant rests on the white, house-shaped altar. The pose differs slightly from the human-shaped marker in Day City, but the two images invite comparison.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_altar_path_rubbing ===
# ui:open_evidence:altar_path_rubbing
A path runs along the altar's pillars. Its pattern has no visible end.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_altar_blessing_glyph ===
# ui:open_evidence:altar_blessing_glyph
An unfamiliar symbol is carved into the altar. It does not resemble a passage of written text.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_altar_blessing_translation ===
# ui:open_evidence:altar_blessing_translation
Aurora interprets the symbol as a blessing:

"To disappear is to set out on a journey without end. May the wishes of crystal remain with you."
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_crystal_god_rubbing ===
# ui:open_evidence:crystal_god_rubbing
The altar's decoration preserves the outline of the Crystal God, but the place where the crystals once stood is now empty.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_removed_crystal_god ===
# ui:open_evidence:removed_crystal_god
In the searchlight's view of the past, crystals fill the altar's empty recess and form the figure of a god. Today the crystals have been pried out.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_altar_moon_stone ===
# ui:open_evidence:altar_moon_stone
A moon-shaped stone once lay among the altar's offerings. It resembles a small token, but there is nothing here that establishes its value as currency.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_crystal_god_prophecy ===
# ui:open_evidence:crystal_god_prophecy
A legend of the Crystal God:

"When an infant with skin as smooth as crystal comes to Night City, the Nightfolk will see the light once more."

The child foretold in the prophecy was called the <link="divine_messenger">Divine Messenger</link>.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_moon_stone_blessing ===
# ui:open_evidence:moon_stone_blessing
The moon-shaped stones are offerings of blessing, not coins. The Nightfolk do not leave them as payment for goods or mark territory through them. A stone left for someone expresses a wish for their well-being.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_infant_memorial_correspondence ===
# ui:open_evidence:infant_memorial_correspondence
The human-shaped marker in Day City corresponds to the infant memorial in Night City. One city describes a death; the other commemorates a <link="disappearance">disappearance</link>.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_mother_child_rubbing ===
# ui:open_evidence:night_mother_child_rubbing
The upper part of the small stone shows a figure holding a child. The child can be compared with the infant on the altar.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_mother_hands_rubbing ===
# ui:open_evidence:night_mother_hands_rubbing
Below the figure holding a child, a member of the Dayfolk and a member of the Nightfolk hold their hands. The arrangement resembles the picture preserved inside the Scholar's crystal monument.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_mother_river_rubbing ===
# ui:open_evidence:night_mother_river_rubbing
Cracked lines surround the stone like the bed of a dried river. They form the border of the memorial rather than a separate scene in either half.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_dry_underground_river ===
# ui:open_evidence:dry_underground_river
The underground river has dried up. Its exposed bed preserves the cracked pattern seen around the small stone.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_mother_no_traces ===
# ui:open_evidence:night_mother_no_traces
The searchlight reveals no discernible traces around this stone. There is no record here of later visitors or offerings.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_mother_death_finding ===
# ui:open_evidence:night_mother_death_finding
The dry river border records a death from <link="thirst">hunger and thirst</link>. It connects the mother's fate with the loss of the underground water source.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_father_child_rubbing ===
# ui:open_evidence:night_father_child_rubbing
The figure on the upper part of the stone carries a child on his back. The child can be compared with the infant on the altar.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_father_path_rubbing ===
# ui:open_evidence:night_father_path_rubbing
A figure climbs an upward path along the border of the stone. The route resembles the passage known as the Skyway.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_father_god_rubbing ===
# ui:open_evidence:night_father_god_rubbing
The lower part of the stone bears the image of the Crystal God. It resembles the figure once installed on the infant's altar.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_father_moon_stone ===
# ui:open_evidence:night_father_moon_stone
A moon-shaped stone once lay before the father's marker. It resembles the stones left as offerings on the infant's altar.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_natural_collapse_record ===
# ui:open_evidence:natural_collapse_record
...Before the division of day and night, the People of Sun and Moon lived together. After the separation into upper and lower cities, a natural collapse sealed the road to the surface.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_skyway_history ===
# ui:open_evidence:skyway_history
The Skyway is a path cleared upward through fallen stone. It is uneven, but not steep.

Searching for food and water, the Nightfolk dug and climbed in every direction. At last, they opened a route upward through the collapsed ruins.

The Dayfolk called the day they arrived "the Day Darkness Descended." Much food and many livestock were taken before the Dayfolk even knew who had done it. Eventually, they discovered the passage to Night City.

The reopened route also led the Dayfolk to the shining stones the Nightfolk had excavated while searching for food and water: crystals that would later power Day City's development.

The exchange continued with each cycle of day and night. The Dayfolk brought back crystals; the Nightfolk brought back food. Each took what they needed. This balance lasted a long time.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_skyway_reference ===
# ui:open_evidence:skyway_reference
An uneven path rises through the fallen stone toward the surface. It is not the sheer climb its name might suggest. Its shape corresponds to the ascending route carved around the father's stone.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_father_death ===
# ui:open_evidence:night_father_death
The father left to search for the missing infant. The path itself was not a dangerous climb. He continued searching <link="missed_sleeping_deadline">beyond the permitted waking hours</link> and failed to return to a sleeping coffin in time.

His death can be compared with the report of the Scholar's husband disappearing at dawn.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_paired_skin_pictures ===
# ui:open_evidence:paired_skin_pictures
The handholding figures on the mother's stone correspond to the blue marks on the Scholar's preserved skin. Together with the records of wounds appearing upon waking, they suggest that the body itself could carry a message between day and night.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_girl_figure_rubbing ===
# ui:open_evidence:girl_figure_rubbing
Another human figure appears on this marker, older than the infant represented by the small stone. A structure surrounds her body.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_girl_coffin_rubbing ===
# ui:open_evidence:girl_coffin_rubbing
The girl stands inside an upright structure with her hands joined before her chest. The surrounding frame can be compared with the illustration in the old history book.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_girl_beast_rubbing ===
# ui:open_evidence:girl_beast_rubbing
A twin beast decorates the marble-like marker. It resembles the creatures carved on other Day City monuments.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_girl_path_rubbing ===
# ui:open_evidence:girl_path_rubbing
The edge of the upright frame carries the pattern of an unending path. It recalls the border on the infant's altar in Night City.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_girl_signature_rubbing ===
# ui:open_evidence:girl_signature_rubbing
The girl, her joined hands, and the upright coffin form a single composition. This complete motif can be compared with the covers of the diary and the investigation notebook.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_family_statuette ===
# ui:open_evidence:family_statuette
A small sculpture of four family members once stood before the marker. It was carved by the girl. Its figures can be compared with the photograph at the sun-shaped monument.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_day_city_history ===
# ui:open_evidence:day_city_history
This history was a banned book until it was discovered.

Both Dayfolk and Nightfolk must rest in their sleeping coffins at the proper time if they are to awaken the following day.

Before their division, they were known together as the People of Sun and Moon. Some had the daylight; others had the moonlit night.

In their shared residential districts, sleeping coffins stood upright to conserve space. Later, when the Nightfolk moved underground, the number of people on the surface decreased. Space was no longer scarce, and the Dayfolk developed the habit of lying down in their coffins.

The Nightfolk placed theirs underground, where the darkness of the caves made them almost indistinguishable from the surrounding floor.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_history_coffin_illustration ===
# ui:open_evidence:history_coffin_illustration
An illustration in the old history book shows a sleeping coffin standing upright. Its outline resembles the structure surrounding the girl on the solitary marker.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_girl_diary ===
# ui:open_evidence:girl_diary
If the truth of death itself is being covered up, then am I not an accomplice when I carve monuments to that lie?

I can no longer bear this hypocritical world. If even one person had stopped to question what was wrong with the world we lived in, perhaps we would never have come to this.

I once loved and respected my mother so much. She was my example from childhood. But first she failed to protect my brother; then she blamed my father's disappearance on others. Even when I tried to tell her the truth about our world, she insisted that useless sympathy would destroy Day City.

How many more times must we hurt our own people in the name of protecting them?

She left me a message on my windowsill when she came to the Day City. She is so intelligent that she acquired the language of Day City just by observing the surroundings and reading the library, and she found out my identity as her correspondence just by the messages conveyed by the stones. She said there was an old site in the ruins, with sleeping coffins that could keep the two of us alive.

She told me why she wanted to leave. Before her brother was born, she had a place in the family. Afterwards, every hope and every tenderness seemed to belong to him. When he disappeared, she waited for her parents to notice that she was still there. Instead, their grief filled the place he had left. Night City called them the Holy Father and Holy Mother. She could not remember the last time she had felt like their daughter.

I wanted to leave a world my mother kept defending. She wanted to leave a home where she felt unseen. Neither of us would bring our mother. With my mother's influence in Day City, everyone would find out if she came. For the other girl, leaving without hers was the point.

I have to persuade her. We can only escape on our own. The One-way Passage Order is launching soon. We need to act fast.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_diary_cover ===
# ui:open_evidence:diary_cover
The diary remains intact, as if new. It seems that it's not part of the remains collected by previous archaeologists. Its cover bears the image of a girl standing inside an upright coffin, hands joined before her chest.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_notebook_cover ===
# ui:open_evidence:notebook_cover
Aurora gave you this black-and-white notebook. On its cover, a girl stands inside an upright coffin, hands joined before her chest.

You have been carrying the image throughout your investigation, holding it like the girl in the monument.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_four_person_family_finding ===
# ui:open_evidence:four_person_family_finding
The four figures in the statuette correspond to the family in the photograph. The shared base holds only three markers. The solitary girl's marker stands apart from that family plot.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_girl_cover_correspondence ===
# ui:open_evidence:girl_cover_correspondence
The complete girl-and-coffin composition on the solitary marker corresponds to the image on the diary or the investigation notebook. The person who made the monument, the writer, and the person who supplied the notebook may be connected.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_slot ===
Choose ONE collected evidence. It is frozen when the call begins.
+ [No evidence]
    ~ selected_id = ""
    ~ selected_tags = ()
    -> test_hub
+ {owned_evidence ? EvidenceId.dayfolk_appearance} [The Appearance of the Dayfolk]
    ~ selected_id = "dayfolk_appearance"
    ~ selected_tags = (EvidenceTag.dayfolk_appearance, EvidenceTag.human_figure_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.moon_reference} [The Moon Above Night City]
    ~ selected_id = "moon_reference"
    ~ selected_tags = (EvidenceTag.moon_reference, EvidenceTag.moon_motif)
    -> test_hub
+ {owned_evidence ? EvidenceId.infant_figure_rubbing} [The Small Human-Shaped Marker]
    ~ selected_id = "infant_figure_rubbing"
    ~ selected_tags = (EvidenceTag.human_figure_reference, EvidenceTag.infant_memorial, EvidenceTag.dayfolk_appearance)
    -> test_hub
+ {owned_evidence ? EvidenceId.infant_moon_rubbing} [The Small Marker's Curved Decoration]
    ~ selected_id = "infant_moon_rubbing"
    ~ selected_tags = (EvidenceTag.moon_motif)
    -> test_hub
+ {owned_evidence ? EvidenceId.designer_manuscript} [A Marker for Someone Without an Occupation]
    ~ selected_id = "designer_manuscript"
    ~ selected_tags = (EvidenceTag.infant_identity, EvidenceTag.occupation_marker_custom, EvidenceTag.human_figure_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.designer_journal} [A Page of the Designer's Journal]
    ~ selected_id = "designer_journal"
    ~ selected_tags = (EvidenceTag.infant_appearance_mismatch, EvidenceTag.family_requested_depiction)
    -> test_hub
+ {owned_evidence ? EvidenceId.infant_graffiti} [A Sketch of the Infant]
    ~ selected_id = "infant_graffiti"
    ~ selected_tags = (EvidenceTag.infant_appearance_mismatch, EvidenceTag.infant_actual_appearance)
    -> test_hub
+ {owned_evidence ? EvidenceId.infant_death_doubt} [An Unresolved Death]
    ~ selected_id = "infant_death_doubt"
    ~ selected_tags = (EvidenceTag.infant_death_unresolved, EvidenceTag.infant_appearance_mismatch)
    -> test_hub
+ {owned_evidence ? EvidenceId.shared_family_base} [One Base, Three Tombs]
    ~ selected_id = "shared_family_base"
    ~ selected_tags = (EvidenceTag.shared_family_plot, EvidenceTag.three_family_markers, EvidenceTag.missing_family_member_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.crystal_marker_rubbing} [The Crystal Monument's Outline]
    ~ selected_id = "crystal_marker_rubbing"
    ~ selected_tags = (EvidenceTag.crystal_shape, EvidenceTag.crystal_research_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.scholar_beast_rubbing} [The Crystal Monument's Twin Beast]
    ~ selected_id = "scholar_beast_rubbing"
    ~ selected_tags = (EvidenceTag.twin_beast_motif, EvidenceTag.disappearance_symbol_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.night_city_crystal} [Crystal from Night City]
    ~ selected_id = "night_city_crystal"
    ~ selected_tags = (EvidenceTag.crystal_shape, EvidenceTag.night_city_mineral_origin, EvidenceTag.intercity_resource_exchange)
    -> test_hub
+ {owned_evidence ? EvidenceId.skin_picture} [The Picture Preserved on Skin]
    ~ selected_id = "skin_picture"
    ~ selected_tags = (EvidenceTag.day_night_handholding, EvidenceTag.skin_as_message_medium, EvidenceTag.shared_body_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.disappearance_inquiry} [The Scholar's Notes on Disappearances]
    ~ selected_id = "disappearance_inquiry"
    ~ selected_tags = (EvidenceTag.dawn_disappearances, EvidenceTag.unexplained_waking_wounds, EvidenceTag.sleep_coffin_required, EvidenceTag.husband_disappearance, EvidenceTag.day_city_bias)
    -> test_hub
+ {owned_evidence ? EvidenceId.profession_record} [The Scholar, Her Work, and Her Patron]
    ~ selected_id = "profession_record"
    ~ selected_tags = (EvidenceTag.scholar_identity, EvidenceTag.tycoon_identity, EvidenceTag.crystal_research_reference, EvidenceTag.scholar_tycoon_marriage, EvidenceTag.family_mausoleum_custom)
    -> test_hub
+ {owned_evidence ? EvidenceId.one_way_passage_order} [An Order for a One-Way Passage]
    ~ selected_id = "one_way_passage_order"
    ~ selected_tags = (EvidenceTag.one_way_passage, EvidenceTag.intercity_resource_exchange, EvidenceTag.night_city_supply_blockade, EvidenceTag.day_city_bias)
    -> test_hub
+ {owned_evidence ? EvidenceId.sun_reference} [The Sun Above Day City]
    ~ selected_id = "sun_reference"
    ~ selected_tags = (EvidenceTag.sun_shape, EvidenceTag.sun_motif)
    -> test_hub
+ {owned_evidence ? EvidenceId.sun_shaped_marker_rubbing} [The Sun-Shaped Monument]
    ~ selected_id = "sun_shaped_marker_rubbing"
    ~ selected_tags = (EvidenceTag.sun_shape, EvidenceTag.sun_motif)
    -> test_hub
+ {owned_evidence ? EvidenceId.sun_shaped_beast_rubbing} [The Sun-Shaped Monument's Twin Beast]
    ~ selected_id = "sun_shaped_beast_rubbing"
    ~ selected_tags = (EvidenceTag.twin_beast_motif, EvidenceTag.disappearance_symbol_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.day_city_coin} [A Coin from the Wishing Pool]
    ~ selected_id = "day_city_coin"
    ~ selected_tags = (EvidenceTag.sun_shape, EvidenceTag.day_city_currency, EvidenceTag.sun_motif)
    -> test_hub
+ {owned_evidence ? EvidenceId.ram_spirit_emblem} [The Ram-Spirit Emblem]
    ~ selected_id = "ram_spirit_emblem"
    ~ selected_tags = (EvidenceTag.day_city_belief, EvidenceTag.ram_spirit_motif)
    -> test_hub
+ {owned_evidence ? EvidenceId.giant_footprint} [A Giant Footprint in the Ruins]
    ~ selected_id = "giant_footprint"
    ~ selected_tags = (EvidenceTag.ancient_creature_trace, EvidenceTag.twin_beast_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.twin_beast_trace} [The Creature Revealed Above the Footprint]
    ~ selected_id = "twin_beast_trace"
    ~ selected_tags = (EvidenceTag.twin_beast_motif, EvidenceTag.twin_beast_reference, EvidenceTag.contrasting_halves)
    -> test_hub
+ {owned_evidence ? EvidenceId.twin_beast_account} [An Account of the Twin-Bodied Creature]
    ~ selected_id = "twin_beast_account"
    ~ selected_tags = (EvidenceTag.twin_beast_reference, EvidenceTag.contrasting_halves, EvidenceTag.ancient_disappearance)
    -> test_hub
+ {owned_evidence ? EvidenceId.repeated_beast_motifs} [The Same Beast on Other Graves]
    ~ selected_id = "repeated_beast_motifs"
    ~ selected_tags = (EvidenceTag.twin_beast_motif, EvidenceTag.repeated_local_symbol)
    -> test_hub
+ {owned_evidence ? EvidenceId.family_photo} [A Photograph of Four]
    ~ selected_id = "family_photo"
    ~ selected_tags = (EvidenceTag.four_person_family, EvidenceTag.missing_family_member_reference, EvidenceTag.family_image_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.altar_infant_rubbing} [The Infant on the White Altar]
    ~ selected_id = "altar_infant_rubbing"
    ~ selected_tags = (EvidenceTag.infant_memorial, EvidenceTag.night_infant_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.altar_path_rubbing} [The Altar's Unending Path]
    ~ selected_id = "altar_path_rubbing"
    ~ selected_tags = (EvidenceTag.endless_path_motif, EvidenceTag.night_departure_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.altar_blessing_glyph} [An Unfamiliar Glyph on the Altar]
    ~ selected_id = "altar_blessing_glyph"
    ~ selected_tags = (EvidenceTag.night_blessing_glyph, EvidenceTag.night_symbol_translation, EvidenceTag.aurora_translation_knowledge)
    -> test_hub
+ {owned_evidence ? EvidenceId.altar_blessing_translation} [A Blessing for the Unending Journey]
    ~ selected_id = "altar_blessing_translation"
    ~ selected_tags = (EvidenceTag.night_blessing_glyph, EvidenceTag.night_symbol_translation, EvidenceTag.endless_path_motif, EvidenceTag.aurora_translation_knowledge)
    -> test_hub
+ {owned_evidence ? EvidenceId.crystal_god_rubbing} [The Crystal God's Outline]
    ~ selected_id = "crystal_god_rubbing"
    ~ selected_tags = (EvidenceTag.crystal_god_motif, EvidenceTag.night_city_belief)
    -> test_hub
+ {owned_evidence ? EvidenceId.removed_crystal_god} [The Crystal Figure That Once Stood Here]
    ~ selected_id = "removed_crystal_god"
    ~ selected_tags = (EvidenceTag.crystal_god_motif, EvidenceTag.removed_crystal_offering, EvidenceTag.crystal_extraction_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.altar_moon_stone} [A Moon-Shaped Stone on the Altar]
    ~ selected_id = "altar_moon_stone"
    ~ selected_tags = (EvidenceTag.moon_stone_offering, EvidenceTag.night_blessing_reference, EvidenceTag.moon_motif)
    -> test_hub
+ {owned_evidence ? EvidenceId.crystal_god_prophecy} [The Crystal God's Prophecy]
    ~ selected_id = "crystal_god_prophecy"
    ~ selected_tags = (EvidenceTag.night_infant_reference, EvidenceTag.smooth_skinned_child, EvidenceTag.night_city_belief, EvidenceTag.aurora_translation_knowledge)
    -> test_hub
+ {owned_evidence ? EvidenceId.moon_stone_blessing} [A Blessing, Not a Payment]
    ~ selected_id = "moon_stone_blessing"
    ~ selected_tags = (EvidenceTag.moon_stone_offering, EvidenceTag.night_blessing_reference, EvidenceTag.different_exchange_customs)
    -> test_hub
+ {owned_evidence ? EvidenceId.infant_memorial_correspondence} [Two Memorials to an Infant]
    ~ selected_id = "infant_memorial_correspondence"
    ~ selected_tags = (EvidenceTag.infant_memorial, EvidenceTag.paired_day_night_memorials, EvidenceTag.contradictory_death_accounts)
    -> test_hub
+ {owned_evidence ? EvidenceId.night_mother_child_rubbing} [A Figure Holding a Child]
    ~ selected_id = "night_mother_child_rubbing"
    ~ selected_tags = (EvidenceTag.night_infant_reference, EvidenceTag.parent_child_image, EvidenceTag.night_mother_past)
    -> test_hub
+ {owned_evidence ? EvidenceId.night_mother_hands_rubbing} [Two Figures Holding Hands]
    ~ selected_id = "night_mother_hands_rubbing"
    ~ selected_tags = (EvidenceTag.day_night_handholding, EvidenceTag.night_mother_future, EvidenceTag.shared_body_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.night_mother_river_rubbing} [The Dry River Around the Stone]
    ~ selected_id = "night_mother_river_rubbing"
    ~ selected_tags = (EvidenceTag.dry_river_motif, EvidenceTag.night_mother_death_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.dry_underground_river} [The Underground Riverbed]
    ~ selected_id = "dry_underground_river"
    ~ selected_tags = (EvidenceTag.dry_river_motif, EvidenceTag.water_source_lost)
    -> test_hub
+ {owned_evidence ? EvidenceId.night_mother_no_traces} [No Readable Traces Around the Stone]
    ~ selected_id = "night_mother_no_traces"
    ~ selected_tags = (EvidenceTag.absence_of_readable_traces, EvidenceTag.last_survivor_question)
    -> test_hub
+ {owned_evidence ? EvidenceId.night_mother_death_finding} [The Meaning of the Dry River Border]
    ~ selected_id = "night_mother_death_finding"
    ~ selected_tags = (EvidenceTag.night_mother_death_reference, EvidenceTag.death_by_hunger_and_thirst, EvidenceTag.water_source_lost)
    -> test_hub
+ {owned_evidence ? EvidenceId.night_father_child_rubbing} [A Figure Carrying a Child]
    ~ selected_id = "night_father_child_rubbing"
    ~ selected_tags = (EvidenceTag.night_infant_reference, EvidenceTag.parent_child_image, EvidenceTag.night_father_past)
    -> test_hub
+ {owned_evidence ? EvidenceId.night_father_path_rubbing} [A Figure Ascending the Path]
    ~ selected_id = "night_father_path_rubbing"
    ~ selected_tags = (EvidenceTag.ascending_path_motif, EvidenceTag.night_father_final_journey)
    -> test_hub
+ {owned_evidence ? EvidenceId.night_father_god_rubbing} [The Crystal God Below the Father]
    ~ selected_id = "night_father_god_rubbing"
    ~ selected_tags = (EvidenceTag.crystal_god_motif, EvidenceTag.night_city_belief)
    -> test_hub
+ {owned_evidence ? EvidenceId.night_father_moon_stone} [A Moon-Shaped Stone Before the Father's Marker]
    ~ selected_id = "night_father_moon_stone"
    ~ selected_tags = (EvidenceTag.moon_stone_offering, EvidenceTag.night_blessing_reference, EvidenceTag.moon_motif)
    -> test_hub
+ {owned_evidence ? EvidenceId.natural_collapse_record} [The Collapse That Sealed the Road]
    ~ selected_id = "natural_collapse_record"
    ~ selected_tags = (EvidenceTag.shared_day_night_history, EvidenceTag.original_separation, EvidenceTag.natural_collapse)
    -> test_hub
+ {owned_evidence ? EvidenceId.skyway_history} [An Account of the Skyway]
    ~ selected_id = "skyway_history"
    ~ selected_tags = (EvidenceTag.ascending_path_motif, EvidenceTag.skyway_not_steep, EvidenceTag.intercity_resource_exchange, EvidenceTag.night_city_mineral_origin)
    -> test_hub
+ {owned_evidence ? EvidenceId.skyway_reference} [The Path to the Surface]
    ~ selected_id = "skyway_reference"
    ~ selected_tags = (EvidenceTag.ascending_path_motif, EvidenceTag.skyway_not_steep, EvidenceTag.night_father_final_journey)
    -> test_hub
+ {owned_evidence ? EvidenceId.night_father_death} [The Father's Search Beyond His Waking Hours]
    ~ selected_id = "night_father_death"
    ~ selected_tags = (EvidenceTag.sleep_coffin_required, EvidenceTag.missed_sleeping_deadline, EvidenceTag.night_father_final_journey, EvidenceTag.paired_day_night_death)
    -> test_hub
+ {owned_evidence ? EvidenceId.paired_skin_pictures} [A Picture Across Day and Night]
    ~ selected_id = "paired_skin_pictures"
    ~ selected_tags = (EvidenceTag.day_night_handholding, EvidenceTag.skin_as_message_medium, EvidenceTag.unexplained_waking_wounds, EvidenceTag.shared_body_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.girl_figure_rubbing} [The Girl Inside the Frame]
    ~ selected_id = "girl_figure_rubbing"
    ~ selected_tags = (EvidenceTag.human_figure_reference, EvidenceTag.girl_memorial)
    -> test_hub
+ {owned_evidence ? EvidenceId.girl_coffin_rubbing} [The Upright Frame Around the Girl]
    ~ selected_id = "girl_coffin_rubbing"
    ~ selected_tags = (EvidenceTag.upright_coffin_motif, EvidenceTag.girl_memorial)
    -> test_hub
+ {owned_evidence ? EvidenceId.girl_beast_rubbing} [The Girl's Twin-Beast Decoration]
    ~ selected_id = "girl_beast_rubbing"
    ~ selected_tags = (EvidenceTag.twin_beast_motif, EvidenceTag.disappearance_symbol_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.girl_path_rubbing} [The Unending Path Around the Girl]
    ~ selected_id = "girl_path_rubbing"
    ~ selected_tags = (EvidenceTag.endless_path_motif, EvidenceTag.night_departure_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.girl_signature_rubbing} [The Girl-and-Coffin Motif]
    ~ selected_id = "girl_signature_rubbing"
    ~ selected_tags = (EvidenceTag.girl_coffin_motif, EvidenceTag.girl_memorial, EvidenceTag.author_identity_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.family_statuette} [A Statuette of Four]
    ~ selected_id = "family_statuette"
    ~ selected_tags = (EvidenceTag.four_person_family, EvidenceTag.family_image_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.day_city_history} [A History of Day City]
    ~ selected_id = "day_city_history"
    ~ selected_tags = (EvidenceTag.shared_day_night_history, EvidenceTag.sleep_coffin_required, EvidenceTag.upright_coffin_motif, EvidenceTag.population_decline)
    -> test_hub
+ {owned_evidence ? EvidenceId.history_coffin_illustration} [An Upright Sleeping Coffin]
    ~ selected_id = "history_coffin_illustration"
    ~ selected_tags = (EvidenceTag.upright_coffin_motif, EvidenceTag.shared_day_night_history)
    -> test_hub
+ {owned_evidence ? EvidenceId.girl_diary} [A Diary Page, Author Unknown]
    ~ selected_id = "girl_diary"
    ~ selected_tags = (EvidenceTag.author_identity_reference, EvidenceTag.funerary_artist_reference, EvidenceTag.deliberate_departure, EvidenceTag.two_mothers_dilemma, EvidenceTag.resentment_toward_mother)
    -> test_hub
+ {owned_evidence ? EvidenceId.diary_cover} [The Motif on the Diary Cover]
    ~ selected_id = "diary_cover"
    ~ selected_tags = (EvidenceTag.girl_coffin_motif, EvidenceTag.author_identity_reference, EvidenceTag.well_preserved_diary)
    -> test_hub
+ {owned_evidence ? EvidenceId.notebook_cover} [The Cover of Your Investigation Notebook]
    ~ selected_id = "notebook_cover"
    ~ selected_tags = (EvidenceTag.girl_coffin_motif, EvidenceTag.author_identity_reference, EvidenceTag.aurora_provided_object)
    -> test_hub
+ {owned_evidence ? EvidenceId.four_person_family_finding} [Four People Remembered, Three Graves Together]
    ~ selected_id = "four_person_family_finding"
    ~ selected_tags = (EvidenceTag.four_person_family, EvidenceTag.missing_family_member_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.girl_cover_correspondence} [The Same Girl on Stone and Paper]
    ~ selected_id = "girl_cover_correspondence"
    ~ selected_tags = (EvidenceTag.girl_coffin_motif, EvidenceTag.author_identity_reference, EvidenceTag.aurora_identity_reference)
    -> test_hub
+ {owned_evidence ? EvidenceId.scholar_no_traces} [No Later Visitors at the Crystal Monument]
    ~ selected_id = "scholar_no_traces"
    ~ selected_tags = (EvidenceTag.scholar_no_visitors, EvidenceTag.absence_of_readable_traces, EvidenceTag.last_survivor_question)
    -> test_hub
+ [Back] -> test_hub

=== test_terms ===
DEV: simulate clicking a link in an acquired document or finding. Runtime link clicks should call the same actions.

+ {owned_evidence ? EvidenceId.infant_medical_record} [Euthanasia]
    ~ causes += Cause.euthanasia
    # event:collect_term:euthanasia
    # term_type:death_cause
    Recorded globally: Euthanasia.
    -> test_terms

+ {owned_evidence ? EvidenceId.designer_manuscript} [Infant]
    ~ identities += Identity.infant
    ~ collected_words += WordId.w0
    # event:collect_term:infant
    # term_type:identity
    Recorded globally: Infant.
    -> test_terms

+ {owned_evidence ? EvidenceId.profession_record} [Scholar]
    ~ identities += Identity.scholar
    ~ collected_words += WordId.w2
    # event:collect_term:scholar
    # term_type:identity
    Recorded globally: Scholar.
    -> test_terms

+ {owned_evidence ? EvidenceId.profession_record} [Tycoon]
    ~ identities += Identity.tycoon
    ~ collected_words += WordId.w3
    # event:collect_term:tycoon
    # term_type:identity
    Recorded globally: Tycoon.
    -> test_terms

+ {owned_evidence ? EvidenceId.infant_death_doubt} [Unexplained circumstances]
    ~ causes += Cause.unexplained
    ~ collected_words += WordId.w4
    # event:collect_term:unexplained death
    # term_type:death_cause
    Recorded globally: Unexplained circumstances.
    -> test_terms

+ {owned_evidence ? EvidenceId.night_mother_death_finding} [Hunger and thirst]
    ~ causes += Cause.hunger_and_thirst
    ~ collected_words += WordId.w5
    # event:collect_term:thirst
    # term_type:death_cause
    Recorded globally: Hunger and thirst.
    -> test_terms

+ {owned_evidence ? EvidenceId.disappearance_inquiry || owned_evidence ? EvidenceId.infant_memorial_correspondence} [Disappearance]
    ~ causes += Cause.disappearance
    ~ collected_words += WordId.w6
    # event:collect_term:disappearance
    # term_type:death_cause
    Recorded globally: Disappearance.
    -> test_terms

+ {owned_evidence ? EvidenceId.night_father_death} [Beyond permitted waking hours]
    ~ causes += Cause.missed_sleeping_deadline
    ~ collected_words += WordId.w7
    # event:collect_term:missed_sleeping_deadline
    # term_type:death_cause
    Recorded globally: Beyond permitted waking hours.
    -> test_terms

+ [Back] -> test_hub

=== test_searchlight ===
DEV: Current snapshot year {searchlight_year}; rewind {2050-searchlight_year} years from 2050.
+ [Set 2050 / present]
    ~ searchlight_year = 2050
    -> test_searchlight
+ [Set 2005 / rewind 45 years]
    ~ searchlight_year = 2005
    -> test_searchlight
+ [Set 2000 / rewind 50 years]
    ~ searchlight_year = 2000
    -> test_searchlight
+ [Set 1990 / rewind 60 years]
    ~ searchlight_year = 1990
    -> test_searchlight
+ [Set 1800 / rewind 250 years — provisional ancient date]
    ~ searchlight_year = 1800
    -> test_searchlight

+ [Illuminate target: infant_graffiti]
    {searchlight_year == 2000:
        ~ owned_evidence += EvidenceId.infant_graffiti
        ~ known_tags += (EvidenceTag.infant_appearance_mismatch, EvidenceTag.infant_actual_appearance)
        # event:grant_evidence:infant_graffiti
        -> test_preview_infant_graffiti
    - else:
        No readable trace at this test setting. DEV expected year: 2000.
        -> test_searchlight
    }

+ [Illuminate target: skin_picture]
    {searchlight_year == 2005:
        ~ owned_evidence += EvidenceId.skin_picture
        ~ known_tags += (EvidenceTag.day_night_handholding, EvidenceTag.skin_as_message_medium, EvidenceTag.shared_body_reference)
        # event:grant_evidence:skin_picture
        -> test_preview_skin_picture
    - else:
        No readable trace at this test setting. DEV expected year: 2005.
        -> test_searchlight
    }

+ [Illuminate target: day_city_coin]
    {searchlight_year == 1990:
        ~ owned_evidence += EvidenceId.day_city_coin
        ~ known_tags += (EvidenceTag.sun_shape, EvidenceTag.day_city_currency, EvidenceTag.sun_motif)
        # event:grant_evidence:day_city_coin
        -> test_preview_day_city_coin
    - else:
        No readable trace at this test setting. DEV expected year: 1990.
        -> test_searchlight
    }

+ [Illuminate target: twin_beast_trace]
    {searchlight_year == 1800:
        ~ owned_evidence += EvidenceId.twin_beast_trace
        ~ known_tags += (EvidenceTag.twin_beast_motif, EvidenceTag.twin_beast_reference, EvidenceTag.contrasting_halves)
        # event:grant_evidence:twin_beast_trace
        -> test_preview_twin_beast_trace
    - else:
        No readable trace at this test setting. DEV expected year: 1800.
        -> test_searchlight
    }

+ [Illuminate target: family_photo]
    {searchlight_year == 2000:
        ~ owned_evidence += EvidenceId.family_photo
        ~ known_tags += (EvidenceTag.four_person_family, EvidenceTag.missing_family_member_reference, EvidenceTag.family_image_reference)
        # event:grant_evidence:family_photo
        -> test_preview_family_photo
    - else:
        No readable trace at this test setting. DEV expected year: 2000.
        -> test_searchlight
    }

+ [Illuminate target: removed_crystal_god]
    {searchlight_year == 2000:
        ~ owned_evidence += EvidenceId.removed_crystal_god
        ~ known_tags += (EvidenceTag.crystal_god_motif, EvidenceTag.removed_crystal_offering, EvidenceTag.crystal_extraction_reference)
        # event:grant_evidence:removed_crystal_god
        -> test_preview_removed_crystal_god
    - else:
        No readable trace at this test setting. DEV expected year: 2000.
        -> test_searchlight
    }

+ [Illuminate target: altar_moon_stone]
    {searchlight_year == 2000:
        ~ owned_evidence += EvidenceId.altar_moon_stone
        ~ known_tags += (EvidenceTag.moon_stone_offering, EvidenceTag.night_blessing_reference, EvidenceTag.moon_motif)
        # event:grant_evidence:altar_moon_stone
        -> test_preview_altar_moon_stone
    - else:
        No readable trace at this test setting. DEV expected year: 2000.
        -> test_searchlight
    }

+ [Illuminate target: night_father_moon_stone]
    {searchlight_year == 2000:
        ~ owned_evidence += EvidenceId.night_father_moon_stone
        ~ known_tags += (EvidenceTag.moon_stone_offering, EvidenceTag.night_blessing_reference, EvidenceTag.moon_motif)
        # event:grant_evidence:night_father_moon_stone
        -> test_preview_night_father_moon_stone
    - else:
        No readable trace at this test setting. DEV expected year: 2000.
        -> test_searchlight
    }

+ [Illuminate target: family_statuette]
    {searchlight_year == 2005:
        ~ owned_evidence += EvidenceId.family_statuette
        ~ known_tags += (EvidenceTag.four_person_family, EvidenceTag.family_image_reference)
        # event:grant_evidence:family_statuette
        -> test_preview_family_statuette
    - else:
        No readable trace at this test setting. DEV expected year: 2005.
        -> test_searchlight
    }

+ [Scan the mother's marker after burial]
    {searchlight_year == 2005:
        ~ scan_2005 = true
    }
    {searchlight_year == 2050:
        ~ scan_2050 = true
    }
    {scan_2005 && scan_2050:
        ~ owned_evidence += EvidenceId.night_mother_no_traces
        ~ known_tags += (EvidenceTag.absence_of_readable_traces, EvidenceTag.last_survivor_question)
        # event:grant_evidence:night_mother_no_traces
        DEV: both endpoints scanned. This is a simplified negative-scan test, not final tool design.
    - else:
        DEV: scan both 2005 and 2050. A missed year is not proof of absence.
    }
    -> test_searchlight
+ [Scan the Scholar's monument after burial]
    {searchlight_year == 2005:
        ~ scan_scholar_2005 = true
    }
    {searchlight_year == 2050:
        ~ scan_scholar_2050 = true
    }
    {scan_scholar_2005 && scan_scholar_2050:
        ~ owned_evidence += EvidenceId.scholar_no_traces
        ~ known_tags += (EvidenceTag.scholar_no_visitors, EvidenceTag.absence_of_readable_traces, EvidenceTag.last_survivor_question)
        # event:grant_evidence:scholar_no_traces
        DEV: Scholar's post-burial endpoints checked. No later readable visits.
    - else:
        DEV: Check 2005 and 2050 at the Scholar's monument. The mother's scan does not count here.
    }
    -> test_searchlight
+ [Back] -> test_hub

LIST Relation = moon, crystal, sun, baby_pair, river, father_path, skin, family, cover, human, beast, mother_child, father_child, coffin

=== test_compare ===
DEV: compare actual records before interpretation questions become available.
+ {(owned_evidence ? EvidenceId.infant_moon_rubbing) && (owned_evidence ? EvidenceId.moon_reference)} [infant_moon_rubbing ↔ moon_reference]
    ~ links += Relation.moon
    ~ pending_relation_feedback = true
    # event:comparison:moon
    Correspondence recorded.
    -> test_compare
+ {(owned_evidence ? EvidenceId.infant_figure_rubbing) && (owned_evidence ? EvidenceId.dayfolk_appearance)} [infant_figure_rubbing ↔ dayfolk_appearance]
    ~ links += Relation.human
    ~ pending_relation_feedback = true
    # event:comparison:human
    Correspondence recorded.
    -> test_compare
+ {(owned_evidence ? EvidenceId.crystal_marker_rubbing) && (owned_evidence ? EvidenceId.night_city_crystal)} [crystal_marker_rubbing ↔ night_city_crystal]
    ~ links += Relation.crystal
    ~ pending_relation_feedback = true
    # event:comparison:crystal
    Correspondence recorded.
    -> test_compare
+ {(owned_evidence ? EvidenceId.sun_shaped_marker_rubbing) && (owned_evidence ? EvidenceId.sun_reference)} [sun_shaped_marker_rubbing ↔ sun_reference]
    ~ links += Relation.sun
    ~ pending_relation_feedback = true
    # event:comparison:sun
    Correspondence recorded.
    -> test_compare
+ {(owned_evidence ? EvidenceId.sun_shaped_marker_rubbing) && (owned_evidence ? EvidenceId.day_city_coin)} [sun_shaped_marker_rubbing ↔ day_city_coin]
    ~ links += Relation.sun
    ~ pending_relation_feedback = true
    # event:comparison:sun
    Correspondence recorded.
    -> test_compare
+ {(owned_evidence ? EvidenceId.scholar_beast_rubbing) && (owned_evidence ? EvidenceId.twin_beast_trace)} [scholar_beast_rubbing ↔ twin_beast_trace]
    ~ links += Relation.beast
    ~ pending_relation_feedback = true
    # event:comparison:beast
    Correspondence recorded.
    -> test_compare
+ {(owned_evidence ? EvidenceId.sun_shaped_beast_rubbing) && (owned_evidence ? EvidenceId.twin_beast_trace)} [sun_shaped_beast_rubbing ↔ twin_beast_trace]
    ~ links += Relation.beast
    ~ pending_relation_feedback = true
    # event:comparison:beast
    Correspondence recorded.
    -> test_compare
+ {(owned_evidence ? EvidenceId.girl_beast_rubbing) && (owned_evidence ? EvidenceId.twin_beast_trace)} [girl_beast_rubbing ↔ twin_beast_trace]
    ~ links += Relation.beast
    ~ pending_relation_feedback = true
    # event:comparison:beast
    Correspondence recorded.
    -> test_compare
+ {(owned_evidence ? EvidenceId.infant_figure_rubbing) && (owned_evidence ? EvidenceId.altar_infant_rubbing)} [infant_figure_rubbing ↔ altar_infant_rubbing]
    ~ links += Relation.baby_pair
    ~ pending_relation_feedback = true
    # event:comparison:baby_pair
    Correspondence recorded.
    ~ owned_evidence += EvidenceId.infant_memorial_correspondence
    ~ known_tags += (EvidenceTag.infant_memorial, EvidenceTag.paired_day_night_memorials, EvidenceTag.contradictory_death_accounts)
    # event:grant_evidence:infant_memorial_correspondence
    -> test_compare
+ {(owned_evidence ? EvidenceId.night_mother_child_rubbing) && (owned_evidence ? EvidenceId.altar_infant_rubbing)} [night_mother_child_rubbing ↔ altar_infant_rubbing]
    ~ links += Relation.mother_child
    ~ pending_relation_feedback = true
    # event:comparison:mother_child
    Correspondence recorded.
    -> test_compare
+ {(owned_evidence ? EvidenceId.night_father_child_rubbing) && (owned_evidence ? EvidenceId.altar_infant_rubbing)} [night_father_child_rubbing ↔ altar_infant_rubbing]
    ~ links += Relation.father_child
    ~ pending_relation_feedback = true
    # event:comparison:father_child
    Correspondence recorded.
    -> test_compare
+ {(owned_evidence ? EvidenceId.night_mother_river_rubbing) && (owned_evidence ? EvidenceId.dry_underground_river)} [night_mother_river_rubbing ↔ dry_underground_river]
    ~ links += Relation.river
    ~ pending_relation_feedback = true
    # event:comparison:river
    Correspondence recorded.
    ~ owned_evidence += EvidenceId.night_mother_death_finding
    ~ known_tags += (EvidenceTag.night_mother_death_reference, EvidenceTag.death_by_hunger_and_thirst, EvidenceTag.water_source_lost)
    # event:grant_evidence:night_mother_death_finding
    -> test_compare
+ {(owned_evidence ? EvidenceId.night_father_path_rubbing) && (owned_evidence ? EvidenceId.skyway_reference)} [night_father_path_rubbing ↔ skyway_reference]
    ~ links += Relation.father_path
    ~ pending_relation_feedback = true
    # event:comparison:father_path
    Correspondence recorded.
    -> test_compare
+ {(owned_evidence ? EvidenceId.night_mother_hands_rubbing) && (owned_evidence ? EvidenceId.skin_picture)} [night_mother_hands_rubbing ↔ skin_picture]
    ~ links += Relation.skin
    ~ pending_relation_feedback = true
    # event:comparison:skin
    Correspondence recorded.
    -> test_compare
+ {(owned_evidence ? EvidenceId.family_photo) && (owned_evidence ? EvidenceId.family_statuette)} [family_photo ↔ family_statuette]
    ~ links += Relation.family
    ~ pending_relation_feedback = true
    # event:comparison:family
    Correspondence recorded.
    ~ owned_evidence += EvidenceId.four_person_family_finding
    ~ known_tags += (EvidenceTag.four_person_family, EvidenceTag.missing_family_member_reference)
    # event:grant_evidence:four_person_family_finding
    -> test_compare
+ {(owned_evidence ? EvidenceId.girl_coffin_rubbing) && (owned_evidence ? EvidenceId.history_coffin_illustration)} [girl_coffin_rubbing ↔ history_coffin_illustration]
    ~ links += Relation.coffin
    ~ pending_relation_feedback = true
    # event:comparison:coffin
    Correspondence recorded.
    -> test_compare
+ {(owned_evidence ? EvidenceId.girl_signature_rubbing) && (owned_evidence ? EvidenceId.notebook_cover)} [girl_signature_rubbing ↔ notebook_cover]
    ~ links += Relation.cover
    ~ pending_relation_feedback = true
    # event:comparison:cover
    Correspondence recorded.
    ~ owned_evidence += EvidenceId.girl_cover_correspondence
    ~ known_tags += (EvidenceTag.girl_coffin_motif, EvidenceTag.author_identity_reference, EvidenceTag.aurora_identity_reference)
    # event:grant_evidence:girl_cover_correspondence
    -> test_compare
+ {(owned_evidence ? EvidenceId.girl_signature_rubbing) && (owned_evidence ? EvidenceId.diary_cover)} [girl_signature_rubbing ↔ diary_cover]
    ~ links += Relation.cover
    ~ pending_relation_feedback = true
    # event:comparison:cover
    Correspondence recorded.
    ~ owned_evidence += EvidenceId.girl_cover_correspondence
    ~ known_tags += (EvidenceTag.girl_coffin_motif, EvidenceTag.author_identity_reference, EvidenceTag.aurora_identity_reference)
    # event:grant_evidence:girl_cover_correspondence
    -> test_compare
+ [Back] -> test_hub

=== test_radio_menu ===
Which marker would you like to ask about?
DEV: prepare evidence at the hub before starting. You cannot replace it during a call.

+ [The Small Human-Shaped Marker]
    ~ active_tomb = "baby"
    -> test_freeze_evidence

+ [The Crystal Monument]
    ~ active_tomb = "scholar"
    -> test_freeze_evidence

+ [The Sun-Shaped Monument]
    ~ active_tomb = "sun"
    -> test_freeze_evidence

+ [The White Infant Altar]
    ~ active_tomb = "altar"
    -> test_freeze_evidence

+ [The Small Stone Beside the Altar]
    ~ active_tomb = "mother"
    -> test_freeze_evidence

+ [The Other Stone Beside the Altar]
    ~ active_tomb = "father"
    -> test_freeze_evidence

+ {girl_revealed} [The Solitary Human-Shaped Marker]
    ~ active_tomb = "girl"
    -> test_freeze_evidence

+ [Back] -> test_hub

=== test_freeze_evidence ===
{pending_relation_feedback:
    ~ feedback_kind = "linked"
    ~ pending_relation_feedback = false
- else:
    ~ feedback_kind = ""
}
~ submitted_id = selected_id
~ submitted_tags = selected_tags
# event:radio_start
DEV: frozen evidence={submitted_id == "":none|{submitted_id}}.
{active_tomb == "baby": -> daybaby_tele}
{active_tomb == "scholar": -> test_radio_scholar}
{active_tomb == "sun": -> test_radio_sun}
{active_tomb == "altar": -> test_radio_altar}
{active_tomb == "mother": -> test_radio_mother}
{active_tomb == "father": -> test_radio_father}
{active_tomb == "girl" && girl_revealed: -> test_radio_girl}
-> test_hub

// PRESERVED AUTHOR SMALL-MARKER QUESTIONS, with added test-only branches.

=== daybaby_tele ===
-> test_radio_baby

=== test_baby_terms ===
+ {natural_reply_seen} [natural death]
    ~ causes += Cause.natural
    # event:collect_term:natural
    -> test_radio_baby
+ {owned_evidence ? EvidenceId.infant_death_doubt} [unexplained circumstances]
    ~ causes += Cause.unexplained
    # event:collect_term:unexplained death
    -> test_radio_baby
+ [Back] -> test_radio_baby

=== test_radio_scholar ===
# ui:radio_questions
-> test_menu_feedback ->
What would you like to ask?
+ {submitted_id == "repeated_beast_motifs"} [What does it mean when the same symbol keeps appearing?] -> test_answer_repeated_beast
+ {(links ? Relation.crystal)} [Why is the monument shaped like a crystal?] -> test_answer_scholar_8
+ {((links ? Relation.beast) || (owned_evidence ? EvidenceId.repeated_beast_motifs))} [What does the two-part creature mean?] -> test_answer_scholar_12
+ {1 == 1} [Did the cities ever cooperate?] -> test_answer_scholar_17
+ {submitted_id == "one_way_passage_order"} [Why can I go between the cities? Shouldn’t the gate have closed?] -> test_answer_scholar_passage_gate
+ {1 == 1} [Why is it in black and white?] -> test_answer_scholar_20
+ {1 == 1} [How could a picture be kept inside this crystal?] -> test_answer_scholar_25
+ {(1 == 1) && (has_tag(EvidenceTag.scholar_no_visitors))} [The Scholar seems reputable in the Day City. Why is her grave never visited by anyone else?] -> test_answer_scholar_31
+ {(1 == 1) && (has_tag(EvidenceTag.unexplained_waking_wounds)) && (read_answers ? AnswerId.scholar_25_supported_27)} [Did she cut her own skin to send the message?] -> test_answer_scholar_35
+ {(1 == 1) && (has_tag(EvidenceTag.missing_family_member_reference) || has_tag(EvidenceTag.four_person_family)) && (read_answers ? AnswerId.scholar_25_supported_27)} [You seem to have some personal feelings towards the Scholar.] -> test_answer_scholar_39
+ [Why did the Scholar never apply for the family mausoleum?] -> test_scholar_mausoleum
+ {((has_tag(EvidenceTag.dawn_disappearances) && ((read_answers ? AnswerId.scholar_12_supported_15) || (read_answers ? AnswerId.sun_13_supported_15))) || (hypothesis_open && (has_tag(EvidenceTag.skin_as_message_medium) || has_tag(EvidenceTag.paired_day_night_death))))} [Do you think the cause of disappearance aligns with what the Scholar has investigated?]
    ~ hypothesis_return = "scholar"
    -> test_disappearance_hypothesis
+ [Collect a word from this call] -> test_radio_terms_scholar
+ [End this call] -> test_end_call

=== test_radio_sun ===
# ui:radio_questions
-> test_menu_feedback ->
What would you like to ask?
+ {submitted_id == "repeated_beast_motifs"} [What does it mean when the same symbol keeps appearing?] -> test_answer_repeated_beast
+ {((links ? Relation.beast) || (owned_evidence ? EvidenceId.repeated_beast_motifs))} [What does the beast on this marker mean?] -> test_answer_sun_13
+ {(owned_evidence ? EvidenceId.shared_family_base)} [Do these three markers belong together?] -> test_answer_sun_17
+ {(1 == 1) && (has_tag(EvidenceTag.four_person_family) || has_tag(EvidenceTag.missing_family_member_reference))} [Which family member has no place on the base?] -> test_answer_sun_25
+ {((has_tag(EvidenceTag.dawn_disappearances) && ((read_answers ? AnswerId.scholar_12_supported_15) || (read_answers ? AnswerId.sun_13_supported_15))) || (hypothesis_open && (has_tag(EvidenceTag.skin_as_message_medium) || has_tag(EvidenceTag.paired_day_night_death))))} [Do you think the cause of disappearance aligns with what the Scholar has investigated?]
    ~ hypothesis_return = "sun"
    -> test_disappearance_hypothesis
+ {submitted_id == "family_photo"} [Who left the photo on the grave?] -> test_answer_sun_photo
+ [Collect a word from this call] -> test_radio_terms_sun
+ [End this call] -> test_end_call

=== test_radio_altar ===
# ui:radio_questions
-> test_menu_feedback ->
What would you like to ask?
+ {submitted_id == "altar_blessing_glyph"} [What does this repeated symbol mean?] -> test_answer_altar_8
+ {(links ? Relation.baby_pair)} [Is this the child from the small marker?] -> test_answer_altar_12
+ {1 == 1} [Are the moon-shaped stones coins?] -> test_answer_altar_16
+ {1 == 1} [What was removed from the empty recess?] -> test_answer_altar_20
+ {LIST_COUNT(queried_night_glyphs) == 5} [How can you translate a symbol from a culture without a written language?] -> test_answer_altar_24
+ {(1 == 1) && (has_tag(EvidenceTag.infant_appearance_mismatch) || has_tag(EvidenceTag.infant_actual_appearance))} [Was the child in the wrong city?] -> test_answer_altar_28
+ {owned_evidence ? EvidenceId.altar_path_rubbing} [What does the geometric border on the altar mean?]
    ~ glyph_return = "altar"
    -> query_night_unending_path
+ {(owned_evidence ? EvidenceId.crystal_god_rubbing) || (owned_evidence ? EvidenceId.night_father_god_rubbing)} [What does the angular figure represent?]
    ~ glyph_return = "altar"
    -> query_night_crystal_god
+ {(submitted_id == "altar_blessing_glyph") && (read_answers ? AnswerId.altar_8_supported_10)} [Why does the same blessing appear on all three graves?] -> test_answer_repeated_blessing
+ [Collect a word from this call] -> test_radio_terms_altar
+ [End this call] -> test_end_call

=== test_radio_mother ===
# ui:radio_questions
-> test_menu_feedback ->
What would you like to ask?
+ {(links ? Relation.mother_child)} [Who is the figure holding the child?] -> test_answer_mother_8
+ {((links ? Relation.river) || (queried_night_glyphs ? NightGlyph.dry_river))} [What does the dry river border tell us about her death?] -> test_answer_mother_12
+ {(links ? Relation.skin)} [Why does the handholding picture resemble the Scholar's?] -> test_answer_mother_17
+ {1 == 1} [Does the lack of offerings mean she was the last survivor?] -> test_answer_mother_21
+ {owned_evidence ? EvidenceId.night_mother_river_rubbing} [What does the geometric border on this stone mean?]
    ~ glyph_return = "mother"
    -> query_night_dry_river
+ {owned_evidence ? EvidenceId.night_mother_flower} [What does the painted flower mean?] -> test_answer_mother_flower
+ {submitted_id == "altar_blessing_glyph"} [What does this repeated symbol mean?] -> test_answer_altar_8
+ {(submitted_id == "altar_blessing_glyph") && (read_answers ? AnswerId.altar_8_supported_10)} [Why does the same blessing appear on all three graves?] -> test_answer_repeated_blessing
+ [Collect a word from this call] -> test_radio_terms_mother
+ [End this call] -> test_end_call

=== test_radio_father ===
# ui:radio_questions
-> test_menu_feedback ->
What would you like to ask?
+ {(links ? Relation.father_child)} [Who is carrying the child?] -> test_answer_father_8
+ {((links ? Relation.father_path) || (queried_night_glyphs ? NightGlyph.ascending_path))} [Did he die because the Skyway was dangerous?] -> test_answer_father_12
+ {has_tag(EvidenceTag.paired_day_night_death) || has_tag(EvidenceTag.husband_disappearance)} [Could his death be linked to the Scholar's husband?] -> test_answer_father_16
+ {1 == 1} [What does the moon-shaped offering mean?] -> test_answer_father_20
+ {(1 == 1) && (has_tag(EvidenceTag.natural_collapse) || has_tag(EvidenceTag.shared_day_night_history))} [Was the original separation really a natural disaster?] -> test_answer_father_24
+ {owned_evidence ? EvidenceId.night_father_path_rubbing} [What does the rising pattern along the border mean?]
    ~ glyph_return = "father"
    -> query_night_ascending_path
+ {(owned_evidence ? EvidenceId.crystal_god_rubbing) || (owned_evidence ? EvidenceId.night_father_god_rubbing)} [What does the angular figure represent?]
    ~ glyph_return = "father"
    -> query_night_crystal_god
+ {submitted_id == "altar_blessing_glyph"} [What does this repeated symbol mean?] -> test_answer_altar_8
+ {(submitted_id == "altar_blessing_glyph") && (read_answers ? AnswerId.altar_8_supported_10)} [Why does the same blessing appear on all three graves?] -> test_answer_repeated_blessing
+ [Collect a word from this call] -> test_radio_terms_father
+ [End this call] -> test_end_call

=== test_radio_girl ===
# ui:radio_questions
-> test_menu_feedback ->
What would you like to ask?
+ {submitted_id == "repeated_beast_motifs"} [What does it mean when the same symbol keeps appearing?] -> test_answer_repeated_beast
+ {(links ? Relation.coffin)} [What is the upright frame around her?] -> test_answer_girl_8
+ {1 == 1} [Who made this marker?] -> test_answer_girl_12
+ {(links ? Relation.family)} [Do the family sculpture and the photograph belong together?] -> test_answer_girl_16
+ {1 == 1} [Does disappearance always mean death?] -> test_answer_girl_20
+ {(1 == 1) && (has_tag(EvidenceTag.aurora_provided_object) || has_tag(EvidenceTag.aurora_identity_reference)) && ((links ? Relation.cover) || (owned_evidence ? EvidenceId.girl_cover_correspondence))} [Aurora, why is this girl on the notebook you gave me?] -> test_answer_girl_24
+ {(owned_evidence ? EvidenceId.girl_teddy_bear) && (owned_evidence ? EvidenceId.family_photo)} [Why is the toy bear in front of the solitary marker?] -> test_answer_girl_bear_preview
+ {(owned_evidence ? EvidenceId.girl_painted_flower) && know(EvidenceTag.mother_daughter_flower_meaning)} [What does the repeating pattern of the painted flower mean?] -> test_answer_girl_flower_preview
+ [Collect a word from this call] -> test_radio_terms_girl
+ [End this call] -> test_end_call

=== test_radio_terms_scholar ===
DEV: collect only words from answers you have already read.
+ {(read_answers ? AnswerId.scholar_8_supported_10)} [Scholar]
    ~ identities += Identity.scholar
    # event:collect_term:scholar
    -> test_radio_terms_scholar
+ {(read_answers ? AnswerId.scholar_12_supported_15)} [disappearance]
    ~ causes += Cause.disappearance
    # event:collect_term:disappearance
    -> test_radio_terms_scholar
+ [Back] -> test_radio_scholar

=== test_radio_terms_sun ===
DEV: collect only words from answers you have already read.
+ {(owned_evidence ? EvidenceId.profession_record)} [Tycoon]
    ~ identities += Identity.tycoon
    # event:collect_term:tycoon
    -> test_radio_terms_sun
+ {(read_answers ? AnswerId.sun_13_supported_15)} [disappearance]
    ~ causes += Cause.disappearance
    # event:collect_term:disappearance
    -> test_radio_terms_sun
+ [Back] -> test_radio_sun

=== test_radio_terms_altar ===
DEV: collect only words from answers you have already read.
+ {(queried_night_glyphs ? NightGlyph.unending_path) || (read_answers ? AnswerId.altar_8_supported_10) || (read_answers ? AnswerId.altar_12_supported_14)} [disappearance]
    ~ causes += Cause.disappearance
    # event:collect_term:disappearance
    -> test_radio_terms_altar
+ [Back] -> test_radio_altar

=== test_radio_terms_mother ===
DEV: collect only words from answers you have already read.
+ {(read_answers ? AnswerId.mother_8_supported_10)} [mother in Night City]
    ~ identities += Identity.night_mother
    # event:collect_term:night_mother
    -> test_radio_terms_mother
+ {(read_answers ? AnswerId.mother_12_supported_14)} [hunger and thirst]
    ~ causes += Cause.hunger_and_thirst
    # event:collect_term:thirst
    -> test_radio_terms_mother
+ [Back] -> test_radio_mother

=== test_radio_terms_father ===
DEV: collect only words from answers you have already read.
+ {(read_answers ? AnswerId.father_8_supported_10)} [father in Night City]
    ~ identities += Identity.night_father
    # event:collect_term:night_father
    -> test_radio_terms_father
+ {(read_answers ? AnswerId.father_12_supported_14)} [beyond the permitted waking hours]
    ~ causes += Cause.missed_sleeping_deadline
    # event:collect_term:missed_sleeping_deadline
    -> test_radio_terms_father
+ {(read_answers ? AnswerId.father_16_normal_17)} [disappearance]
    ~ causes += Cause.disappearance
    # event:collect_term:disappearance
    -> test_radio_terms_father
+ [Back] -> test_radio_father

=== test_radio_terms_girl ===
DEV: collect only words from answers you have already read.
+ {(read_answers ? AnswerId.girl_12_supported_14)} [funerary artist]
    ~ identities += Identity.funerary_artist
    # event:collect_term:funerary_artist
    -> test_radio_terms_girl
+ [Back] -> test_radio_girl

=== test_reports ===
Select a report. Candidates unlocked anywhere are available for every marker.

+ [The Small Human-Shaped Marker]
    ~ active_tomb = "baby"
    -> test_report_identity

+ [The Crystal Monument]
    ~ active_tomb = "scholar"
    -> test_report_identity

+ [The Sun-Shaped Monument]
    ~ active_tomb = "sun"
    -> test_report_identity

+ [The White Infant Altar]
    ~ active_tomb = "altar"
    -> test_report_identity

+ [The Small Stone Beside the Altar]
    ~ active_tomb = "mother"
    -> test_report_identity

+ [The Other Stone Beside the Altar]
    ~ active_tomb = "father"
    -> test_report_identity

+ {girl_revealed} [The Solitary Human-Shaped Marker]
    ~ active_tomb = "girl"
    -> test_report_identity

+ [Back] -> test_hub

=== test_report_identity ===
Choose an identity; unlocking it has not selected it for you.

+ {identities ? Identity.infant} [infant]
    ~ report_identity = Identity.infant
    -> test_report_cause

+ {identities ? Identity.scholar} [scholar]
    ~ report_identity = Identity.scholar
    -> test_report_cause

+ {identities ? Identity.tycoon} [tycoon]
    ~ report_identity = Identity.tycoon
    -> test_report_cause

+ {identities ? Identity.night_mother} [night_mother]
    ~ report_identity = Identity.night_mother
    -> test_report_cause

+ {identities ? Identity.night_father} [night_father]
    ~ report_identity = Identity.night_father
    -> test_report_cause

+ {identities ? Identity.funerary_artist} [funerary_artist]
    ~ report_identity = Identity.funerary_artist
    -> test_report_cause

+ {identities ? Identity.aurora} [aurora]
    ~ report_identity = Identity.aurora
    -> test_report_cause

+ [Cancel] -> test_hub

=== test_report_cause ===
Choose the recorded cause / fate.

+ {causes ? Cause.natural} [natural]
    ~ report_cause = Cause.natural
    -> test_report_check

+ {causes ? Cause.euthanasia} [Euthanasia]
    ~ report_cause = Cause.euthanasia
    -> test_report_check

+ {causes ? Cause.unexplained} [unexplained]
    ~ report_cause = Cause.unexplained
    -> test_report_check

+ {causes ? Cause.hunger_and_thirst} [hunger_and_thirst]
    ~ report_cause = Cause.hunger_and_thirst
    -> test_report_check

+ {causes ? Cause.disappearance} [disappearance]
    ~ report_cause = Cause.disappearance
    -> test_report_check

+ {causes ? Cause.missed_sleeping_deadline} [missed_sleeping_deadline]
    ~ report_cause = Cause.missed_sleeping_deadline
    -> test_report_check

+ {causes ? Cause.escape} [escape]
    ~ report_cause = Cause.escape
    -> test_report_check

+ [Cancel] -> test_hub

=== test_report_check ===
DEV: report={active_tomb}; identity={report_identity}; fate={report_cause}.
+ [Submit this report] -> test_report_validate
+ [Change the answer] -> test_report_identity
+ [Cancel] -> test_hub

=== test_report_validate ===

{active_tomb == "baby" && report_identity == Identity.infant && (report_cause == Cause.natural || report_cause == Cause.unexplained || report_cause == Cause.euthanasia):
    ~ completed_reports += TombId.baby
    # event:report_accepted:baby
    Report recorded. DEV acceptance is provisional and does not judge Aurora.

    -> test_hub
}

{active_tomb == "scholar" && report_identity == Identity.scholar && (report_cause == Cause.disappearance):
    ~ completed_reports += TombId.scholar
    # event:report_accepted:scholar
    Report recorded. DEV acceptance is provisional and does not judge Aurora.

    -> test_hub
}

{active_tomb == "sun" && report_identity == Identity.tycoon && (report_cause == Cause.disappearance):
    ~ completed_reports += TombId.sun
    # event:report_accepted:sun
    Report recorded. DEV acceptance is provisional and does not judge Aurora.

    -> test_hub
}

{active_tomb == "altar" && report_identity == Identity.infant && (report_cause == Cause.disappearance):
    ~ completed_reports += TombId.altar
    # event:report_accepted:altar
    Report recorded. DEV acceptance is provisional and does not judge Aurora.

    -> test_hub
}

{active_tomb == "mother" && report_identity == Identity.night_mother && (report_cause == Cause.hunger_and_thirst):
    ~ completed_reports += TombId.mother
    # event:report_accepted:mother
    Report recorded. DEV acceptance is provisional and does not judge Aurora.

    -> test_hub
}

{active_tomb == "father" && report_identity == Identity.night_father && (report_cause == Cause.missed_sleeping_deadline):
    ~ completed_reports += TombId.father
    # event:report_accepted:father
    Report recorded. DEV acceptance is provisional and does not judge Aurora.

    -> test_hub
}

{active_tomb == "girl" && (report_identity == Identity.aurora || report_identity == Identity.funerary_artist) && (report_cause == Cause.disappearance || report_cause == Cause.escape):
    {final_confronted:
        ~ completed_reports += TombId.girl
        # event:report_accepted:girl
        -> test_open_ending
    }
}
This test report is not yet supported. Check the identity, fate, and relevant evidence.
-> test_reports

=== test_bonus ===
// Dialogue source: 05_婴儿夜城祭坛!B13. Unlock after two accepted Day City reports AND two accepted Night City reports. Two bonus QUESTIONS, not an overall radio call limit.
(Her breathing steadies. She sounds ready to answer something larger than a single grave.) #narrator
You didn't expect a call from her. But she'd like to talk to you briefly. She wants this call to be brief, so you can only ask the two questions you’re most curious about. #aurora
DEV: bonus questions remaining {bonus_remaining}.
* {bonus_remaining > 0} [What are the Dayfolk and Nightfolk?]
    (She pauses once, then sets the explanation down plainly.) #narrator
    They have separate minds and take turns being awake. They share one living body. If one dies, the other cannot survive. The Dayfolk acted as if they could cut that dependence away. #aurora
    ~ bonus_remaining = bonus_remaining - 1
    -> test_bonus_check
* {bonus_remaining > 0} [Why do you know so much?]
    (A small silence falls across the name. She answers without decorating it.) #narrator
    (A small silence falls across the name. She answers without decorating it.) #narrator
    Aurora is a name. It does not tell you how many people are speaking, or how many points of view they have. It's never in your record. #aurora
    ~ bonus_remaining = bonus_remaining - 1
    -> test_bonus_check
* {bonus_remaining > 0} [What does disappearance mean?]
    (You hear a dry, almost amused breath. She chooses an example close to your own life.) #narrator
    Think of two people taking turns using one account. The account is closed. Neither can enter, but only one receives the notice. The other has no record of what happened. That is how something can die for one person and disappear for the other. #aurora
    ~ bonus_remaining = bonus_remaining - 1
    -> test_bonus_check
* {bonus_remaining > 0} [Were the two cities always enemies?]
    (Her answer begins firmly. A quieter note enters when she mentions the shared cemetery.) #narrator
    No. There was a cemetery where both peoples were buried together. You will not visit it on this trip. They did not always keep their graves separate, nor their residences. If you learn about cemeteries in human civilization, they are often the microcosm of a city's history of integration and segregation—cemeteries are the diorama of cities. #aurora
    ~ bonus_remaining = bonus_remaining - 1
    -> test_bonus_check
+ [Continue the investigation]
    ~ bonus_done = true
    -> test_hub

=== test_bonus_check ===
{bonus_remaining <= 0:
    ~ bonus_done = true
    (She lets out a quiet breath and brings the discussion back to the task.) #narrator
    I have to drop. See ya. #aurora
    -> test_hub
}
-> test_bonus

=== test_submit_all ===
The six investigation reports are ready. Submit them now?
+ [Submit]
    ~ reports_submitted = true
    # event:reports_submitted
    # music_phase:after_reports
    -> test_walk
+ [Keep investigating] -> test_hub

=== test_walk ===
# ui:notebook_cover
You close the investigation pages and plan your journey back. For a while, you look at the black-and-white cover.
All this time, the girl has been standing quietly inside her frame.
You carry the book with you as you walk. You witnessed the stones and the people they recorded, but you would never know how they truly lived.
Nothing can be changed. But something can be remembered.
That way feels longer than the way you came. You came with nothing, but now you are leaving with a civilization's weight.
The path extends to a single stone. Cold and lonely. Like one standing beside the street for a delayed bus to come.
It's a standing monument that belongs to neither the Day nor the Night.
~ girl_revealed = true
# event:reveal_girl_marker
-> test_desc_girl

=== test_confrontation ===
# feedback:gold
(The wind echoes through the city no one has returned to. It might be your imagination, but it feels colder now.) #narrator
(You can't tell. We keep losing memories at every moment. Words said in the last moment, a warm smile that you pass by a minute ago, and those fleeting and private feelings attached to them.) #narrator
“We feel, and all that we have felt is swept away in the bright tumult of the world.” #narrator
(You first read Goethe's poem An Lottchen from Zweig's The World of Yesterday, where he recounts the beautiful world before the war that strips us of our humanity.) #narrator
(It is only when you witness a collapse that you realize how fragile our established routines can be. You wonder whether…) #narrator
+ [The girl on the mark feels the same.] -> test_ending_reflect
+ [The Night girl in the diary feels the same.] -> test_ending_reflect
+ [Aurora feels the same.] -> test_ending_reflect

=== test_ending_reflect ===
(And they are one. One that shares the fate and memories of the civilization.) #narrator
(After some moments of solitude, you have to give Aurora a call. But before that, you might sort out your thoughts.) #narrator
What is the true reason of the civilization's fall? #narrator
+ [Night City does not have the concept of exchange]
    ~ ending_cause = 1
    -> test_ending_mothers_question
+ [The One-way Passage Order of the Day City]
    ~ ending_cause = 2
    -> test_ending_mothers_question
+ [The effect of ONE being perceived as TWO]
    ~ ending_cause = 3
    -> test_ending_mothers_question

=== test_ending_mothers_question ===
What did the mothers do to their daughter? #narrator
+ [They simply love them.] -> test_ending_day_call
+ [They hurt them.] -> test_ending_day_call
+ [Hard to conclude, it's not black or white.] -> test_ending_day_call

=== test_ending_day_call ===
(You have your attribution with you. They mark your judgment after days of investigation.) #narrator
(Nothing right or wrong. It's all about interpretations.) #narrator
(But what each of us called right became, in all our hands, a wrong no one could undo.) #narrator
Hi? #aurora
(A tentative greeting. As if it's the first time she's talking to you.) #narrator
(You may have captured a subtle sense of panic in her voice, as though that figure behind the husky voice is a lost teenage girl.) #narrator
I have completed my investigation thoroughly. #player
Good to hear. What else? #aurora
I have to ask you a few questions… that might be personal. #player
(A brief, unnatural pause on the other side. You are not sure whether the person on the other side feels unprepared for the moment or has prepared for too long.) #narrator
(Long enough to be accustomed to waiting. Long enough to believe that this moment will never come.) #narrator
Let me know your thoughts. #aurora
{ending_cause == 1:
I've found the reason that the Twins collapsed. It's Night City does not have the concept of exchange. #player
}
{ending_cause == 2:
I've found the reason that the Twins collapsed. It's The One-way Passage Order of the Day City. #player
}
{ending_cause == 3:
I've found the reason that the Twins collapsed. It's Inducing effect of ONE being perceived as TWO. #player
}
{ending_cause == 3:
That's what I thought as well. #aurora
- else:
Both of us know that it’s more than that. #aurora
}
That's too similar to us human beings. #player
We drew a line around ourselves and named it civilization. #player
We expelled those beyond the defined boundaries and sent them downriver on a ship of fools. #player
We watched it disappear, never knowing it carried our own flesh. #aurora
(She definitely knows what you are referring to. But you sense a more intimate implication beneath "flesh" as her word of choice.) #narrator
Disappointment in your fellow man, I understand. What about your blood relatives? #player
(You also left them alone, with no intention of salvage. You didn't speak that out. They were teenage girls. You can't blame them for not saving the world that now remains in yesterday.) #narrator
You knew it. #aurora
{(owned_evidence ? EvidenceId.girl_teddy_bear) && (owned_evidence ? EvidenceId.family_photo):
-> test_ending_day_bear
}
-> test_ending_day_guilt

=== test_ending_day_bear ===
She left your toy at the marker you made before you escaped. #player
+ [She was worried about you.] -> test_ending_day_bear_qualify
+ [She came out to find you.] -> test_ending_day_bear_qualify
+ [She loved you.] -> test_ending_day_bear_qualify

=== test_ending_day_bear_qualify ===
+ [Despite the injustice she was complicit in.] -> test_ending_day_guilt
+ [Though you don't have to forgive her.] -> test_ending_day_guilt
+ [Though we all regret something that cannot be reversed.] -> test_ending_day_guilt

=== test_ending_day_guilt ===
You sent me here to make up for your guilt, but… #player
+ [I can recover nothing but facts you mostly already know.] -> test_ending_day_earth
+ [You have to face that by yourself.] -> test_ending_day_earth
+ [A witness has no ability to resolve the knots for someone who experienced all this.] -> test_ending_day_earth

=== test_ending_day_earth ===
(If things happened 50 years ago, you should now be speaking to an old lady that used to live on this planet.) #narrator
(A teenage girl thought that escaping would solve the entire problem. Yet when she's really light-years away from her homeland and dozens of years from the home in her memories, time suddenly becomes a counting unit that loses its tangibility.) #narrator
(The girl was stuck in the past that she was once determined to abandon.) #narrator
I can't remember the day when the Earth first visited the Twins. I was found by the aliens. By then, I knew not a single word of human language, but I knew they wanted to pick us up. #aurora
We were relying on food in the Day City and in the wild. Those days were more about surviving than living. I pointed to the sleeping coffin. They understood, and we were both fetched to Earth. #aurora
Every day before my day ends, I write her a note on my thoughts and my progress in communicating with the people. Together, we learnt the human language. #aurora
So you never did anything together? #player
We can't. We are the closest friends that never met each other. That's the limitation the Twins were born with. #aurora
The archaeologists were friendly to us. But "friendly" is a different word to "friend". To my shame, I started to miss the people that I once deemed as stubborn, harsh and cruel, and most importantly, hypocritical, the trait that I do not want myself to fall into the most. #aurora
Neither of us can step out of the specially designed space adapted to our physical condition. Nothing is too different from our years of straying on the Twins. #aurora
We were sharing the same flesh—not only the Day and the Night. Also my people and I. As they were lost, I'm lost, too. #aurora
Have you ever been given a chance to come back? #player
(If they can travel that far to Earth and stay alive for years, they should be able to return. But they sent you as the delegate. There is a deeper reason that stopped her from looking back.) #narrator
I always have the choice. The researchers ask us from time to time. It was me that did not want to look back. #aurora
+ [Because your health cannot support a journey this long?] -> test_ending_day_return_1
+ [Because you are busy?] -> test_ending_day_return_2
+ [Because of your guilt?] -> test_ending_day_return_3

=== test_ending_day_return_1 ===
To my surprise, I'm still quite healthy given my age and my living in a different environment. #aurora
-> test_ending_day_dream

=== test_ending_day_return_2 ===
Time is the thing that I possess the most to waste. #aurora
-> test_ending_day_dream

=== test_ending_day_return_3 ===
… #aurora
-> test_ending_day_dream

=== test_ending_day_dream ===
It took me quite a while to understand "dream" in human language. Dayfolk viewed sleep as a rehearsal of death because we totally lose our consciousness when we fall asleep in the sleeping coffin. That's when our night counterparts fully deploy our life for the other part of a day. #aurora
Then one day, after a day of conversation with the researchers, I was recalling the past details so intensely that I once again saw the familiar faces at night. #aurora
It was the first time I witnessed how dark a long night can be, and the first time her appearance became so clear that I recognized her at first sight. #aurora
She was younger than the woman I had in mind. The night was so dark that it blurred her look. But it's already the clearest out of that vast pool of memories across time. #aurora
I said hi. Not sure if she responded. Perhaps deep in my consciousness I still had her voice, but I cannot frame it into a sound that I could match with her—the Scholar, or rather, my mother. #aurora
She passed me the toy, smiling. She didn’t smile that much. She always looked worried. Day City is a place where everyone uses something to exchange for another, like my parents' marriage, like her education to me. That time she gave me a toy. First gift ever, not again. #aurora
I woke up the next morning with tears on my cheeks. It's the first and last time that I understood what it means to have a dream. #aurora
For years I've been anticipating another dream. Yet what I got were nights of complete silence. It was after the night I heard the whisper of the breeze on that remote star which I've never returned to that I felt the emptiness in that solitary silence. #aurora
+ [You missed her.] -> test_ending_day_empathy
+ [You loved her.] -> test_ending_day_empathy

=== test_ending_day_empathy ===
+ [But you don't have to look back.] -> test_ending_day_empathy_finish
+ [You should allow yourself to preserve those emotions.] -> test_ending_day_empathy_finish
+ [You might follow your heart to visit her again.] -> test_ending_day_empathy_finish

=== test_ending_day_empathy_finish ===
+ [Even if she did not love you in the way you want.] -> test_ending_day_goodbye
+ [Even if she is not perfect.] -> test_ending_day_goodbye
+ [That's the complexity we have to embrace.] -> test_ending_day_goodbye

=== test_ending_day_goodbye ===
(You feel that tremor in your limbs again, with fear and a little bit of anticipation for her response.) #narrator
(For a while, she says nothing. You hear only the buzzing sound mixing with the wind.) #narrator
(The wind gets stronger. The night is about to come. Then you hear sobbing on the other side.) #narrator
(She hangs up without a goodbye. You keep the receiver to your ear. That beeping sound speaks for her struggles.) #narrator
(You sit until the moon rises, randomly thinking about your decisions if you were in their situation.) #narrator
(You suppose you know the answers. But as always, they remain assumptions that change nothing. You call again.) #narrator
+ [Call again.] -> test_ending_night_start

=== test_ending_night_start ===
# city:night
I read her note. I know what you are calling for. #aurora
+ [Perhaps I know more than you thought.] -> test_ending_night_note
+ [But I still hope you can stay for the chat.] -> test_ending_night_note

=== test_ending_night_note ===
She's more sensitive than I am. Oversensitive. The guilt is torturing her all the time. Poor… #aurora
(She swallowed the last word. A sudden realization that time passed.) #narrator
+ [Poor Aurora.] -> test_ending_night_escape
+ [Poor Girl.] -> test_ending_night_escape

=== test_ending_night_escape ===
That hard decision was made when you were girls, definitely. #player
(She chuckled to herself.) #narrator
Nothing hard for me. If I hadn't escaped, I would be locked in the underworld by the one-way passage. #aurora
+ [But you had the choice to take your mother.] -> test_ending_night_mother
+ [But you had an option to stay for your people.] -> test_ending_night_mother

=== test_ending_night_mother ===
We've been talking for a while. You should know I don't care for someone who cares nothing about me. #aurora
(You spot slight reluctance towards the end of the sentence.) #narrator
{(owned_evidence ? EvidenceId.girl_painted_flower) && know(EvidenceTag.mother_daughter_flower_meaning):
I found a unique icon of a flower on your mother's stone, which repeats on your solitary marker. You told me that it is a symbol of love that is one of a kind, only between the two of you. Who left it there? #player
(Her voice is back to that sober tone, but with slight shivering hidden beneath.) #narrator
I left it there. My mother has never come to the ground since my brother's disappearance. #aurora
This doesn’t mean I love her. I just feel pity that no one else is going to understand its meaning after her. Let the stone remember it beyond my mother or myself. #aurora
She remembered that icon before her death. It was left on her tombstone. #player
… #aurora
(Silence. ) #narrator
}
(Night Aurora drained herself to learn and survive. She had to pretend to be strong, to act as though none of the sacrifices had left a mark. Only then could she tell herself it had been worth leaving.) #narrator
+ [It can still hurt. That doesn’t mean it wasn’t worth leaving.] -> test_ending_night_question
+ [Admitting love does not conflict with your need to escape.] -> test_ending_night_question
+ [You do not have to put yourself in opposition to your mom to justify your choice.] -> test_ending_night_question

=== test_ending_night_question ===
(She responded with an undisturbed voice.) #narrator
If you were me, how would you feel about my escape? #aurora
+ [Honestly, I can never feel personally the ignorance you've been through, but I know it's tough.] -> test_ending_night_empathy
+ [You were not making the wrong choice. I might make similar choices.] -> test_ending_night_empathy
+ [It's a brave choice. We are born with attachments, which are so difficult to break.] -> test_ending_night_empathy

=== test_ending_night_empathy ===
+ [But no matter how I choose, my feelings do not prove your feelings to be wrong.] -> test_ending_night_childhood
+ [You don't need my answer to make yourself an individual worthy of others' empathy.] -> test_ending_night_childhood

=== test_ending_night_childhood ===
(A long sigh comes from the other side.) #narrator
Nightfolk do not have a language. We have no order, no social construct, nothing other than digging for survival. #aurora
We have icons. Some of them have a meaning that is agreed upon. Most of them remain between closely related individuals. #aurora
We Nightfolk have bad eyesight. When I was a child, I put a flower discreetly on my mother's head. It was loosely tied to the ends of her hair. When she was back, the flower was still there. She never noticed it. #aurora
I was laughing. She had a grin after me. The next day I put a flower in her hair again. Every day. Until one day I joined the working group and found that there was no way she could come back with that flower every day after that kind of rigorous labor. #aurora
We never specifically define that icon. It's never painted, delivered as a letter, or conveyed like a wish that was featured on my brother's stone. It is a meaning that was never described. #aurora
What I felt was only anger. I felt angry when my brother rested in her arms. I felt angry when she was standing on the altar and the group was singing the same hymn. #aurora
I lost her when she became the godmother of our people. She no longer worked, and she took off the flower every day when she was preparing herself for the morning prayer. #aurora
She decided to take off that unique icon just between us. The glossy son became her only child, a divine body that carried her flesh. I am nothing related to her. #aurora
I thought escaping without her would free me from that attachment. I learnt language from Day City. I started to describe my feelings via the letters to the other Aurora, but I still could not describe my feelings towards my mother. #aurora
Until I reached the human world and encountered that word again as “love.” #aurora
(She stopped her narration with a breath of relief.) #narrator
If so, are you coming back one day? #player
I may. #aurora
(No promise. No decision. But you opened up a possibility of returning home.) #narrator
(She said goodbye, and the radio never calls back.) #narrator
-> test_ending_finish

=== test_ending_finish ===
~ final_confronted = true
{not (seen_subtexts ? Subtext.final):
    ~ seen_subtexts += Subtext.final
    ~ subtext_count += 1
}
~ identities += Identity.aurora
~ causes += Cause.escape
# event:collect_term:aurora
# event:collect_term:escape
# event:aurora_confronted
-> test_open_ending

=== test_open_ending ===
(You are not sure if the Day Aurora will call back when the night ends. But you look to the horizon, and see a beautiful light shine from the back of the solitary stone.) #narrator
(No matter what—on Earth or these obsolete cities. Tomorrow the sun will rise.) #narrator
# event:open_ending
-> END

=== test_preview_scholar_no_traces ===
# ui:open_evidence:scholar_no_traces
Across the checked period after the burial, the searchlight reveals no readable traces of later visits to the crystal monument. This absence alone does not establish why nobody returned.
+ [Back] -> test_hub

=== test_answer_baby_8 ===
# question_id:baby_8
{has_tag(EvidenceTag.moon_motif) || has_tag(EvidenceTag.moon_reference):
Yes, it does look like a moon. I suppose sleep is the closest rehearsal the living have for death. When night falls, the Dayfolk slip into slumber. On this marker, the moon stands for <link="natural">natural death</link>. #aurora
~ read_answers += AnswerId.baby_8_normal_9
~ feedback_kind = "linked"
- else:
{not ((read_answers ? AnswerId.baby_8_normal_9) && has_tag(EvidenceTag.infant_actual_appearance)):
The outline is a starting point. Show me your comparison with the moon, and we can ask what it meant to the Dayfolk. #aurora
~ feedback_kind = "unmatched"
}
}
{has_tag(EvidenceTag.infant_actual_appearance):
# feedback:gold
(The warmth in her voice draws back. For a moment, the grain of the transmission is clearer than her breathing.) #narrator
The moon offers a peaceful ending, but that is the story the family chose to put in stone. If the child's real face was left out, perhaps there were <link="unexplained death">unexplained circumstances</link> behind his death. Let us keep looking. #aurora
~ read_answers += AnswerId.baby_8_additional_10
~ owned_evidence += EvidenceId.infant_death_doubt
~ known_tags += (EvidenceTag.infant_death_unresolved, EvidenceTag.infant_appearance_mismatch)
# event:grant_evidence:infant_death_doubt
{not (seen_subtexts ? Subtext.baby_8_additional):
    ~ seen_subtexts += Subtext.baby_8_additional
    ~ subtext_count += 1
}
~ feedback_kind = "hidden"
}
-> test_radio_baby

=== test_answer_baby_17 ===
# question_id:baby_17
~ temp supported = false
{(read_answers ? AnswerId.baby_17_comparison) && submitted_id == "designer_manuscript":
Before we ask why, perhaps we should ask why not. Day City remembers a life through its work. This <link="infant">child</link> was the first to die without an identifiable occupation. So the designer gave him something no title was needed for: the shape of a person. #aurora
("A child without an occupation is a person before anything else,” you were reminded of the quote from the manuscript. Despite the punchline, or slogan that speaks to everyone else but the infant, can he really separate from the social influence?) #narrator
~ read_answers += AnswerId.baby_17_supported_19
~ supported = true
~ feedback_kind = "linked"
}
{submitted_id == "dayfolk_appearance":
Yes, this is an icon for the Dayfolk. Have you found a designer's manuscript that explains why this marker was shaped like a person? #aurora
~ read_answers += AnswerId.baby_17_comparison
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
Compare the rubbing with the figure in the cemetery. What do the two shapes have in common? #aurora
~ read_answers += AnswerId.baby_17_normal_13
~ feedback_kind = "unmatched"
}
-> test_radio_baby

=== test_answer_baby_21 ===
// Author draft: 婴儿小碑 C19. Hidden question has no ordinary runtime branch.
// (She repeats your word under her breath. “Real.” The channel carries the faint shape of a question she never asked, or a story she never told.)
//
// I wonder which face you mean by 'real', {player_name}: the one the family remembered, or the one their story could not make room for. We should find something firmer than hearsay before we choose between them.
# question_id:baby_21
# feedback:gold
I cannot tell you who drew it, {player_name}. Perhaps someone had grown tired of seeing the same approved face carved over every life that did not fit. #aurora
(She seems to have personal feelings about this topic.) #narrator
~ read_answers += AnswerId.baby_21_hidden_23
{not (seen_subtexts ? Subtext.baby_21):
    ~ seen_subtexts += Subtext.baby_21
    ~ subtext_count += 1
}
~ feedback_kind = "hidden"
-> test_radio_baby

=== test_radio_baby ===
# ui:radio_questions
-> test_menu_feedback ->
What would you like to ask?
+ {(links ? Relation.moon)} [How do we interpret the icon on the tombstone?] -> test_answer_baby_8
+ {(owned_evidence ? EvidenceId.infant_figure_rubbing)} [Why is the tombstone shaped like a person?] -> test_answer_baby_17
+ {(1 == 1) && (has_tag(EvidenceTag.infant_actual_appearance))} [Who drew the child's real appearance?] -> test_answer_baby_21
+ [Collect a word from this call] -> test_radio_terms_baby
+ [End this call] -> test_end_call

=== test_answer_scholar_8 ===
# question_id:scholar_8
~ temp supported = false
{has_tag(EvidenceTag.crystal_shape) || has_tag(EvidenceTag.crystal_research_reference):
(Pride enters her voice so briefly that you cannot tell whose it is.) #narrator
As the manuscript says, they gave her the title <link="scholar">Scholar</link> when she discovered what the crystal could do. Her stone remembers that work in the very material she studied—the work she was truly proud of. #aurora
(You can't help thinking back to the moment when you first saw the crystal in the Night City. Unlike its transparency in the Day City, the enigmatic darkness draws you in and makes you wonder how these beautiful stones changed Day and Night.) #narrator
~ read_answers += AnswerId.scholar_8_supported_10
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
The crystal had a history before it became a memorial. {player_name}, find its mineral counterpart, or the record of the work it made possible. #aurora
~ read_answers += AnswerId.scholar_8_normal_9
~ feedback_kind = "unmatched"
}
-> test_radio_scholar

=== test_answer_repeated_beast ===
# feedback:gold
(She goes quiet long enough for you to hear the wind at your end of the call.) #narrator
On one stone, a creature might have belonged to a single life. When it keeps turning up on graves that have nothing else in common, I start to wonder what the whole city needed a way to say. #aurora
Look for a pattern like that in Night City. If the same sign turns up on several graves there, ask yourself what those people kept leaving for one another. They may have had something quite different to say. #aurora
~ read_answers += AnswerId.repeated_beast_hidden
~ feedback_kind = "hidden"
{active_tomb == "scholar": -> test_radio_scholar}
{active_tomb == "sun": -> test_radio_sun}
-> test_radio_girl

=== test_answer_scholar_12 ===
# question_id:scholar_12
~ temp supported = false
{has_tag(EvidenceTag.ancient_disappearance):
(The last word of the old account seems to hold her for a moment. She lets it go slowly.) #narrator
The old account says the creature vanished in a single night. These little figures seem to carry that absence from stone to stone. They record <link="disappearance">disappearance</link>. You may find other traces of what disappearance meant for the Dayfolk. #aurora
~ read_answers += AnswerId.scholar_12_supported_15
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
(A faint click interrupts her breath. She waits until the channel is quiet before answering.) #narrator
A familiar shape can travel from grave to grave without telling us its name. Look for the creature beyond these stones, {player_name}. Perhaps a trace of it—or the same icon returning again and again. #aurora
~ read_answers += AnswerId.scholar_12_normal_13
~ feedback_kind = "unmatched"
}
-> test_radio_scholar

=== test_answer_scholar_17 ===
# question_id:scholar_17
~ temp supported = false
{has_tag(EvidenceTag.night_city_mineral_origin) || has_tag(EvidenceTag.intercity_resource_exchange):
(Something opens in her voice. For a second, the distance between the two cities seems to shrink with it.) #narrator
This is an important step. Food went down; crystal came up. For a long while, each city worked to produce something the other needed. The stone has kept a little of that old dependence — though there is still insufficient evidence to establish whether they shared any aspect of life. #aurora
~ read_answers += AnswerId.scholar_17_supported_19
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
I would be careful about asking a single stone to speak for two cities. We need some evidence that passed between them. #aurora
~ read_answers += AnswerId.scholar_17_normal_18
~ feedback_kind = "unmatched"
}
-> test_radio_scholar

=== test_answer_scholar_passage_gate ===
# feedback:gold
(A small pause. You hear something click on her end of the line.) #narrator
The gate was meant to close behind anyone going down. Its crystal power supply ran for far longer than it was designed to. The mechanism failed years ago, with the gate open. That’s how you’ve been able to cross in both directions. #aurora
~ read_answers += AnswerId.scholar_passage_gate_hidden
~ feedback_kind = "hidden"
-> test_radio_scholar

=== test_answer_scholar_20 ===
# question_id:scholar_20
(The answer comes quickly. Too quickly, perhaps. Then her voice finds its usual unhurried rhythm.) #narrator
I cannot speak for her. But I believe she must have discovered something about the world she lived in. Some truth she could not leave out of her own memorial. Your notebook is black and white for a reason, too. #aurora
(You look at your notebook once again. One double-page spread accommodating two contrasting halves. Does it signal a kind of coexistence, or a history of segregation?) #narrator
~ read_answers += AnswerId.scholar_20_normal_21
~ feedback_kind = ""
-> test_radio_scholar

=== test_answer_scholar_25 ===
# question_id:scholar_25
~ temp supported = false
{has_tag(EvidenceTag.skin_as_message_medium) || has_tag(EvidenceTag.day_night_handholding):
(The name of neither city comes easily. A tiny catch in her breathing survives the distance intact.) #narrator
A Dayfolk and a Nightfolk, hand in hand... I never expected her to be so cruel to herself. #aurora
~ read_answers += AnswerId.scholar_25_supported_27
~ supported = true
~ feedback_kind = "linked"
{know(EvidenceTag.unexplained_waking_wounds):
~ owned_evidence += EvidenceId.paired_skin_pictures
~ known_tags += (EvidenceTag.day_night_handholding, EvidenceTag.skin_as_message_medium, EvidenceTag.unexplained_waking_wounds, EvidenceTag.shared_body_reference)
# event:grant_evidence:paired_skin_pictures
}
}
{not supported:
I cannot make out the picture, but I am fairly sure that fragment is skin — from past research, we know that the Dayfolk have blue blood, and some of it remains on the fragment. Try the searchlight. Take it back to a time before it decayed, before we decide what it was trying to say. #aurora
~ read_answers += AnswerId.scholar_25_normal_26
~ feedback_kind = "unmatched"
}
-> test_radio_scholar

=== test_answer_scholar_31 ===
# question_id:scholar_31
# feedback:gold
(For a long while, only the thin electrical hum reaches you. Then a breath catches, and leaves her in a long, uneven sigh. You cannot see her, but for once the distance fails to conceal how much the question has touched her.) #narrator
…or there is no one left to remember her. I made that decision. I made that decision... #aurora
~ read_answers += AnswerId.scholar_31_hidden_33
{not (seen_subtexts ? Subtext.scholar_31):
    ~ seen_subtexts += Subtext.scholar_31
    ~ subtext_count += 1
}
~ feedback_kind = "hidden"
-> test_radio_scholar

=== test_answer_scholar_35 ===
# question_id:scholar_35
# feedback:gold
(The static swells around her silence. You hear the beginning of a word, then a slow breath. When she speaks again, she has chosen each word with care.) #narrator
You are perceptive. Dayfolk and Nightfolk share one life. A wound left on one body is still there when the other wakes. Few people discovered they could send a message that way. Most called the injuries Nightfolk retaliation. The misunderstanding only widened the divide between the cities. #aurora
~ read_answers += AnswerId.scholar_35_hidden_37
~ owned_evidence += EvidenceId.paired_skin_pictures
~ known_tags += (EvidenceTag.day_night_handholding, EvidenceTag.skin_as_message_medium, EvidenceTag.unexplained_waking_wounds, EvidenceTag.shared_body_reference)
# event:grant_evidence:paired_skin_pictures
{not (seen_subtexts ? Subtext.scholar_35):
    ~ seen_subtexts += Subtext.scholar_35
    ~ subtext_count += 1
}
~ feedback_kind = "hidden"
-> test_radio_scholar

=== test_answer_scholar_39 ===
# question_id:scholar_39
# feedback:gold
(A small intake of breath. When she answers, the warmth has returned a little too neatly, like a blanket pulled over something that is still moving.) #narrator
I imagine anyone would be moved, {player_name}. To make your own skin carry a message—well. We need not have known her to feel that. Shall we return to the investigation? #aurora
~ read_answers += AnswerId.scholar_39_hidden_41
{not (seen_subtexts ? Subtext.scholar_39):
    ~ seen_subtexts += Subtext.scholar_39
    ~ subtext_count += 1
}
~ feedback_kind = "hidden"
-> test_radio_scholar

=== test_answer_sun_13 ===
# question_id:sun_13
~ temp supported = false
{has_tag(EvidenceTag.ancient_disappearance):
So many stones have borrowed the same creature. Its vanishing in the old account gives the carving its meaning: <link="disappearance">disappearance</link>. An image left behind where a life cannot be found. #aurora
~ read_answers += AnswerId.sun_13_supported_15
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
The creature keeps returning, doesn't it? Let us give it a name before we give it a meaning. What does the old account say? #aurora
(Perhaps use your tools to observe those markers again.) #narrator
~ read_answers += AnswerId.sun_13_normal_14
~ feedback_kind = "unmatched"
}
-> test_radio_sun

=== test_answer_sun_17 ===
# question_id:sun_17
~ temp supported = false
{has_tag(EvidenceTag.shared_family_plot) || has_tag(EvidenceTag.three_family_markers):
(She exhales, quietly pleased. The next sentence comes without hesitation.) #narrator
Yes. One unbroken base carries all three. They belong to the same family plot. The stone has kept them together, even after their stories parted. #aurora
~ read_answers += AnswerId.sun_17_supported_19
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
(A soft tap reaches you through the line. She answers with the patient rhythm of someone guiding a hand along an edge.) #narrator
Look beneath their feet. A family resemblance may be written in the stone they stand on. Are their bases truly joined? #aurora
~ read_answers += AnswerId.sun_17_normal_18
~ feedback_kind = "unmatched"
}
-> test_radio_sun

=== test_answer_sun_photo ===
{sun_photo_asked:
...I have nothing to tell. #aurora
- else:
She left it. #aurora
(The answer comes before the question has quite left the channel. Then there is a silence just long enough for you to hear what slipped through.) #narrator
I have to go. Goodbye. #aurora
# radio:hang_up
~ sun_photo_asked = true
}
-> test_radio_sun

=== test_answer_sun_25 ===
# question_id:sun_25
# feedback:gold
(Silence. Only the buzzing sound reminds you that the call is not interrupted.) #narrator
Someone was still there after the others were gone. I wonder whether the family left a place for her, or whether she had already begun to leave it herself. #aurora
~ read_answers += AnswerId.sun_25_hidden_27
{not (seen_subtexts ? Subtext.sun_25):
    ~ seen_subtexts += Subtext.sun_25
    ~ subtext_count += 1
}
~ feedback_kind = "hidden"
-> test_radio_sun

=== test_answer_altar_8 ===
# question_id:altar_8
~ temp supported = false
{submitted_id == "altar_blessing_glyph":
It is a blessing: “To disappear is to set out on a journey without end. May the wishes of crystal remain with you.” It wishes the departed well. #aurora
~ queried_night_glyphs += NightGlyph.blessing
# event:night_symbol_queried:blessing
~ read_answers += AnswerId.altar_8_supported_10
~ supported = true
~ feedback_kind = "hidden"
~ owned_evidence += EvidenceId.altar_blessing_translation
~ known_tags += (EvidenceTag.night_blessing_glyph, EvidenceTag.night_symbol_translation, EvidenceTag.endless_path_motif, EvidenceTag.aurora_translation_knowledge)
# event:grant_evidence:altar_blessing_translation
}
{not supported:
Photograph the same sign on all three graves first. Bring me that record, and I can read it for you. #aurora
~ read_answers += AnswerId.altar_8_normal_9
~ feedback_kind = "unmatched"
}
{active_tomb == "mother": -> test_radio_mother}
{active_tomb == "father": -> test_radio_father}
-> test_radio_altar

=== test_answer_altar_12 ===
# question_id:altar_12
~ temp supported = false
{has_tag(EvidenceTag.infant_memorial) || has_tag(EvidenceTag.paired_day_night_memorials):
(She speaks in an undisturbed tone.) #narrator
Day City records a death. Night City records a <link="disappearance">disappearance</link>. That difference does not mean there were two children. Check the figures together. #aurora
~ read_answers += AnswerId.altar_12_supported_14
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
Compare the figures first, then we'll see. #aurora
~ read_answers += AnswerId.altar_12_normal_13
~ feedback_kind = "unmatched"
}
-> test_radio_altar

=== test_answer_altar_16 ===
# question_id:altar_16
~ temp supported = false
{has_tag(EvidenceTag.moon_stone_offering):
Not everything can be interpreted with a modern mindset, and not all offerings are intended for commercial exchange. These are blessings given by the Nightfolk. #aurora
~ read_answers += AnswerId.altar_16_supported_18
~ supported = true
~ feedback_kind = "linked"
~ owned_evidence += EvidenceId.moon_stone_blessing
~ known_tags += (EvidenceTag.moon_stone_offering, EvidenceTag.night_blessing_reference, EvidenceTag.different_exchange_customs)
# event:grant_evidence:moon_stone_blessing
}
{not supported:
Show me the stones first. #aurora
~ read_answers += AnswerId.altar_16_normal_17
~ feedback_kind = "unmatched"
}
-> test_radio_altar

=== test_answer_altar_20 ===
# question_id:altar_20
~ temp supported = false
{has_tag(EvidenceTag.removed_crystal_offering) || has_tag(EvidenceTag.crystal_extraction_reference):
(Her voice tightens around the missing object, then settles back into its usual level register.) #narrator
The Crystal God stood there intact. The crystals were later pried out. Day City needed crystal, but I cannot prove they did it. For now, you can take this as a provisional argument. #aurora
~ read_answers += AnswerId.altar_20_supported_22
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
Use the searchlight on the empty recess. We need to see what was there. #aurora
~ read_answers += AnswerId.altar_20_normal_21
~ feedback_kind = "unmatched"
}
-> test_radio_altar

=== test_answer_altar_24 ===
# question_id:altar_24
# feedback:gold
(The silence lasts just a fraction longer than the question seems to need. Her reply is direct.) #narrator
A symbol can be remembered without a written language. Someone who used it could pass on its meaning. I am not working from books alone. #aurora
~ read_answers += AnswerId.altar_24_hidden_26
{not (seen_subtexts ? Subtext.altar_24):
    ~ seen_subtexts += Subtext.altar_24
    ~ subtext_count += 1
}
~ feedback_kind = "hidden"
-> test_radio_altar

=== test_answer_altar_28 ===
# question_id:altar_28
# feedback:gold
Check the division first. If it was wrong, 'born in the wrong city' may be the wrong question. Keep the two memorials together. #aurora
(Her voice stops abruptly. The night spills around you, with barely a sound. You start to think about how the Day City looked, and your call with Aurora then.) #narrator
(It's different, definitely. Two worlds overlap in the dimension of time.) #narrator
(Was it "wrong"? Or is it just a glimpse through the overlap?) #narrator
~ read_answers += AnswerId.altar_28_hidden_30
{not (seen_subtexts ? Subtext.altar_28):
    ~ seen_subtexts += Subtext.altar_28
    ~ subtext_count += 1
}
~ feedback_kind = "hidden"
-> test_radio_altar

=== test_answer_mother_8 ===
# question_id:mother_8
~ temp supported = false
{has_tag(EvidenceTag.parent_child_image) || has_tag(EvidenceTag.night_mother_past):
(For one word, the bluntness gives way to something gentler. Then it is gone.) #narrator
That is the altar infant. The figure is his <link="night_mother">mother in Night City</link>. #aurora
~ read_answers += AnswerId.mother_8_supported_10
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
(A quiet intake of breath. She answers before it has quite left her.) #narrator
Compare the child with the altar infant. That will tell us who she was holding. #aurora
~ read_answers += AnswerId.mother_8_normal_9
~ feedback_kind = "unmatched"
}
-> test_radio_mother

=== test_answer_mother_12 ===
# question_id:mother_12
~ temp supported = false
{submitted_id == "dry_underground_river" || has_tag(EvidenceTag.water_source_lost):
(The first word sounds choked up. She takes another breath and continues.) #narrator
The border matches the dry riverbed. It records <link="thirst">hunger and thirst</link> as her cause of death. #aurora
~ read_answers += AnswerId.mother_12_supported_14
~ supported = true
~ feedback_kind = "linked"
~ owned_evidence += EvidenceId.night_mother_death_finding
~ known_tags += (EvidenceTag.night_mother_death_reference, EvidenceTag.death_by_hunger_and_thirst, EvidenceTag.water_source_lost)
# event:grant_evidence:night_mother_death_finding
}
{not supported:
(Her answer comes after a single, deliberate beat.) #narrator
The symbol means a dry river. Check the actual riverbed or the records of lost water before we conclude that she died of hunger and thirst. #aurora
~ read_answers += AnswerId.mother_12_normal_13
~ feedback_kind = "unmatched"
}
-> test_radio_mother

=== test_answer_mother_17 ===
# question_id:mother_17
~ temp supported = false
{has_tag(EvidenceTag.shared_body_reference):
The wounds carried over when the other person woke. A mark on the shared body could carry a message between them. #aurora
~ read_answers += AnswerId.mother_17_supported_19
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
The pictures match. But the medium is unknown. #aurora
~ read_answers += AnswerId.mother_17_normal_18
~ feedback_kind = "unmatched"
}
-> test_radio_mother

=== test_answer_mother_21 ===
# question_id:mother_21
~ temp supported = false
{has_tag(EvidenceTag.absence_of_readable_traces) || has_tag(EvidenceTag.last_survivor_question) && submitted_id == "night_mother_no_traces":
(The hiss of the open line grows suddenly loud. Her answer returns without its usual firmness.) #narrator
No sign of anyone returning. She may have been the last. I used to think she would only notice me if I went missing too. I left. I never found out whether she did. #aurora
~ read_answers += AnswerId.mother_21_supported_23
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
One empty scan is not enough. Check the period after her burial. #aurora
~ read_answers += AnswerId.mother_21_normal_22
~ feedback_kind = "unmatched"
}
-> test_radio_mother

=== test_answer_mother_flower ===
# question_id:mother_flower
{has_tag(EvidenceTag.night_mother_flower_trace):
(She is quiet long enough for the static to return. When she speaks, she leaves no space between the short sentences.) #narrator
A flower. A mother and daughter drew it for each other when the girl was small. It meant "I love you." Just between them. #aurora
It is not a blessing used throughout Night City. This one belonged to those two people. #aurora
~ owned_evidence += EvidenceId.mother_daughter_flower_meaning
~ known_tags += EvidenceTag.mother_daughter_flower_meaning
# event:grant_evidence:mother_daughter_flower_meaning
~ read_answers += AnswerId.mother_flower_supported
~ feedback_kind = "linked"
- else:
Show me the flower the searchlight recovered. We should not assume that every painted mark is a funerary symbol. #aurora
~ read_answers += AnswerId.mother_flower_normal
~ feedback_kind = "unmatched"
}
-> test_radio_mother

=== test_answer_father_8 ===
# question_id:father_8
~ temp supported = false
{has_tag(EvidenceTag.parent_child_image) || has_tag(EvidenceTag.night_father_past):
(She starts to answer, stops, then swallows close to the microphone. The second attempt is steady.) #narrator
The same child. Look at the way he is held. The man carrying him is his <link="night_father">father in Night City</link>. #aurora
~ read_answers += AnswerId.father_8_supported_10
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
Match the child with the altar figure before you name the parent. #aurora
~ read_answers += AnswerId.father_8_normal_9
~ feedback_kind = "unmatched"
}
-> test_radio_father

=== test_answer_father_12 ===
# question_id:father_12
~ temp supported = false
{has_tag(EvidenceTag.skyway_not_steep) || has_tag(EvidenceTag.missed_sleeping_deadline):
The path was uneven, but it was not a dangerous climb. He kept searching <link="missed_sleeping_deadline">beyond the permitted waking hours</link> and failed to reach a sleeping coffin in time. #aurora
~ read_answers += AnswerId.father_12_supported_14
~ supported = true
~ feedback_kind = "linked"
~ owned_evidence += EvidenceId.night_father_death
~ known_tags += (EvidenceTag.sleep_coffin_required, EvidenceTag.missed_sleeping_deadline, EvidenceTag.night_father_final_journey, EvidenceTag.paired_day_night_death)
# event:grant_evidence:night_father_death
}
{not supported:
Check the actual path or its history. An upward line does not show how steep it was. #aurora
~ read_answers += AnswerId.father_12_normal_13
~ feedback_kind = "unmatched"
}
-> test_radio_father

=== test_answer_father_16 ===
# question_id:father_16
~ temp supported = false
{has_tag(EvidenceTag.paired_day_night_death):
One dies. The other disappears at dawn. Check whether these are two records of one life. #aurora
~ read_answers += AnswerId.father_16_supported_18
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
Bring the Scholar's <link="disappearance">disappearance</link> report. We need the time her husband vanished. #aurora
~ read_answers += AnswerId.father_16_normal_17
~ feedback_kind = "unmatched"
}
-> test_radio_father

=== test_answer_father_20 ===
# question_id:father_20
~ temp supported = false
{has_tag(EvidenceTag.moon_stone_offering) || has_tag(EvidenceTag.night_blessing_reference):
It is a blessing for the person who left. Nobody was paying for the path. #aurora
~ read_answers += AnswerId.father_20_supported_22
~ supported = true
~ feedback_kind = "linked"
~ owned_evidence += EvidenceId.moon_stone_blessing
~ known_tags += (EvidenceTag.moon_stone_offering, EvidenceTag.night_blessing_reference, EvidenceTag.different_exchange_customs)
# event:grant_evidence:moon_stone_blessing
}
{not supported:
Record the stone. Compare it with the altar offerings. #aurora
~ read_answers += AnswerId.father_20_normal_21
~ feedback_kind = "unmatched"
}
-> test_radio_father

=== test_answer_father_24 ===
# question_id:father_24
# feedback:gold
(There is no hesitation in the first sentence. She slows down only to mark the limits of what you know.) #narrator
The history calls it natural. Shared coffins weaken the claim that there was no room. They do not prove who caused the collapse. We need separate evidence for that. #aurora
~ read_answers += AnswerId.father_24_hidden_26
{not (seen_subtexts ? Subtext.father_24):
    ~ seen_subtexts += Subtext.father_24
    ~ subtext_count += 1
}
~ feedback_kind = "hidden"
-> test_radio_father

=== test_answer_girl_8 ===
# question_id:girl_8
~ temp supported = false
{has_tag(EvidenceTag.upright_coffin_motif) || has_tag(EvidenceTag.shared_day_night_history):
An upright sleeping coffin, just like the old illustration. A change in how people slept can leave a surprisingly long shadow. #aurora
~ read_answers += AnswerId.girl_8_supported_10
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
That frame has an older history than the girl inside it. Let us look for its shape in the book. #aurora
~ read_answers += AnswerId.girl_8_normal_9
~ feedback_kind = "unmatched"
}
-> test_radio_girl

=== test_answer_girl_12 ===
# question_id:girl_12
~ temp supported = false
{has_tag(EvidenceTag.funerary_artist_reference):
(For a moment, the sentence seems to cost her more than it should.) #narrator
The diary writer carved memorials and came to question the stories they were asked to preserve. She was a <link="funerary_artist">funerary artist</link>. Perhaps this was the one stone she could finally let speak for herself. #aurora
~ read_answers += AnswerId.girl_12_supported_14
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
A human shape can stand for many lives. Her work may have left a clearer signature in the diary. #aurora
~ read_answers += AnswerId.girl_12_normal_13
~ feedback_kind = "unmatched"
}
-> test_radio_girl

=== test_answer_girl_16 ===
# question_id:girl_16
~ temp supported = false
{has_tag(EvidenceTag.family_image_reference) || has_tag(EvidenceTag.four_person_family):
(A breath shivers against the microphone. When she speaks, the composure is there, but thinner.) #narrator
The four figures match the family photograph. Three markers share a base; the girl’s marker stands apart. The sculpture and photograph let us identify the same family across the two sites. #aurora
~ read_answers += AnswerId.girl_16_supported_18
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
(There is a small break in the rhythm of her breathing. She asks you to compare the figures with unusual care.) #narrator
Let us put the four little figures beside the four faces. We should know the family before we name its missing place. #aurora
~ read_answers += AnswerId.girl_16_normal_17
~ feedback_kind = "unmatched"
}
-> test_radio_girl

=== test_answer_girl_20 ===
# question_id:girl_20
~ temp supported = false
{has_tag(EvidenceTag.deliberate_departure) || has_tag(EvidenceTag.two_mothers_dilemma):
(She draws out the first word, then presses the rest into an even rhythm. You hear how much work the evenness takes.) #narrator
The diary gives the two girls different reasons to leave. One could no longer bear what her mother defended. The other had spent years waiting to be noticed, first beside her brother, then beside the space he left. Their departure was deliberate. A memorial can mark an absence without proving a death. #aurora
~ read_answers += AnswerId.girl_20_supported_22
~ supported = true
~ feedback_kind = "linked"
}
{not supported:
(The silence feels less like thought than resistance. You wait until it gives way.) #narrator
Read what she meant to do. A stone can remember an absence without knowing where the person went. #aurora
~ read_answers += AnswerId.girl_20_normal_21
~ feedback_kind = "unmatched"
}
-> test_radio_girl

=== test_answer_girl_24 ===
# question_id:girl_24
You are about to ask Aurora about the girl on the cover. Are you ready to begin the final conversation? #narrator
+ [Begin the final conversation.] -> test_confrontation
+ [Keep investigating.] -> test_radio_girl

=== test_radio_terms_baby ===
DEV: collect only words from answers you have already read.
+ {(read_answers ? AnswerId.baby_8_normal_9)} [natural death]
    ~ causes += Cause.natural
    # event:collect_term:natural
    -> test_radio_terms_baby
+ {(read_answers ? AnswerId.baby_8_additional_10)} [unexplained circumstances]
    ~ causes += Cause.unexplained
    # event:collect_term:unexplained death
    -> test_radio_terms_baby
+ [Back] -> test_radio_baby

=== test_menu_feedback ===
{feedback_kind == "": ->->}
# ui:question_feedback
~ temp pick = RANDOM(0,3)
{feedback_kind == "unmatched":
# feedback_mode:unmatched
{active_tomb == "altar" || active_tomb == "mother" || active_tomb == "father":
{pick == 0:
Not yet. Check the scene for a closer match. #aurora
}
{pick == 1:
We do not have enough to connect those. Try another piece of evidence. #aurora
}
{pick == 2:
Check the shape again. We need a match we can point to. #aurora
}
{pick == 3:
Keep looking. We can return to the question when you find something. #aurora
}
- else:
{active_tomb == "baby":
~ temp baby_pick = RANDOM(0,2)
{baby_pick == 0:
Keep looking, {player_name}. There is still a missing piece between the question and the stone. #aurora
}
{baby_pick == 1:
For now, let the stones have the next word. They may tell you what I cannot yet. #aurora
}
{baby_pick == 2:
{player_name}, leave a little room for the next discovery. We can return to this when you find a match. #aurora
}
- else:
{pick == 0:
Perhaps another look at the scene will give us the missing piece. #aurora
}
{pick == 1:
I wonder whether those two shapes are telling the same story. Let us look a little closer. #aurora
}
{pick == 2:
We can leave that question open, {player_name}. Something nearby may give it a firmer footing. #aurora
}
{pick == 3:
There is still a little space between what we see and what we know. Have another look. #aurora
}
}
}
}
{feedback_kind == "linked":
# feedback_mode:linked
{active_tomb == "altar" || active_tomb == "mother" || active_tomb == "father":
{pick == 0:
Yes. Those match. Record the connection. #aurora
}
{pick == 1:
Good. That link is supported. #aurora
}
{pick == 2:
That fits what you found. Keep going. #aurora
}
{pick == 3:
You have the connection. Put it in the notebook. #aurora
}
- else:
{pick == 0:
Yes, that fits. One piece has found its place. #aurora
}
{pick == 1:
That is a careful connection, {player_name}. Keep it in your notes. #aurora
}
{pick == 2:
We have a little more of the picture now. You saw that well. #aurora
}
{pick == 3:
The pattern is clearer now. Let us hold on to that connection. #aurora
}
}
}
{feedback_kind == "hidden":
# feedback_mode:hidden
# feedback:gold
{active_tomb == "altar" || active_tomb == "mother" || active_tomb == "father":
{pick == 0:
That was the right question. Keep the answer. #aurora
}
{pick == 1:
You had a reason to ask. Now we know more. #aurora
}
{pick == 2:
Good. That tells us something the inscription did not. #aurora
}
{pick == 3:
That answer matters. Make a note of it. #aurora
}
- else:
{pick == 0:
You were right to ask. There is more here than the inscription can hold. #aurora
}
{pick == 1:
That was worth following, {player_name}. Let us keep the answer. #aurora
}
{pick == 2:
A good question. We have reached something the stone left unsaid. #aurora
}
{pick == 3:
I'm glad you followed that thread. We can leave it open a little longer. #aurora
}
}
}
~ feedback_kind = ""
->->

=== test_end_call ===
~ temp pick = RANDOM(0,3)
{active_tomb == "altar" || active_tomb == "mother" || active_tomb == "father":
{pick == 0:
All right. Call when you have more. #aurora
}
{pick == 1:
Go on. I'll keep the channel open. #aurora
}
{pick == 2:
We can stop here. Talk to you later. #aurora
}
{pick == 3:
Understood. Keep your notes. We'll continue later. #aurora
}
- else:
{pick == 0:
I'll leave you with the stones for a while. Call when you are ready. #aurora
}
{pick == 1:
Go on, {player_name}. There may be another piece waiting nearby. #aurora
}
{pick == 2:
Let us leave the page open. We can return to it. #aurora
}
{pick == 3:
Until later. I'll be here when you have something to share. #aurora
}
}
# event:radio_end
~ feedback_kind = ""
-> test_hub

=== test_scholar_mausoleum ===
{submitted_id == "profession_record":
I didn't know she had the privilege of doing so, yet she never did. She was someone who valued reputation and recognition; she lived her life in the prescribed mold of a successful Dayfolk. But she never mentioned the mausoleum again. Why? #aurora
(The next line is so faint that it sounds like a whisper to herself.) #narrator
She might be feeling as guilty as… #aurora
(The last few words disperse in the humming sound.) #narrator
~ feedback_kind = "linked"
- else:
I'm not sure whether the Scholar is eligible… Have you found any evidence related to that? #aurora
~ feedback_kind = "unmatched"
}
-> test_radio_scholar

=== test_disappearance_hypothesis ===
{has_tag(EvidenceTag.dawn_disappearances):
    ~ hypothesis_open = true
}
{has_tag(EvidenceTag.skin_as_message_medium):
    ~ hypothesis_skin = true
}
{has_tag(EvidenceTag.paired_day_night_death):
    ~ hypothesis_death = true
}
{hypothesis_skin && hypothesis_death:
You seem to know the link between disappearance and death, which proves the Scholar's speculation wrong. You know much more than I do. I want to know: #player
-> test_disappearance_followups
- else:
{hypothesis_skin:
You saw that conflict — the Scholar ended up using skin as a medium to convey a message, proving her initial conclusion that the scars were caused by the Nightfolk wrong. This does not directly prove her conclusion about disappearance wrong, but I would encourage you to investigate along this thread. #aurora
(You can feel the strong implication behind her words. It feels like she knows everything but is still toying with you. You wonder if she will tell you where she's from and what she has done.) #narrator
- else:
The Dayfolk often get stuck in their own understanding of the world. You may want to find more conflicts between the world they firmly believe in and the actual world around us. #aurora
}
~ feedback_kind = "hidden"
-> test_disappearance_return
}

=== test_disappearance_followups ===
* [What is the exact rule that governs disappearance and death across the cities?]
    They have separate minds and take turns being awake. They share one living body. If one dies, the other cannot survive. What one city records as death, the other may record as disappearance. #aurora
    -> test_disappearance_followups
* [Who are you?]
    (Her voice fractures, just like the world you are standing in, a world that belongs to yesterday.) #narrator
    I am someone who belongs to this place, yet something stops me from going back. #aurora
    -> test_disappearance_followups
+ [Return to the questions]
    ~ feedback_kind = "hidden"
    -> test_disappearance_return

=== test_disappearance_return ===
{hypothesis_return == "scholar": -> test_radio_scholar}
-> test_radio_sun


=== query_night_unending_path ===
# question_id:query_night_unending_path
It means an unending journey: someone left and did not return. On a memorial, it records <link="disappearance">disappearance</link>. It does not tell us what happened to that person. #aurora
~ queried_night_glyphs += NightGlyph.unending_path
# event:night_symbol_queried:unending_path
~ feedback_kind = "linked"
-> return_night_glyph

=== query_night_dry_river ===
# question_id:query_night_dry_river
It represents a river that has run dry. That is the meaning of the symbol. Whether it describes this place, a loss of water, or the circumstances of her death needs further evidence. #aurora
~ queried_night_glyphs += NightGlyph.dry_river
# event:night_symbol_queried:dry_river
~ feedback_kind = "linked"
-> return_night_glyph

=== query_night_ascending_path ===
# question_id:query_night_ascending_path
A path leading upward, toward the surface. It records a journey. It does not tell us how steep the path was or why the traveller died. #aurora
~ queried_night_glyphs += NightGlyph.ascending_path
# event:night_symbol_queried:ascending_path
~ feedback_kind = "linked"
-> return_night_glyph

=== query_night_crystal_god ===
# question_id:query_night_crystal_god
The Crystal God. It marks faith in the deity. The same figure can appear on an altar or a personal memorial; its presence alone does not tell us who removed the crystals. #aurora
~ queried_night_glyphs += NightGlyph.crystal_god
# event:night_symbol_queried:crystal_god
~ feedback_kind = "linked"
-> return_night_glyph

=== return_night_glyph ===
{glyph_return == "mother": -> test_radio_mother}
{glyph_return == "father": -> test_radio_father}
-> test_radio_altar

=== test_answer_girl_bear_preview ===
{has_tag(EvidenceTag.girl_teddy_bear_trace) || submitted_id == "family_photo":
(You almost asked that question, but deep down, you know why it’s here.) #narrator
(You decided not to ask this way.) #narrator
Anything else? #aurora
- else:
I'm not sure what you are talking about. #aurora
}
~ feedback_kind = ""
-> test_radio_girl

=== test_answer_girl_flower_preview ===
{has_tag(EvidenceTag.girl_painted_flower_trace) || submitted_id == "mother_daughter_flower_meaning":
(If your guess is correct, she might not know. You decided to keep this question for later.) #narrator
Anything else? #aurora
- else:
I'm confused. #aurora
}
~ feedback_kind = ""
-> test_radio_girl

=== ending_false ===
// Source: dialogue backfill workbook, 假结局.
(You close the notebook. For a moment your thumb rests in the seam between the black and the white.) #narrator
(You have the odd feeling that you have been to this city before. This is like all the cities that you've encountered before. Nothing less. Nothing more.) #narrator
(You picked up Aurora's call.) #narrator
I have it. Thank you. You must be tired. #aurora
Can I ask you something before you go? Did anyone ever come back to the cemetery? #aurora
There were traces of visitors. I couldn’t tell you who they came for. #player
I see. And did you find anything on your way out? #aurora
Just the way back. #player
(She gives a little laugh. You recognize the sound. She made it the first time you told her you’d landed safely.) #narrator
Of course. Have a safe journey home. #aurora
(You wait for her to say she’ll speak to you again. The radio clicks. You put it away.) #narrator
(You walk the same way you came. Your footprints are still there. You find it reassuring that there is something here you can recognize at a glance.) #narrator
(A few steps later, you hear her question again. Did you find anything? There was a small lift in her voice on the last word. You had mistaken it for the courtesy of someone letting you finish.) #narrator
(You recognize that sound now. Someone has spent a long time imagining the answer. You wonder what she had hoped you would say.) #narrator
(Perhaps there were stories you passed close enough to touch. Every day people pass that close to you. They go home, turn on a light, and forget they ever saw you. You have done the same to them.) #narrator
(There was a first morning on this planet, and there was a last one anyone woke up to see. For a little while, between those mornings, people knew who they were waiting for.) #narrator
(At the ship, you find yourself trying to remember a stone from the planet. It is strange that you miss something that doesn't really relate to your life.) #narrator
(Tomorrow the sun will rise. You start to think whether you left any coffee in your cup before you left. You hope there is no flies landing in it, or worse, hope it doesn’t stink.) #narrator
(For a while the radio could still reach her. You leave it beside you and watch the Twins recede. First time you really see the planet from far, in a nicely divided black and white. You are in awe of that spectacular scene.) #narrator
(Years from now, you may remember that you once knew someone named Aurora. You may even remember that she was waiting for something, but that's it. By then, the world she carried will have slipped as far into your memory as it now slips into the dark, wild universe.) #narrator
-> END

=== test_answer_repeated_blessing ===
# question_id:repeated_blessing
A shared blessing. It appears on graves of different people because it belongs to a custom, not to one person. #aurora
The Nightfolk wish the departed well. The same sign, left again and again, makes that wish something the whole city can recognise. #aurora
~ feedback_kind = "hidden"
{active_tomb == "mother": -> test_radio_mother}
{active_tomb == "father": -> test_radio_father}
-> test_radio_altar
