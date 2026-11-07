// Tutorial/opening text master. Standalone preview; do not INCLUDE into telecomm_master.ink.
VAR player_name = "Investigator"
-> tutorial_text_index

=== tutorial_text_index ===
+ [开场] -> chat_start
+ [弧形与月亮] -> chat_tutorial_sun_moon
+ [首次进入夜城] -> chat_tutorial_night_arrival
+ [返回昼城] -> chat_tutorial_day_return
+ [登记婴儿碑] -> chat_tutorial_recorded
+ [收集手稿关键词] -> chat_tutorial_keyword_noted
+ [探照灯教学] -> chat_tutorial_searchlight_intro
+ [发现婴儿涂鸦] -> chat_tutorial_searchlight_found
+ [进入无线电] -> chat_tutorial_radio_ready
+ [隐藏提问教学] -> chat_tutorial_hidden_question
+ [填写调查报告] -> chat_tutorial_report_intro
+ [新手调查结束] -> chat_tutorial_investigation_complete
+ [相机登场] -> chat_tutorial_camera_intro
+ [相机基座观察] -> chat_tutorial_camera_connections
+ [开始正式调查] -> chat_tutorial_camera_outro
+ [End] -> END

=== chat_start ===
# runtime_xml:start.xml
// line_id:chat_start:001
Oh, my notebook’s in black and white. #player
// line_id:chat_start:002
Aurora never told me why. I guess it’s an aesthetic choice. #player
// line_id:chat_start:003
... #??
// line_id:chat_start:004
...Hello? Can you hear me? #??
// line_id:chat_start:005
(It doesn't take you a second to realize who's speaking. That's the first time you hear her voice beyond your textual exchange. Her voice is huskier than you thought.) #narrator
// line_id:chat_start:006
Aurora? Is that you? The connection’s finally back. I’ve landed safely on Twins. #player
// line_id:chat_start:007
Glad you’re safe! I hope the trip wasn’t too rough. Have you had a chance to look through your handbook? #aurora
// line_id:chat_start:008
Yeah, I was just looking at it. Interesting color scheme. #player
// line_id:chat_start:009
There’s a reason for it. Seen from space, Twins is a planet in black and white... Just like the civilization that once lived there. Of course, that’s a bonus to the name. It was first named the Twins because its day and night align with Earth’s, despite the distance between them. #aurora
// line_id:chat_start:010
Should I expect to meet anyone here? #player
// line_id:chat_start:011
No, but you’ll find their traces—a fallen civilization of two cities. Our archaeologists have searched their libraries, their homes, their schools. All the places where they lived. But there’s one place they overlooked. #aurora
// line_id:chat_start:012
Where? #player
// line_id:chat_start:013
(You might have an answer in mind. But you wait for her confirmation.) #narrator
// line_id:chat_start:014
Where they remembered the dead. The cemeteries. That’s your mission: to uncover what words alone cannot tell us, through the memories they left behind. #aurora
// line_id:chat_start:015
We don’t have much transmission time left. I have to go. Talk to you later. #aurora
// line_id:chat_start:016
(Now it’s just you, your handbook, and the faint breath of the planet.) #narrator
// line_id:chat_start:017
(You feel a tremor in your limbs.) #narrator
// line_id:chat_start:018
(You stand up. The faint breeze brushing past your ears feels much like the wind back home. Perhaps the people who once lived here weren’t so different from you, either.) #narrator
// line_id:chat_start:019
(You’re here to gather their memories. Your steps grow steadier.) #narrator
// line_id:chat_start:020
(Then you see it: the place where an entire civilization rests.) #narrator
-> END

=== chat_tutorial_sun_moon ===
# runtime_xml:tutorial_sun_moon.xml
// line_id:chat_tutorial_sun_moon:001
There seems to be a crescent shape on the base. #aurora
// line_id:chat_tutorial_sun_moon:002
Kinda similar to the shape of the moon on Earth. #player
// line_id:chat_tutorial_sun_moon:003
Try it. #aurora
-> END

=== chat_tutorial_night_arrival ===
# runtime_xml:tutorial_night_arrival.xml
// line_id:chat_tutorial_night_arrival:001
Wow, where have I been? #player
// line_id:chat_tutorial_night_arrival:002
You relocated to the underground Night City, and had a good rest until the moon rose. #aurora
// line_id:chat_tutorial_night_arrival:003
How come I wasn't aware of anything? #player
// line_id:chat_tutorial_night_arrival:004
It's the magical notebook playing a trick on you… (She giggles.) Just kidding. Previous archaeologists observed something similar. Your consciousness in Day and Night seems to separate on the Twins. #aurora
// line_id:chat_tutorial_night_arrival:005
Then how should I proceed with my investigation? #player
// line_id:chat_tutorial_night_arrival:006
Use the notebook to record and compare. Ask about each city at its own time of day: Day City in daylight, Night City at night. #aurora
// line_id:chat_tutorial_night_arrival:007
You've made progress. You've established the link between the crescent icon and the moon. #aurora
// line_id:chat_tutorial_night_arrival:008
But that tells me nothing about what the moon means as a symbol in Day City. #player
// line_id:chat_tutorial_night_arrival:009
You can ask over the field radio—but only when the sun rises. #aurora
// line_id:chat_tutorial_night_arrival:010
Then let me bring back the sun. #player
-> END

=== chat_tutorial_day_return ===
# runtime_xml:tutorial_day_return.xml
// line_id:chat_tutorial_day_return:001
I'm back in the daylight. #player
// line_id:chat_tutorial_day_return:002
Welcome back. By the way, every page of your notebook has a sun and moon icon in the corner, and you can use it to switch between day and night too. #aurora
// line_id:chat_tutorial_day_return:003
Next, make a rubbing of the figure on the small marker. That will record the tombstone in your notebook. #aurora
-> END

=== chat_tutorial_recorded ===
# runtime_xml:tutorial_recorded.xml
// line_id:chat_tutorial_recorded:001
Nice job. Now you have two questions to work with: who is commemorated by this tombstone, and how did they die? #aurora
// line_id:chat_tutorial_recorded:002
I have no idea how to approach this. #player
// line_id:chat_tutorial_recorded:003
Don't worry. I've translated some manuscripts to help with your work. You'll find them under the Manuscripts tab. Translation takes time, so I'll send more from time to time, choosing the pieces most relevant to your progress. #aurora
// line_id:chat_tutorial_recorded:004
Thanks. I'll take some time to read them. Talk to you later. #player
-> END

=== chat_tutorial_keyword_noted ===
# runtime_xml:tutorial_keyword_noted.xml
// line_id:chat_tutorial_keyword_noted:001
I've kept that in mind. #player
-> END

=== chat_tutorial_searchlight_intro ===
# runtime_xml:tutorial_searchlight_intro.xml
// line_id:chat_tutorial_searchlight_intro:001
Apart from the rubbing tool, I was also given this searchlight. Let me check… #player
// line_id:chat_tutorial_searchlight_intro:002
“Rewind time to see the traces of the past.” Interesting. #player
// line_id:chat_tutorial_searchlight_intro:003
Let me point it at the small marker and see what was here fifty years ago. #player
-> END

=== chat_tutorial_searchlight_found ===
# runtime_xml:tutorial_searchlight_found.xml
// line_id:chat_tutorial_searchlight_found:001
A drawing… This child looks different from the figure on the marker. #player
// line_id:chat_tutorial_searchlight_found:002
I've recorded the sketch in Clues. I can find it there, and beside the marker's entry in the notebook. #player
-> END

=== chat_tutorial_radio_ready ===
# runtime_xml:tutorial_radio_ready.xml
// line_id:chat_tutorial_radio_ready:001
Perhaps I should call Aurora to cross-check my findings so far. #player
// line_id:chat_tutorial_radio_ready:002
Choose the marker, then a question. Send a relevant record with it, and we can work out what your observations mean. Some records let you ask questions you couldn't ask before. Others reveal more in an answer you've already heard. #aurora
-> END

=== chat_tutorial_report_intro ===
# runtime_xml:tutorial_report_intro.xml
// line_id:chat_tutorial_report_intro:001
You have enough to make a first report. Open Gravestones in your notebook and fill in the infant’s identity and cause of death. You can come back and revise either answer as you learn more. #aurora
-> END

=== chat_tutorial_hidden_question ===
# runtime_xml:tutorial_hidden_question.xml
// line_id:chat_tutorial_hidden_question:001
People don't know what they don't know. Only with certain materials can I ask deeper questions about this civilization—and the people who once lived here. #player
// line_id:chat_tutorial_hidden_question:002
Let the sketch change the question. Place it in the evidence slot before you choose what to ask. #aurora
-> END

=== chat_tutorial_investigation_complete ===
# runtime_xml:tutorial_investigation_complete.xml
// line_id:chat_tutorial_investigation_complete:001
I think I've figured out how the infant died. #player
// line_id:chat_tutorial_investigation_complete:002
Keep that answer in mind, and don't be afraid to change your provisional answers. That's what abductive reasoning is about: finding the best explanation for what you've observed. I've translated more documents that may help with your next investigation. Good luck. #aurora
-> END

=== chat_tutorial_camera_intro ===
# runtime_xml:tutorial_camera_intro.xml
// line_id:chat_tutorial_camera_intro:001
You finally take in the cemetery as a whole. Stones stand silently across the years, telling a collective story that no one remembers. #narrator
// line_id:chat_tutorial_camera_intro:002
They stand like soldiers, guarding a homeland that has long since fallen into ruin. #narrator
// line_id:chat_tutorial_camera_intro:003
A collective memory. The thought makes you reach for your last tool: a high-precision camera, built to capture every detail of a scene. #narrator
-> END

=== chat_tutorial_camera_connections ===
# runtime_xml:tutorial_camera_connections.xml
// line_id:chat_tutorial_camera_connections:001
In the photograph, repeated forms become easier to connect. Look at the continuous stone base shared by three monuments—including the infant's marker. #narrator
-> END

=== chat_tutorial_camera_outro ===
# runtime_xml:tutorial_camera_outro.xml
// line_id:chat_tutorial_camera_outro:001
The camera won't always point things out for you. Most of the time, you'll need to spot the repetitions yourself. Once you've marked them, the camera can compare their patterns. #narrator
// line_id:chat_tutorial_camera_outro:002
Now your investigation begins: a search for how these lives ended—or a journey into how they were lived. #narrator
-> END

=== chat_guide_prompts ===
# runtime_script:sun_moon_tutorial.gd
// line_id:chat_guide_prompts:002
1 / 4  Pick up the rubbing tool to record the crescent on the small marker. #narrator
// line_id:chat_guide_prompts:003
1 / 4  There seems to be a crescent shape on the base. Make a rubbing of it. #narrator
// line_id:chat_guide_prompts:004
2 / 4  Open your notebook (Tab or N). A sun icon is provided in Rise & Set. #narrator
// line_id:chat_guide_prompts:005
3 / 4  Choose the Rise & Set tab. #narrator
// line_id:chat_guide_prompts:006
4 / 4  Drag the moon from the black page onto the sun in the scene. The notebook folds away as you drag out. #narrator
// line_id:chat_guide_prompts:007
Aurora is on the line… #narrator
// line_id:chat_guide_prompts:008
Bring back daylight: open Rise & Set and drag the sun onto the moon. Day City questions are available in daylight. #narrator
// line_id:chat_guide_prompts:009
Make a rubbing of the small marker's person-shaped figure. Completing it will record the whole marker. #narrator
// line_id:chat_guide_prompts:010
Open Manuscripts and read A Marker for Someone Without an Occupation. #narrator
// line_id:chat_guide_prompts:011
Click the underlined infant in the designer's manuscript to take down a keyword. It will become a report option. #narrator
// line_id:chat_guide_prompts:012
Return to the manuscript list and read A Page of the Designer's Journal as well. Its account may give you another question. #narrator
// line_id:chat_guide_prompts:013
Take your time reading. When finished, return to the manuscript list or close the notebook. #narrator
// line_id:chat_guide_prompts:014
Contact Aurora and select the first question. Choose the best evidence that helps answer the question. #narrator
// line_id:chat_guide_prompts:015
Click the underlined natural death in Aurora's reply. You can also use Read last reply to collect a missed term. #narrator
// line_id:chat_guide_prompts:016
Now ask why the marker is shaped like a person. Submit the comparison you made with the Day City figure. #narrator
// line_id:chat_guide_prompts:017
Contact Aurora. Place A Sketch of the Infant in the slot before choosing a question: a hidden question about its artist will appear. #narrator
// line_id:chat_guide_prompts:018
You can follow up on some questions with a different piece of evidence. Select the first question again and submit A Sketch of the Infant. #narrator
// line_id:chat_guide_prompts:019
Collect the underlined unexplained circumstances from Aurora's reply. #narrator
// line_id:chat_guide_prompts:020
End the call. Open Gravestones and choose the small marker's identity and death from your collected keywords. #narrator
// line_id:chat_guide_prompts:021
Close the notebook (Tab / N). Next, use the searchlight to investigate the small marker's past. #narrator
// line_id:chat_guide_prompts:022
Pick up the searchlight. It can reveal traces that are no longer visible in the present. #narrator
// line_id:chat_guide_prompts:023
Click the figure or base of the small marker to lock the light there. The beam stays fixed while you adjust the year. #narrator
// line_id:chat_guide_prompts:024
Scroll the mouse wheel to 50 years ago (2000). Shift + scroll moves 10 years at a time. #narrator
// line_id:chat_guide_prompts:025
Keep the light on the small marker for a moment. If nothing appears, click its figure or base to re-aim. #narrator
-> END
