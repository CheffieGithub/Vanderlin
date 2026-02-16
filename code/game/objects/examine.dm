/datum/examine_effect/proc/trigger(mob/user)
	return

/datum/examine_effect/proc/get_examine_line(mob/user)
	return

/obj/item/examine(mob/user) //This might be spammy. Remove?
	. = ..()
	var/price_text = get_displayed_price(user)
	if(uses_integrity)
		if(atom_integrity < max_integrity)
			var/meme = round(((atom_integrity / max_integrity) * 100), 1)
			switch(meme)
				if(0 to 1)
					. += "<span class='warning'>It's broken.</span>"
				if(1 to 10)
					. += "<span class='warning'>It's nearly broken.</span>"
				if(10 to 30)
					. += "<span class='warning'>It's severely damaged.</span>"
				if(30 to 80)
					. += "<span class='warning'>It's damaged.</span>"
				if(80 to 99)
					. += "<span class='warning'>It's a little damaged.</span>"

	if(price_text)
		. += price_text

	// Only show if it's actually useable as bait, so that it doesn't show up on every single item of the game.
	if(isbait)
		var/baitquality = ""
		switch(baitpenalty)
			if(0)
				baitquality = "excellent"
			if(5)
				baitquality = "good"
			if(10)
				baitquality = "passable"
		. += "<span class='info'>It is \a [baitquality] bait for fish.</span>"

	for(var/datum/examine_effect/E in examine_effects)
		E.trigger(user)

	if(item_weight || get_stored_weight())
		. += "It weighs around [round(item_weight + get_stored_weight(), 0.1)]KG."

/**
 * Creates a tooltip for chat that gives combat information about this item.
 */
/obj/item/proc/get_chat_tooltip(mob/viewer, show_crits)
	return get_examine_string(viewer)

/obj/item/clothing/get_chat_tooltip(mob/viewer, show_crits)
	var/examine_text = ..()

	if(!armor)
		return examine_text

	var/list/strings = list("PROECTION VALUES:")
	for(var/string in ARMOR_LIST_DAMAGE())
		var/rating = armor.getRating(string)
		if(rating > 0)
			continue
		strings += "[armor_to_protection_name(string)]: [armor_to_protection_class(rating)]"

	if(length(strings) == 1)
		return examine_text

	if(show_crits && !prevent_crits)
		strings += "CRIT SUSCEPTIBLE!"

	//This makes it appear darker than the rest of examine text.
	examine_text = "<font color='#808080'>[examine_text]</font>"
	return span_tooltip(strings.Join("\n"), examine_text)
