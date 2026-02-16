/**
 * Called when a mob examines this atom: [/mob/verb/examinate]
 *
 * Default behaviour is to get the name and icon of the object and its reagents where
 * the [TRANSPARENT] flag is set on the reagents holder
 *
 * Produces a signal [COMSIG_ATOM_EXAMINE], for modifying the list returned from this proc
 */
/atom/proc/examine(mob/user)
	var/examine_string = get_examine_string(user, thats = TRUE)
	if(examine_string)
		. = list("[examine_string].[get_inspect_button()]")
	else
		. = list()

	if(desc)
		. += "<span class='info'>[desc]</span>"

	if(reagents)
		if(reagents.flags & TRANSPARENT)
			if(length(reagents.reagent_list))
				if(user.can_see_reagents()) //Show each individual reagent
					. += "It contains:"
					for(var/datum/reagent/R in reagents.reagent_list)
						. += "[(UNIT_FORM_STRING(R.volume))] of <font color=[R.color]>[R.name]</font>"
				else //Otherwise, just show the total volume
					var/total_volume = 0
					var/reagent_color
					for(var/datum/reagent/R in reagents.reagent_list)
						total_volume += R.volume
					reagent_color = mix_color_from_reagents(reagents.reagent_list)
					. += "It contains [(UNIT_FORM_STRING(total_volume))] of <font color=[reagent_color]>something.</font>"
			else
				. += "It's empty."
		else if(reagents.flags & AMOUNT_VISIBLE)
			if(reagents.total_volume)
				. += "<span class='notice'>It has [(UNIT_FORM_STRING(round(reagents.total_volume, 0.1)))] left.</span>"
			else
				. += "<span class='danger'>It's empty.</span>"
		//SNIFFING
		if (user.zone_selected == BODY_ZONE_PRECISE_NOSE && get_dist(src, user) <= 1)
			// if atom's path is item/reagent_containers/glass/carafe
			var/is_not_closed = FALSE
			if(istype(src, /obj/item/reagent_containers/glass/bottle))
				var/obj/item/reagent_containers/glass/bottle/A = src
				is_not_closed = !A.closed
			else if(istype(src, /obj/item/reagent_containers/glass/alchemical))
				var/obj/item/reagent_containers/glass/alchemical/A = src
				is_not_closed = !A.closed
			if(is_not_closed && reagents.total_volume) // if the container is open, and there's liquids in there
				user.visible_message(span_info("[user] takes a whiff of [src]."))
				. += span_notice("I smell [src.reagents.generate_scent_message()].")
				if(HAS_TRAIT(user, TRAIT_LEGENDARY_ALCHEMIST))
					var/list/full_reagents = list()
					for(var/datum/reagent/R in reagents.reagent_list)
						if(R.volume > 0)
							full_reagents += "[lowertext(R.name)]"
					if(length(full_reagents))
						. += span_notice("I can identity this smell as [full_reagents.Join(", ")].")

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)

/**
 * Get the name of this object for examine
 *
 * You can override what is returned from this proc by registering to listen for the
 * COMSIG_ATOM_GET_EXAMINE_NAME signal
 */
/atom/proc/get_examine_name(mob/user)
	. = "\a <b>[src]</b>"
	var/list/override = list(gender == PLURAL ? "some" : "a", " ", "[name]")
	if(article)
		. = "[article] <b>[src]</b>"
		override[EXAMINE_POSITION_ARTICLE] = article
	if(SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, override) & COMPONENT_EXNAME_CHANGED)
		. = override.Join("")

///Generate the full examine string of this atom (including icon for goonchat)
/atom/proc/get_examine_string(mob/user, thats = FALSE)
	return "[thats? "That's ":""][get_examine_name(user)]"

/atom/proc/get_inspect_button()
	return ""

/atom/proc/get_inspect_entries()
	return list()
