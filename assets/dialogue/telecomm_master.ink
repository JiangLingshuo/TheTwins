->opening

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
->END

===daybaby_tele===
First tombstone, first encounter. 
->questions

=questions
What would you like to check? 
// Evidence slot: Some questions require evidence.
// Certain pieces of evidence may unlock additional questions. 
+ [The decoration looks like a moon. What does it mean?]
    When the night falls, dayfolks slip into slumber. Sleep is a state of serenity that is so similar to death; hence, moon represents  <link="natural">natural death</link> for the night folks.#aurora
    -> questions

+ [Why is the tombstone shaped like a person?]
    What does the designer's manuscript say?#aurora
    -> questions

+ [That's all for now.]
    Talk to you later.#aurora
    -> END
