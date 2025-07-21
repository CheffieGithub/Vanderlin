/////////////////////////////////////////Scrying///////////////////

/obj/item/scrying
	name = "scrying orb"
	desc = "On its glass depths, you can scry on many unsuspecting beings.."
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state ="scrying"
	throw_speed = 3
	throw_range = 7
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/blank.ogg'
	sellprice = 30
	dropshrink = 0.6

	grid_height = 32
	grid_width = 32

	var/last_scry
	var/cooldown = 30 SECONDS

/obj/item/scrying/eye
	name = "accursed eye"
	desc = "It is pulsating."
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state ="scryeye"
	cooldown = 5 MINUTES

/obj/item/scrying/attack_self(mob/user, params)
	. = ..()
	if(world.time < last_scry + cooldown)
		to_chat(user, span_warning("I look into the ball but only see inky smoke. Maybe I should wait."))
		return
	var/input = stripped_input(user, "Who are you looking for?", "Scrying Orb")
	if(!input)
		return
	if(!user.mind?.know_name(input))
		to_chat(user, span_warning("I don't know anyone by that name."))
		return
	for(var/datum/mind/mind as anything in SSticker.minds)
		var/mob/living/carbon/human/to_scry = mind.current
		if(QDELETED(to_scry))
			continue
		if(!LOWERSTRINGCOMP(to_scry.real_name, input))
			continue
		if(HAS_TRAIT(to_scry, TRAIT_ANTISCRYING))
			to_chat(user, span_warning("I peer into the ball, but an impenetrable fog shrouds [input]."))
			to_chat(to_scry, span_warning("My magical shrouding reacted to something."))
			return
		message_admins("SCRYING: [user.real_name] ([user.ckey]) has used the scrying orb to leer at [to_scry.real_name] ([to_scry.ckey])")
		log_game("SCRYING: [user.real_name] ([user.ckey]) has used the scrying orb to leer at [to_scry.real_name] ([to_scry.ckey])")
		var/mob/dead/observer/screye/S = user.scry_ghost()
		if(!S)
			return
		S.ManualFollow(to_scry)
		last_scry = world.time
		user.visible_message(span_danger("[user] stares into [src], [user.p_their()] eyes rolling back into [user.p_their()] head."))
		addtimer(CALLBACK(S, TYPE_PROC_REF(/mob/dead/observer, reenter_corpse)), 8 SECONDS)
		if(to_scry.stat || is_blind(to_scry))
			return
		if(to_scry.STAPER >= 15)
			var/name = to_scry.mind?.known_as(user)
			if(name)
				to_chat(to_scry, span_warning("I can clearly see the face of [name] staring at me!."))
				return
			to_chat(to_scry, span_warning("I can clearly see the face of an unknown [user.gender == FEMALE ? "woman" : "man"] staring at me!"))
			return
		if(to_scry.STAPER >= 11)
			to_chat(to_scry, span_warning("I feel a pair of unknown eyes on me."))
		return
	to_chat(user, span_warning("I peer into the ball, but can't find [input]."))

/////////////////////////////////////////Crystal ball ghsot vision///////////////////

/obj/item/crystalball/attack_self(mob/user, params)
	user.visible_message(span_danger("[user] stares into [src], their eyes rolling back into their head."))
	user.ghostize(1)

/*	..................   NOC Device (Fixed scrying ball)   ................... */
/obj/structure/nocdevice
	name = "NOC Device"
	desc = "A intricate lunar observation machine, that allows its user to study the face of Noc in the sky, reflecting he true whereabouts of hidden beings.."
	icon = 'icons/roguetown/misc/96x96.dmi'
	icon_state = "nocdevice"
	plane = -1
	layer = 4.2
	var/last_scry

/obj/structure/nocdevice/attack_hand(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	if(!H.virginity)
		to_chat(user, span_notice("Noc looks angry with me..."))
	if(world.time < last_scry + 30 SECONDS)
		to_chat(user, span_warning("I peer into the sky but cannot focus the lens on the face of Noc. Maybe I should wait."))
		return
	var/input = stripped_input(user, "Who are you looking for?", "Scrying Orb")
	if(!input)
		return
	if(!user.mind?.know_name(input))
		to_chat(user, span_warning("I don't know anyone by that name."))
		return
	for(var/datum/mind/mind as anything in SSticker.minds)
		var/mob/living/carbon/human/to_scry = mind.current
		if(QDELETED(to_scry))
			continue
		if(!LOWERSTRINGCOMP(to_scry.real_name, input))
			continue
		if(HAS_TRAIT(to_scry, TRAIT_ANTISCRYING))
			to_chat(user, span_warning("I peer into the lens, but an impenetrable fog shrouds [input]."))
			to_chat(to_scry, span_warning("My magical shrouding reacted to something."))
			return
		message_admins("SCRYING: [user.real_name] ([user.ckey]) has used the noc device orb to leer at [to_scry.real_name] ([to_scry.ckey])")
		log_game("SCRYING: [user.real_name] ([user.ckey]) has used the noc device to leer at [to_scry.real_name] ([to_scry.ckey])")
		var/mob/dead/observer/screye/S = user.scry_ghost()
		if(!S)
			return
		S.ManualFollow(to_scry)
		last_scry = world.time
		user.visible_message(span_danger("[user] stares into [src], squinting and concentrating..."))
		addtimer(CALLBACK(S, TYPE_PROC_REF(/mob/dead/observer, reenter_corpse)), 8 SECONDS)
		if(to_scry.stat || is_blind(to_scry))
			return
		if(to_scry.STAPER >= 15)
			var/name = to_scry.mind?.known_as(user)
			if(name)
				to_chat(to_scry, span_warning("I can clearly see the face of [name] staring at me!."))
				return
			to_chat(to_scry, span_warning("I can clearly see the face of an unknown [user.gender == FEMALE ? "woman" : "man"] staring at me!"))
			return
		if(to_scry.STAPER >= 11)
			to_chat(to_scry, span_warning("I feel a pair of unknown eyes on me."))
		return
	to_chat(user, span_warning("I peer into the viewpiece, but Noc does not reveal where [input] is."))
