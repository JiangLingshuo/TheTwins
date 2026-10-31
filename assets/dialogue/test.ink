// TWINS - STANDALONE LINKAGE TEST
// Source: 墓碑表.xlsx; newer author instructions and current evidence tags override stale cells.
// English dialogue is a test draft, not final production copy.
// Existing telecomm prose is preserved below. Only control flow is adapted.
// Do NOT INCLUDE telecomm_master.ink or tombstone_master.ink: their test copies live here.
// Evidence IDs/tags and DEV previews are generated from the current evidence_master.ink.
// Rebuild/sync these snapshots when changing source evidence tags or prose.
INCLUDE evidence_master.ink

LIST EvidenceId = dayfolk_appearance, moon_reference, infant_figure_rubbing, infant_moon_rubbing, designer_manuscript, designer_journal, infant_graffiti, infant_death_doubt, shared_family_base, crystal_marker_rubbing, scholar_beast_rubbing, night_city_crystal, skin_picture, disappearance_inquiry, profession_record, one_way_passage_order, sun_reference, sun_shaped_marker_rubbing, sun_shaped_beast_rubbing, day_city_coin, ram_spirit_emblem, giant_footprint, twin_beast_trace, twin_beast_account, repeated_beast_motifs, family_photo, altar_infant_rubbing, altar_path_rubbing, altar_blessing_glyph, altar_blessing_translation, crystal_god_rubbing, removed_crystal_god, altar_moon_stone, crystal_god_prophecy, moon_stone_blessing, infant_memorial_correspondence, night_mother_child_rubbing, night_mother_hands_rubbing, night_mother_river_rubbing, dry_underground_river, night_mother_no_traces, night_mother_death_finding, night_father_child_rubbing, night_father_path_rubbing, night_father_god_rubbing, night_father_moon_stone, natural_collapse_record, skyway_history, skyway_reference, night_father_death, paired_skin_pictures, girl_figure_rubbing, girl_coffin_rubbing, girl_beast_rubbing, girl_path_rubbing, girl_signature_rubbing, family_statuette, day_city_history, history_coffin_illustration, girl_diary, diary_cover, notebook_cover, four_person_family_finding, girl_cover_correspondence

LIST EvidenceTag = absence_of_readable_traces, ancient_creature_trace, ancient_disappearance, ascending_path_motif, aurora_identity_reference, aurora_provided_object, aurora_translation_knowledge, author_identity_reference, contradictory_death_accounts, contrasting_halves, crystal_extraction_reference, crystal_god_motif, crystal_research_reference, crystal_shape, dawn_disappearances, day_city_belief, day_city_bias, day_city_currency, day_night_handholding, dayfolk_appearance, death_by_hunger_and_thirst, deliberate_departure, different_exchange_customs, disappearance_symbol_reference, dry_river_motif, endless_path_motif, family_image_reference, family_mausoleum_custom, family_requested_depiction, four_person_family, funerary_artist_reference, girl_coffin_motif, girl_memorial, human_figure_reference, husband_disappearance, infant_actual_appearance, infant_appearance_mismatch, infant_death_unresolved, infant_identity, infant_memorial, intercity_resource_exchange, last_survivor_question, missed_sleeping_deadline, missing_family_member_reference, moon_motif, moon_reference, moon_stone_offering, mother_remembers_daughter, natural_collapse, night_blessing_glyph, night_blessing_reference, night_city_belief, night_city_mineral_origin, night_city_supply_blockade, night_departure_reference, night_father_final_journey, night_father_past, night_infant_reference, night_mother_death_reference, night_mother_future, night_mother_past, night_symbol_translation, occupation_marker_custom, one_way_passage, original_separation, paired_day_night_death, paired_day_night_memorials, parent_child_image, population_decline, ram_spirit_motif, removed_crystal_offering, repeated_local_symbol, resentment_toward_mother, scholar_identity, scholar_tycoon_marriage, shared_body_reference, shared_day_night_history, shared_family_plot, skin_as_message_medium, skyway_not_steep, sleep_coffin_required, smooth_skinned_child, sun_motif, sun_shape, three_family_markers, twin_beast_motif, twin_beast_reference, two_mothers_dilemma, tycoon_identity, unexplained_waking_wounds, upright_coffin_motif, water_source_lost, well_preserved_diary

LIST TombId = baby, scholar, sun, altar, mother, father, girl

LIST Identity = infant, student, scholar, tycoon, night_mother, night_father, funerary_artist, aurora

LIST Cause = natural, unexplained, hunger_and_thirst, disappearance, missed_sleeping_deadline, escape

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
VAR collected_words = ()
VAR report_identity = ()
VAR report_cause = ()
VAR completed_reports = ()
VAR links = ()
LIST Subtext = baby_drawer, baby_shared, scholar_skin, sun_missing, altar_translation, altar_child, mother_message, father_history, final
VAR seen_subtexts = ()
VAR subtext_count = 0
VAR reports_submitted = false
VAR girl_revealed = false
VAR final_confronted = false
VAR searchlight_year = 2050
VAR scan_2005 = false
VAR scan_2050 = false
VAR bonus_remaining = 2
VAR bonus_done = false
VAR return_after_terms = "hub"
VAR natural_reply_seen = false
-> test_start

=== function has_tag(tag) ===
~ return submitted_tags ? tag

=== function know(tag) ===
~ return known_tags ? tag

=== test_start ===
DEV: Twins dialogue / evidence linkage test.
Choose a source evidence, then contact Aurora. One evidence is frozen for the whole call.
-> test_hub

=== test_hub ===
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

===opening===
//Write your name on the notebook cover, then flip through a few pages. Dialogue: tag the speaker; narration: no tag.

Oh, my notebook’s in black and white.#player
Aurora never told me why. I guess it’s an aesthetic choice.#player
...#??
...Hello? Can you hear me?#??
Aurora? Is that you? The connection’s finally back. I’ve landed safely on Twins.#player
Glad you’re safe! I hope the trip wasn’t too rough. Have you had a chance to look through your handbook?#aurora
Yeah, I was just looking at it. Interesting color scheme.#player
There’s a reason for it. Seen from space, Twins is a planet in black and white... Just like the civilization that once lived there.#aurora
Should I expect to meet anyone here?#player
No, but you’ll find their traces—a fallen civilization of two cities. Our archaeologists have searched their libraries, their homes, their schools. All the places where they lived. But there’s one place they overlooked.#aurora
Where?#player
Where they remembered the dead. The cemeteries. That’s your mission: to uncover what words alone cannot tell us, through the memories they left behind.#aurora
We don’t have much transmission time left. I have to go. Talk to you later.#aurora

(Now it’s just you, your handbook, and the faint breath of the planet.)
(You feel a tremor in your limbs.)
(You stand up. The faint breeze brushing past your ears feels much like the wind back home. Perhaps the people who once lived here weren’t so different from you, either.)
(You’re here to gather their memories. Your steps grow steadier.)
(Then you see it: the place where an entire civilization rests.)

//Show the cemetery scene.
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
// Source: 01_婴儿小碑!C12; latest description keeps the moon interpretation unconfirmed.
# type:tombstone
# tombstone_id:baby
# location:day_cemetery
# title:The Small Human-Shaped Marker
A small human-shaped marker, as thin as a page of stone. A curved decoration is carved into its surface. Its base continues beneath two other monuments.
+ [Contact Aurora about this marker]
    ~ active_tomb = "baby"
    -> test_freeze_evidence
+ [Back to the cemetery] -> test_hub

=== test_desc_scholar ===
// Source: 02_学者晶石碑!B8,C11; searchlight reveals the skin, not a high-precision camera.
# type:tombstone
# tombstone_id:scholar
# location:day_cemetery
# title:The Crystal Monument
The black-and-white crystal catches a faint light. Beneath a carved creature, a thin fragment is sealed inside. Something seems to be drawn on it.
+ [Contact Aurora about this marker]
    ~ active_tomb = "scholar"
    -> test_freeze_evidence
+ [Back to the cemetery] -> test_hub

=== test_desc_sun ===
// Source: 03_大亨金钱碑!C12; latest instruction replaces coin-like naming with sun-shaped.
# type:tombstone
# tombstone_id:sun
# location:day_cemetery
# title:The Sun-Shaped Monument
Radiating points surround a small creature whose two halves look entirely different. The stone base beneath it extends to join two other markers.
+ [Contact Aurora about this marker]
    ~ active_tomb = "sun"
    -> test_freeze_evidence
+ [Back to the cemetery] -> test_hub

=== test_desc_altar ===
// Source: 05_婴儿夜城祭坛!B8,C12.
# type:tombstone
# tombstone_id:altar
# location:night_cemetery
# title:The White Infant Altar
A grand, house-shaped memorial draws the eye in the cramped underground cemetery. An infant rests upon its white stone platform. An unending path runs along its pillars; a recess below stands empty.
+ [Contact Aurora about this marker]
    ~ active_tomb = "altar"
    -> test_freeze_evidence
+ [Back to the cemetery] -> test_hub

=== test_desc_mother ===
// Source: 06_夜母石碑!B8,B11; identity is not named before investigation.
# type:tombstone
# tombstone_id:mother
# location:night_cemetery
# title:The Small Stone Beside the Altar
An unassuming stone stands beside the great altar. Geometric pictures cover its face: a figure with a child above, two figures reaching toward each other below, and cracked lines around the edge.
+ [Contact Aurora about this marker]
    ~ active_tomb = "mother"
    -> test_freeze_evidence
+ [Back to the cemetery] -> test_hub

=== test_desc_father ===
// Source: 07_夜父石碑!B8,B13.
# type:tombstone
# tombstone_id:father
# location:night_cemetery
# title:The Other Stone Beside the Altar
Another modest stone stands on the other side of the altar. A figure carries a child above a crystal-like figure. Along the border, a smaller figure climbs an upward path.
+ [Contact Aurora about this marker]
    ~ active_tomb = "father"
    -> test_freeze_evidence
+ [Back to the cemetery] -> test_hub

=== test_desc_girl ===
// Source: 04_小女孩终局碑!B8,C12; appearance does not identify Aurora by itself.
# type:tombstone
# tombstone_id:girl
# location:cemetery_edge
# title:The Solitary Human-Shaped Marker
Another human figure stands within a frame of pale stone. She seems older than the child on the small marker. A two-part creature and an unending path decorate the frame. The stone is embedded too deeply to measure its thickness.
+ [Contact Aurora about this marker]
    ~ active_tomb = "girl"
    -> test_freeze_evidence
+ [Back to the cemetery] -> test_hub

=== test_library ===
DEV ONLY: force-grant a source record and read its current preview. This bypasses scene and story gates.
Findings are not ordinary pickups; use this menu only to inspect or reproduce a branch.

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
    ~ known_tags += (EvidenceTag.four_person_family, EvidenceTag.family_image_reference, EvidenceTag.mother_remembers_daughter)
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
    ~ known_tags += (EvidenceTag.four_person_family, EvidenceTag.missing_family_member_reference, EvidenceTag.mother_remembers_daughter)
    # event:grant_evidence:four_person_family_finding
    -> test_preview_four_person_family_finding

+ [girl_cover_correspondence — The Same Girl on Stone and Paper]
    ~ owned_evidence += EvidenceId.girl_cover_correspondence
    ~ known_tags += (EvidenceTag.girl_coffin_motif, EvidenceTag.author_identity_reference, EvidenceTag.aurora_identity_reference)
    # event:grant_evidence:girl_cover_correspondence
    -> test_preview_girl_cover_correspondence

+ [Back] -> test_hub

=== test_preview_dayfolk_appearance ===
// DEV preview copied from ev_dayfolk_appearance; use an independent evidence reader in production.
# ui:open_evidence:dayfolk_appearance
The figure has a smooth face and the familiar outline of the Dayfolk. Its features offer a reference for the human-shaped marker.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_moon_reference ===
// DEV preview copied from ev_moon_reference; use an independent evidence reader in production.
# ui:open_evidence:moon_reference
A pale crescent is visible above the cemetery. Its outline resembles the curved decoration on the small marker, although it is not quite the shape of Earth's moon.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_infant_figure_rubbing ===
// DEV preview copied from ev_infant_figure_rubbing; use an independent evidence reader in production.
# ui:open_evidence:infant_figure_rubbing
The marker takes the shape of a person rather than the tools of an occupation. Its face follows the smooth appearance of the Dayfolk.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_infant_moon_rubbing ===
// DEV preview copied from ev_infant_moon_rubbing; use an independent evidence reader in production.
# ui:open_evidence:infant_moon_rubbing
A curved shape is carved into the small marker. The rubbing preserves its outline for comparison with the surrounding world.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_designer_manuscript ===
// DEV preview copied from ev_designer_manuscript; use an independent evidence reader in production.
# ui:open_evidence:designer_manuscript
A translated copy of designer manuscript
Our cemetery usually represents a person through an icon of their occupation. This burial is different: the deceased is an <link="infant">infant</link> who had not yet been assigned an occupation. None of the existing designs would do.

The family asked us not to define the child by work he had never begun. We chose a human figure instead. The child had no occupation, but he was still a person.

"A child without an occupation is a person before anything else."
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_designer_journal ===
// DEV preview copied from ev_designer_journal; use an independent evidence reader in production.
# ui:open_evidence:designer_journal
My <link="student">student</link> visited me with urgency. She showed me a photo of the actual appearance of the infant. I was stunned as I never saw a dayfolk that was born like this. She asked me to design the tombstone with his real appearance, so that he can truly be remembered. I rejected her, as I have having a commission from the infant's parents, not her. She left with disappointment, and perhaps, a little bit of anger.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_infant_graffiti ===
// DEV preview copied from ev_infant_graffiti; use an independent evidence reader in production.
# ui:open_evidence:infant_graffiti
The searchlight reveals an old sketch of the infant. His appearance differs from the smooth figure chosen for the marker.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_infant_death_doubt ===
// DEV preview copied from ev_infant_death_doubt; use an independent evidence reader in production.
# ui:open_evidence:infant_death_doubt
The family's chosen depiction does not match with the records of the infant's appearance. The tombstone's expression of natural death does not settle what actually happened to him. There may be <link="unexplained death">unexplained circumstances</link> behind this death.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_shared_family_base ===
// DEV preview copied from ev_shared_family_base; use an independent evidence reader in production.
# ui:open_evidence:shared_family_base
The small gravestone, the crystal monument, and the sun-shaped monument share one continuous stone base. They are not merely three separate graves standing close together.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_crystal_marker_rubbing ===
// DEV preview copied from ev_crystal_marker_rubbing; use an independent evidence reader in production.
# ui:open_evidence:crystal_marker_rubbing
The monument is a transparent, many-sided crystal, half black and half white. The rubbing preserves the outline of its facets.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_scholar_beast_rubbing ===
// DEV preview copied from ev_scholar_beast_rubbing; use an independent evidence reader in production.
# ui:open_evidence:scholar_beast_rubbing
A twin beast is carved on the crystal monument. Its two halves belong to one body, but their appearances differ.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_city_crystal ===
// DEV preview copied from ev_night_city_crystal; use an independent evidence reader in production.
# ui:open_evidence:night_city_crystal
This mineral was found in Night City. Its facets resemble the outline of the crystal monument in Day City.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_skin_picture ===
// DEV preview copied from ev_skin_picture; use an independent evidence reader in production.
# ui:open_evidence:skin_picture
Rewound to a time before the skin decayed, the searchlight reveals the picture clearly. A member of the Dayfolk and a member of the Nightfolk reach out and clasp hands.

The lines are formed by blue blood seeping through the skin. A skin drawing with unexplained reason.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_disappearance_inquiry ===
// DEV preview copied from ev_disappearance_inquiry; use an independent evidence reader in production.
# ui:open_evidence:disappearance_inquiry
The unexplained <link="disappearance">disappearances</link> in Day City are always reported at dawn, when people wake.

The Dayfolk's bodies are unusual. Anyone who fails to enter a sleeping coffin on time will die. Once inside, however, they lose all awareness and ability to act for the entire night, under the coffin's complete protection.

Who has been tampering with their sleeping coffins? I cannot investigate the movements of the Nightfolks while they are awake. I can only suspect that, while taking our food, they have also done something to my husband and my people.

It is not only disappearances. Many of us, myself included, have found <link="fresh_wounds">fresh wounds</link> upon waking. Given the Nightfolk's habit of plundering, they are most likely responsible. I must remain vigilant.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_profession_record ===
// DEV preview copied from ev_profession_record; use an independent evidence reader in production.
# ui:open_evidence:profession_record
The record describes a Day City resident who first studied this transparent mineral and discovered the energy within it. She was granted the title of <link="scholar">Scholar</link>.

The stones were later used to power machinery. The occupational title thus became associated with crystal research.

A young man from a wealthy family was the first to invest in her research. He later became her husband and came to be known as the <link="tycoon">Tycoon</link>.

In recognition of her outstanding contributions to Day City, the Scholar may apply for a mausoleum beyond the usual grave-marker design and have her family interred within it. For the Dayfolk, who place such importance on the rituals of death, this is the highest honor.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_one_way_passage_order ===
// DEV preview copied from ev_one_way_passage_order; use an independent evidence reader in production.
# ui:open_evidence:one_way_passage_order
An order to the Scholar: We must put an end to Nightfolk incursions at their source.

They were once allowed to take our food in exchange for the crystals they excavated. Now they neglect their work, yet continue to demand more and more from Day City.

A one-way passage must be established: the Dayfolk may descend, but the Nightfolk must not be allowed to ascend.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_sun_reference ===
// DEV preview copied from ev_sun_reference; use an independent evidence reader in production.
# ui:open_evidence:sun_reference
The bright sun above Day City offers a possible reference for the monument's radiating outline. The same sun-like outline can also be compared with the pointed rims of Day City coins.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_sun_shaped_marker_rubbing ===
// DEV preview copied from ev_sun_shaped_marker_rubbing; use an independent evidence reader in production.
# ui:open_evidence:sun_shaped_marker_rubbing
Radiating points surround the monument like a shining sun. The rubbing records its distinctive outline.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_sun_shaped_beast_rubbing ===
// DEV preview copied from ev_sun_shaped_beast_rubbing; use an independent evidence reader in production.
# ui:open_evidence:sun_shaped_beast_rubbing
A small creature occupies the center of the monument. One half looks different from the other, although both are joined to the same body.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_day_city_coin ===
// DEV preview copied from ev_day_city_coin; use an independent evidence reader in production.
# ui:open_evidence:day_city_coin
Circulating coins once lay in the wishing pool beneath the ram-spirit emblem. Their pointed rims form a sun-like outline, similar to the sun-shaped monument. The pool fell out of use as technology developed and people turned to other beliefs.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_ram_spirit_emblem ===
// DEV preview copied from ev_ram_spirit_emblem; use an independent evidence reader in production.
# ui:open_evidence:ram_spirit_emblem
A ram-spirit emblem stands above the wishing pool. It belongs to the religious imagery of Day City.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_giant_footprint ===
// DEV preview copied from ev_giant_footprint; use an independent evidence reader in production.
# ui:open_evidence:giant_footprint
A vast footprint remains in the ruins. The print alone does not reveal the full appearance of the creature that left it.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_twin_beast_trace ===
// DEV preview copied from ev_twin_beast_trace; use an independent evidence reader in production.
# ui:open_evidence:twin_beast_trace
The searchlight reveals the creature that once occupied this space: one body with two strikingly different halves. Its outline can be compared with the small beasts carved on the monuments.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_twin_beast_account ===
// DEV preview copied from ev_twin_beast_account; use an independent evidence reader in production.
# ui:open_evidence:twin_beast_account
Legend tells of a twin-bodied creature that lived here before Day City was founded. Its two halves looked entirely different: one was covered in fur, with narrow eyes; the other was smooth, with clearly visible eyes.

Then, in a single night, they disappeared.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_repeated_beast_motifs ===
// DEV preview copied from ev_repeated_beast_motifs; use an independent evidence reader in production.
# ui:open_evidence:repeated_beast_motifs
The same twin beast appears on several other markers in Day City. It is not a decoration unique to the sun-shaped monument.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_family_photo ===
// DEV preview copied from ev_family_photo; use an independent evidence reader in production.
# ui:open_evidence:family_photo
A photograph once stood in front of the monument. It shows four members of a family. There are only three markers on the shared base.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_altar_infant_rubbing ===
// DEV preview copied from ev_altar_infant_rubbing; use an independent evidence reader in production.
# ui:open_evidence:altar_infant_rubbing
An infant rests on the white, house-shaped altar. The pose differs slightly from the human-shaped marker in Day City, but the two images invite comparison.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_altar_path_rubbing ===
// DEV preview copied from ev_altar_path_rubbing; use an independent evidence reader in production.
# ui:open_evidence:altar_path_rubbing
A path runs along the altar's pillars. Its pattern has no visible end.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_altar_blessing_glyph ===
// DEV preview copied from ev_altar_blessing_glyph; use an independent evidence reader in production.
# ui:open_evidence:altar_blessing_glyph
An unfamiliar symbol is carved into the altar. It does not resemble a passage of written text.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_altar_blessing_translation ===
// DEV preview copied from ev_altar_blessing_translation; use an independent evidence reader in production.
# ui:open_evidence:altar_blessing_translation
Aurora interprets the symbol as a blessing:

"To disappear is to set out on a journey without end. May the wishes of crystal remain with you."
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_crystal_god_rubbing ===
// DEV preview copied from ev_crystal_god_rubbing; use an independent evidence reader in production.
# ui:open_evidence:crystal_god_rubbing
The altar's decoration preserves the outline of the Crystal God, but the place where the crystals once stood is now empty.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_removed_crystal_god ===
// DEV preview copied from ev_removed_crystal_god; use an independent evidence reader in production.
# ui:open_evidence:removed_crystal_god
In the searchlight's view of the past, crystals fill the altar's empty recess and form the figure of a god. Today the crystals have been pried out.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_altar_moon_stone ===
// DEV preview copied from ev_altar_moon_stone; use an independent evidence reader in production.
# ui:open_evidence:altar_moon_stone
A moon-shaped stone once lay among the altar's offerings. It resembles a small token, but there is nothing here that establishes its value as currency.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_crystal_god_prophecy ===
// DEV preview copied from ev_crystal_god_prophecy; use an independent evidence reader in production.
# ui:open_evidence:crystal_god_prophecy
A legend of the Crystal God:

"When an infant with skin as smooth as crystal comes to Night City, the Nightfolk will see the light once more."
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_moon_stone_blessing ===
// DEV preview copied from ev_moon_stone_blessing; use an independent evidence reader in production.
# ui:open_evidence:moon_stone_blessing
The moon-shaped stones are offerings of blessing, not coins. The Nightfolk do not leave them as payment for goods or mark territory through them. A stone left for someone expresses a wish for their well-being.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_infant_memorial_correspondence ===
// DEV preview copied from ev_infant_memorial_correspondence; use an independent evidence reader in production.
# ui:open_evidence:infant_memorial_correspondence
The human-shaped marker in Day City corresponds to the infant memorial in Night City. One city describes a death; the other commemorates a <link="disappearance">disappearance</link>.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_mother_child_rubbing ===
// DEV preview copied from ev_night_mother_child_rubbing; use an independent evidence reader in production.
# ui:open_evidence:night_mother_child_rubbing
The upper part of the small stone shows a figure holding a child. The child can be compared with the infant on the altar.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_mother_hands_rubbing ===
// DEV preview copied from ev_night_mother_hands_rubbing; use an independent evidence reader in production.
# ui:open_evidence:night_mother_hands_rubbing
Below the figure holding a child, a member of the Dayfolk and a member of the Nightfolk hold their hands. The arrangement resembles the picture preserved inside the Scholar's crystal monument.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_mother_river_rubbing ===
// DEV preview copied from ev_night_mother_river_rubbing; use an independent evidence reader in production.
# ui:open_evidence:night_mother_river_rubbing
Cracked lines surround the stone like the bed of a dried river. They form the border of the memorial rather than a separate scene in either half.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_dry_underground_river ===
// DEV preview copied from ev_dry_underground_river; use an independent evidence reader in production.
# ui:open_evidence:dry_underground_river
The underground river has dried up. Its exposed bed preserves the cracked pattern seen around the small stone.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_mother_no_traces ===
// DEV preview copied from ev_night_mother_no_traces; use an independent evidence reader in production.
# ui:open_evidence:night_mother_no_traces
The searchlight reveals no discernible traces around this stone. There is no record here of later visitors or offerings.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_mother_death_finding ===
// DEV preview copied from ev_night_mother_death_finding; use an independent evidence reader in production.
# ui:open_evidence:night_mother_death_finding
The dry river border records a death from <link="thirst">hunger and thirst</link>. It connects the mother's fate with the loss of the underground water source.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_father_child_rubbing ===
// DEV preview copied from ev_night_father_child_rubbing; use an independent evidence reader in production.
# ui:open_evidence:night_father_child_rubbing
The figure on the upper part of the stone carries a child on his back. The child can be compared with the infant on the altar.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_father_path_rubbing ===
// DEV preview copied from ev_night_father_path_rubbing; use an independent evidence reader in production.
# ui:open_evidence:night_father_path_rubbing
A figure climbs an upward path along the border of the stone. The route resembles the passage known as the Skyway.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_father_god_rubbing ===
// DEV preview copied from ev_night_father_god_rubbing; use an independent evidence reader in production.
# ui:open_evidence:night_father_god_rubbing
The lower part of the stone bears the image of the Crystal God. It resembles the figure once installed on the infant's altar.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_father_moon_stone ===
// DEV preview copied from ev_night_father_moon_stone; use an independent evidence reader in production.
# ui:open_evidence:night_father_moon_stone
A moon-shaped stone once lay before the father's marker. It resembles the stones left as offerings on the infant's altar.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_natural_collapse_record ===
// DEV preview copied from ev_natural_collapse_record; use an independent evidence reader in production.
# ui:open_evidence:natural_collapse_record
...Before the division of day and night, the People of Sun and Moon lived together. After the separation into upper and lower cities, a <link="natural_collapse">natural collapse</link> sealed the road to the surface.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_skyway_history ===
// DEV preview copied from ev_skyway_history; use an independent evidence reader in production.
# ui:open_evidence:skyway_history
The Skyway is a path cleared upward through fallen stone. It is uneven, but not steep.

Searching for food and water, the Nightfolk dug and climbed in every direction. At last, they opened a route upward through the collapsed ruins.

The Dayfolk called the day they arrived "the Day Darkness Descended." Much food and many livestock were taken before the Dayfolk even knew who had done it. Eventually, they discovered the passage to Night City.

The reopened route also led the Dayfolk to the shining stones the Nightfolk had excavated while searching for food and water: crystals that would later power Day City's development.

The exchange continued with each cycle of day and night. The Dayfolk brought back crystals; the Nightfolk brought back food. Each took what they needed. This balance lasted a long time.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_skyway_reference ===
// DEV preview copied from ev_skyway_reference; use an independent evidence reader in production.
# ui:open_evidence:skyway_reference
An uneven path rises through the fallen stone toward the surface. It is not the sheer climb its name might suggest. Its shape corresponds to the ascending route carved around the father's stone.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_night_father_death ===
// DEV preview copied from ev_night_father_death; use an independent evidence reader in production.
# ui:open_evidence:night_father_death
The father left to search for the missing infant. The path itself was not a dangerous climb. He continued searching <link="missed_sleeping_deadline">beyond the permitted waking hours</link> and failed to return to a sleeping coffin in time.

His death can be compared with the report of the Scholar's husband disappearing at dawn.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_paired_skin_pictures ===
// DEV preview copied from ev_paired_skin_pictures; use an independent evidence reader in production.
# ui:open_evidence:paired_skin_pictures
The handholding figures on the mother's stone correspond to the blue marks on the Scholar's preserved skin. Together with the records of wounds appearing upon waking, they suggest that the body itself could carry a message between day and night.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_girl_figure_rubbing ===
// DEV preview copied from ev_girl_figure_rubbing; use an independent evidence reader in production.
# ui:open_evidence:girl_figure_rubbing
Another human figure appears on this marker, older than the infant represented by the small stone. A structure surrounds her body.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_girl_coffin_rubbing ===
// DEV preview copied from ev_girl_coffin_rubbing; use an independent evidence reader in production.
# ui:open_evidence:girl_coffin_rubbing
The girl stands inside an upright structure with her hands joined before her chest. The surrounding frame can be compared with the illustration in the old history book.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_girl_beast_rubbing ===
// DEV preview copied from ev_girl_beast_rubbing; use an independent evidence reader in production.
# ui:open_evidence:girl_beast_rubbing
A twin beast decorates the marble-like marker. It resembles the creatures carved on other Day City monuments.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_girl_path_rubbing ===
// DEV preview copied from ev_girl_path_rubbing; use an independent evidence reader in production.
# ui:open_evidence:girl_path_rubbing
The edge of the upright frame carries the pattern of an unending path. It recalls the border on the infant's altar in Night City.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_girl_signature_rubbing ===
// DEV preview copied from ev_girl_signature_rubbing; use an independent evidence reader in production.
# ui:open_evidence:girl_signature_rubbing
The girl, her joined hands, and the upright coffin form a single composition. This complete motif can be compared with the covers of the diary and the investigation notebook.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_family_statuette ===
// DEV preview copied from ev_family_statuette; use an independent evidence reader in production.
# ui:open_evidence:family_statuette
A small sculpture of four family members once stood before the marker. It was carved by the girl and left here by her mother. Its figures can be compared with the photograph at the sun-shaped monument.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_day_city_history ===
// DEV preview copied from ev_day_city_history; use an independent evidence reader in production.
# ui:open_evidence:day_city_history
This history was a <link="banned_book">banned book</link> until it was discovered.

Both Dayfolk and Nightfolk must rest in their <link="sleeping_coffin">sleeping coffins</link> at the proper time if they are to awaken the following day.

Before their division, they were known together as the <link="sun_moon_people">People of Sun and Moon</link>. Some had the daylight; others had the moonlit night.

In their shared residential districts, sleeping coffins stood upright to conserve space. Later, when the Nightfolk moved underground, the <link="population_decline">number of people on the surface decreased</link>. Space was no longer scarce, and the Dayfolk developed the habit of lying down in their coffins.

The Nightfolk placed theirs underground, where the darkness of the caves made them almost indistinguishable from the surrounding floor.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_history_coffin_illustration ===
// DEV preview copied from ev_history_coffin_illustration; use an independent evidence reader in production.
# ui:open_evidence:history_coffin_illustration
An illustration in the old history book shows a sleeping coffin standing upright. Its outline resembles the structure surrounding the girl on the solitary marker.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_girl_diary ===
// DEV preview copied from ev_girl_diary; use an independent evidence reader in production.
# ui:open_evidence:girl_diary
If the truth of death itself is being covered up, then <link="diary_complicity">am I not an accomplice when I carve monuments to that lie</link>?

I can no longer bear this <link="diary_hypocrisy">hypocritical world</link>. If even one person had stopped to question what was wrong with the world we lived in, perhaps we would never have come to this.

I once loved and respected my mother so much. She was my example from childhood. But first she failed to protect my brother; then she blamed my father's disappearance on others. Even when I tried to tell her the truth about our world, she insisted that useless sympathy would destroy Day City.

How many more times must we hurt our own people in the name of protecting them?

She left me a message on my windowsill when she came to the Day City. She is so intelligent that she acquired the language of Day City just by observing the surroundings and reading the library, and she found out my identity as her correspondence just by the messages conveyed by the stones. She said there was an old site in the ruins, with sleeping coffins that could keep the two of us alive.

She wants to bring her mother. But <link="diary_mothers">if she brings her mother, we will have to bring mine</link>. With my mother's influence in Day City, everyone will find out. We will go through it all again.

I have to persuade her. We can only <link="diary_escape">escape on our own</link>. The One-way Passage Order is launching soon. We need to act fast.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_diary_cover ===
// DEV preview copied from ev_diary_cover; use an independent evidence reader in production.
# ui:open_evidence:diary_cover
The diary remains intact, as if new. It seems that it's not part of the remains collected by previous archaeologists. Its cover bears the image of a girl standing inside an upright coffin, hands joined before her chest.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_notebook_cover ===
// DEV preview copied from ev_notebook_cover; use an independent evidence reader in production.
# ui:open_evidence:notebook_cover
Aurora gave you this black-and-white notebook. On its cover, a girl stands inside an upright coffin, hands joined before her chest.

You have been carrying the image throughout your investigation, holding it like the girl in the monument.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_four_person_family_finding ===
// DEV preview copied from ev_four_person_family_finding; use an independent evidence reader in production.
# ui:open_evidence:four_person_family_finding
The four figures in the statuette correspond to the family in the photograph. The shared base holds only three markers. The solitary girl's marker stands apart from that family plot.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_preview_girl_cover_correspondence ===
// DEV preview copied from ev_girl_cover_correspondence; use an independent evidence reader in production.
# ui:open_evidence:girl_cover_correspondence
The complete girl-and-coffin composition on the solitary marker corresponds to the image on the diary or the investigation notebook. The person who made the monument, the writer, and the person who supplied the notebook may be connected.
+ [Collect a highlighted term] -> test_terms
+ [Back] -> test_hub

=== test_slot ===
Choose ONE collected evidence. Its tags are copied when you begin a call.
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
    ~ selected_tags = (EvidenceTag.four_person_family, EvidenceTag.family_image_reference, EvidenceTag.mother_remembers_daughter)
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
    ~ selected_tags = (EvidenceTag.four_person_family, EvidenceTag.missing_family_member_reference, EvidenceTag.mother_remembers_daughter)
    -> test_hub

+ {owned_evidence ? EvidenceId.girl_cover_correspondence} [The Same Girl on Stone and Paper]
    ~ selected_id = "girl_cover_correspondence"
    ~ selected_tags = (EvidenceTag.girl_coffin_motif, EvidenceTag.author_identity_reference, EvidenceTag.aurora_identity_reference)
    -> test_hub

+ [Back] -> test_hub

LIST WordId = w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17

=== test_terms ===
DEV: simulate clicking a link in an acquired document or finding. Runtime link clicks should call the same actions.

+ {owned_evidence ? EvidenceId.designer_manuscript} [Infant]
    ~ identities += Identity.infant
    ~ collected_words += WordId.w0
    # event:collect_term:infant
    # term_type:identity
    Recorded globally: Infant.
    -> test_terms

+ {owned_evidence ? EvidenceId.designer_journal} [Student]
    ~ identities += Identity.student
    ~ collected_words += WordId.w1
    # event:collect_term:student
    # term_type:identity
    Recorded globally: Student.
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

+ {owned_evidence ? EvidenceId.disappearance_inquiry} [Clue word: fresh_wounds]
    ~ collected_words += WordId.w8
    # event:collect_term:fresh_wounds
    # term_type:evidence
    Clue recorded: fresh_wounds. This does not add an identity or cause.
    -> test_terms

+ {owned_evidence ? EvidenceId.natural_collapse_record} [Clue word: natural_collapse]
    ~ collected_words += WordId.w9
    # event:collect_term:natural_collapse
    # term_type:evidence
    Clue recorded: natural_collapse. This does not add an identity or cause.
    -> test_terms

+ {owned_evidence ? EvidenceId.day_city_history} [Clue word: banned_book]
    ~ collected_words += WordId.w10
    # event:collect_term:banned_book
    # term_type:evidence
    Clue recorded: banned_book. This does not add an identity or cause.
    -> test_terms

+ {owned_evidence ? EvidenceId.day_city_history} [Clue word: sleeping_coffin]
    ~ collected_words += WordId.w11
    # event:collect_term:sleeping_coffin
    # term_type:evidence
    Clue recorded: sleeping_coffin. This does not add an identity or cause.
    -> test_terms

+ {owned_evidence ? EvidenceId.day_city_history} [Clue word: sun_moon_people]
    ~ collected_words += WordId.w12
    # event:collect_term:sun_moon_people
    # term_type:evidence
    Clue recorded: sun_moon_people. This does not add an identity or cause.
    -> test_terms

+ {owned_evidence ? EvidenceId.day_city_history} [Clue word: population_decline]
    ~ collected_words += WordId.w13
    # event:collect_term:population_decline
    # term_type:evidence
    Clue recorded: population_decline. This does not add an identity or cause.
    -> test_terms

+ {owned_evidence ? EvidenceId.girl_diary} [Clue word: diary_complicity]
    ~ collected_words += WordId.w14
    # event:collect_term:diary_complicity
    # term_type:evidence
    Clue recorded: diary_complicity. This does not add an identity or cause.
    -> test_terms

+ {owned_evidence ? EvidenceId.girl_diary} [Clue word: diary_hypocrisy]
    ~ collected_words += WordId.w15
    # event:collect_term:diary_hypocrisy
    # term_type:evidence
    Clue recorded: diary_hypocrisy. This does not add an identity or cause.
    -> test_terms

+ {owned_evidence ? EvidenceId.girl_diary} [Clue word: diary_mothers]
    ~ collected_words += WordId.w16
    # event:collect_term:diary_mothers
    # term_type:evidence
    Clue recorded: diary_mothers. This does not add an identity or cause.
    -> test_terms

+ {owned_evidence ? EvidenceId.girl_diary} [Clue word: diary_escape]
    ~ collected_words += WordId.w17
    # event:collect_term:diary_escape
    # term_type:evidence
    Clue recorded: diary_escape. This does not add an identity or cause.
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
        ~ known_tags += (EvidenceTag.four_person_family, EvidenceTag.family_image_reference, EvidenceTag.mother_remembers_daughter)
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
+ [Back] -> test_hub

LIST Relation = moon, crystal, sun, baby_pair, river, father_path, skin, family, cover
=== test_compare ===
DEV: explicit approved comparisons. Acquiring one ingredient never awards a finding automatically.

+ {(owned_evidence ? EvidenceId.infant_moon_rubbing) && (owned_evidence ? EvidenceId.moon_reference)} [infant_moon_rubbing ↔ moon_reference]
    ~ links += Relation.moon
    # event:comparison:moon
    The curved carving corresponds to the moon.

    -> test_compare

+ {(owned_evidence ? EvidenceId.crystal_marker_rubbing) && (owned_evidence ? EvidenceId.night_city_crystal)} [crystal_marker_rubbing ↔ night_city_crystal]
    ~ links += Relation.crystal
    # event:comparison:crystal
    The monument reproduces Night City crystal.

    -> test_compare

+ {(owned_evidence ? EvidenceId.sun_shaped_marker_rubbing) && (owned_evidence ? EvidenceId.sun_reference)} [sun_shaped_marker_rubbing ↔ sun_reference]
    ~ links += Relation.sun
    # event:comparison:sun
    The radiating shape resembles the sun; that does not settle its occupational meaning.

    -> test_compare

+ {(owned_evidence ? EvidenceId.sun_shaped_marker_rubbing) && (owned_evidence ? EvidenceId.day_city_coin)} [sun_shaped_marker_rubbing ↔ day_city_coin]
    ~ links += Relation.sun
    # event:comparison:sun
    The same sun-like outline appears on Day City coins.

    -> test_compare

+ {(owned_evidence ? EvidenceId.infant_figure_rubbing) && (owned_evidence ? EvidenceId.altar_infant_rubbing)} [infant_figure_rubbing ↔ altar_infant_rubbing]
    ~ links += Relation.baby_pair
    # event:comparison:baby_pair
    The two memorials correspond, although one records death and the other disappearance.

    ~ owned_evidence += EvidenceId.infant_memorial_correspondence
    ~ known_tags += (EvidenceTag.infant_memorial, EvidenceTag.paired_day_night_memorials, EvidenceTag.contradictory_death_accounts)
    # event:grant_evidence:infant_memorial_correspondence

    -> test_compare

+ {(owned_evidence ? EvidenceId.night_mother_river_rubbing) && (owned_evidence ? EvidenceId.dry_underground_river)} [night_mother_river_rubbing ↔ dry_underground_river]
    ~ links += Relation.river
    # event:comparison:river
    The river border connects her death with hunger and thirst.

    ~ owned_evidence += EvidenceId.night_mother_death_finding
    ~ known_tags += (EvidenceTag.night_mother_death_reference, EvidenceTag.death_by_hunger_and_thirst, EvidenceTag.water_source_lost)
    # event:grant_evidence:night_mother_death_finding

    -> test_compare

+ {(owned_evidence ? EvidenceId.night_father_path_rubbing) && (owned_evidence ? EvidenceId.skyway_reference)} [night_father_path_rubbing ↔ skyway_reference]
    ~ links += Relation.father_path
    # event:comparison:father_path
    The carved ascent corresponds to the Skyway; it is not a sheer cliff.

    -> test_compare

+ {(owned_evidence ? EvidenceId.night_mother_hands_rubbing) && (owned_evidence ? EvidenceId.skin_picture)} [night_mother_hands_rubbing ↔ skin_picture]
    ~ links += Relation.skin
    # event:comparison:skin
    The two handholding images correspond. The wound record is still needed to interpret the message medium.

    -> test_compare

+ {(owned_evidence ? EvidenceId.family_photo) && (owned_evidence ? EvidenceId.family_statuette)} [family_photo ↔ family_statuette]
    ~ links += Relation.family
    # event:comparison:family
    Four remembered family members, but only three markers share the base.

    ~ owned_evidence += EvidenceId.four_person_family_finding
    ~ known_tags += (EvidenceTag.four_person_family, EvidenceTag.missing_family_member_reference, EvidenceTag.mother_remembers_daughter)
    # event:grant_evidence:four_person_family_finding

    -> test_compare

+ {(owned_evidence ? EvidenceId.girl_signature_rubbing) && (owned_evidence ? EvidenceId.notebook_cover)} [girl_signature_rubbing ↔ notebook_cover]
    ~ links += Relation.cover
    # event:comparison:cover
    The complete composition repeats on stone and your notebook cover.

    ~ owned_evidence += EvidenceId.girl_cover_correspondence
    ~ known_tags += (EvidenceTag.girl_coffin_motif, EvidenceTag.author_identity_reference, EvidenceTag.aurora_identity_reference)
    # event:grant_evidence:girl_cover_correspondence

    -> test_compare

+ {(owned_evidence ? EvidenceId.girl_signature_rubbing) && (owned_evidence ? EvidenceId.diary_cover)} [girl_signature_rubbing ↔ diary_cover]
    ~ links += Relation.cover
    # event:comparison:cover
    The complete composition repeats on stone and the diary cover.

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

===daybaby_tele===
First tombstone, first encounter. 
->questions

=questions
What would you like to check? 
// Evidence slot: Some questions require evidence.
// Certain pieces of evidence may unlock additional questions. 
+ [The decoration looks like a moon. What does it mean?]
    ~ natural_reply_seen = true
    When the night falls, dayfolks slip into slumber. Sleep is a state of serenity that is so similar to death; hence, moon represents  <link="natural">natural death</link> for the night folks.#aurora
    {has_tag(EvidenceTag.infant_appearance_mismatch):
        # feedback:gold
        A peaceful symbol cannot explain why the child's real appearance was kept off his marker. That death may have <link="unexplained death">unexplained circumstances</link>.#aurora
        ~ owned_evidence += EvidenceId.infant_death_doubt
        ~ known_tags += (EvidenceTag.infant_death_unresolved, EvidenceTag.infant_appearance_mismatch)
        # event:grant_evidence:infant_death_doubt
    }
    -> questions

+ [Why is the tombstone shaped like a person?]
    What does the designer's manuscript say?#aurora
    {has_tag(EvidenceTag.infant_identity):
        He had no assigned occupation. An <link="infant">infant</link> was still entitled to be remembered as a person.#aurora
    }
    -> questions

+ {has_tag(EvidenceTag.infant_actual_appearance) || has_tag(EvidenceTag.family_requested_depiction)} [Who drew the child's real appearance?]
    # feedback:gold
    Someone who could not bear the face they had chosen for him.#aurora
    {know(EvidenceTag.funerary_artist_reference):
        She was learning to make memorials then. She learned rather early what a stone could be asked to hide.#aurora
    }
    {not (seen_subtexts ? Subtext.baby_drawer):
        ~ seen_subtexts += Subtext.baby_drawer
        ~ subtext_count += 1
    }
    -> questions

+ {has_tag(EvidenceTag.paired_day_night_death)} [Could death in one city be disappearance in the other?]
    # feedback:gold
    You have found a reason to stop treating the cities as separate stories. Keep following that thought.#aurora
    {not (seen_subtexts ? Subtext.baby_shared):
        ~ seen_subtexts += Subtext.baby_shared
        ~ subtext_count += 1
    }
    -> questions

+ [Collect a word from this call]
    -> test_baby_terms

+ [That's all for now.]
    Talk to you later.#aurora
    -> test_hub

=== test_baby_terms ===
+ {natural_reply_seen} [natural death]
    ~ causes += Cause.natural
    # event:collect_term:natural
    -> daybaby_tele.questions
+ {owned_evidence ? EvidenceId.infant_death_doubt} [unexplained circumstances]
    ~ causes += Cause.unexplained
    # event:collect_term:unexplained death
    -> daybaby_tele.questions
+ [Back] -> daybaby_tele.questions

=== test_radio_scholar ===
What would you like to ask?

+ [Why is the monument shaped like a crystal?]
    // Source: 02!B9,C13. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.crystal_shape) || has_tag(EvidenceTag.crystal_research_reference):

        The occupational record names the first crystal researcher a <link="scholar">Scholar</link>. The form commemorates her work.#aurora

    - else:
        Compare the outline with a mineral sample or read the occupational record before choosing a profession.#aurora
    }
    -> test_radio_scholar

+ [What does the two-part creature mean?]
    // Source: 02!B15;03!C13. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.ancient_disappearance):

        The old account describes a creature that vanished in one night. Its image records <link="disappearance">disappearance</link>, not an explanation of what happened.#aurora

    - else:
        A recurring decoration is a useful lead. We still need its reference outside the cemetery.#aurora
    }
    -> test_radio_scholar

+ [Did the cities ever cooperate?]
    // Source: 02!B15;07!C12. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.night_city_mineral_origin) || has_tag(EvidenceTag.intercity_resource_exchange):

        Crystals came up from Night City while food went down. The cities depended on each other long before this monument was made.#aurora

    - else:
        The stone alone cannot tell us how the two cities dealt with each other.#aurora
    }
    -> test_radio_scholar

+ [How could a picture be kept inside this crystal?]
    // Source: 02!B10,B15; test completion of the unfinished callback. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.skin_as_message_medium) || has_tag(EvidenceTag.day_night_handholding):

        Those are marks in skin. It may have been the only surface that could carry a message where its maker could not go.#aurora

        {know(EvidenceTag.unexplained_waking_wounds):
            ~ owned_evidence += EvidenceId.paired_skin_pictures
            ~ known_tags += (EvidenceTag.day_night_handholding, EvidenceTag.skin_as_message_medium, EvidenceTag.unexplained_waking_wounds, EvidenceTag.shared_body_reference)
            # event:grant_evidence:paired_skin_pictures
        }

    - else:
        Use the searchlight on the fragment before deciding what the picture shows.#aurora
    }
    -> test_radio_scholar

+ {has_tag(EvidenceTag.skin_as_message_medium) || has_tag(EvidenceTag.day_night_handholding)} [Why does this picture sound familiar to you?]
    # feedback:gold
    She was trying to reach someone. I wish I had understood that before I left.#aurora
    {not (seen_subtexts ? Subtext.scholar_skin):
        ~ seen_subtexts += Subtext.scholar_skin
        ~ subtext_count += 1
    }
    -> test_radio_scholar

+ [Collect a word from this call] -> test_radio_terms_scholar
+ [End this call] -> test_hub

=== test_radio_sun ===
What would you like to ask?

+ [Is this simply a monument to the sun?]
    // Source: 03!B9,B15; latest sun-first instruction. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.day_city_currency):

        {know(EvidenceTag.tycoon_identity):
            The outline also appears on circulating coins. With the occupational record, it points toward the <link="tycoon">Tycoon</link> who funded the Scholar.#aurora
        - else:
            The outline matches circulating coins as well as the sun. That is a useful comparison. Read the occupational record before choosing the owner's identity.#aurora
        }

    - else:
        The rays do resemble the sun. A visual resemblance is not yet an occupation.#aurora
    }
    -> test_radio_sun

+ [Why is the same beast on other markers?]
    // Source: 03!B8,C13,B15. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.ancient_disappearance):

        The repetition makes it a shared funerary sign. The old creature account connects it with <link="disappearance">disappearance</link>.#aurora

    - else:
        Repeated examples suggest a shared sign, but do not establish its meaning. Compare it with the old creature account.#aurora
    }
    -> test_radio_sun

+ [Do these three markers belong together?]
    // Source: 03!C14,B15. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.shared_family_plot) || has_tag(EvidenceTag.three_family_markers):

        Their continuous base marks one family plot. They were not merely buried near one another.#aurora

    - else:
        Check the base beneath the markers rather than their spacing alone.#aurora
    }
    -> test_radio_sun

+ [Why are four people remembered by only three markers?]
    // Source: 03!B10,B15. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.four_person_family) || has_tag(EvidenceTag.missing_family_member_reference):

        A family photograph can preserve someone who has no place on that base. Count the absences as carefully as the graves.#aurora

    - else:
        You need a family image and the shared base before that question can be answered.#aurora
    }
    -> test_radio_sun

+ {has_tag(EvidenceTag.four_person_family) || has_tag(EvidenceTag.missing_family_member_reference)} [Which family member has no place on the base?]
    # feedback:gold
    Someone was still there when the others were gone. That does not mean she stayed.#aurora
    {not (seen_subtexts ? Subtext.sun_missing):
        ~ seen_subtexts += Subtext.sun_missing
        ~ subtext_count += 1
    }
    -> test_radio_sun

+ [Collect a word from this call] -> test_radio_terms_sun
+ [End this call] -> test_hub

=== test_radio_altar ===
What would you like to ask?

+ [What does the unfamiliar glyph say?]
    // Source: 05!B9. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.night_blessing_glyph):

        To disappear is to set out on a journey without end. May the wishes of crystal remain with you. The border records <link="disappearance">disappearance</link>.#aurora

        ~ owned_evidence += EvidenceId.altar_blessing_translation
        ~ known_tags += (EvidenceTag.night_blessing_glyph, EvidenceTag.night_symbol_translation, EvidenceTag.endless_path_motif, EvidenceTag.aurora_translation_knowledge)
        # event:grant_evidence:altar_blessing_translation

    - else:
        Please show me the glyph itself. A description of an unfamiliar mark is not a translation.#aurora
    }
    -> test_radio_altar

+ [Is this the child from the small marker?]
    // Source: 05!B9,B13. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.infant_memorial) || has_tag(EvidenceTag.paired_day_night_memorials):

        Compare the two infant images directly. One city calls it a death, the other a disappearance. These are competing records, not automatically separate children.#aurora

    - else:
        Compare the infant figures before assigning a shared identity.#aurora
    }
    -> test_radio_altar

+ [Are the moon-shaped stones coins?]
    // Source: 05!B13. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.moon_stone_offering) || has_tag(EvidenceTag.night_blessing_reference):

        They are blessings, not payments. Leaving one expresses a wish for the person who has gone.#aurora

        ~ owned_evidence += EvidenceId.moon_stone_blessing
        ~ known_tags += (EvidenceTag.moon_stone_offering, EvidenceTag.night_blessing_reference, EvidenceTag.different_exchange_customs)
        # event:grant_evidence:moon_stone_blessing

    - else:
        Their shape is not enough to call them money. Find an offering here or at another marker.#aurora
    }
    -> test_radio_altar

+ [What was removed from the empty recess?]
    // Source: 05!B10,B13; avoid identifying a culprit from the raw trace. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.removed_crystal_offering) || has_tag(EvidenceTag.crystal_extraction_reference):

        The old view shows the Crystal God intact. It was later pried out. Day City had an appetite for crystal, but this image alone does not identify the hand that removed it.#aurora

    - else:
        The empty space needs to be compared with a view of what once filled it.#aurora
    }
    -> test_radio_altar

+ {has_tag(EvidenceTag.aurora_translation_knowledge) || has_tag(EvidenceTag.night_symbol_translation)} [How can you translate a symbol from a culture without a written language?]
    # feedback:gold
    A language does not have to be written to be remembered. Some knowledge survives through another point of view.#aurora
    {not (seen_subtexts ? Subtext.altar_translation):
        ~ seen_subtexts += Subtext.altar_translation
        ~ subtext_count += 1
    }
    -> test_radio_altar
+ {has_tag(EvidenceTag.infant_appearance_mismatch) || has_tag(EvidenceTag.infant_actual_appearance)} [Was the child in the wrong city?]
    # feedback:gold
    Or was the division wrong? Keep the two memorials together in your notes.#aurora
    {not (seen_subtexts ? Subtext.altar_child):
        ~ seen_subtexts += Subtext.altar_child
        ~ subtext_count += 1
    }
    -> test_radio_altar

+ [Collect a word from this call] -> test_radio_terms_altar
+ [End this call] -> test_hub

=== test_radio_mother ===
What would you like to ask?

+ [Who is the figure holding the child?]
    // Source: 06!B8,B9. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.parent_child_image) || has_tag(EvidenceTag.night_mother_past):

        The child corresponds to the altar infant. This is the child's <link="night_mother">mother in Night City</link>.#aurora

    - else:
        Compare the child with the infant on the altar before naming their relationship.#aurora
    }
    -> test_radio_mother

+ [What does the dry river border record?]
    // Source: 06!B12. Accepted tags are OR, on the frozen submitted evidence.
    {(has_tag(EvidenceTag.dry_river_motif) || has_tag(EvidenceTag.water_source_lost)) && (links ? Relation.river):

        The border follows the dried underground river. It records a death from <link="thirst">hunger and thirst</link>.#aurora

        ~ owned_evidence += EvidenceId.night_mother_death_finding
        ~ known_tags += (EvidenceTag.night_mother_death_reference, EvidenceTag.death_by_hunger_and_thirst, EvidenceTag.water_source_lost)
        # event:grant_evidence:night_mother_death_finding

    - else:
        Look for the same pattern in the underground landscape.#aurora
    }
    -> test_radio_mother

+ [Why does the handholding picture resemble the Scholar's?]
    // Source: 06!B12;02!C12. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.skin_as_message_medium) || has_tag(EvidenceTag.unexplained_waking_wounds) || has_tag(EvidenceTag.shared_body_reference):

        The waking wounds tell you how one person could leave a mark for the other. The body could carry what their waking lives could not.#aurora

    - else:
        A matching picture is a start. The wound record may tell you how the message travelled.#aurora
    }
    -> test_radio_mother

+ [Does the lack of offerings mean she was the last survivor?]
    // Source: 06!B10,B12. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.absence_of_readable_traces) || has_tag(EvidenceTag.last_survivor_question):

        It is consistent with nobody returning. Absence alone cannot prove she was the last living person. Keep that conclusion qualified.#aurora

    - else:
        A single empty scan may be the wrong setting. Check the period after the burial.#aurora
    }
    -> test_radio_mother

+ {has_tag(EvidenceTag.day_night_handholding) || has_tag(EvidenceTag.shared_body_reference)} [Was the message meant for her daughter as well?]
    # feedback:gold
    Perhaps it was the understanding she could not give her daughter while they were together. A message arriving late is still a message.#aurora
    {not (seen_subtexts ? Subtext.mother_message):
        ~ seen_subtexts += Subtext.mother_message
        ~ subtext_count += 1
    }
    -> test_radio_mother

+ [Collect a word from this call] -> test_radio_terms_mother
+ [End this call] -> test_hub

=== test_radio_father ===
What would you like to ask?

+ [Who is carrying the child?]
    // Source: 07!B14. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.parent_child_image) || has_tag(EvidenceTag.night_father_past):

        The repeated child identifies a family relationship. This is the infant's <link="night_father">father in Night City</link>.#aurora

    - else:
        Compare the child with the altar figure before naming the parent.#aurora
    }
    -> test_radio_father

+ [Did he die because the Skyway was dangerous?]
    // Source: 07!B14. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.skyway_not_steep) || has_tag(EvidenceTag.missed_sleeping_deadline):

        The path was uneven, not a precipice. He searched for the infant <link="missed_sleeping_deadline">beyond the permitted waking hours</link> and did not reach a sleeping coffin in time.#aurora

        ~ owned_evidence += EvidenceId.night_father_death
        ~ known_tags += (EvidenceTag.sleep_coffin_required, EvidenceTag.missed_sleeping_deadline, EvidenceTag.night_father_final_journey, EvidenceTag.paired_day_night_death)
        # event:grant_evidence:night_father_death

    - else:
        Bring the path reference or its history. The carved ascent alone does not prove a fall.#aurora
    }
    -> test_radio_father

+ [Could his death be linked to the Scholar's husband?]
    // Source: 07!B14. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.husband_disappearance) || has_tag(EvidenceTag.dawn_disappearances) || has_tag(EvidenceTag.paired_day_night_death):

        The timing matters: one death and one disappearance at dawn. Test whether you have been counting one life twice.#aurora

    - else:
        You need the Scholar's disappearance record to compare the timing.#aurora
    }
    -> test_radio_father

+ [What does the moon-shaped offering mean?]
    // Source: 07!B10;05!B13. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.moon_stone_offering) || has_tag(EvidenceTag.night_blessing_reference):

        Someone wished him well on his journey. It was not a payment for the path.#aurora

        ~ owned_evidence += EvidenceId.moon_stone_blessing
        ~ known_tags += (EvidenceTag.moon_stone_offering, EvidenceTag.night_blessing_reference, EvidenceTag.different_exchange_customs)
        # event:grant_evidence:moon_stone_blessing

    - else:
        Record the offering or compare it with the altar stones.#aurora
    }
    -> test_radio_father

+ {has_tag(EvidenceTag.natural_collapse) || has_tag(EvidenceTag.shared_day_night_history)} [Was the original separation really a natural disaster?]
    # feedback:gold
    That is what the history calls it. Sharing a coffin challenges the story about crowding; it does not, by itself, prove who brought the roof down.#aurora
    {not (seen_subtexts ? Subtext.father_history):
        ~ seen_subtexts += Subtext.father_history
        ~ subtext_count += 1
    }
    -> test_radio_father

+ [Collect a word from this call] -> test_radio_terms_father
+ [End this call] -> test_hub

=== test_radio_girl ===
What would you like to ask?

+ [What is the upright frame around her?]
    // Source: 04!B9,C11. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.upright_coffin_motif) || has_tag(EvidenceTag.shared_day_night_history):

        The old illustration shows an upright sleeping coffin. It belongs to an earlier way of living, not a different kind of body.#aurora

    - else:
        Compare the frame with the historical illustration before deciding what it contains.#aurora
    }
    -> test_radio_girl

+ [Who made this marker?]
    // Source: 04!B15. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.funerary_artist_reference):

        The diary writer carved memorials and questioned the stories they concealed. This figure commemorates a <link="funerary_artist">funerary artist</link>.#aurora

    - else:
        The human outline is not enough to assign an occupation. Read the diary or compare its cover.#aurora
    }
    -> test_radio_girl

+ [Do the family sculpture and the photograph belong together?]
    // Source: 04!B10,B15. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.family_image_reference) || has_tag(EvidenceTag.four_person_family):

        Four people were remembered. Three markers share a base, while this one stands apart. The sculpture was left by her mother.#aurora

    - else:
        Compare the four-person images directly before treating them as one family.#aurora
    }
    -> test_radio_girl

+ [Does disappearance always mean death?]
    // Source: 04!B8,B15. Accepted tags are OR, on the frozen submitted evidence.
    {has_tag(EvidenceTag.deliberate_departure) || has_tag(EvidenceTag.two_mothers_dilemma):

        The diary describes a decision to leave. <link="disappearance">Disappearance</link> was what those left behind could record; it does not prove the girl died.#aurora

    - else:
        Read what the writer intended to do. A symbol can preserve an absence without settling its cause.#aurora
    }
    -> test_radio_girl

+ {has_tag(EvidenceTag.aurora_provided_object) || has_tag(EvidenceTag.aurora_identity_reference)} [Aurora, why is this girl on the notebook you gave me?]
    {links ? Relation.cover:
        -> test_confrontation
    - else:
        Compare the whole image first. A resemblance should not have to carry your entire conclusion.#aurora
        -> test_radio_girl
    }

+ [Collect a word from this call] -> test_radio_terms_girl
+ [End this call] -> test_hub

=== test_radio_terms_scholar ===
DEV: emulate a link click after reading a supported reply.

+ {has_tag(EvidenceTag.crystal_shape) || has_tag(EvidenceTag.crystal_research_reference)} [Scholar]
    ~ identities += Identity.scholar
    # event:collect_term:scholar
    -> test_radio_terms_scholar

+ {has_tag(EvidenceTag.ancient_disappearance)} [disappearance]
    ~ causes += Cause.disappearance
    # event:collect_term:disappearance
    -> test_radio_terms_scholar

+ [Back] -> test_radio_scholar

=== test_radio_terms_sun ===
DEV: emulate a link click after reading a supported reply.

+ {(has_tag(EvidenceTag.day_city_currency)) && know(EvidenceTag.tycoon_identity)} [Tycoon]
    ~ identities += Identity.tycoon
    # event:collect_term:tycoon
    -> test_radio_terms_sun

+ {has_tag(EvidenceTag.ancient_disappearance)} [disappearance]
    ~ causes += Cause.disappearance
    # event:collect_term:disappearance
    -> test_radio_terms_sun

+ [Back] -> test_radio_sun

=== test_radio_terms_altar ===
DEV: emulate a link click after reading a supported reply.

+ {has_tag(EvidenceTag.night_blessing_glyph)} [disappearance]
    ~ causes += Cause.disappearance
    # event:collect_term:disappearance
    -> test_radio_terms_altar

+ [Back] -> test_radio_altar

=== test_radio_terms_mother ===
DEV: emulate a link click after reading a supported reply.

+ {has_tag(EvidenceTag.parent_child_image) || has_tag(EvidenceTag.night_mother_past)} [mother in Night City]
    ~ identities += Identity.night_mother
    # event:collect_term:night_mother
    -> test_radio_terms_mother

+ {(has_tag(EvidenceTag.dry_river_motif) || has_tag(EvidenceTag.water_source_lost)) && (links ? Relation.river)} [hunger and thirst]
    ~ causes += Cause.hunger_and_thirst
    # event:collect_term:thirst
    -> test_radio_terms_mother

+ [Back] -> test_radio_mother

=== test_radio_terms_father ===
DEV: emulate a link click after reading a supported reply.

+ {has_tag(EvidenceTag.parent_child_image) || has_tag(EvidenceTag.night_father_past)} [father in Night City]
    ~ identities += Identity.night_father
    # event:collect_term:night_father
    -> test_radio_terms_father

+ {has_tag(EvidenceTag.skyway_not_steep) || has_tag(EvidenceTag.missed_sleeping_deadline)} [beyond the permitted waking hours]
    ~ causes += Cause.missed_sleeping_deadline
    # event:collect_term:missed_sleeping_deadline
    -> test_radio_terms_father

+ [Back] -> test_radio_father

=== test_radio_terms_girl ===
DEV: emulate a link click after reading a supported reply.

+ {has_tag(EvidenceTag.funerary_artist_reference)} [funerary artist]
    ~ identities += Identity.funerary_artist
    # event:collect_term:funerary_artist
    -> test_radio_terms_girl

+ {has_tag(EvidenceTag.deliberate_departure) || has_tag(EvidenceTag.two_mothers_dilemma)} [Disappearance]
    ~ causes += Cause.disappearance
    # event:collect_term:disappearance
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

+ {identities ? Identity.student} [student]
    ~ report_identity = Identity.student
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

{active_tomb == "baby" && report_identity == Identity.infant && (report_cause == Cause.natural || report_cause == Cause.unexplained):
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

    {not bonus_done:
        ~ bonus_remaining = 2
        -> test_bonus
    }

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
// Source: 05_婴儿夜城祭坛!B13. Two bonus QUESTIONS, not an overall radio call limit.
You have followed one child across two cities. What would you most like to ask now?#aurora
DEV: bonus questions remaining {bonus_remaining}.
* {bonus_remaining > 0} [What are the Dayfolk and Nightfolk?]
    Less like a sun and moon that never meet, more like conjoined twins: separate minds and actions, but a shared life. The Dayfolk wanted to imagine a sun that could survive without its moon.#aurora
    ~ bonus_remaining = bonus_remaining - 1
    -> test_bonus_check
* {bonus_remaining > 0} [Why do you know so much?]
    Aurora is a name. You cannot know from a name whether you are speaking to one person, many, or something in between. Do not underestimate what different points of view can remember.#aurora
    ~ bonus_remaining = bonus_remaining - 1
    -> test_bonus_check
* {bonus_remaining > 0} [What does disappearance mean?]
    Imagine two friends taking turns using one account. If it is closed, neither can enter—but the notice goes to only one of them. To the other, it has simply vanished.#aurora
    ~ bonus_remaining = bonus_remaining - 1
    -> test_bonus_check
* {bonus_remaining > 0} [Were the two cities always enemies?]
    There was once a cemetery where they were buried together. You will not visit it on this journey. Stones can remember coexistence long after histories learn to describe only separation.#aurora
    ~ bonus_remaining = bonus_remaining - 1
    -> test_bonus_check
+ [Continue the investigation]
    ~ bonus_done = true
    -> test_hub

=== test_bonus_check ===
{bonus_remaining <= 0:
    ~ bonus_done = true
    That is enough for now. Follow what the stones can still tell you.#aurora
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
// User ending brief: cover contemplation, walking, a familiar solitary marker.
# ui:notebook_cover
You close the investigation pages. For a while, you look at the black-and-white cover.
All this time, the girl has been standing quietly inside her frame.
You carry the book with you as you walk. The same pale paths pass beneath your feet.
Then, beyond the ordered rows, a single stone catches your eye.
You look down at the cover. You look back at the stone.
~ girl_revealed = true
# event:reveal_girl_marker
-> test_desc_girl

=== test_confrontation ===
// Test completion of 04!B15 and the author's open-ending brief; no verdict choice.
# feedback:gold
The girl, the coffin, the hands. This is not just a similar decoration.#player
I made it. I wrote those pages. And I left.#aurora
~ final_confronted = true
{not (seen_subtexts ? Subtext.final):
        ~ seen_subtexts += Subtext.final
        ~ subtext_count += 1
    }
# event:aurora_confronted
{know(EvidenceTag.mother_remembers_daughter):
    She left the family sculpture here, after you were gone.#player
    I did not know. I could not bring myself to come back and find out.#aurora
}
{know(EvidenceTag.day_night_handholding):
    The handholding picture was still there, in both cities.#player
    She understood something in the end. I wish I had been there to hear it.#aurora
}
I hated the ways she called harm protection. When it was time to leave, I would not take her with us. I was afraid she would bring that world after us. I was angry enough to let that be the whole answer.#aurora
And now?#player
Now I know that an answer can keep you alive and still be something you carry for the rest of your life. I sent you because I could not bear to stand where you are standing.#aurora
You have found what she left. I do not know what she would have said to me.#aurora
+ [Record Aurora as the girl's identity]
    ~ identities += Identity.aurora
    # event:collect_term:aurora
    -> test_radio_girl
+ [Record her departure; leave the conversation open]
    ~ causes += Cause.escape
    # event:collect_term:escape
    -> test_open_ending

=== test_open_ending ===
The radio stays open.
You have enough to describe what happened. There are things a report cannot answer for the people who lived through them.
You leave a space beneath the last line.
# event:open_ending
+ [Return to the test hub] -> test_hub
+ [End] -> END
