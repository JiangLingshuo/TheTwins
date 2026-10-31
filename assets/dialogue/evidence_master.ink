// TWINS - EVIDENCE LIBRARY
// English draft for author revision. Source: current 墓碑表.xlsx.
// This file contains evidence content, not dialogue or acquisition logic.
// Include once from the main file: INCLUDE evidence.ink
// Each knot can be read independently; DONE finishes that evidence read.
//
// PROJECT CONVENTIONS (not automatic Ink behaviour):
// # id = stable evidence identifier; keep it unchanged when editing the prose.
// # title = player-facing title.
// # category = rubbing / manuscript / trace / object / observation / finding.
// # location = where/how the PLAYER obtains this record, not its historical origin.
// # related_location = associated investigation area; not a pickup instruction.
// aurora_transmission means Aurora sends a document/copy to the player.
// Draft default: manuscripts, their copied illustrations, and diary-cover records
// are transmitted by Aurora; confirm any exceptional physical pickups separately.
// Transmission timing/unlock conditions belong to acquisition logic, not these tags.
// # evidence_tag = repeatable inference label, queried by the game.
// A dialogue may accept ANY evidence with the required tag (OR), not all items.
// The game must register these tags and check the evidence currently submitted.
// <link="id">text</link> marks a requested clickable term; UI support is required.
// Read these knots with a separate content reader so opening evidence does not
// move the active dialogue. Metadata alone does not award evidence or findings.
//
// OBSERVATIONS VS. FINDINGS:
// Descriptions preserve what is visible or written. Documents preserve their
// author's beliefs, including prejudice. A tag is not proof of every accusation.
// Findings are separate entries to award ONLY after the relevant comparison or
// dialogue, not when an ingredient is collected. Searchlight dates below are
// author-facing scheduling suggestions, not newly discovered historical facts.
// Raw visual records can be folded into one summary card after a comparison;
// keep their original IDs and tags as aliases of that card.
//
// SEARCHLIGHT TIME METADATA (project conventions, not built-in Ink logic):
// Investigation year: 2050. Dates follow the suggested narrative timeline.
// searchlight_year = year of the visible snapshot, not necessarily creation date.
// searchlight_years_ago = 2050 minus searchlight_year, for the tool dial.
// searchlight_date_status = timeline_suggestion / provisional_ancient_date.
// Year-level precision only; seasonal notes are author-facing scheduling guidance.
// These tags do not implement the tool or change acquisition/unlock logic.
// A negative scan is a range check, not a positive trace at an invented instant.
//
// LATEST RULES OVERRIDE STALE CELLS:
// Scholar: twin beast / disappearance, not moon / natural death.
// Skin picture: revealed clearly by the searchlight.
// Tombstone thickness encodes age; the infant's 1 cm is not treated as "no age".
// The night altar's suspected "coins" are moon-shaped blessing stones.
// The final girl is not confirmed as Aurora until the appropriate deduction.
//
// Existing English in the workbook is used where consistent with current Chinese.
// Source comments and TODOs below are author-facing, never player-facing text.


// ================================================================
// 01 - DAY CITY: THE INFANT
// ================================================================

=== ev_dayfolk_appearance ===
# type:evidence
# id:dayfolk_appearance
# title:The Appearance of the Dayfolk
# category:observation
# location:day_cemetery
# tool: camera
# evidence_tag:dayfolk_appearance
# evidence_tag:human_figure_reference
// Source: 01_婴儿小碑!B9. TODO: choose the actual environmental reference image.
The figure has a smooth face and the familiar outline of the Dayfolk. Its features offer a reference for the human-shaped marker.
-> DONE

=== ev_moon_reference ===
# type:evidence
# id:moon_reference
# title:The Moon Above Night City
# category:observation
# location:night_cemetery
# tool: camera
# evidence_tag:moon_reference
# evidence_tag:moon_motif
// Source: 01_婴儿小碑!B8:B9. The local moon should differ from Earth's moon.
A pale crescent is visible above the cemetery. Its outline resembles the curved decoration on the small marker, although it is not quite the shape of Earth's moon.
-> DONE

=== ev_infant_figure_rubbing ===
# type:evidence
# id:infant_figure_rubbing
# title:The Small Human-Shaped Marker
# category:rubbing
# location:day_cemetery
# evidence_tag:human_figure_reference
# evidence_tag:infant_memorial
# evidence_tag:dayfolk_appearance
// Source: 01_婴儿小碑!B8:B9. Record the image, not the victim's true appearance.
The marker takes the shape of a person rather than the tools of an occupation. Its face follows the smooth appearance of the Dayfolk.
-> DONE

=== ev_infant_moon_rubbing ===
# type:evidence
# id:infant_moon_rubbing
# title:The Small Marker's Curved Decoration
# category:rubbing
# location:day_cemetery
# evidence_tag:moon_motif
// Source: 01_婴儿小碑!B8:B9. Meaning is learned through comparison and dialogue.
A curved shape is carved into the small marker. The rubbing preserves its outline for comparison with the surrounding world.
-> DONE

=== ev_designer_manuscript ===
# type:evidence
# id:designer_manuscript
# title:A Marker for Someone Without an Occupation
# category:manuscript
# location:aurora_transmission
# related_location:day_cemetery
# evidence_tag:infant_identity
# evidence_tag:occupation_marker_custom
# evidence_tag:human_figure_reference
// Source: 01_婴儿小碑!C13. The separate margin note carries the mismatch tag.
A translated copy of designer manuscript
Our cemetery usually represents a person through an icon of their occupation. This burial is different: the deceased is an <link="infant">infant</link> who had not yet been assigned an occupation. None of the existing designs would do.

The family asked us not to define the child by work he had never begun. We chose a human figure instead. The child had no occupation, but he was still a person.

"A child without an occupation is a person before anything else."
-> DONE

=== ev_designer_journal ===
# type:evidence
# id:designer_journal
# title:A Page of the Designer's Journal
# category:manuscript
# location:aurora_transmission
# related_location:day_cemetery
# evidence_tag:infant_appearance_mismatch
# evidence_tag:family_requested_depiction
My <link="student">student</link> visited me with urgency. She showed me a photo of the actual appearance of the infant. I was stunned as I never saw a dayfolk that was born like this. She asked me to design the tombstone with his real appearance, so that he can truly be remembered. I rejected her, as I have having a commission from the infant's parents, not her. She left with disappointment, and perhaps, a little bit of anger. 
-> DONE

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
// Suggested snapshot: 2000 (50 years before investigation), summer, after the infant burial.
// Timing rationale: The sister records her brother after the burial; she is about fourteen.
// Source: 01_婴儿小碑!B10,B15.
// TODO: the artist's identifying mark is not specified in the workbook; do not invent one here.
The searchlight reveals an old sketch of the infant. His appearance differs from the smooth figure chosen for the marker.
-> DONE

=== ev_infant_death_doubt ===
# type:evidence
# id:infant_death_doubt
# title:An Unresolved Death
# category:finding
# location:notebook
# evidence_tag:infant_death_unresolved
# evidence_tag:infant_appearance_mismatch
// Source: 01_婴儿小碑!B7,B15. Award after the evidence-supported reply.
The family's chosen depiction does not match with the records of the infant's appearance. The tombstone's expression of natural death does not settle what actually happened to him. There may be <link="unexplained death">unexplained circumstances</link> behind this death.
-> DONE

=== ev_shared_family_base ===
# type:evidence
# id:shared_family_base
# title:One Base, Three Tombs
# category:observation
# location:day_cemetery
# tool: camera
# evidence_tag:shared_family_plot
# evidence_tag:three_family_markers
# evidence_tag:missing_family_member_reference
// Source: 01!B8; 02!B8; 03_大亨金钱碑!C14.
The small gravestone, the crystal monument, and the sun-shaped monument share one continuous stone base. They are not merely three separate graves standing close together.
-> DONE


// ================================================================
// 02 - DAY CITY: THE SCHOLAR
// ================================================================

=== ev_crystal_marker_rubbing ===
# type:evidence
# id:crystal_marker_rubbing
# title:The Crystal Monument's Outline
# category:rubbing
# location:day_cemetery
# evidence_tag:crystal_shape
# evidence_tag:crystal_research_reference
// Source: 02_学者晶石碑!B8:B9.
The monument is a transparent, many-sided crystal, half black and half white. The rubbing preserves the outline of its facets.
-> DONE

=== ev_scholar_beast_rubbing ===
# type:evidence
# id:scholar_beast_rubbing
# title:The Crystal Monument's Twin Beast
# category:rubbing
# location:day_cemetery
# evidence_tag:twin_beast_motif
# evidence_tag:disappearance_symbol_reference
// Source: 02_学者晶石碑!B8:B9,B15. Supersedes the old moon decoration.
A twin beast is carved on the crystal monument. Its two halves belong to one body, but their appearances differ.
-> DONE

=== ev_night_city_crystal ===
# type:evidence
# id:night_city_crystal
# title:Crystal from Night City
# category:object
# location:night_cemetery
# evidence_tag:crystal_shape
# evidence_tag:night_city_mineral_origin
# evidence_tag:intercity_resource_exchange
// Source: 02_学者晶石碑!B9,B15; 07_夜父石碑!C12.
This mineral was found in Night City. Its facets resemble the outline of the crystal monument in Day City.
-> DONE

=== ev_skin_picture ===
# type:evidence
# id:skin_picture
# title:The Picture Preserved on Skin
# category:trace
# location:day_cemetery
# tool:searchlight
# searchlight_year:2005
# searchlight_years_ago:45
# searchlight_date_status:timeline_suggestion
# evidence_tag:day_night_handholding
# evidence_tag:skin_as_message_medium
# evidence_tag:shared_body_reference
// Suggested snapshot: 2005 (45 years before investigation), autumn, the mother's final days.
// Timing rationale: The Scholar and Night Mother exchange the picture shortly before their shared death.
// Source: 02_学者晶石碑!B8,B10.
Rewound to a time before the skin decayed, the searchlight reveals the picture clearly. A member of the Dayfolk and a member of the Nightfolk reach out and clasp hands.

The lines are formed by blue blood seeping through the skin. A skin drawing with unexplained reason.
-> DONE

=== ev_disappearance_inquiry ===
# type:evidence
# id:disappearance_inquiry
# title:The Scholar's Notes on Disappearances
# category:manuscript
# location:aurora_transmission
# related_location:day_cemetery
# evidence_tag:dawn_disappearances
# evidence_tag:unexplained_waking_wounds
# evidence_tag:sleep_coffin_required
# evidence_tag:husband_disappearance
# evidence_tag:day_city_bias
// Source: 02_学者晶石碑!C12. These are the author's beliefs, not objective narration.
The unexplained <link="disappearance">disappearances</link> in Day City are always reported at dawn, when people wake.

The Dayfolk's bodies are unusual. Anyone who fails to enter a sleeping coffin on time will die. Once inside, however, they lose all awareness and ability to act for the entire night, under the coffin's complete protection.

Who has been tampering with their sleeping coffins? I cannot investigate the movements of the Nightfolks while they are awake. I can only suspect that, while taking our food, they have also done something to my husband and my people.

It is not only disappearances. Many of us, myself included, have found <link="fresh_wounds">fresh wounds</link> upon waking. Given the Nightfolk's habit of plundering, they are most likely responsible. I must remain vigilant.
-> DONE

=== ev_profession_record ===
# type:evidence
# id:profession_record
# title:The Scholar, Her Work, and Her Patron
# category:manuscript
# location:aurora_transmission
# related_location:day_cemetery
# evidence_tag:scholar_identity
# evidence_tag:tycoon_identity
# evidence_tag:crystal_research_reference
# evidence_tag:scholar_tycoon_marriage
# evidence_tag:family_mausoleum_custom
// Source: 02_学者晶石碑!C13. The older English says no relatives are named; that is obsolete.
The record describes a Day City resident who first studied this transparent mineral and discovered the energy within it. She was granted the title of <link="scholar">Scholar</link>.

The stones were later used to power machinery. The occupational title thus became associated with crystal research.

A young man from a wealthy family was the first to invest in her research. He later became her husband and came to be known as the <link="tycoon">Tycoon</link>.

In recognition of her outstanding contributions to Day City, the Scholar may apply for a mausoleum beyond the usual grave-marker design and have her family interred within it. For the Dayfolk, who place such importance on the rituals of death, this is the highest honor.
-> DONE

=== ev_one_way_passage_order ===
# type:evidence
# id:one_way_passage_order
# title:An Order for a One-Way Passage
# category:manuscript
# location:aurora_transmission
# related_location:day_cemetery
# evidence_tag:one_way_passage
# evidence_tag:intercity_resource_exchange
# evidence_tag:night_city_supply_blockade
# evidence_tag:day_city_bias
// Source: 02_学者晶石碑!C14. Preserve the issuing authority's prejudiced wording.
An order to the Scholar: We must put an end to Nightfolk incursions at their source.

They were once allowed to take our food in exchange for the crystals they excavated. Now they neglect their work, yet continue to demand more and more from Day City.

A one-way passage must be established: the Dayfolk may descend, but the Nightfolk must not be allowed to ascend.
-> DONE


// ================================================================
// 03 - DAY CITY: THE SUN-SHAPED MONUMENT
// ================================================================

=== ev_sun_reference ===
# type:evidence
# id:sun_reference
# title:The Sun Above Day City
# category:observation
# location:day_cemetery
# tool: camera
# evidence_tag:sun_shape
# evidence_tag:sun_motif
// Scene reference for the sun-shaped monument and the pointed outlines of Day City coins.
// A shared outline supports comparison; it does not establish the deceased's occupation.
The bright sun above Day City offers a possible reference for the monument's radiating outline. The same sun-like outline can also be compared with the pointed rims of Day City coins.
-> DONE

=== ev_sun_shaped_marker_rubbing ===
# type:evidence
# id:sun_shaped_marker_rubbing
# title:The Sun-Shaped Monument
# category:rubbing
# location:day_cemetery
# evidence_tag:sun_shape
# evidence_tag:sun_motif
// Source: 03_大亨金钱碑!B8:B9.
Radiating points surround the monument like a shining sun. The rubbing records its distinctive outline.
-> DONE

=== ev_sun_shaped_beast_rubbing ===
# type:evidence
# id:sun_shaped_beast_rubbing
# title:The Sun-Shaped Monument's Twin Beast
# category:rubbing
# location:day_cemetery
# evidence_tag:twin_beast_motif
# evidence_tag:disappearance_symbol_reference
// Source: 03_大亨金钱碑!B8:B9.
A small creature occupies the center of the monument. One half looks different from the other, although both are joined to the same body.
-> DONE

=== ev_day_city_coin ===
# type:evidence
# id:day_city_coin
# title:A Coin from the Wishing Pool
# category:object
# tool:searchlight
# searchlight_year:1990
# searchlight_years_ago:60
# location:day_cemetery
# evidence_tag:sun_shape
# evidence_tag:day_city_currency
# evidence_tag:sun_motif
// Source: 03_大亨金钱碑!B9. Do not confuse this with Night City's blessing stones.
Circulating coins once lay in the wishing pool beneath the ram-spirit emblem. Their pointed rims form a sun-like outline, similar to the sun-shaped monument. The pool fell out of use as technology developed and people turned to other beliefs.
-> DONE

=== ev_ram_spirit_emblem ===
# type:evidence
# id:ram_spirit_emblem
# title:The Ram-Spirit Emblem
# category:rubbing
# location:day_cemetery
# evidence_tag:day_city_belief
# evidence_tag:ram_spirit_motif
// Source: 03_大亨金钱碑!B9. Its later use is not yet specified.
A ram-spirit emblem stands above the wishing pool. It belongs to the religious imagery of Day City.
-> DONE

=== ev_giant_footprint ===
# type:evidence
# id:giant_footprint
# title:A Giant Footprint in the Ruins
# category:observation
# location:day_city_ruins
# tool: camera
# evidence_tag:ancient_creature_trace
# evidence_tag:twin_beast_reference
// Source: 03_大亨金钱碑!B9.
A vast footprint remains in the ruins. The print alone does not reveal the full appearance of the creature that left it.
-> DONE

=== ev_twin_beast_trace ===
# type:evidence
# id:twin_beast_trace
# title:The Creature Revealed Above the Footprint
# category:trace
# location:day_city_ruins
# tool:searchlight
# searchlight_year:1800
# searchlight_years_ago:250
# searchlight_date_status:provisional_ancient_date
# evidence_tag:twin_beast_motif
# evidence_tag:twin_beast_reference
# evidence_tag:contrasting_halves
// Suggested snapshot: 1800 (250 years before investigation), before Day City was founded; provisional placeholder.
// Timing rationale: Ancient-history date only: 1800 is a suggested tool setting, NOT established chronology. It must precede Day City's founding; revise when the founding/separation dates are fixed.
// Source: 03_大亨金钱碑!B9.
The searchlight reveals the creature that once occupied this space: one body with two strikingly different halves. Its outline can be compared with the small beasts carved on the monuments.
-> DONE

=== ev_twin_beast_account ===
# type:evidence
# id:twin_beast_account
# title:An Account of the Twin-Bodied Creature
# category:manuscript
# location:aurora_transmission
# related_location:day_cemetery
# evidence_tag:twin_beast_reference
# evidence_tag:contrasting_halves
# evidence_tag:ancient_disappearance
// Source: 03_大亨金钱碑!C13.
Legend tells of a twin-bodied creature that lived here before Day City was founded. Its two halves looked entirely different: one was covered in fur, with narrow eyes; the other was smooth, with clearly visible eyes.

Then, in a single night, they disappeared.
-> DONE

=== ev_repeated_beast_motifs ===
# type:evidence
# id:repeated_beast_motifs
# title:The Same Beast on Other Graves
# category:observation
# location:day_cemetery
# tool: camera
# evidence_tag:twin_beast_motif
# evidence_tag:repeated_local_symbol
// Source: 03_大亨金钱碑!B8. Frequency alone does not establish meaning.
The same twin beast appears on several other markers in Day City. It is not a decoration unique to the sun-shaped monument.
-> DONE

=== ev_family_photo ===
# type:evidence
# id:family_photo
# title:A Photograph of Four
# category:trace
# location:day_cemetery
# tool:searchlight
# searchlight_year:2000
# searchlight_years_ago:50
# searchlight_date_status:timeline_suggestion
# evidence_tag:four_person_family
# evidence_tag:missing_family_member_reference
# evidence_tag:family_image_reference
// Suggested snapshot: 2000 (50 years before investigation), summer or autumn, after the father's memorial is erected.
// Timing rationale: The photograph shows the earlier family of four; the searchlight date is when it stood at the grave, NOT when the photograph was taken.
// Source: 03_大亨金钱碑!B10,B15.
A photograph once stood in front of the monument. It shows four members of a family. There are only three markers on the shared base.
-> DONE


// ================================================================
// 04 - NIGHT CITY: THE INFANT'S ALTAR
// ================================================================

=== ev_altar_infant_rubbing ===
# type:evidence
# id:altar_infant_rubbing
# title:The Infant on the White Altar
# category:rubbing
# location:night_cemetery
# evidence_tag:infant_memorial
# evidence_tag:night_infant_reference
// Source: 05_婴儿夜城祭坛!B8:B9. Preserve a comparable image; do not assert a shared identity yet.
An infant rests on the white, house-shaped altar. The pose differs slightly from the human-shaped marker in Day City, but the two images invite comparison.
-> DONE

=== ev_altar_path_rubbing ===
# type:evidence
# id:altar_path_rubbing
# title:The Altar's Unending Path
# category:rubbing
# location:night_cemetery
# evidence_tag:endless_path_motif
# evidence_tag:night_departure_reference
// Source: 05_婴儿夜城祭坛!B8.
A path runs along the altar's pillars. Its pattern has no visible end.
-> DONE

=== ev_altar_blessing_glyph ===
# type:evidence
# id:altar_blessing_glyph
# title:An Unfamiliar Glyph on the Altar
# category:rubbing
# location:night_cemetery
# evidence_tag:night_blessing_glyph
# evidence_tag:night_symbol_translation
# evidence_tag:aurora_translation_knowledge
// Source: 05_婴儿夜城祭坛!B9. The translation is a separate finding below.
An unfamiliar symbol is carved into the altar. It does not resemble a passage of written text.
-> DONE

=== ev_altar_blessing_translation ===
# type:evidence
# id:altar_blessing_translation
# title:A Blessing for the Unending Journey
# category:finding
# location:notebook
# evidence_tag:night_blessing_glyph
# evidence_tag:night_symbol_translation
# evidence_tag:endless_path_motif
# evidence_tag:aurora_translation_knowledge
// Source: 05_婴儿夜城祭坛!B9. Award after Aurora interprets the glyph.
Aurora interprets the symbol as a blessing:

"To disappear is to set out on a journey without end. May the wishes of crystal remain with you."
-> DONE

=== ev_crystal_god_rubbing ===
# type:evidence
# id:crystal_god_rubbing
# title:The Crystal God's Outline
# category:rubbing
# location:night_cemetery
# evidence_tag:crystal_god_motif
# evidence_tag:night_city_belief
// Source: 05_婴儿夜城祭坛!B8.
The altar's decoration preserves the outline of the Crystal God, but the place where the crystals once stood is now empty.
-> DONE

=== ev_removed_crystal_god ===
# type:evidence
# id:removed_crystal_god
# title:The Crystal Figure That Once Stood Here
# category:trace
# location:night_cemetery
# tool:searchlight
# searchlight_year:2000
# searchlight_years_ago:50
# searchlight_date_status:timeline_suggestion
# evidence_tag:crystal_god_motif
# evidence_tag:removed_crystal_offering
# evidence_tag:crystal_extraction_reference
// Suggested snapshot: 2000 (50 years before investigation), summer, shortly after the infant altar is dedicated.
// Timing rationale: Show the crystal figure intact before its later removal. Its removal date remains unconfirmed; this snapshot does not identify the remover.
// Source: 05_婴儿夜城祭坛!B8,B10. The raw image does not identify who removed it.
In the searchlight's view of the past, crystals fill the altar's empty recess and form the figure of a god. Today the crystals have been pried out.
-> DONE

=== ev_altar_moon_stone ===
# type:evidence
# id:altar_moon_stone
# title:A Moon-Shaped Stone on the Altar
# category:trace
# location:night_cemetery
# tool:searchlight
# searchlight_year:2000
# searchlight_years_ago:50
# searchlight_date_status:timeline_suggestion
# evidence_tag:moon_stone_offering
# evidence_tag:night_blessing_reference
# evidence_tag:moon_motif
// Suggested snapshot: 2000 (50 years before investigation), summer, during mourning for the missing infant.
// Timing rationale: The blessing stone is present among the infant altar offerings.
// Source: 05_婴儿夜城祭坛!B10,B13. Not identified as money.
A moon-shaped stone once lay among the altar's offerings. It resembles a small token, but there is nothing here that establishes its value as currency.
-> DONE

=== ev_crystal_god_prophecy ===
# type:evidence
# id:crystal_god_prophecy
# title:The Crystal God's Prophecy
# category:manuscript
# location:aurora_transmission
# related_location:night_cemetery
# evidence_tag:night_infant_reference
# evidence_tag:smooth_skinned_child
# evidence_tag:night_city_belief
# evidence_tag:aurora_translation_knowledge
// Source: 05_婴儿夜城祭坛!C11,B13. The source of the recorded oral tradition remains to be specified.
A legend of the Crystal God:

"When an infant with skin as smooth as crystal comes to Night City, the Nightfolk will see the light once more."
-> DONE

=== ev_moon_stone_blessing ===
# type:evidence
# id:moon_stone_blessing
# title:A Blessing, Not a Payment
# category:finding
# location:notebook
# evidence_tag:moon_stone_offering
# evidence_tag:night_blessing_reference
# evidence_tag:different_exchange_customs
// Source: 05_婴儿夜城祭坛!B13. Award after the relevant interpretation, not on first pickup.
The moon-shaped stones are offerings of blessing, not coins. The Nightfolk do not leave them as payment for goods or mark territory through them. A stone left for someone expresses a wish for their well-being.
-> DONE

=== ev_infant_memorial_correspondence ===
# type:evidence
# id:infant_memorial_correspondence
# title:Two Memorials to an Infant
# category:finding
# location:notebook
# evidence_tag:infant_memorial
# evidence_tag:paired_day_night_memorials
# evidence_tag:contradictory_death_accounts
// Source: 05_婴儿夜城祭坛!B9,B13. Award only after the two infant images are compared.
The human-shaped marker in Day City corresponds to the infant memorial in Night City. One city describes a death; the other commemorates a <link="disappearance">disappearance</link>.
-> DONE


// ================================================================
// 05 - NIGHT CITY: THE MOTHER
// ================================================================

=== ev_night_mother_child_rubbing ===
# type:evidence
# id:night_mother_child_rubbing
# title:A Figure Holding a Child
# category:rubbing
# location:night_cemetery
# evidence_tag:night_infant_reference
# evidence_tag:parent_child_image
# evidence_tag:night_mother_past
// Source: 06_夜母石碑!B8:B9. Upper field: the deceased's past/material life.
The upper part of the small stone shows a figure holding a child. The child can be compared with the infant on the altar.
-> DONE

=== ev_night_mother_hands_rubbing ===
# type:evidence
# id:night_mother_hands_rubbing
# title:Two Figures Holding Hands
# category:rubbing
# location:night_cemetery
# evidence_tag:day_night_handholding
# evidence_tag:night_mother_future
# evidence_tag:shared_body_reference
// Source: 06_夜母石碑!B8:B9. Lower field: a future/wish, not a literal event date.
Below the figure holding a child, a member of the Dayfolk and a member of the Nightfolk hold their hands. The arrangement resembles the picture preserved inside the Scholar's crystal monument.
-> DONE

=== ev_night_mother_river_rubbing ===
# type:evidence
# id:night_mother_river_rubbing
# title:The Dry River Around the Stone
# category:rubbing
# location:night_cemetery
# evidence_tag:dry_river_motif
# evidence_tag:night_mother_death_reference
// Source: 06_夜母石碑!B8:B9.
Cracked lines surround the stone like the bed of a dried river. They form the border of the memorial rather than a separate scene in either half.
-> DONE

=== ev_dry_underground_river ===
# type:evidence
# id:dry_underground_river
# title:The Underground Riverbed
# category:observation
# location:night_city
# tool: camera
# evidence_tag:dry_river_motif
# evidence_tag:water_source_lost
// Source: 06_夜母石碑!B9,B12.
The underground river has dried up. Its exposed bed preserves the cracked pattern seen around the small stone.
-> DONE

=== ev_night_mother_no_traces ===
# type:evidence
# id:night_mother_no_traces
# title:No Readable Traces Around the Stone
# category:observation
# location:night_cemetery
# tool:searchlight
# searchlight_scan_start_year:2005
# searchlight_scan_end_year:2050
# searchlight_scan_years_ago_min:0
# searchlight_scan_years_ago_max:45
# searchlight_date_status:timeline_suggestion
# evidence_tag:absence_of_readable_traces
# evidence_tag:last_survivor_question
// Negative scan: after the mother's death in autumn 2005 through the 2050 investigation.
// Do not unlock this absence finding from a single dial setting; check the relevant post-burial range.
// Source: 06_夜母石碑!B10,B12. Do not award "last survivor" from absence alone.
The searchlight reveals no discernible traces around this stone. There is no record here of later visitors or offerings.
-> DONE

=== ev_night_mother_death_finding ===
# type:evidence
# id:night_mother_death_finding
# title:The Meaning of the Dry River Border
# category:finding
# location:notebook
# evidence_tag:night_mother_death_reference
# evidence_tag:death_by_hunger_and_thirst
# evidence_tag:water_source_lost
// Source: 06_夜母石碑!B12. Award after comparing the border with the riverbed and interpreting it.
The dry river border records a death from <link="thirst">hunger and thirst</link>. It connects the mother's fate with the loss of the underground water source.
-> DONE


// ================================================================
// 06 - NIGHT CITY: THE FATHER
// ================================================================

=== ev_night_father_child_rubbing ===
# type:evidence
# id:night_father_child_rubbing
# title:A Figure Carrying a Child
# category:rubbing
# location:night_cemetery
# evidence_tag:night_infant_reference
# evidence_tag:parent_child_image
# evidence_tag:night_father_past
// Source: 07_夜父石碑!B8:B9.
The figure on the upper part of the stone carries a child on his back. The child can be compared with the infant on the altar.
-> DONE

=== ev_night_father_path_rubbing ===
# type:evidence
# id:night_father_path_rubbing
# title:A Figure Ascending the Path
# category:rubbing
# location:night_cemetery
# evidence_tag:ascending_path_motif
# evidence_tag:night_father_final_journey
// Source: 07_夜父石碑!B8:B9.
A figure climbs an upward path along the border of the stone. The route resembles the passage known as the Skyway.
-> DONE

=== ev_night_father_god_rubbing ===
# type:evidence
# id:night_father_god_rubbing
# title:The Crystal God Below the Father
# category:rubbing
# location:night_cemetery
# evidence_tag:crystal_god_motif
# evidence_tag:night_city_belief
// Source: 07_夜父石碑!B8:B9. Lower field: faith/future.
The lower part of the stone bears the image of the Crystal God. It resembles the figure once installed on the infant's altar.
-> DONE

=== ev_night_father_moon_stone ===
# type:evidence
# id:night_father_moon_stone
# title:A Moon-Shaped Stone Before the Father's Marker
# category:trace
# location:night_cemetery
# tool:searchlight
# searchlight_year:2000
# searchlight_years_ago:50
# searchlight_date_status:timeline_suggestion
# evidence_tag:moon_stone_offering
# evidence_tag:night_blessing_reference
# evidence_tag:moon_motif
// Suggested snapshot: 2000 (50 years before investigation), summer or autumn, shortly after the father's death.
// Timing rationale: The father dies days or weeks after the infant. Allow time for his marker and the blessing offering.
// Source: 07_夜父石碑!B10.
A moon-shaped stone once lay before the father's marker. It resembles the stones left as offerings on the infant's altar.
-> DONE

=== ev_natural_collapse_record ===
# type:evidence
# id:natural_collapse_record
# title:The Collapse That Sealed the Road
# category:manuscript
# location:aurora_transmission
# related_location:night_cemetery
# evidence_tag:shared_day_night_history
# evidence_tag:original_separation
# evidence_tag:natural_collapse
// Source: 07_夜父石碑!C11. This excerpt belongs to the banned Day City history.
...Before the division of day and night, the People of Sun and Moon lived together. After the separation into upper and lower cities, a <link="natural_collapse">natural collapse</link> sealed the road to the surface.
-> DONE

=== ev_skyway_history ===
# type:evidence
# id:skyway_history
# title:An Account of the Skyway
# category:manuscript
# location:aurora_transmission
# related_location:night_cemetery
# evidence_tag:ascending_path_motif
# evidence_tag:skyway_not_steep
# evidence_tag:intercity_resource_exchange
# evidence_tag:night_city_mineral_origin
// Source: 07_夜父石碑!C12. "Skyway" is a provisional translation of 天梯, not a literal ladder.
The Skyway is a path cleared upward through fallen stone. It is uneven, but not steep.

Searching for food and water, the Nightfolk dug and climbed in every direction. At last, they opened a route upward through the collapsed ruins.

The Dayfolk called the day they arrived "the Day Darkness Descended." Much food and many livestock were taken before the Dayfolk even knew who had done it. Eventually, they discovered the passage to Night City.

The reopened route also led the Dayfolk to the shining stones the Nightfolk had excavated while searching for food and water: crystals that would later power Day City's development.

The exchange continued with each cycle of day and night. The Dayfolk brought back crystals; the Nightfolk brought back food. Each took what they needed. This balance lasted a long time.
-> DONE

=== ev_skyway_reference ===
# type:evidence
# id:skyway_reference
# title:The Path to the Surface
# category:observation
# location:skyway
# tool: camera
# evidence_tag:ascending_path_motif
# evidence_tag:skyway_not_steep
# evidence_tag:night_father_final_journey
// Source: 07_夜父石碑!B9,B14. Do not add dated search marks absent from this workbook.
An uneven path rises through the fallen stone toward the surface. It is not the sheer climb its name might suggest. Its shape corresponds to the ascending route carved around the father's stone.
-> DONE

=== ev_night_father_death ===
# type:evidence
# id:night_father_death
# title:The Father's Search Beyond His Waking Hours
# category:finding
# location:notebook
# evidence_tag:sleep_coffin_required
# evidence_tag:missed_sleeping_deadline
# evidence_tag:night_father_final_journey
# evidence_tag:paired_day_night_death
// Source: 07_夜父石碑!B14. Award after the relevant dialogue establishes this conclusion.
The father left to search for the missing infant. The path itself was not a dangerous climb. He continued searching <link="missed_sleeping_deadline">beyond the permitted waking hours</link> and failed to return to a sleeping coffin in time.

His death can be compared with the report of the Scholar's husband disappearing at dawn.
-> DONE

=== ev_paired_skin_pictures ===
# type:evidence
# id:paired_skin_pictures
# title:A Picture Across Day and Night
# category:finding
# location:notebook
# evidence_tag:day_night_handholding
# evidence_tag:skin_as_message_medium
# evidence_tag:unexplained_waking_wounds
# evidence_tag:shared_body_reference
// Source: 06_夜母石碑!B12; 02_学者晶石碑!B10,C12. Award after comparison/interpretation.
The handholding figures on the mother's stone correspond to the blue marks on the Scholar's preserved skin. Together with the records of wounds appearing upon waking, they suggest that the body itself could carry a message between day and night.
-> DONE


// ================================================================
// 07 - THE FINAL GIRL'S MARKER
// ================================================================

=== ev_girl_figure_rubbing ===
# type:evidence
# id:girl_figure_rubbing
# title:The Girl Inside the Frame
# category:rubbing
# location:cemetery_edge
# evidence_tag:human_figure_reference
# evidence_tag:girl_memorial
// Source: 04_小女孩终局碑!B7,C12,B15. Resemblance alone does not make her an infant.
Another human figure appears on this marker, older than the infant represented by the small stone. A structure surrounds her body.
-> DONE

=== ev_girl_coffin_rubbing ===
# type:evidence
# id:girl_coffin_rubbing
# title:The Upright Frame Around the Girl
# category:rubbing
# location:cemetery_edge
# evidence_tag:upright_coffin_motif
# evidence_tag:girl_memorial
// Source: 04_小女孩终局碑!B7,B9.
The girl stands inside an upright structure with her hands joined before her chest. The surrounding frame can be compared with the illustration in the old history book.
-> DONE

=== ev_girl_beast_rubbing ===
# type:evidence
# id:girl_beast_rubbing
# title:The Girl's Twin-Beast Decoration
# category:rubbing
# location:cemetery_edge
# evidence_tag:twin_beast_motif
# evidence_tag:disappearance_symbol_reference
// Source: 04_小女孩终局碑!B8. Do not label this "escape" until interpreted.
A twin beast decorates the marble-like marker. It resembles the creatures carved on other Day City monuments.
-> DONE

=== ev_girl_path_rubbing ===
# type:evidence
# id:girl_path_rubbing
# title:The Unending Path Around the Girl
# category:rubbing
# location:cemetery_edge
# evidence_tag:endless_path_motif
# evidence_tag:night_departure_reference
// Source: 04_小女孩终局碑!B8.
The edge of the upright frame carries the pattern of an unending path. It recalls the border on the infant's altar in Night City.
-> DONE

=== ev_girl_signature_rubbing ===
# type:evidence
# id:girl_signature_rubbing
# title:The Girl-and-Coffin Motif
# category:rubbing
# location:cemetery_edge
# evidence_tag:girl_coffin_motif
# evidence_tag:girl_memorial
# evidence_tag:author_identity_reference
// Source: 04_小女孩终局碑!B8:B9,B15. Use the whole arrangement, not just the frame.
The girl, her joined hands, and the upright coffin form a single composition. This complete motif can be compared with the covers of the diary and the investigation notebook.
-> DONE

=== ev_family_statuette ===
# type:evidence
# id:family_statuette
# title:A Statuette of Four
# category:trace
# location:cemetery_edge
# tool:searchlight
# searchlight_year:2005
# searchlight_years_ago:45
# searchlight_date_status:timeline_suggestion
# evidence_tag:four_person_family
# evidence_tag:family_image_reference
# evidence_tag:mother_remembers_daughter
// Suggested snapshot: 2005 (45 years before investigation), summer, after the girl leaves and before the mother dies.
// Timing rationale: The mother leaves the girl's earlier sculpture at her solitary marker after her departure.
// Source: 04_小女孩终局碑!B10,B15. No additional inscription is specified.
A small sculpture of four family members once stood before the marker. It was carved by the girl and left here by her mother. Its figures can be compared with the photograph at the sun-shaped monument.
-> DONE

=== ev_day_city_history ===
# type:evidence
# id:day_city_history
# title:A History of Day City
# category:manuscript
# location:aurora_transmission
# related_location:cemetery_edge
# evidence_tag:shared_day_night_history
# evidence_tag:sleep_coffin_required
# evidence_tag:upright_coffin_motif
# evidence_tag:population_decline
// Source: 04_小女孩终局碑!C11. Historical claims remain the book's account.
This history was a <link="banned_book">banned book</link> until it was discovered.

Both Dayfolk and Nightfolk must rest in their <link="sleeping_coffin">sleeping coffins</link> at the proper time if they are to awaken the following day.

Before their division, they were known together as the <link="sun_moon_people">People of Sun and Moon</link>. Some had the daylight; others had the moonlit night.

In their shared residential districts, sleeping coffins stood upright to conserve space. Later, when the Nightfolk moved underground, the <link="population_decline">number of people on the surface decreased</link>. Space was no longer scarce, and the Dayfolk developed the habit of lying down in their coffins.

The Nightfolk placed theirs underground, where the darkness of the caves made them almost indistinguishable from the surrounding floor.
-> DONE

=== ev_history_coffin_illustration ===
# type:evidence
# id:history_coffin_illustration
# title:An Upright Sleeping Coffin
# category:rubbing
# location:aurora_transmission
# related_location:cemetery_edge
# evidence_tag:upright_coffin_motif
# evidence_tag:shared_day_night_history
// Source: 04_小女孩终局碑!B9,B11. The illustration can be copied and compared.
An illustration in the old history book shows a sleeping coffin standing upright. Its outline resembles the structure surrounding the girl on the solitary marker.
-> DONE

=== ev_girl_diary ===
# type:evidence
# id:girl_diary
# title:A Diary Page, Author Unknown
# category:manuscript
# location:aurora_transmission
# related_location:cemetery_edge
# evidence_tag:author_identity_reference
# evidence_tag:funerary_artist_reference
# evidence_tag:deliberate_departure
# evidence_tag:two_mothers_dilemma
# evidence_tag:resentment_toward_mother
// Source: 04_小女孩终局碑!B13,C13. Preserve its anger; do not add forgiveness or a verdict.
If the truth of death itself is being covered up, then <link="diary_complicity">am I not an accomplice when I carve monuments to that lie</link>?

I can no longer bear this <link="diary_hypocrisy">hypocritical world</link>. If even one person had stopped to question what was wrong with the world we lived in, perhaps we would never have come to this.

I once loved and respected my mother so much. She was my example from childhood. But first she failed to protect my brother; then she blamed my father's disappearance on others. Even when I tried to tell her the truth about our world, she insisted that useless sympathy would destroy Day City.

How many more times must we hurt our own people in the name of protecting them?

She left me a message on my windowsill when she came to the Day City. She is so intelligent that she acquired the language of Day City just by observing the surroundings and reading the library, and she found out my identity as her correspondence just by the messages conveyed by the stones. She said there was an old site in the ruins, with sleeping coffins that could keep the two of us alive.

She wants to bring her mother. But <link="diary_mothers">if she brings her mother, we will have to bring mine</link>. With my mother's influence in Day City, everyone will find out. We will go through it all again.

I have to persuade her. We can only <link="diary_escape">escape on our own</link>. The One-way Passage Order is launching soon. We need to act fast.
-> DONE

=== ev_diary_cover ===
# type:evidence
# id:diary_cover
# title:The Motif on the Diary Cover
# category:observation
# location:aurora_transmission
# related_location:cemetery_edge
# evidence_tag:girl_coffin_motif
# evidence_tag:author_identity_reference
# evidence_tag:well_preserved_diary
// Source: 04_小女孩终局碑!B13. "As new" is observable; do not assign a placement date.
The diary remains intact, as if new. It seems that it's not part of the remains collected by previous archaeologists. Its cover bears the image of a girl standing inside an upright coffin, hands joined before her chest.
-> DONE

=== ev_notebook_cover ===
# type:evidence
# id:notebook_cover
# title:The Cover of Your Investigation Notebook
# category:observation
# location:field_notebook
# evidence_tag:girl_coffin_motif
# evidence_tag:author_identity_reference
# evidence_tag:aurora_provided_object
// Source: 04_小女孩终局碑!B8:B9,B15; user-authored opening identifies the notebook as Aurora's.
Aurora gave you this black-and-white notebook. On its cover, a girl stands inside an upright coffin, hands joined before her chest.

You have been carrying the image throughout your investigation, holding it like the girl in the monument.
-> DONE

=== ev_four_person_family_finding ===
# type:evidence
# id:four_person_family_finding
# title:Four People Remembered, Three Graves Together
# category:finding
# location:notebook
# evidence_tag:four_person_family
# evidence_tag:missing_family_member_reference
# evidence_tag:mother_remembers_daughter
// Source: 03!B10,B15; 04_小女孩终局碑!B10,B15. Award after the photo/statuette comparison.
The four figures in the statuette correspond to the family in the photograph. The shared base holds only three markers. The solitary girl's marker stands apart from that family plot.
-> DONE

=== ev_girl_cover_correspondence ===
# type:evidence
# id:girl_cover_correspondence
# title:The Same Girl on Stone and Paper
# category:finding
# location:notebook
# evidence_tag:girl_coffin_motif
# evidence_tag:author_identity_reference
# evidence_tag:aurora_identity_reference
// Source: 04_小女孩终局碑!B9,B15. Award after an actual cover/marker comparison.
The complete girl-and-coffin composition on the solitary marker corresponds to the image on the diary or the investigation notebook. The person who made the monument, the writer, and the person who supplied the notebook may be connected.
-> DONE

// END OF EVIDENCE LIBRARY.
// Not included: radio replies, bonus questions, report dropdown definitions,
// unresolved chronology, or extra callback objects invented only for the HTML prototype.
