/obj/effect/proc_holder/spell/self/message
	name = "Message"
	desc = "Latch onto the mind of one who is familiar to you, whispering a message into their head."
	cost = 1
	releasedrain = 30
	recharge_time = 60 SECONDS
	warnie = "spellwarning"
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	overlay_state = "message"
	var/identify_difficulty = 15 //the stat threshold needed to pass the identify check

/obj/effect/proc_holder/spell/self/message/cast(list/targets, mob/user)
	var/input = browser_input_text(user, "Who are you trying to contact?", "NOC'S GIFT")
	if(!input)
		return FALSE
	if(!user.mind?.know_name(input))
		to_chat(user, span_warning("I don't know anyone by that name."))
		return FALSE
	for(var/datum/mind/mind as anything in SSticker.minds)
		var/mob/living/carbon/human/recipient = mind.current
		if(!LOWERSTRINGCOMP(recipient.real_name, input))
			continue
		var/message = browser_input_text(user, "You make a connection. What are you trying to say?", "NOC'S GIFT")
		if(!message)
			return FALSE
		if(browser_alert(user, "Hide your identity?", "NOC'S GIFT", DEFAULT_INPUT_CHOICES) == CHOICE_NO) //yes or no popup, if you say No run this code
			identify_difficulty = 0 //anyone can clear this

		var/identified = FALSE
		if(recipient.STAPER >= identify_difficulty) //quick stat check
			var/name = recipient.mind?.known_as(user.mind)
			if(name) //do we know who this person is?
				identified = TRUE // we do
				to_chat(recipient, "Arcyne whispers fill the back of my head, resolving into [name]'s voice: <font color=#7246ff>[message]</font>")
		if(!identified) //we failed the check OR we just dont know who that is
			to_chat(recipient, "Arcyne whispers fill the back of my head, resolving into an unknown [user.gender == FEMALE ? "woman" : "man"]'s voice: <font color=#7246ff>[message]</font>")
		user.log_message("[key_name(user)] sent a spell message to [key_name(recipient)]; message: [message]", LOG_GAME, color = "#0000ff")
		// maybe an option to return a message, here?
		return ..()
	to_chat(user, span_warning("I seek a mental connection... but find nothing, was [input] really their name?"))
	return FALSE
